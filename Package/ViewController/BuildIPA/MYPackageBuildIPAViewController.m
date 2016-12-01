//
//  MYPackageBuildIPAViewController.m
//  Package
//
//  Created by Whirlwind on 16/5/19.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageBuildIPAViewController.h"
#import "MYPackageContainerViewController.h"

#import "MYPackageAnalyzeProjectTask.h"
#import "MYPackageAnalyzeSchemeTask.h"
#import "MYPackageAnalyzeTargetTask.h"

#import "MYPackageBuildTask.h"
#import "MYPackageLipoTask.h"

#import "MYPackageUploadLocalTask.h"

@interface MYPackageBuildIPAViewController ()

@property (weak) IBOutlet NSTextField   *bundleIdTextField;
@property (weak) IBOutlet NSTextField   *displayNameTextField;
@property (weak) IBOutlet NSTextField   *versionTextField;
@property (weak) IBOutlet NSPopUpButton *configrationSelector;

@property (weak) IBOutlet NSButton *packageCheck;
@property (weak) IBOutlet NSButton *uploadCheck;

@end

@implementation MYPackageBuildIPAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *configurations = [NSMutableArray array];
    for (MYPackageProject *project in self.config.selectedScheme.projects) {
        [configurations addObjectsFromArray:project.configrations];
    }
    [self.configrationSelector addItemsWithTitles:[configurations valueForKeyPath:@"@distinctUnionOfObjects.self"]];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.title = [NSString stringWithFormat:@"%@ / %@", self.config.workspace.name, self.config.selectedSchemeName];
}

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
    self.config.version       = self.versionTextField.stringValue;
    self.config.configruation = self.configrationSelector.selectedItem.title;
    NSString *name = [self.displayNameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([name length] > 0) {
        self.config.podName = name;
    }
    if (self.config.version.length == 0) {
        [self.containerVC finishLoadingWithErrorText:@"版本号不能为空！"];
        return;
    }
    [self runTask];
}

- (void)runTask {
    NSMutableArray *tasks = [NSMutableArray array];
    if (self.packageCheck.state == NSOnState) {
        [tasks addObjectsFromArray:@[NSStringFromClass([MYPackageAnalyzeSchemeTask class]), //重新执行一遍分析，防止用户修改项目导致设置不一致
                                     NSStringFromClass([MYPackageAnalyzeProjectTask class]),
                                     NSStringFromClass([MYPackageAnalyzeTargetTask class]),
                                     NSStringFromClass([MYPackageBuildTask class]),
                                     NSStringFromClass([MYPackageLipoTask class]),
                                     ]];
    }
    if (self.uploadCheck.state == NSOnState) {
        [tasks addObjectsFromArray:@[NSStringFromClass([MYPackageUploadLocalTask class]),
                                     ]];
    }
    if ([tasks count] == 0) {
        return;
    }
    self.rightButton.title = @"取消";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL result = [self runTasks:tasks autoOrder:YES];
        dispatch_main_async_safe(^{
            [self postUserNotificationWithResult:result];
            if (result) {
                [self.containerVC showNormalText:@"任务执行成功！"];
                [self.config.logger logN:@"\n任务执行成功！"];
            } else {
                [self.config.logger logN:@"\n任务执行失败！"];
            }
            self.rightButton.title = @"开始";
        });
    });
}

@end
