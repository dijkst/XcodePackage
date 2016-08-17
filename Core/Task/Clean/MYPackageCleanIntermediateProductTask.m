//
//  MYPackageCleanIntermediateProductTask.m
//  Package
//
//  Created by Whirlwind on 15/8/9.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageCleanIntermediateProductTask.h"

@implementation MYPackageCleanIntermediateProductTask

- (NSString *)name {
    return @"清理中间产物";
}

- (BOOL)launch {
    if (![super launch]) {
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
        if (![filename isEqualToString:@"lipo"] && ![filename isEqualToString:@"log"]) {
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
