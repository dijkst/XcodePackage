//
//  MYPackageListProfilesTask.m
//  Package
//
//  Created by Whirlwind on 2017/2/8.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageListProfilesTask.h"

@implementation MYPackageListProfilesTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    if ([self executeRubyScript:@"list_provisioning_profiles", nil] != 0) {
        self.errorMessage = @"获取描述文件列表失败！";
        return NO;
    }
    return YES;
}

@end
