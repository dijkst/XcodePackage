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
    [fm removeItemAtPath:self.config.productsDir
                   error:nil];
    [fm createDirectoryAtPath:self.config.productsDir
  withIntermediateDirectories:YES
                   attributes:nil
                        error:nil];
    
    [[self.config.selectedScheme targets] enumerateObjectsUsingBlock:^(MYPackageTarget *_Nonnull target, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *fromPath = [[self.config devicePathForTarget:target] stringByAppendingPathComponent:target.fullProductName];
        NSString *toPath = [[self.config productPathForTarget:target] stringByAppendingPathComponent:target.fullProductName];
        if ((target.sdkEnv & MYPackageTargetPlatformSubTypeDevice) == 0) {
            fromPath = [[self.config simulatorPathForTarget:target] stringByAppendingPathComponent:target.fullProductName];
        }
        [self moveResourceFilesToFolder:target productPath:fromPath];
        if (!target.needLipo) {
            [self.config.logger logN:@"cp %@ %@", [fromPath substringFromIndex:self.config.outputDir.length + 1], [toPath substringFromIndex:self.config.outputDir.length + 1]];
            if (![fm copyItemAtPath:fromPath
                             toPath:toPath
                              error:&error]) {
                self.errorMessage = [error localizedDescription];
                *stop = YES;
            }
        }
    }];

    if (self.errorMessage) {
        return NO;
    }
    self.workingDirectory = self.config.outputDir;
    NSString *shellPath = [self scriptForName:@"lipo" ofType:@"sh"];
    if ([self executeCommand:[NSString stringWithFormat:@"\"%@\"", shellPath]] != 0) {
        self.errorMessage = @"合并通用二进制出错，详见日志！";
        return NO;
    }
    return YES;
}

- (void)moveResourceFilesToFolder:(MYPackageTarget *)target productPath:(NSString *)productPath {
    if (target.type != MYPackageTargetTypeStaticLibrary) {
        // 只有静态库需要移动资源到 Resources 目录
        return;
    }
    if (![target.wrapperExtension isEqualToString:@"framework"]) {
        // 只有 Framework 才有 Resources 目录
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *resourcePath = [productPath stringByAppendingPathComponent:@"Resources"];
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

    NSString *oldResourcePath = [productPath stringByAppendingPathComponent:[target.resourcePath substringFromIndex:target.fullProductName.length + 1]];
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
