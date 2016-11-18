//
//  MYPackageBaseTask.m
//  Package
//
//  Created by Whirlwind on 15/5/4.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageBaseTask.h"

@implementation MYPackageBaseTask

- (void)cancel {
    [self.config.logger logN:@"User Cancel!"];
}

- (BOOL)launch {
    _errorMessage = nil;
    return YES;
}

- (void)setErrorMessage:(NSString *)errorMessage {
    _errorMessage = errorMessage;
    [self.config.logger logN:@"❌ %@", errorMessage];
}

+ (BOOL)shouldLaunchInTaskList:(NSArray<NSString *> *)taskList {
    return YES;
}

@end
