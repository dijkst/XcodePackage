//
//  MYPackageResignAppTask.m
//  Package
//
//  Created by Whirlwind on 2017/2/7.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageResignAppTask.h"

@implementation MYPackageResignAppTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    if ([self.config.signType length] == 0 || [self.config.teamID length] == 0) {
        [self logInfo:@"未设置 signType 或者 teamId，不导出 IPA!"];
        return YES;
    }
    
    NSString *archivePath = [self.config.productsDir stringByAppendingPathComponent:@"archive.xcarchive"];

    NSDictionary *options = @{
                              @"method": self.config.signType,
                              @"teamID": self.config.teamID,
                              @"compileBitcode": @(NO)
                              };
    NSString *optionsPath = [self.config.productsDir stringByAppendingPathComponent:@"exportOptions.plist"];
    [options writeToFile:optionsPath atomically:YES];

    if ([self executeCommand:[NSString stringWithFormat:@"set -o pipefail && xcodebuild -archivePath \"%@\" -exportPath \"%@\" -exportOptionsPlist \"%@\" -exportArchive | bundle exec xcpretty",
                              archivePath,
                              self.config.productsDir,
                              optionsPath
                              ]] != 0) {
        self.errorMessage = @"编译项目出错，详见日志！";
        return NO;
    }
    return YES;
}

@end
