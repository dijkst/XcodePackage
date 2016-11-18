//
//  PackageAppDelegate.m
//  Package
//
//  Created by Whirlwind on 15/10/21.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "PackageAppDelegate.h"
#import "SafeThread.h"
#import "MYPackageContainerViewController.h"
#import "MYPackageConfig.h"

@interface PackageAppDelegate () <NSUserNotificationCenterDelegate>

@property (nonatomic, strong) MYPackageContainerViewController *mainVC;

@end

@implementation PackageAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _mainVC = [[MYPackageContainerViewController alloc] init];
    [_mainVC setConfig:[[MYPackageConfig alloc] init]];

    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    _mainVC.config.workspaceFilePath = [args objectForKey:@"workspace"] ?: [args objectForKey:@"project"];

    self.window.contentViewController      = _mainVC;
    self.window.titleVisibility            = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    self.window.styleMask                 |= NSFullSizeContentViewWindowMask;
    self.window.movableByWindowBackground  = YES;
}

- (void)windowWillClose:(NSNotification *)notification {
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)postMessageNotification:(NSString *)message {
    dispatch_main_async_safe(^{
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.soundName = NSUserNotificationDefaultSoundName;
        notification.informativeText = message;
        [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark - window

- (IBAction)showLogWindow:(id)sender {
    NSURL *url = [NSURL fileURLWithPath:_mainVC.config.logPath];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)showFinder:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:_mainVC.config.outputDir];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.tag == 101) {
        // 打开输出目录菜单只在选择了项目之后才有效
        return _mainVC.config.workspace.path != nil;
    }
    return YES;
}

@end
