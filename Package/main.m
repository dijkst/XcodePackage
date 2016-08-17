//
//  main.m
//  Package
//
//  Created by Whirlwind on 15/10/21.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MYPackageCommandLine.h"

int main(int argc, const char *argv[]) {
    if ([MYPackageCommandLine canRunWithCommandLineMode]) {
        @autoreleasepool {
            __block int s = -100;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                s = [MYPackageCommandLine run];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    CFRunLoopStop(CFRunLoopGetCurrent());
                });
            });
            CFRunLoopRun();
            return s;
        }
    } else {
        return NSApplicationMain(argc, argv);
    }
}

