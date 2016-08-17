//
//  MYPackagePrepareEnvironmentViewController.m
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackagePrepareEnvironmentViewController.h"
#import "MYPackageContainerViewController.h"
#import "MYPackageSelectProjectViewController.h"
#import "MYPackageSelectSchemeViewController.h"

#import "MYPackageInitTask.h"
#import "MYPackagePrepareEnvironmentTask.h"

@interface MYPackagePrepareEnvironmentViewController ()

@end

@implementation MYPackagePrepareEnvironmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBackButton = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self runTasks:@[NSStringFromClass([MYPackageInitTask class]),
                             NSStringFromClass([MYPackagePrepareEnvironmentTask class])
                             ]
                 autoOrder:NO]) {
            dispatch_main_async_safe(^{
                if (self.config.workspaceFilePath) {
                    [self.containerVC changeTopViewController:[[MYPackageSelectSchemeViewController alloc] init]];
                } else {
                    [self.containerVC changeTopViewController:[[MYPackageSelectProjectViewController alloc] init]];
                }
            });
        }
    });
}

@end
