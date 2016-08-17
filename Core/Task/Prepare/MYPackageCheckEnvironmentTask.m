//
//  MYPackageCheckEnvironmentTask.m
//  Package
//
//  Created by Whirlwind on 16/4/18.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageCheckEnvironmentTask.h"

@implementation MYPackageCheckEnvironmentTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:shellEnv[@"BUNDLE_GEMFILE"]]) {
        self.errorMessage = [NSString stringWithFormat:@"Ruby Gems 目录不存在，请联系管理员！%@", shellEnv[@"BUNDLE_GEMFILE"]];
        return NO;
    }
    if ([self executeCommand:@"bundle check"] != 0) {
        self.errorMessage = @"Gem 环境不正常，请联系管理员！";
        return NO;
    }
    return YES;
}

@end
