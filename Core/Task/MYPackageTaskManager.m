//
//  MYPackageTaskManager.m
//  Package
//
//  Created by Whirlwind on 15/10/22.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageTaskManager.h"

static NSArray *taskClassOrder;

@implementation MYPackageTaskManager

+ (void)load {
    taskClassOrder = @[
                       // Prepare
                       @"MYPackageInitTask",
                       @"MYPackagePrepareEnvironmentTask",
                       @"MYPackageCheckEnvironmentTask",
                       @"MYPackageCheckGitTask",
                       @"MYPackageAnalyzeGitTask",
                       @"MYPackageListSchemeTask",
                       @"MYPackageAnalyzeSchemeTask",
                       @"MYPackageAnalyzeProjectTask",
                       @"MYPackageAnalyzeTargetTask",

                       // Build
                       @"MYPackageCleanTask",
                       @"MYPackageBuildTask",
                       @"MYPackageLipoTask",

                       // Package
                       @"MYPackageAnalyzeProductTask",
                       @"MYPackageUpdateVersionNumberTask",
                       @"MYPackageZipTask",
                       @"MYPackageCreateSpecTask",

                       // release
                       @"MYPackageUploadLocalTask",
                       @"MYPackageCreateTagTask",

                       // Clean
                       @"MYPackageCleanIntermediateProductTask",
                       @"MYPackageCleanFinalProductTask",

                       // Statistics
                       @"MYPackageUploadStatisticsTask"
                       ];
}

+ (NSMutableDictionary *)beforeHooks {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *__beforeHooks;
    dispatch_once(&onceToken, ^{
        __beforeHooks = [NSMutableDictionary dictionary];
    });
    return __beforeHooks;
}

+ (NSMutableDictionary *)afterHooks {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *__afterHooks;
    dispatch_once(&onceToken, ^{
        __afterHooks = [NSMutableDictionary dictionary];
    });
    return __afterHooks;
}

+ (void)registHookTaskName:(NSString *)hookTaskName taskName:(NSString *)taskName hooks:(NSMutableDictionary *)allHooks {
    @synchronized (self) {
        NSMutableArray *hooks = [allHooks objectForKey:taskName];
        if (!hooks) {
            hooks = [NSMutableArray array];
            [allHooks setObject:hooks forKey:taskName];
        }
        [hooks addObject:hookTaskName];
    }
}

+ (void)registHookTaskName:(NSString *)hookTaskName beforeTaskName:(NSString *)taskName {
    [self registHookTaskName:hookTaskName taskName:taskName hooks:[self beforeHooks]];
}

+ (void)registHookTaskName:(NSString *)hookTaskName afterTaskName:(NSString *)taskName {
    [self registHookTaskName:hookTaskName taskName:taskName hooks:[self afterHooks]];
}

- (BOOL)runTasks:(NSArray *)tasks {
    if (!tasks) {
        return [self runTaskClassNames:taskClassOrder];
    }
    NSMutableArray *taskClassNames = [NSMutableArray arrayWithCapacity:[tasks count]];
    for (NSString *taskName in tasks) {
        NSString *taskClassName = [taskName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[taskName substringToIndex:1] uppercaseString]];
        taskClassName = [NSString stringWithFormat:@"MYPackage%@Task", taskClassName];
        if (NSClassFromString(taskClassName)) {
            [taskClassNames addObject:taskClassName];
        } else {
            [self.config.logger logN:@"任务 %@ 不存在，将被忽略！", taskName];
        }
    }
    return [self runTaskClassNamesInOrder:taskClassNames];
}

- (BOOL)runTaskClassNamesInOrder:(NSArray *)tasks {
    NSMutableArray *orderedTasks = [NSMutableArray arrayWithCapacity:tasks.count];
    for (NSString *taskName in taskClassOrder) {
        if ([tasks indexOfObject:taskName] != NSNotFound) {
            [orderedTasks addObject:taskName];
        }
    }
    return [self runTaskClassNames:orderedTasks];
}

- (BOOL)runTaskClassNames:(NSArray *)tasks {
    for (NSString *taskName in tasks) {
        if (![self runTaskClassName:taskName inTaskList:tasks]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)runTaskClassName:(NSString *)taskName inTaskList:(NSArray *)taskList {
    Class taskClass = NSClassFromString(taskName);
    if (taskClass) {
        if (![taskClass shouldLaunchInTaskList:taskList]) {
            return YES;
        }

        for (NSString *hookName in [[[self class] beforeHooks] objectForKey:taskName]) {
            if (![self runTaskClassName:hookName inTaskList:taskList]) {
                return NO;
            }
        }

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        _currentTask = [[taskClass alloc] init];
        [_currentTask setConfig:_config];
        [_currentTask setTaskManager:self];
        
        [center postNotificationName:MYPackageTaskManagerWillRunTaskNotification
                              object:self
                            userInfo:@{@"task": _currentTask}];

        [self.config.logger logN:@"==================== Task: %@ ====================", taskName];
        NSDate *startDate = [NSDate date];

        BOOL result = [_currentTask launch];
        self.lastErrorMessage = _currentTask.errorMessage;

        [self.config.logger logN:@"---------------------- %f s ----------------------\n", [[NSDate date] timeIntervalSinceDate:startDate]];

        [center postNotificationName:MYPackageTaskManagerFinishRunTaskNotification
                              object:self
                            userInfo:@{@"task": _currentTask, @"success": @(result)}];

        if (result) {
            for (NSString *hookName in [[[self class] afterHooks] objectForKey:taskName]) {
                if (![self runTaskClassName:hookName inTaskList:taskList]) {
                    return NO;
                }
            }
        }

        return result;
    }
    return NO;
}

@end
