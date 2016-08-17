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
                       @"MYPackageUploadTask",
                       @"MYPackageCreateTagTask",

                       // Clean
                       @"MYPackageCleanIntermediateProductTask",
                       @"MYPackageCleanFinalProductTask",

                       // Statistics
                       @"MYPackageUploadStatisticsTask"
                       ];
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
    for (NSString *taskName in taskClassOrder) {
        if ([tasks indexOfObject:taskName] != NSNotFound) {
            if (![self runTaskClassName:taskName]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)runTaskClassNames:(NSArray *)tasks {
    for (NSString *taskName in tasks) {
        if (![self runTaskClassName:taskName]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)runTaskClassName:(NSString *)taskName {
    Class taskClass = NSClassFromString(taskName);
    if (taskClass) {
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
        return result;
    }
    return NO;
}

@end
