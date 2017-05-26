//
//  MYPackageTaskManager.m
//  Package
//
//  Created by Whirlwind on 15/10/22.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageTaskManager.h"
#import "MYPackageTaskManager+TaskList.h"

@interface MYPackageTaskManager ()

@property (nonatomic, readonly) MYPackageBaseTask *currentTask;

@end

@implementation MYPackageTaskManager

+ (NSMutableDictionary *)tasksObserver {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *__tasksObserver;
    dispatch_once(&onceToken, ^{
        __tasksObserver = [NSMutableDictionary dictionary];
    });
    return __tasksObserver;
}

+ (void)registTasksObserver:(void(^)(NSMutableArray *tasks))observer id:(NSInteger)_id {
    [[self tasksObserver] setObject:observer forKey:@(_id)];
}

- (BOOL)runTasks:(NSArray *)tasks {
    if (!tasks) {
        return [self runTaskClassNames:[self taskClassOrder]];
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
    for (NSString *taskName in [self taskClassOrder]) {
        if ([tasks indexOfObject:taskName] != NSNotFound) {
            [orderedTasks addObject:taskName];
        }
    }
    return [self runTaskClassNames:orderedTasks];
}

- (BOOL)runTaskClassNames:(NSArray *)tasks {
    NSArray *sortedKeys = [[[[self class] tasksObserver] allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return [obj1 integerValue] < [obj2 integerValue];
    }];
    NSArray *observers = [[[self class] tasksObserver] objectsForKeys:sortedKeys notFoundMarker:[NSNull null]];
    NSMutableArray *ts = [tasks mutableCopy] ?: [NSMutableArray array];
    for (void(^observer)(NSMutableArray *) in observers) {
        observer(ts);
    }
    BOOL result = YES;
    NSMutableString *output = [NSMutableString string];
    for (NSString *taskName in ts) {
        Class taskClass = NSClassFromString(taskName);
        if (!taskClass) {
            continue;
        }
        if (![taskClass shouldLaunchWithPreTaskStatus:result manager:self]) {
            continue;
        }
        if (![self runTaskClass:taskClass]) {
            result = NO;
        }
        if ([self.currentTask.output length] > 0) {
            [output appendString:self.currentTask.output];
        }
        if (self.currentTask.isCancelled) {
            break;
        }
    }
    self.output = output;
    return result;
}

- (BOOL)runTaskClass:(Class)taskClass {
    if (taskClass) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        _currentTask = [[taskClass alloc] init];
        [_currentTask setConfig:_config];
        [_currentTask setTaskManager:self];
        
        [center postNotificationName:MYPackageTaskManagerWillRunTaskNotification
                              object:self
                            userInfo:@{@"task": _currentTask}];

        [self.config.logger logN:@"==================== Task: %@ ====================", NSStringFromClass(taskClass)];
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

- (void)cancelAllTask {
    [self.currentTask cancel];
}

@end
