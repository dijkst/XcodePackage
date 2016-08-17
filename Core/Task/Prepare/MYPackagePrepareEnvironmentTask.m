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

- (BOOL)setupRubyEnvironment {
    // 检查是否需要升级 Gem 版本
    if ([self executeCommand:@"gem --version"] != 0) {
        self.errorMessage = @"获取 Gem 版本失败！";
        return NO;
    }
    BOOL updateGem = [self.shellTask.outputString compare:@"2.6.0" options:NSNumericSearch] == NSOrderedAscending;

    BOOL updateBundler = NO;
    if ([self executeCommand:@"command which bundle && gem query -i -n \\^bundler\\$"] != 0) {
        // 需要安装 bundler
        updateBundler = YES;
    } else {
        // 检查是否需要升级 bundler 版本
        if ([self executeCommand:@"bundle --version"] != 0) {
            self.errorMessage = @"bundle 环境异常！";
            return NO;
        }
        NSString *version = [[self.shellTask.outputString componentsSeparatedByString:@" "] lastObject];
        if ([version compare:@"1.12.1" options:NSNumericSearch] == NSOrderedAscending) {
            updateBundler = YES;
        }
    }

    if (updateGem || updateBundler) {
        if ([self executeCommand:@"command which ruby"] != 0) {
            self.errorMessage = @"获取 Ruby 路径失败！";
            return NO;
        }
        BOOL system = ![self.shellTask.outputString hasPrefix:[@"~" stringByExpandingTildeInPath]];

        if ([self executeCommand:[self command:[NSString stringWithFormat:@"./setup_ruby_env.sh -gem %@ -bundler %@", updateGem ? @"true" : @"true", updateBundler ? @"true" : @"false"] withAdministrator:system]] != 0) {
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
