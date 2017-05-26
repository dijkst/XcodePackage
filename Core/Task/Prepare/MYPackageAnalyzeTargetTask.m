//
//  MYPackageAnalyzeTargetTask.m
//  Package
//
//  Created by Whirlwind on 16/3/15.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageAnalyzeTargetTask.h"

@implementation MYPackageAnalyzeTargetTask

- (NSString *)name {
    return @"分析 Target 信息";
}

// 替换环境变量
- (NSString *)parseTemplate:(NSString *)template target:(MYPackageTarget *)target {
    NSRegularExpression *regular;
    regular = [NSRegularExpression regularExpressionWithPattern:@"\\$\\((.+)\\)"
                                                        options:NSRegularExpressionCaseInsensitive
                                                          error:nil];
    NSRange range = [regular rangeOfFirstMatchInString:template
                                               options:0
                                                 range:NSMakeRange(0, template.length)];
    if (range.location != NSNotFound) {
        NSString *name = [regular stringByReplacingMatchesInString:[template substringWithRange:range]
                                                           options:0
                                                             range:NSMakeRange(0, template.length)
                                                      withTemplate:@"$1"];
        NSString *value = [target.configurations objectForKey:name];
        if (value) {
            return [template stringByReplacingCharactersInRange:range withString:value];
        }
    }
    return template;
}

// 分析版本号 和 显示名称(App用)
- (BOOL)analyzeShortVersionNumber {
    if (self.config.version) {
        return YES;
    }
    MYPackageTarget *target   = self.config.selectedScheme.targets[0];
    NSString        *infoPath = target.originInfoPlistPath;
    if (!infoPath) {
        [self.config.logger logN:@"<INFO> Target %@ 没有 InfoPlist 文件，无法分析版本号！跳过执行！", target.name];
        return YES;
    }
    if (![infoPath hasPrefix:@"/"]) {
        infoPath = [[target.project.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:infoPath];
    }
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    if (!info) {
        self.errorMessage = [NSString stringWithFormat:@"读取 Info.plist 失败: %@", infoPath];
        return NO;
    }
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *displayName = [info objectForKey:@"CFBundleDisplayName"] ?: [info objectForKey:@"CFBundleName"];

    if (version) {
        version = [self parseTemplate:version target:target];
    }
    if (displayName) {
        displayName = [self parseTemplate:displayName target:target];
    }
    self.config.version = version;
    self.config.displayName = displayName;
    return YES;
}

- (BOOL)analyzeTargetConfigruationForName:(NSString *)targetName inProject:(MYPackageProject *)project {
    if ([project targetForName:targetName]) {
        return YES;
    }
    if ([self executeCommand:[NSString stringWithFormat:@"xcodebuild -project '%@' -target '%@' -showBuildSettings -xcconfig '%@'",
                              project.filePath,
                              targetName,
                              self.config.xcconfig
                              ]] != 0) {
        self.errorMessage = [NSString stringWithFormat:@"分析 %@ target 出错，详见日志！", targetName];
        return NO;
    }
    NSError             *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"^Build settings for action .*? and target .*?:\n"
                                                                             options:NSRegularExpressionUseUnixLineSeparators
                                                                               error:&error];
    NSTextCheckingResult *result = [regular firstMatchInString:self.shellTask.outputString options:0 range:NSMakeRange(0, self.shellTask.outputString.length)];
    if (result.range.location == NSNotFound) {
        self.errorMessage = [NSString stringWithFormat:@"分析 %@ target 配置出错！", targetName];
        return NO;
    }
    NSMutableDictionary *dic    = [NSMutableDictionary dictionary];
    NSString            *config = [[self.shellTask.outputString substringFromIndex:NSMaxRange(result.range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *line in [config componentsSeparatedByString:@"\n"]) {
        NSString *str  = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSRange  range = [str rangeOfString:@" = "];
        if (range.location == NSNotFound) {
            continue;
        }
        NSString *key   = [str substringToIndex:range.location];
        NSString *value = [str substringFromIndex:NSMaxRange(range)];
        [dic setObject:value forKey:key];
    }
    MYPackageTarget *target = [[MYPackageTarget alloc] initWithName:targetName];
    target.configurations = dic;
    target.project        = project;
    [project.targets setObject:target forKey:targetName];
    return YES;
}

- (BOOL)analyzeTargetConfiguration {
    __block BOOL success = YES;
    [self.config.selectedScheme.targetNames enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull name, NSString *_Nonnull path, BOOL *_Nonnull stop) {
        MYPackageProject *project = [self.config.workspace.projects objectForKey:path];
        if (![self analyzeTargetConfigruationForName:name inProject:project]) {
            success = NO;
            return;
        }
        NSString *demoTarget = [name stringByAppendingString:@"Demo"];
        if ([project.targetNames indexOfObject:demoTarget] != NSNotFound) {
            [self analyzeTargetConfigruationForName:demoTarget inProject:project];
        }
    }];
    return success;
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    return [self analyzeTargetConfiguration] && [self analyzeShortVersionNumber];
}

@end
