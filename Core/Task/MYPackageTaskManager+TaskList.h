//
//  MYPackageTaskManager+TaskList.h
//  Package
//
//  Created by Whirlwind on 2017/2/6.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageTaskManager.h"

extern NSArray *taskClassOrderSetup;
extern NSArray *taskClassOrderPrefix;
extern NSArray *taskClassOrderForApp;
extern NSArray *taskClassOrderForLib;
extern NSArray *taskClassOrderSuffix;

@interface MYPackageTaskManager (TaskList)

+ (NSMutableArray *)taskClassNamesForTasks:(NSArray *)shortTasks;
- (NSMutableArray *)taskClassOrder;

@end
