//
//  MYPackageBuildLibTask.m
//  Package
//
//  Created by Whirlwind on 15/5/4.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageBuildLibTask.h"

@interface MYPackageBuildLibTask ()
@end

@implementation MYPackageBuildLibTask

- (NSString *)name {
    return @"编译二进制";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSMutableArray *simulators = [NSMutableArray array];
    NSMutableArray *devices = [NSMutableArray array];
    for (MYPackageTarget *target in self.config.selectedScheme.targets) {
        if (target.needLipo) {
            [simulators addObject:[NSString stringWithFormat:@"-destination 'generic/platform=%@ Simulator'", target.platformName]];
        }
        [devices addObject:[NSString stringWithFormat:@"-destination 'generic/platform=%@'", target.platformName]];
    }
    simulators = [simulators valueForKeyPath:@"@distinctUnionOfObjects.self"];
    devices = [devices valueForKeyPath:@"@distinctUnionOfObjects.self"];
    NSString *cmd = [NSString stringWithFormat:@"xcodebuild -project '%@' -configuration '%@' -xcconfig '%@' -scheme '%@' %@",
                     self.config.workspace.filePath,
                     self.config.configruation,
                     self.config.xcconfig,
                     self.config.selectedScheme.name,
                     self.config.xcconfigSettings ?: @""];
    if ([simulators count] > 0 &&
        [self executeCommand:[NSString stringWithFormat:@"%@ CONFIGURATION_BUILD_DIR='build/simulator/$(PLATFORM_NAME)/' %@ build",
                              cmd,
                              [simulators componentsJoinedByString:@" "]]] != 0) {
        self.errorMessage = @"编译项目出错，详见日志！";
        return NO;
    }
    if ([devices count] > 0 &&
        [self executeCommand:[NSString stringWithFormat:@"%@ INSTALL_PATH='build/os/$(PLATFORM_NAME)/' INSTALL_ROOT='' SKIP_INSTALL=NO DWARF_DSYM_FOLDER_PATH='$(pwd)/build/iphoneos' %@ archive", cmd,
                              [devices componentsJoinedByString:@" "]]] != 0) {
        self.errorMessage = @"编译项目出错，详见日志！";
        return NO;
    }
    return YES;
}

@end
