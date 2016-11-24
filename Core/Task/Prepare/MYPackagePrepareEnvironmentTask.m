//
//  MYPackagePrepareEnvironmentTask.m
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackagePrepareEnvironmentTask.h"

@implementation MYPackagePrepareEnvironmentTask

- (NSString *)name {
    return @"初始化环境，首次执行需要比较长时间";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    return [self setupRubyEnvironment] && [self setupGemEnvironment];
}

- (NSComparisonResult)compareVersion:(NSString *)versionString1 withVersion2:(NSString *)versionString2 {
    NSArray *version1 = [versionString1 componentsSeparatedByString:@"."];
    NSArray *version2 = [versionString2 componentsSeparatedByString:@"."];
    for(int i = 0 ; i < version1.count || i < version2.count; i++){
        NSInteger value1 = 0;
        NSInteger value2 = 0;
        if(i < version1.count){
            value1 = [version1[i] integerValue];
        }
        if(i < version2.count){
            value2 = [version2[i] integerValue];
        }
        if(value1  == value2){
            continue;
        }else{
            if(value1 > value2){
                return NSOrderedDescending;
            }else{
                return NSOrderedAscending;
            }
        }
    }
    return NSOrderedSame;
}

- (NSString *)getInstallerVersion:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RubyEnv" ofType:nil];
    NSArray *list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@-(.*)\\..+", name] options:NSRegularExpressionCaseInsensitive error:nil];

    for (NSString *filename in list) {
        NSTextCheckingResult *result = [regex firstMatchInString:filename options:NSMatchingReportCompletion range:NSMakeRange(0, filename.length)];
        if (result && result.range.location != NSNotFound) {
            return [regex stringByReplacingMatchesInString:filename
                                                   options:NSMatchingReportCompletion
                                                     range:NSMakeRange(0, filename.length)
                                              withTemplate:@"$1"];
        }
    }
    return nil;
}

- (BOOL)setupRubyEnvironment {
    // 检查是否需要升级 Gem 版本
    if ([self executeCommand:@"gem --version"] != 0) {
        self.errorMessage = @"获取 Gem 版本失败！";
        return NO;
    }

    // 获取内置 rubygems 安装包版本号
    NSString *embedGemVersion = [self getInstallerVersion:@"rubygems"];
    if (!embedGemVersion) {
        self.errorMessage = @"内置 RubyGems 安装包丢失!";
        return NO;
    }

    NSString *version = [self.shellTask.outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    version = [[version componentsSeparatedByString:@"\n"] lastObject];
    if ([self compareVersion:version withVersion2:embedGemVersion] != NSOrderedAscending) {
        embedGemVersion = nil;
    }

    // 获取内置 bundler 安装包版本号
    NSString *embedBundlerVersion = [self getInstallerVersion:@"bundler"];
    if (!embedBundlerVersion) {
        self.errorMessage = @"内置 bundler 安装包丢失!";
        return NO;
    }

    if ([self executeCommand:@"command which bundle && gem query -i -n \\^bundler\\$"] != 0) {
        // 需要安装 bundler
    } else {
        // 检查是否需要升级 bundler 版本
        if ([self executeCommand:@"bundle --version"] != 0) {
            self.errorMessage = @"bundle 环境异常！";
            return NO;
        }

        version = [self.shellTask.outputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        version = [[version componentsSeparatedByString:@"\n"] lastObject];
        version = [[self.shellTask.outputString componentsSeparatedByString:@" "] lastObject];
        if ([self compareVersion:version withVersion2:embedBundlerVersion] != NSOrderedAscending) {
            embedBundlerVersion = nil;
        }
    }

    if (embedGemVersion || embedBundlerVersion) {
        if ([self executeCommand:@"command which ruby"] != 0) {
            self.errorMessage = @"获取 Ruby 路径失败！";
            return NO;
        }
        BOOL system = [self.shellTask.outputString rangeOfString:[@"~" stringByExpandingTildeInPath]].location == NSNotFound;

        if ([self executeCommand:[self command:[NSString stringWithFormat:@"./setup_ruby_env.sh -gem \"%@\" -bundler \"%@\"", embedGemVersion ?: @"", embedBundlerVersion ?: @""] withAdministrator:system]] != 0) {
            self.errorMessage = [NSString stringWithFormat:@"更新 Ruby 环境失败！%@", self.shellTask.errorString];
            return NO;
        }
    }
    return YES;
}

- (BOOL)setupGemEnvironment {
    if ([self executeCommand:@"./setup_gem_env.sh"] != 0) {
        self.errorMessage = [NSString stringWithFormat:@"安装 Gem 环境失败！%@", self.shellTask.errorString];
        return NO;
    }
    return YES;
}

@end
