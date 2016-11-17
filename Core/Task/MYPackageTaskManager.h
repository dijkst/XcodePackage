//
//  MYPackageTaskManager.h
//  Package
//
//  Created by Whirlwind on 15/10/22.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYPackageBaseTask.h"
#import "MYPackageConfig.h"

#define MYPackageTaskManagerWillRunTaskNotification @"MYPackageTaskManagerWillRunTaskNotification"
#define MYPackageTaskManagerFinishRunTaskNotification @"MYPackageTaskManagerFinishRunTaskNotification"

@interface MYPackageTaskManager : NSObject

@property (nonatomic, readonly) MYPackageBaseTask *currentTask;
@property (nonatomic, strong) MYPackageConfig     *config;
@property (nonatomic, strong) NSString            *lastErrorMessage;

- (BOOL)runTasks:(NSArray *)tasks;
- (BOOL)runTaskClassNamesInOrder:(NSArray *)tasks;
- (BOOL)runTaskClassNames:(NSArray *)tasks;

+ (void)registHookTaskName:(NSString *)hookTaskName beforeTaskName:(NSString *)taskName;
+ (void)registHookTaskName:(NSString *)hookTaskName afterTaskName:(NSString *)taskName;

@end
