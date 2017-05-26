//
//  MYPackageTaskManager+TaskList.m
//  Package
//
//  Created by Whirlwind on 2017/2/6.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageTaskManager+TaskList.h"

NSArray *taskClassOrderPrefix;
NSArray *taskClassOrderForApp;
NSArray *taskClassOrderForLib;
NSArray *taskClassOrderSuffix;

@implementation MYPackageTaskManager (TaskList)

+ (void)load {
    taskClassOrderPrefix = @[
                             // Prepare
                             @"MYPackageInitTask",
                             @"MYPackageCheckEnvironmentTask",
                             @"MYPackageAnalyzeGitTask",
                             @"MYPackageCheckGitTask",
                             @"MYPackageListSchemeTask",
                             @"MYPackageAnalyzeSchemeTask",
                             @"MYPackageAnalyzeProjectTask",
                             @"MYPackageAnalyzeTargetTask",
                             ];
    taskClassOrderForLib = @[
                             // Build
                             @"MYPackageCleanTask",
                             @"MYPackageBuildLibTask",
                             @"MYPackageLipoTask",

                             // Package
                             @"MYPackageAnalyzeProductTask",
                             @"MYPackageUpdatePlistTask",
                             @"MYPackageZipTask",
                             @"MYPackageCalculateSHA1Task",
                             @"MYPackageCreateSpecTask",

                             // release
                             @"MYPackageCreateTagTask",
                             ];
    taskClassOrderForApp = @[                             
                             // Build
                             @"MYPackageCleanTask",
                             @"MYPackageBuildAppTask",
                             @"MYPackageUpdatePlistTask",
                             @"MYPackageResignAppTask",
                             
                             // release
                             @"MYPackageCreateTagTask",
                             ];
    taskClassOrderSuffix = @[
                             // Clean
                             @"MYPackageCleanIntermediateProductTask",
                             ];
}

+ (NSMutableArray *)taskClassNamesForTasks:(NSArray *)shortTasks {
    NSMutableArray *taskClassNames = [NSMutableArray arrayWithCapacity:[shortTasks count]];
    for (NSString *taskName in shortTasks) {
        NSString *taskClassName = taskName;
        if (![taskClassName hasPrefix:@"MYPackage"]) {
            taskClassName = [taskClassName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[taskClassName substringToIndex:1] uppercaseString]];
            taskClassName = [NSString stringWithFormat:@"MYPackage%@Task", taskClassName];
        }
        if (NSClassFromString(taskClassName)) {
            [taskClassNames addObject:taskClassName];
        }
    }
    return taskClassNames;
}

- (NSMutableArray *)taskClassOrder {
    NSMutableArray *array = [NSMutableArray arrayWithArray:taskClassOrderPrefix];
    if (self.config.appTarget) {
        [array addObjectsFromArray:taskClassOrderForApp];
    } else {
        [array addObjectsFromArray:taskClassOrderForLib];
    }
    [array addObjectsFromArray:taskClassOrderSuffix];
    return array;
}

@end
