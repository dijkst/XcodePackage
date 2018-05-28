//
//  MYPackageZipTask.m
//  Package
//
//  Created by Whirlwind on 15/5/6.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageZipTask.h"

@implementation MYPackageZipTask

- (NSString *)name {
    return @"打包压缩";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError       *error       = nil;

    [fileManager createDirectoryAtPath:self.config.productsDir withIntermediateDirectories:YES attributes:nil error:nil];

    [fileManager removeItemAtPath:self.config.bundlePath error:&error];

    for (MYPackageTarget *target in self.config.selectedScheme.targets) {
        NSString *productDir = [self.config productPathForTarget:target];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[productDir stringByAppendingPathComponent:target.fullProductName]]) {
            self.errorMessage = [NSString stringWithFormat:@"输出结果 %@ 不存在！", target.fullProductName];
            return NO;
        }

        // 复制本地链接的 Framework
        for (NSString *path in [target.localFrameworks allValues]) {
            if (![fileManager fileExistsAtPath:path]) {
                self.errorMessage = [NSString stringWithFormat:@"链接的本地 Framework 不存在：%@", path];
                return NO;
            }
            NSString *toPath = [productDir stringByAppendingPathComponent:[path lastPathComponent]];
            [self.config.logger logN:@"cp '%@' '%@'", path, toPath];
            [fileManager removeItemAtPath:toPath error:nil];
            if (![fileManager copyItemAtPath:path
                                      toPath:toPath
                                       error:&error]) {
                self.errorMessage = [error localizedDescription];
                return NO;
            }
        }
    }
    NSString *zipCmd = [NSString stringWithFormat:@"zip -r -X '%@' * -x \"*.DS_Store\"", self.config.bundlePath];

    if ([self executeCommand:zipCmd inWorkingDirectory:self.config.productsDir] != 0) {
        self.errorMessage = [NSString stringWithFormat:@"打包 %@ 失败！", [self.config.bundlePath substringFromIndex:[self.config.outputDir length]]];
        return NO;
    }
    return YES;
}

@end
