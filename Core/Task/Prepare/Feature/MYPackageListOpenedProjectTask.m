//
//  MYPackageListOpenedProjectTask.m
//  Package
//
//  Created by Whirlwind on 15/10/22.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageListOpenedProjectTask.h"

#if __has_include(<ObjCCommandLine/ObjCShell.h>)
#   import <ObjCCommandLine/ObjCAppleScript.h>
#else
#   import "ObjCAppleScript.h"
#endif

@implementation MYPackageListOpenedProjectTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSDictionary *errorDict = nil;
    NSArray *list = [ObjCAppleScript executeWithSource:@"on is_running(appName)\n\
                   tell application \"System Events\" to (name of processes) contains appName\n\
                   end is_running\n\
                   set xcodeRunning to is_running(\"Xcode\")\n\
                   if xcodeRunning then\n\
                    tell application id \"com.apple.dt.Xcode\"\n\
                        return the path of every workspace document\n\
                    end tell\n\
                   else\n\
                    return {}\n\
                   end if"
                                                 error:&errorDict];
    [self.config.logger logN:[list description]];
    if (errorDict) {
        self.errorMessage = errorDict[NSAppleScriptErrorBriefMessage];
        return NO;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:list options:0 error:nil];
    self.output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return YES;
}

@end
