//
//  MYPackageSelectTaskViewController.m
//  Package
//
//  Created by Whirlwind on 15/11/27.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageSelectTaskViewController.h"
#import "MYPackageContainerViewController.h"

#import "MYPackageGetHighestVersionTask.h"

#import "MYPackageAnalyzeProjectTask.h"
#import "MYPackageAnalyzeSchemeTask.h"
#import "MYPackageAnalyzeTargetTask.h"
#import "MYPackageAnalyzeGitTask.h"

#import "MYPackageCleanTask.h"
#import "MYPackageBuildTask.h"
#import "MYPackageLipoTask.h"
#import "MYPackageCleanIntermediateProductTask.h"

#import "MYPackageCheckGitTask.h"
#import "MYPackageAnalyzeProductTask.h"
#import "MYPackageUpdateVersionNumberTask.h"
#import "MYPackageZipTask.h"
#import "MYPackageCreateSpecTask.h"

#import "MYPackageCreateTagTask.h"

@interface MYPackageSelectTaskViewController ()

@property (weak) IBOutlet NSTextField   *podNameTextField;
@property (weak) IBOutlet NSTextField   *versionTextField;
@property (weak) IBOutlet NSButton      *snapshotCheck;
@property (weak) IBOutlet NSButton      *buildCheck;
@property (weak) IBOutlet NSButton      *packageCheck;
@property (weak) IBOutlet NSButton      *uploadCheck;
@property (weak) IBOutlet NSPopUpButton *configrationSelector;

@property (nonatomic, assign) BOOL podExists;

@end

@implementation MYPackageSelectTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *configurations = [NSMutableArray array];
    for (MYPackageProject *project in self.config.selectedScheme.projects) {
        [configurations addObjectsFromArray:project.configrations];
    }
    [self.configrationSelector addItemsWithTitles:[configurations valueForKeyPath:@"@distinctUnionOfObjects.self"]];
    [self toggleSNAPSHOT:nil];
    self.podNameTextField.stringValue = self.config.podName;
    [self updateVersionTextField];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.title = [NSString stringWithFormat:@"%@ / %@", self.config.workspace.name, self.config.selectedSchemeName];
}

- (void)updateVersionTextField {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *plistVersion = self.config.version;
        NSString *highestVersion = [self getHighestVersion];
        self.podExists = highestVersion != nil;
        NSString *version = nil;
        if (plistVersion && highestVersion) {
            if ([plistVersion compare:highestVersion options:NSNumericSearch] == NSOrderedAscending) {
                version = highestVersion;
            } else {
                version = plistVersion;
            }
        } else if (plistVersion) {
            version = plistVersion;
        } else if (highestVersion) {
            version = highestVersion;
        }
        if (version) {
            dispatch_main_async_safe(^{
                if ([[version uppercaseString] hasSuffix:@"-SNAPSHOT"]) {
                    self.versionTextField.stringValue = [version substringToIndex:version.length - [@"-SNAPSHOT" length]];
                    self.snapshotCheck.state = NSOnState;
                } else {
                    self.versionTextField.stringValue = version;
                    self.snapshotCheck.state = NSOffState;
                }
                [self toggleSNAPSHOT:nil];
            });
        }
    });
}

- (NSString *)getHighestVersion {
    MYPackageGetHighestVersionTask *task = [[MYPackageGetHighestVersionTask alloc] init];
    task.config  = self.config;
    task.podName = self.podNameTextField.stringValue;
    if ([task launch]) {
        return [task.output length] > 0 ? task.output : nil;
    }
    return nil;
}

- (void)awakeFromNib {
    self.rightButton.showsBorderOnlyWhileMouseInside = YES;
    [self.rightButton removeConstraints:self.rightButton.constraints];
}

- (IBAction)toggleSNAPSHOT:(id)sender {
    self.configrationSelector.enabled = self.snapshotCheck.state == NSOnState;
    self.config.configruation         = nil;
    [self.configrationSelector selectItemWithTitle:self.config.configruation];
}

- (IBAction)startAction:(id)sender {
    if (self.busy) {
        [self stopTask];
    } else {
        [self startTask];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    if ([self.podNameTextField.stringValue length] == 0) {
        self.podNameTextField.stringValue = self.config.podName;
    }
    [self updateVersionTextField];
    return YES;
}

- (void)stopTask {
    [self.currentTask cancel];
}

- (void)startTask {
    self.config.version = self.versionTextField.stringValue;
    if (self.snapshotCheck.state == NSOnState) {
        self.config.configruation = self.configrationSelector.selectedItem.title;
    } else {
        self.config.configruation = nil;
    }
    NSString *podName = [self.podNameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([podName length] > 0) {
        self.config.podName = podName;
    }
    if (self.config.version.length == 0) {
        [self.containerVC finishLoadingWithErrorText:@"版本号不能为空！"];
        return;
    }
    if (self.snapshotCheck.state == NSOnState && ![[self.config.version uppercaseString] hasSuffix:@"-SNAPSHOT"]) {
        self.config.version = [self.config.version stringByAppendingString:@"-SNAPSHOT"];
    }
    if (self.uploadCheck.state == NSOnState && !self.podExists) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:@"%@ 不存在，是否继续？", self.config.podName]];
        [alert setInformativeText:[NSString stringWithFormat:@"Pod: %@ 不存在，是否提交第一个版本？\n", self.config.podName]];
        [alert addButtonWithTitle:@"继续"];
        [alert addButtonWithTitle:@"取消"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {
                [self runTask];
            }
        }];
    } else {
        [self runTask];
    }
}

- (void)runTask {
    NSMutableArray *tasks = [NSMutableArray array];
    if (self.buildCheck.state == NSOnState) {
        [tasks addObjectsFromArray:@[NSStringFromClass([MYPackageAnalyzeSchemeTask class]), //重新执行一遍分析，防止用户修改项目导致设置不一致
                                     NSStringFromClass([MYPackageAnalyzeProjectTask class]),
                                     NSStringFromClass([MYPackageAnalyzeTargetTask class]),
                                     NSStringFromClass([MYPackageBuildTask class]),
                                     NSStringFromClass([MYPackageLipoTask class]),
                                     ]];
        if (![self.config isSNAPSHOT]) {
            [tasks addObject:NSStringFromClass([MYPackageCleanTask class])];
            [tasks addObject:NSStringFromClass([MYPackageCleanIntermediateProductTask class])];
        }

    }
    if (self.packageCheck.state == NSOnState) {
        [tasks addObjectsFromArray:@[NSStringFromClass([MYPackageAnalyzeGitTask class]),
                                     NSStringFromClass([MYPackageAnalyzeProductTask class]),
                                     NSStringFromClass([MYPackageUpdateVersionNumberTask class]),
                                     NSStringFromClass([MYPackageZipTask class]),
                                     NSStringFromClass([MYPackageCreateSpecTask class]),
                                     ]];

    }
    if (self.uploadCheck.state == NSOnState) {
        [tasks addObjectsFromArray:@[NSStringFromClass([MYPackageAnalyzeGitTask class])]];
        if (![self.config isSNAPSHOT]) {
            [tasks addObject:NSStringFromClass([MYPackageCheckGitTask class])];
        }
        [tasks addObjectsFromArray:@[NSStringFromClass([MYPackageCreateSpecTask class]),
                                     NSStringFromClass([MYPackageCreateTagTask class]),
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
