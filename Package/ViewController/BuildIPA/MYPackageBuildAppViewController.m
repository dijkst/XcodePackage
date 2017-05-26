//
//  MYPackageBuildAppViewController.m
//  Package
//
//  Created by Whirlwind on 2017/2/8.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageBuildAppViewController.h"
#import "MYPackageContainerViewController.h"
#import "MYPackageQRCodeViewController.h"
#import "NSImage+GDQrCodeImage.h"
#import "MYPackageServer.h"

#import "MYPackageListProfilesTask.h"

#import "MYPackageAnalyzeSchemeTask.h"
#import "MYPackageAnalyzeProjectTask.h"
#import "MYPackageAnalyzeTargetTask.h"
#import "MYPackageUpdatePlistTask.h"
#import "MYPackageBuildAppTask.h"
#import "MYPackageResignAppTask.h"
#import "MYPackageUploadLocalTask.h"

@interface MYPackageBuildAppViewController ()

@property (weak) IBOutlet NSPopUpButton *configrationSelector;
@property (weak) IBOutlet NSTextField   *bundleIdTextField;
@property (weak) IBOutlet NSTextField   *displayNameTextField;
@property (weak) IBOutlet NSTextField   *versionTextField;
@property (weak) IBOutlet NSPopUpButton *codesignSelector;
@property (weak) IBOutlet NSPopUpButton *codesignTypeSelector;

@property (weak) IBOutlet NSButton *archiveCheck;
@property (weak) IBOutlet NSButton *exportCheck;
@property (weak) IBOutlet NSButton *uploadCheck;
@property (weak) IBOutlet NSButton *qrcodeButton;

@property (nonatomic, assign) BOOL profileIsLoading;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<MYPackageProfile *> *> *profiles;

@end

@implementation MYPackageBuildAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *configurations = [NSMutableArray array];
    for (MYPackageProject *project in self.config.selectedScheme.projects) {
        [configurations addObjectsFromArray:project.configrations];
    }
    [self.configrationSelector addItemsWithTitles:[configurations valueForKeyPath:@"@distinctUnionOfObjects.self"]];
    [self.configrationSelector selectItemWithTitle:self.config.configruation];

    self.bundleIdTextField.stringValue = self.config.selectedScheme.targets.firstObject.bundleId;
    self.versionTextField.stringValue = self.config.version;
    self.displayNameTextField.stringValue = self.config.displayName;
    [self reloadProvisioningProfile];
}

#pragma mark - Provisioning Profile
- (void)setProfiles:(NSDictionary<NSString *, NSArray<MYPackageProfile *> *> *)profiles {
    _profiles = profiles;
    [self reloadCodesignList];
}

- (IBAction)signTypeChangedAction:(id)sender {
    [self reloadCodesignList];
}

- (void)reloadCodesignList {
    if (self.profileIsLoading) {
        return;
    }
    [self.codesignSelector removeAllItems];
    NSString *bundleId = [self.bundleIdTextField stringValue];
    if ([bundleId length] > 0) {
        NSMutableDictionary *filterProfiles = [NSMutableDictionary dictionary];
        [self.profiles enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<MYPackageProfile *> * _Nonnull obj, BOOL * _Nonnull stop) {
            NSArray *profiles = [obj filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MYPackageProfile *profile, NSDictionary<NSString *,id> * bindings) {
                return [profile isMatchAppBundleID:bundleId] && profile.SignCertificate && profile.type == self.codesignTypeSelector.selectedItem.tag;
            }]];
            if (profiles.count > 0) {
                [filterProfiles setObject:profiles forKey:key];
            }
        }];
        [filterProfiles enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<MYPackageProfile *> * _Nonnull profiles, BOOL * _Nonnull stop) {
            [self.codesignSelector addItemWithTitle:[NSString stringWithFormat:@"%@ (%@)", [profiles firstObject].TeamName, key]];
            NSMenuItem *teamItem = [self.codesignSelector lastItem];
            teamItem.representedObject = key;
            [profiles enumerateObjectsUsingBlock:^(MYPackageProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.codesignSelector addItemWithTitle:@"!!Placeholder!!"];
                NSMenuItem *item = [self.codesignSelector lastItem];
                item.title = obj.Name;
                item.indentationLevel = 1;
                item.enabled = NO;

                if ([obj.ApplectionIdentifier isEqualToString:bundleId]) {
                    [self.codesignSelector selectItem:teamItem];
                }
            }];
        }];
        self.codesignSelector.enabled = YES;
    }
    if ([self.codesignSelector.itemArray count] == 0) {
        [self.codesignSelector addItemWithTitle:[bundleId length] > 0 ? @"未找到匹配的描述描述文件" : @"请先输入 Bundle ID"];
        self.codesignSelector.enabled = NO;
    }
}

- (void)reloadProvisioningProfile {
    self.profileIsLoading = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self runTasks:@[NSStringFromClass([MYPackageListProfilesTask class])] autoOrder:NO]) {
            dispatch_main_async_safe(^{
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[self.taskManager.output dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                NSMutableDictionary *profiles = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
                [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [profiles setObject:[MYPackageProfile arrayWithJSONObject:obj]
                                 forKey:key];
                }];
                self.profiles = profiles;
            });
        }
        self.profileIsLoading = NO;
    });
}

#pragma mark - NSTextField Delegate
-(void)controlTextDidChange:(NSNotification *)notification {
    [self reloadCodesignList];
}

#pragma mark - task
- (void)startTask {
    if (!self.codesignSelector.selectedItem.representedObject) {
        [self.containerVC showHighlightText:@"请选择签名团队！"];
        return;
    }
    self.config.configruation = self.configrationSelector.selectedItem.title;
    self.config.displayName = self.displayNameTextField.stringValue;
    self.config.bundleId = self.bundleIdTextField.stringValue;
    self.config.version = self.versionTextField.stringValue;
    self.config.teamID = [self.codesignSelector selectedItem].representedObject;
    self.config.signType = profileTypeNameForType([self.codesignTypeSelector selectedItem].tag);
    NSString *name = [self.displayNameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([name length] > 0) {
        self.config.name = name;
    }
    if (self.config.version.length == 0) {
        [self.containerVC showHighlightText:@"版本号不能为空！"];
        return;
    }
    [self.qrcodeButton setHidden:YES];
    [super startTask];
}

- (NSMutableArray *)tasksForRun {
    NSMutableArray *tasks = [super tasksForRun];
    if (self.archiveCheck.state == NSOnState) {
        [tasks addObject:NSStringFromClass([MYPackageAnalyzeSchemeTask class])]; //重新执行一遍分析，防止用户修改项目导致设置不一致
        [tasks addObject:NSStringFromClass([MYPackageAnalyzeProjectTask class])];
        [tasks addObject:NSStringFromClass([MYPackageAnalyzeTargetTask class])];
        [tasks addObject:NSStringFromClass([MYPackageBuildAppTask class])];
    }
    if (self.exportCheck.state == NSOnState) {
        [tasks addObject:NSStringFromClass([MYPackageUpdatePlistTask class])];
        [tasks addObject:NSStringFromClass([MYPackageResignAppTask class])];
    }
    if (self.uploadCheck.state == NSOnState) {
        [tasks addObject:NSStringFromClass([MYPackageUploadLocalTask class])];
    }
    return tasks;
}

- (void)tasks:(NSArray *)tasks didFinishWithResult:(BOOL)result {
    [super tasks:tasks didFinishWithResult:result];
    if (result) {
        [self.containerVC showNormalText:@"任务执行成功！"];
        [self.config.logger logN:@"\n任务执行成功！"];

        if (self.uploadCheck.state == NSOnState) {
            [self.qrcodeButton setImage:[NSImage gd_QrCodeImageWithColor:[NSColor colorWithRed:0 green:150.f/255.f blue:1 alpha:1] message:self.config.downloadUrl]];
            [self.qrcodeButton setHidden:NO];
            [self showPopoverViewAction:self.qrcodeButton];
        }
    } else {
        [self.config.logger logN:@"\n任务执行失败！"];
    }
}

- (IBAction)showPopoverViewAction:(NSButton *)sender {
    MYPackageQRCodeViewController *controller = [[MYPackageQRCodeViewController alloc] init];
    [controller setImage:sender.image];
    NSPopover *popover = [[NSPopover alloc] init];
    [popover setBehavior:NSPopoverBehaviorTransient];
    [popover setContentSize:NSMakeSize(300.0f, 300.0f)];
    [popover setContentViewController:controller];
    [popover setAnimates:YES];
    [popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxXEdge];
}

@end
