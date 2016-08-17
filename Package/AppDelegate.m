//
//  AppDelegate.m
//  Package
//
//  Created by Whirlwind on 15/10/21.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "AppDelegate.h"
#import "SafeThread.h"
#import "MYPackageContainerViewController.h"
#import "MYPackageConfig.h"

@interface AppDelegate () <NSUserNotificationCenterDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) MYPackageContainerViewController *mainVC;

@end

@implementation AppDelegate

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
    if (_mainVC.logWindow.isVisible) {
        _mainVC.logWindow.isVisible = NO;
    }
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
    [_mainVC.logWindow setIsVisible:YES];
    [_mainVC.logTextView scrollToEndOfDocument:nil];
}

- (IBAction)showFinder:(id)sender {
    NSArray *fileURLs = [NSArray arrayWithObjects:[NSURL fileURLWithPath:_mainVC.config.logPath], nil];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.tag == 101) {
        // 打开输出目录菜单只在选择了项目之后才有效
        return _mainVC.config.workspace.path != nil;
    }
    return YES;
}

@end
