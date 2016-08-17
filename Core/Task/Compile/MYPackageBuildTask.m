//
//  MYPackageBuildTask.m
//  Package
//
//  Created by Whirlwind on 15/5/4.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageBuildTask.h"

@interface MYPackageBuildTask ()
@end

@implementation MYPackageBuildTask

- (NSString *)name {
    return @"编译二进制";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSString *shellPath = [self scriptForName:@"build" ofType:@"sh"];
    if ([self executeCommand:[NSString stringWithFormat:@"'%@' '%@' '%@' '%@' '%@'",
                              shellPath,
                              self.config.workspace.filePath,
                              self.config.selectedSchemeName,
                              self.config.configruation,
                              self.config.xcconfigSettings ?: @""
                              ]] != 0) {
        self.errorMessage = @"编译项目出错，详见日志！";
        return NO;
    }
    return YES;
}

@end
