//
//  MYPackageUpdatePlistTask.m
//  Package
//
//  Created by Whirlwind on 15/10/27.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageUpdatePlistTask.h"

@interface NSMutableDictionary (UpdateValue)

- (BOOL)updateString:(NSString *)string forKey:(id<NSCopying>)aKey;

@end

@implementation NSMutableDictionary (UpdateValue)

- (BOOL)updateString:(NSString *)string forKey:(id<NSCopying>)aKey {
    if (string.length == 0) {
        return NO;
    }
    if (![[self objectForKey:aKey] isEqualToString:string]) {
        NSLog(@"updating %@ \"%@\" -> \"%@\"", aKey, [self objectForKey:aKey], string);
        [self setObject:string forKey:aKey];
        return YES;
    }
    return NO;
}

@end

@interface NSString (Prefix)

- (NSString *)stringByReplacingPrefix:(NSString *)oldPrefix withString:(NSString *)newPrefix;

@end

@implementation NSString (Prefix)

- (NSString *)stringByReplacingPrefix:(NSString *)oldPrefix withString:(NSString *)newPrefix {
    if (!oldPrefix || ![self hasPrefix:oldPrefix]) {
        return self;
    }
    NSString *string = [self substringFromIndex:oldPrefix.length];
    return [newPrefix stringByAppendingString:string];
}

@end

@implementation MYPackageUpdatePlistTask

- (NSString *)name {
    return @"更新产品信息";
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

    if (self.config.appTarget) {
        [self updateAppsInFolder:[self.config.productsDir stringByAppendingPathComponent:@"archive.xcarchive/Products/Applications"]
                     displayName:self.config.displayName
                        bundleId:self.config.bundleId
                         version:self.config.version
               oriBundleIdPrefix:nil];
    } else {
        [self.config.selectedScheme.targets enumerateObjectsUsingBlock:^(MYPackageTarget *_Nonnull target, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString *productPath = [[self.config productPathForTarget:target] stringByAppendingPathComponent:target.fullProductName];
            [self updateBundle:productPath displayName:nil version:version bundleIdPrefix:nil oriBundleIdPrefix:nil];
        }];
    }
    return YES;
}

- (NSString *)version {
    if ([self.config.version hasPrefix:@"v"]) {
        return self.config.version;
    }
    return [@"v" stringByAppendingString:self.config.version];
}

- (BOOL)checkVersionValid {
    if (!self.config.selectedScheme.targets.firstObject.isSharedLibrary) {
        return YES;
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
    return YES;
}

- (void)updateAppsInFolder:(NSString *)path displayName:(NSString *)displayName bundleId:(NSString *)bundleId version:(NSString *)version oriBundleIdPrefix:(NSString *)oriBundleIdPrefix {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *bundlePath = [path stringByAppendingPathComponent:filename];
        if ([filename hasSuffix:@".app"] || [filename hasSuffix:@".appex"]) {
            NSString *oriPrefix = [self updateBundle:bundlePath
                                         displayName:displayName
                                             version:version
                                      bundleIdPrefix:bundleId
                                   oriBundleIdPrefix:oriBundleIdPrefix];
            [self updateAppsInFolder:[bundlePath stringByAppendingPathComponent:@"Watch"]
                         displayName:displayName
                            bundleId:bundleId
                             version:version
                   oriBundleIdPrefix:oriPrefix];
            [self updateAppsInFolder:[bundlePath stringByAppendingPathComponent:@"Plugins"]
                         displayName:displayName
                            bundleId:bundleId
                             version:version
                   oriBundleIdPrefix:oriPrefix];
        }
    }];
}

- (NSString *)updateBundle:(NSString *)path displayName:(NSString *)displayName version:(NSString *)version bundleIdPrefix:(NSString *)bundleIdPrefix oriBundleIdPrefix:(NSString *)oriBundleIdPrefix {
    NSString *infoPath = [path stringByAppendingPathComponent:@"Info.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
        [self.config.logger logN:[NSString stringWithFormat:@"<INFO> Info.plist 不存在，跳过！ %@", infoPath]];
        return nil;
    }
    NSLog(@"正在处理InfoPlist: %@", path);
    __block NSString *prefix;
    [self updatePlistFile:infoPath handler:^BOOL(NSMutableDictionary *plist) {
        NSString *oriBundleId = [plist objectForKey:@"CFBundleIdentifier"];
        BOOL updated = NO;
        if ([plist updateString:version forKey:@"CFBundleShortVersionString"]) {
            updated = YES;
        }
        if ([plist updateString:displayName forKey:@"CFBundleDisplayName"]) {
            updated = YES;
        }

        if (bundleIdPrefix) {
            NSString *newBundleId = nil;
            if (oriBundleIdPrefix) {
                newBundleId = [oriBundleId stringByReplacingPrefix:oriBundleIdPrefix withString:bundleIdPrefix];
            } else {
                newBundleId = bundleIdPrefix;
                prefix = oriBundleId;
            }
            if ([plist updateString:newBundleId forKey:@"CFBundleIdentifier"]) {
                updated = YES;
            }

            NSString *extensionBundleId = [plist valueForKeyPath:@"NSExtension.NSExtensionAttributes.WKAppBundleIdentifier"];
            extensionBundleId = [extensionBundleId stringByReplacingPrefix:oriBundleIdPrefix withString:bundleIdPrefix];
            if ([[plist valueForKeyPath:@"NSExtension.NSExtensionAttributes"] updateString:extensionBundleId forKey:@"WKAppBundleIdentifier"]) {
                updated = YES;
            }
        }
        return updated;
    }];
    return oriBundleIdPrefix ?: prefix;
}

- (void)updatePlistFile:(NSString *)path handler:(BOOL(^)(NSMutableDictionary *plist))handler {
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (error) {
        self.errorMessage = [NSString stringWithFormat:@"读取 %@ 失败! %@", [path lastPathComponent], [error localizedDescription]];
        return;
    }
    NSPropertyListFormat format;
    NSMutableDictionary *plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    if (error) {
        self.errorMessage = [NSString stringWithFormat:@"解析 %@ 失败! %@", [path lastPathComponent], [error localizedDescription]];
        return;
    }
    if (handler(plist)) {
        data = [NSPropertyListSerialization dataWithPropertyList:plist format:format options:0 error:&error];
        if (error) {
            self.errorMessage = [NSString stringWithFormat:@"序列号 %@ 失败! %@", [path lastPathComponent], [error localizedDescription]];
            return;
        }
        if (![data writeToFile:path atomically:YES]) {
            if (error) {
                self.errorMessage = [NSString stringWithFormat:@"写入 %@ 失败! %@", [path lastPathComponent], [error localizedDescription]];
            }
        }
    }
}

@end
