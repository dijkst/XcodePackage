//
//  MYPackageAnalyzeProjectTask.m
//  Package
//
//  Created by Whirlwind on 15/5/7.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageAnalyzeProjectTask.h"

@implementation MYPackageAnalyzeProjectTask

- (NSString *)name {
    return [NSString stringWithFormat:@"分析项目 %@ ", [self.config.workspace.filePath lastPathComponent]];
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSArray *projectPaths = [[self.config.selectedScheme.targetNames allValues] valueForKeyPath:@"@distinctUnionOfObjects.self"];
    for (NSString *projectPath in projectPaths) {
        if (![self analyzeProjectPath:projectPath]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)analyzeProjectPath:(NSString *)projectPath {
    if ([self executeCommand:[NSString stringWithFormat:@"xcodebuild -project '%@' -list", projectPath]] != 0) {
        self.errorMessage = @"XCode 分析项目出错，详见日志";
        return NO;
    }

    MYPackageProject *project = [[MYPackageProject alloc] init];
    [project setFilePath:projectPath];
    [self.config.workspace.projects setObject:project forKey:projectPath];

    NSRegularExpression *regular;

    // 分析项目名称
    regular = [NSRegularExpression regularExpressionWithPattern:@"Information about project \"(.+)\":\n"
                                                        options:NSRegularExpressionCaseInsensitive
                                                          error:nil];
    NSRange range = [regular rangeOfFirstMatchInString:self.shellTask.outputString
                                               options:0
                                                 range:NSMakeRange(0, self.shellTask.outputString.length)];
    if (range.location == NSNotFound || range.length == 0) {
        self.errorMessage = @"分析项目名称出错！";
        return NO;
    }
    NSString *name = [regular stringByReplacingMatchesInString:[self.shellTask.outputString substringWithRange:range]
                                                       options:0
                                                         range:NSMakeRange(0, range.length)
                                                  withTemplate:@"$1"];
    [project setName:name];

    // 分析 Target 列表
    NSArray *targets = [self parseString:self.shellTask.outputString forKeyword:@"Targets"];
    if (!targets) {
        return NO;
    }
    [project setTargetNames:targets];

    // 分析 Configuration 列表
    NSArray *configrations = [self parseString:self.shellTask.outputString forKeyword:@"Build Configurations"];
    if (!configrations) {
        return NO;
    }
    [project setConfigrations:configrations];

    return YES;
}

- (NSArray *)parseString:(NSString *)string forKeyword:(NSString *)keyword {
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^ *%@:\n", keyword]
                                                                             options:NSRegularExpressionAnchorsMatchLines
                                                                               error:nil];
    NSRange range = [regular rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (range.location == NSNotFound) {
        self.errorMessage = [NSString stringWithFormat:@"分析项目 %@ 出错！", keyword];
        return nil;
    }
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    for (NSString *line in [[self.shellTask.outputString substringFromIndex:NSMaxRange(range)] componentsSeparatedByString:@"\n"]) {
        NSString *string = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([string length] == 0) {
            break;
        }
        [array addObject:string];
    }
    if ([array count] == 0) {
        self.errorMessage = [NSString stringWithFormat:@"项目 %@ 是空的！", keyword];
        return nil;
    }
    return array;
}

@end
