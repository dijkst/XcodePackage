//
//  MYPackageBaseViewController.m
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageBaseViewController.h"
#import "MYPackageContainerViewController.h"

@interface MYPackageBaseViewController ()

@end

@implementation MYPackageBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer:YES];
    self.showBackButton = YES;
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    if (self.busy) {
        [self.taskManager cancelAllTask];
    }
}

- (void)setRightButton:(NSButton *)rightButton {
    _rightButton = rightButton;

    self.containerVC.rightButton = rightButton;
}

#pragma mark - task
- (IBAction)startAction:(id)sender {
    if (self.busy) {
        [self stopTask];
    } else {
        [self startTask];
    }
}

- (void)stopTask {
    [self.taskManager cancelAllTask];
}

- (void)startTask {
    NSMutableArray *tasks = [self tasksForRun];
    if ([tasks count] == 0) {
        return;
    }
    self.rightButton.title = @"取消";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self runTasks:tasks autoOrder:YES];
        dispatch_main_async_safe(^{
            self.rightButton.title = @"开始";
            [self tasks:tasks didFinishWithResult:result];
        });
    });
}

- (NSMutableArray *)tasksForRun {
    return [NSMutableArray array];
}

- (void)tasks:(NSArray *)tasks didFinishWithResult:(BOOL)result {

}

- (MYPackageTaskManager *)taskManager {
    if (!_taskManager) {
        _taskManager = [[MYPackageTaskManager alloc] init];
        [_taskManager setConfig:self.config];
    }
    return _taskManager;
}

- (BOOL)runTasks:(NSArray<NSString *> *)tasks autoOrder:(BOOL)order {
    self.busy = YES;
    BOOL status = order ? [self.taskManager runTaskClassNamesInOrder:tasks] : [self.taskManager runTaskClassNames:tasks];
    NSString *errorMessage = self.taskManager.lastErrorMessage;
    [self.containerVC finishLoadingWithErrorText:errorMessage];
    self.busy = NO;
    return status;
}

- (void)setBusy:(BOOL)busy {
    _busy = busy;
    dispatch_main_async_safe(^{
        [self.containerVC.backButton setHidden:busy || !self.showBackButton || self.containerVC.childViewControllers.count <= 1];
    });
}

#pragma mark - NSUserNotificationCenter

- (void)postUserNotificationWithResult:(BOOL)result {
    dispatch_main_async_safe(^{
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.informativeText = [NSString stringWithFormat:@"打包任务执行%@", result ? @"成功" : @"失败"];
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    });
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {

}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

@end
