//
//  PackageAppDelegate.h
//  Package
//
//  Created by Whirlwind on 15/10/21.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PackageAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (weak) IBOutlet NSWindow *window;

- (IBAction)showLogWindow:(id)sender;
- (IBAction)showFinder:(id)sender;

@end

