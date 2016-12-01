//
//  MYPackageBaseViewController.h
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MYPackageConfig.h"
#import "MYPackageBaseTask.h"
#import "SafeThread.h"
#import "MYPackageTaskManager.h"

@class MYPackageContainerViewController;
@interface MYPackageBaseViewController : NSViewController <NSUserNotificationCenterDelegate>

@property (nonatomic, copy) MYPackageConfig *config;

@property (nonatomic, strong) MYPackageTaskManager *taskManager;

@property (nonatomic, assign) BOOL busy;

@property (nonatomic, weak) MYPackageContainerViewController *containerVC;

@property (nonatomic, assign) BOOL showBackButton;

@property (strong, nonatomic) IBOutlet NSButton *rightButton;

- (void)postUserNotificationWithResult:(BOOL)result;

- (BOOL)runTasks:(NSArray<NSString *> *)tasks autoOrder:(BOOL)order;

@end
