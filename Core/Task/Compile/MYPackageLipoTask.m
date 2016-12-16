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

    NSArray *libraryTargets = self.config.selectedScheme.libraryTargets;
    if ([libraryTargets count] > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (MYPackageTarget *target in libraryTargets) {
            if (target.needLipo) {
                [names addObject:[NSString stringWithFormat:@"'%@'", target.fullProductName]];
            }
            [self moveResourceFilesToFolder:target];
        }

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

- (void)moveResourceFilesToFolder:(MYPackageTarget *)target {
    if (target.type != MYPackageTargetTypeStaticLibrary) {
        // 只有静态库需要移动资源到 Resources 目录
        return;
    }
    if (![target.wrapperExtension isEqualToString:@"framework"]) {
        // 只有 Framework 才有 Resources 目录
        return;
    }
    NSString *sdk = target.sdkName;
    if (target.needLipo) {
        // 使用真机作为产物
        sdk = [sdk stringByAppendingString:@"os"];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *outputPath = [self.config.outputDir stringByAppendingPathComponent:sdk];
    NSString *resourcePath = [[outputPath stringByAppendingPathComponent:target.fullProductName] stringByAppendingPathComponent:@"Resources"];
    if ([[target.resourcePath lastPathComponent] isEqualToString:@"Resources"] || [fm fileExistsAtPath:resourcePath]) {
        return;
    }
    if ([target.resources count] == 0) {
        return;
    }

    [fm createDirectoryAtPath:resourcePath
  withIntermediateDirectories:YES
                   attributes:nil
                        error:nil];

    NSString *oldResourcePath = [outputPath stringByAppendingPathComponent:target.resourcePath];
    NSDictionary *compileMapper = @{@"storyboard": @"storyboardc",
                                    @"xib": @"nib",
                                    @"xcdatamodel": @"mom",
                                    @"xcdatamodeld": @"momd",
                                    @"xcmappingmodel": @"cdm",
                                    @"xcasset": @"car"};
    for (NSString *fileName in target.resources) {
        NSString *outFileName = fileName;

        // 部分资源编译后后缀发生变化
        NSString *extName = [compileMapper objectForKey:[fileName pathExtension]];
        if (extName) {
            outFileName = [[outFileName stringByDeletingPathExtension] stringByAppendingPathExtension:extName];
        }

        NSString *oldPath = [oldResourcePath stringByAppendingPathComponent:outFileName];
        if ([fm fileExistsAtPath:oldPath]) {
            [fm moveItemAtPath:oldPath
                        toPath:[resourcePath stringByAppendingPathComponent:outFileName]
                         error:nil];
        }
    }

    // 更新 target 的资源路径
    target.resourcePath = [target.fullProductName stringByAppendingPathComponent:@"Resources"];
}

@end
