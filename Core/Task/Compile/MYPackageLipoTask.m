//
//  MYPackageLipoTask.m
//  Package
//
//  Created by Whirlwind on 16/3/14.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageLipoTask.h"

@implementation MYPackageLipoTask

- (NSString *)name {
    return @"合并通用二进制";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    __block NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.config.lipoDir
                   error:nil];
    [fm createDirectoryAtPath:self.config.lipoDir
  withIntermediateDirectories:YES
                   attributes:nil
                        error:nil];
    
    [[self.config.selectedScheme targetsForType:MYPackageTargetTypeBundle] enumerateObjectsUsingBlock:^(MYPackageTarget *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self.config.logger logN:@"cp %@ %@", [@"iphoneos" stringByAppendingPathComponent:obj.fullProductName], [@"lipo" stringByAppendingPathComponent:obj.fullProductName]];
        if (![fm copyItemAtPath:[[self.config.outputDir stringByAppendingPathComponent:@"iphoneos"] stringByAppendingPathComponent:obj.fullProductName]
                         toPath:[self.config.lipoDir stringByAppendingPathComponent:obj.fullProductName]
                          error:&error]) {
            self.errorMessage = [error localizedDescription];
            *stop = YES;
        }
    }];

    if (self.errorMessage) {
        return NO;
    }

    NSMutableArray *names = [NSMutableArray array];
    for (MYPackageTarget *target in self.config.selectedScheme.libraryTargets) {
        [names addObject:[NSString stringWithFormat:@"'%@'", target.fullProductName]];
    }
    if ([names count] > 0) {
        self.workingDirectory = self.config.outputDir;
        NSString *shellPath = [self scriptForName:@"lipo" ofType:@"sh"];
        if ([self executeCommand:[NSString stringWithFormat:@"'%@' %@",
                                  shellPath,
                                  [names componentsJoinedByString:@" "]
                                  ]] != 0) {
            self.errorMessage = @"合并通用二进制出错，详见日志！";
            return NO;
        }
    }
    return YES;
}

@end
