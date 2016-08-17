//
//  MYPackageGetHighestVersionTask.m
//  Package
//
//  Created by Whirlwind on 15/11/2.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageGetHighestVersionTask.h"

@implementation MYPackageGetHighestVersionTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    if ([self executeRubyScript:@"find_highest_version_in_repo", self.podName, nil] != 0) {
        [self.config.logger logN:@"Find highest version fail! %@", self.errorMessage];
        return NO;
    }
    return YES;
}

@end
