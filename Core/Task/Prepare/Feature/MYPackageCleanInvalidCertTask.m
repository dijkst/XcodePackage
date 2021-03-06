//
//  MYPackageCleanInvalidCertTask.m
//  Package
//
//  Created by Whirlwind on 2017/5/17.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageCleanInvalidCertTask.h"

@implementation MYPackageCleanInvalidCertTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    if ([self executeRubyScript:@"clean_invalid_cert", nil] != 0) {
        self.errorMessage = self.shellTask.errorString;
        return NO;
    }
    return YES;
}

@end
