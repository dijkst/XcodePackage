//
//  MYPackageCleanTask.m
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageCleanTask.h"

@implementation MYPackageCleanTask

- (NSString *)name {
    return @"清理编译环境";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSString *cmd = [NSString stringWithFormat:@"set -o pipefail && xcodebuild clean %@ '%@' -scheme '%@' -configuration '%@' | bundle exec xcpretty", PathIsWorkspace(self.config.workspace.filePath) ? @"-workspace" : @"-project", self.config.workspace.filePath, self.config.selectedSchemeName, self.config.configruation];
    if ([self executeCommand:cmd] != 0) {
        self.errorMessage = @"执行清理出错！";
        return NO;
    }
    NSError       *error;
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSArray       *files      = [fileManger contentsOfDirectoryAtPath:self.config.outputDir error:&error];
    if (files == nil) {
        self.errorMessage = [NSString stringWithFormat:@"List file failed: %@ %@", self.config.outputDir, error];
    }
    NSString *path;
    for (NSString *filename in files) {
        if (![filename isEqualToString:@"log"]) {
            path = [self.config.outputDir stringByAppendingPathComponent:filename];
            if (![fileManger removeItemAtPath:path error:&error]) {
                self.errorMessage = [NSString stringWithFormat:@"delete failed: %@ %@", path, [error description]];
                return NO;
            } else {
                [self.config.logger logN:@"delete %@", path];
            }
        }
    }
    return YES;
}

@end
