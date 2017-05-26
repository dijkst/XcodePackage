//
//  MYPackageListProfilesTask.m
//  Package
//
//  Created by Whirlwind on 2017/5/12.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageListProfilesTask.h"

@implementation MYPackageListProfilesTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    if ([self executeRubyScript:@"list_provisioning_profiles", nil] != 0) {
        self.errorMessage = self.output;
        return NO;
    }
    return YES;
}

@end
