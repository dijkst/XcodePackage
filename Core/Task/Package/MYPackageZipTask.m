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
    NSString *zipDir = self.config.zipDir;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError       *error       = nil;

    [fileManager removeItemAtPath:self.config.largeZipPath error:&error];
    [fileManager removeItemAtPath:zipDir error:&error];

    NSMutableArray *files = [NSMutableArray array];
    for (MYPackageTarget *target in self.config.selectedScheme.targets) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self.config.lipoDir stringByAppendingPathComponent:target.fullProductName]]) {
            self.errorMessage = [NSString stringWithFormat:@"输出结果 %@ 不存在！", target.fullProductName];
            return NO;
        }
        [files addObject:target.fullProductName];

        // 复制本地链接的 Framework
        for (NSString *path in [target.localFrameworks allValues]) {
            if (![fileManager fileExistsAtPath:path]) {
                self.errorMessage = [NSString stringWithFormat:@"链接的本地 Framework 不存在：%@", path];
                return NO;
            }
            NSString *toPath = [self.config.lipoDir stringByAppendingPathComponent:[path lastPathComponent]];
            [self.config.logger logN:@"cp '%@' '%@'", path, toPath];
            [fileManager removeItemAtPath:toPath error:nil];
            if (![fileManager copyItemAtPath:path
                                      toPath:toPath
                                       error:&error]) {
                self.errorMessage = [error localizedDescription];
                return NO;
            }
            [files addObject:[path lastPathComponent]];
        }
    }
    NSMutableString *zipCmd = [NSMutableString stringWithFormat:@"zip -r -X '%@' ", self.config.largeZipPath];
    for (NSString *file in [files valueForKeyPath:@"@distinctUnionOfObjects.self"]) {
        [zipCmd appendFormat:@"'%@' ", file];
    }
    [zipCmd appendString:@"-x \"*.DS_Store\""];

    if ([self executeCommand:zipCmd inWorkingDirectory:self.config.lipoDir] != 0) {
        self.errorMessage = [NSString stringWithFormat:@"打包 %@ 失败！", [self.config.largeZipPath substringFromIndex:[self.config.outputDir length]]];
        return NO;
    }
    return YES;
}

@end
