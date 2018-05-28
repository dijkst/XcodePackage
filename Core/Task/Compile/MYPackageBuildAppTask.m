//
//  MYPackageBuildAppTask.m
//  Package
//
//  Created by Whirlwind on 2017/2/6.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageBuildAppTask.h"

@implementation MYPackageBuildAppTask

- (NSString *)name {
    return @"编译二进制";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    [[NSFileManager defaultManager] createDirectoryAtPath:self.config.productsDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *archivePath = [self.config.productsDir stringByAppendingPathComponent:@"archive"];

    if ([self executeCommand:[NSString stringWithFormat:@"set -o pipefail && xcodebuild %@ \"%@\" -configuration \"%@\" -hideShellScriptEnvironment -xcconfig \"%@\" %@ -scheme \"%@\" archive -archivePath \"%@\" | bundle exec xcpretty",
                              PathIsProject(self.config.workspaceFilePath) ? @"-project" : @"-workspace",
                              self.config.workspaceFilePath,
                              self.config.configruation,
                              [self scriptForName:@"build-app" ofType:@"xcconfig"],
                              self.config.xcconfigSettings ?: @"",
                              self.config.selectedSchemeName,
                              archivePath
                              ]] != 0) {
        self.errorMessage = @"编译项目出错，详见日志！";
        return NO;
    }
    return YES;
}

@end
