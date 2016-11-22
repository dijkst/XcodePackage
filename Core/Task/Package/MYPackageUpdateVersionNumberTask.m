//
//  MYPackageUpdateVersionNumberTask.m
//  Package
//
//  Created by Whirlwind on 15/10/27.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageUpdateVersionNumberTask.h"

@implementation MYPackageUpdateVersionNumberTask

- (NSString *)name {
    return @"更新版本号";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSString *version = self.config.version;
    if (version.length == 0) {
        self.errorMessage = @"无法读取版本号！";
        return NO;
    }
    if (![[self.config.version lowercaseString] hasSuffix:@"-snapshot"]) {
        // Tag 是否存在
        int status = [self executeCommand:[NSString stringWithFormat:@"git ls-remote --tags 2>&1 | grep \"refs/tags/%@^{}$\"", self.version] inWorkingDirectory:self.config.workspace.path];
        if (status > 1) {
            self.errorMessage = @"查询 Tag 是否存在失败!";
            return NO;
        }
        if (status == 0 && ![self.shellTask.outputString isEqualToString:[NSString stringWithFormat:@"%@\trefs/tags/%@^{}", self.config.commitHash, self.version]]) {
            self.errorMessage = @"Tag 已存在且 Hash 与当前 Commit 不同！";
            [self.config.logger logN:@"本地 Hash: %@", self.config.commitHash];
            return NO;
        }
    }

    NSArray<MYPackageTarget *> *targets = self.config.selectedScheme.targets;
    [targets enumerateObjectsUsingBlock:^(MYPackageTarget *_Nonnull target, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *infoPath = [self.config.lipoDir stringByAppendingPathComponent:target.infoPlistPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
            [self.config.logger logN:[NSString stringWithFormat:@"<INFO> Info.plist 不存在，跳过！ %@", infoPath]];
            return;
        }
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
        if (!info) {
            [self.config.logger logN:[NSString stringWithFormat:@"<INFO> 读取 Info.plist 失败，跳过！ %@", infoPath]];
            return;
        }
        NSString *ver = [info objectForKey:@"CFBundleShortVersionString"];
        if ([ver isEqualToString:version]) {
            return;
        }
        NSMutableDictionary *newInfo = [info mutableCopy];
        [newInfo setValue:version forKey:@"CFBundleShortVersionString"];
        if (![newInfo writeToFile:infoPath atomically:YES]) {
            self.errorMessage = [NSString stringWithFormat:@"更新 %@ 版本号失败!", target];
            return;
        }
    }];
    return YES;
}

- (NSString *)version {
    if ([self.config.version hasPrefix:@"v"]) {
        return self.config.version;
    }
    return [@"v" stringByAppendingString:self.config.version];
}

@end
