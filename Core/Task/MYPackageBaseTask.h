//
//  MYPackageBaseTask.h
//  Package
//
//  Created by Whirlwind on 15/5/4.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYPackageConfig.h"

@class MYPackageTaskManager;
@interface MYPackageBaseTask : NSObject

@property (nonatomic, strong) MYPackageConfig *config;

@property (nonatomic, weak) MYPackageTaskManager *taskManager;

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSString *output;
@property (nonatomic, readonly) BOOL   isCancelled;
@property (nonatomic, strong) NSString *name;

- (void)cancel;
- (BOOL)launch;

- (void)logInfo:(NSString *)message;

+ (BOOL)shouldLaunchWithPreTaskStatus:(BOOL)status manager:(MYPackageTaskManager *)manager;

@end
