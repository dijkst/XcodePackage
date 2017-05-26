//
//  MYPackageCalculateSHA1Task.m
//  Package
//
//  Created by Whirlwind on 2016/12/12.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageCalculateSHA1Task.h"

@implementation MYPackageCalculateSHA1Task

- (NSString *)name {
    return @"计算 SHA1";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    if ([self executeCommand:[NSString stringWithFormat:@"openssl sha1 \"%@\"", self.config.bundlePath]] != 0) {
        self.errorMessage = self.shellTask.errorString;
        return NO;
    }
    self.config.bundleHash = [[self.output componentsSeparatedByString:@" "] lastObject];
    return YES;
}

@end
