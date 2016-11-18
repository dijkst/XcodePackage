//
//  MYPackageCreateSpecTask.m
//  Package
//
//  Created by Whirlwind on 15/5/6.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageCreateSpecTask.h"

static NSArray *blackKeys;
static NSArray *ignoreResources;

@implementation MYPackageCreateSpecTask

- (instancetype)init {
    if (self = [super init]) {
        if (!blackKeys) {
            blackKeys = @[@"version", @"authors", @"source", @"prepare_command", @"platforms", @"requires_arc", @"compiler_flags", @"pod_target_xcconfig", @"prefix_header_contents", @"prefix_header_file", @"module_name", @"header_dir", @"header_mappings_dir", @"source_files", @"resource_bundles", @"resources", @"exclude_files", @"preserve_paths", @"module_map", @"subspecs"];
        }
        if (!ignoreResources) {
            ignoreResources = @[@"Headers", @"PrivateHeaders", @"Modules", @"Versions", @"_CodeSignature"];
        }
    }
    return self;
}

- (NSString *)name {
    return @"创建 Spec";
}

- (NSArray *)filterArguments:(NSArray *)array needQuote:(BOOL)quote {
    if (!array) {
        return nil;
    }
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSString *argu in array) {
        // 排除 -Wall 等警告标记符
        if ([argu hasPrefix:@"-W"]) {
            continue;
        }
        // 排除继承
        if ([argu isEqualToString:@"$(inherited)"]) {
            continue;
        }
        if ([argu length] > 0) {
            if (quote) {
                if ([argu hasPrefix:@"\""] && [argu hasSuffix:@"\""]) {
                    [ret addObject:argu];
                } else {
                    [ret addObject:[NSString stringWithFormat:@"\"%@\"", argu]];
                }
            } else {
                [ret addObject:argu];
            }
        }
    }
    return ret;
}

- (void)setXcconfig:(NSDictionary *)xcconfig key:(NSString *)key toDictionary:(NSMutableDictionary *)dic isPath:(BOOL)isPath {
    id argu = [xcconfig objectForKey:key];
    if (!argu) {
        return;
    }
    NSArray *argus = [argu isKindOfClass:[NSArray class]] ? argu : @[argu];
    argus = [self filterArguments:argus needQuote:isPath];
    if ([argus count] > 0) {
        [dic setObject:[argus componentsJoinedByString:@" "] forKey:key];
    }
}

- (NSMutableDictionary *)dictionaryForTarget:(MYPackageTarget *)target {
    NSMutableDictionary *spec = [NSMutableDictionary dictionaryWithObject:target.name forKey:@"name"];

    NSMutableArray *frameworks = [NSMutableArray array];
    NSMutableArray *resources  = [NSMutableArray array];
    NSMutableArray *excludes   = [NSMutableArray array];
    NSFileManager  *fm         = [NSFileManager defaultManager];

    // 判断是否是链接库
    if ([target isSharedLibrary]) {
        if ([target.wrapperExtension isEqualToString:@"framework"]) {
            [frameworks addObject:target.fullProductName];
        } else {
            [spec setObject:[NSMutableArray arrayWithObject:target.fullProductName]
                     forKey:@"vendored_libraries"];
        }
        [spec setObject:@{target.supportedPlatform:target.systemMinVersion} forKey:@"platforms"];

        // 判断是否有资源文件
        NSString *infoPath = [self.config.lipoDir stringByAppendingPathComponent:target.resourcePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
            [resources addObject:[target.resourcePath stringByAppendingPathComponent:@"*"]];
        }
    } else {
        if (![target.wrapperExtension isEqualToString:@"framework"]) {
            [spec setObject:target.fullProductName forKey:@"resources"];
        }
    }

    // 本地 framework
    [target.localFrameworks enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *path, BOOL *_Nonnull stop) {
        [frameworks addObject:key];
        NSString *fileName = [key stringByDeletingPathExtension];
        if ([fm fileExistsAtPath:path]) {
            if ([self executeCommand:[NSString stringWithFormat:@"file '%@/%@'", path, fileName]]) {
                // 动态库不复制资源
                if ([self.output indexOfObject:@"dynamically linked shared"] != NSNotFound) {
                    return;
                }
            }
            BOOL isDirectory;
            NSString *resource = [path stringByAppendingPathComponent:@"Resources"];
            if ([fm fileExistsAtPath:resource isDirectory:&isDirectory] && isDirectory) {
                [resources addObject:[[key stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:@"*"]];
            } else {
                [resources addObject:[key stringByAppendingPathComponent:@"*"]];
                [excludes addObject:[NSString stringWithFormat:@"%@/%@", key, fileName]];
                for (NSString *name in ignoreResources) {
                    [excludes addObject:[NSString stringWithFormat:@"%@/%@", key, name]];
                }
            }
        }
    }];

    if ([frameworks count] > 0) {
        [spec setObject:frameworks forKey:@"vendored_frameworks"];
    }
    if ([resources count] > 0) {
        [spec setObject:resources forKey:@"resources"];
    }
    if ([excludes count] > 0) {
        [excludes addObject:@".DS_Store"];
        [excludes addObject:@"Info.plist"];
        [spec setObject:excludes forKey:@"exclude_files"];
    }

    // 判断是否有头文件
    NSString *headerPath = [self.config.lipoDir stringByAppendingPathComponent:target.publicHeaderPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:headerPath]) {
        [spec setObject:[target.publicHeaderPath stringByAppendingPathComponent:@"*"] forKey:@"source_files"];
    }

    MYPackageTarget *demoTarget = [target.project demoTargetForName:target.name];
    if (demoTarget) {
        // 取 frameworks
        if ([demoTarget.frameworks count] > 0) {
            [spec setObject:demoTarget.frameworks forKey:@"frameworks"];
        }
        // 取 libraries
        if ([demoTarget.libraries count] > 0) {
            [spec setObject:demoTarget.libraries forKey:@"libraries"];
        }

        // 取 xcconfig 中的 Header Search Path
        NSMutableDictionary *xcconfig = [NSMutableDictionary dictionary];
        [self setXcconfig:demoTarget.userBuildSettings key:@"HEADER_SEARCH_PATHS" toDictionary:xcconfig isPath:YES];
        [self setXcconfig:demoTarget.userBuildSettings key:@"OTHER_LDFLAGS" toDictionary:xcconfig isPath:NO];
        [self setXcconfig:demoTarget.userBuildSettings key:@"OTHER_CFLAGS" toDictionary:xcconfig isPath:NO];
        if ([xcconfig count] > 0) {
            [spec setObject:xcconfig forKey:@"xcconfig"];
        }
    }
    return spec;
}

- (NSString *)searchUserSpec {
    if ([self executeCommand:@"git rev-parse --show-toplevel" inWorkingDirectory:self.config.selectedScheme.container ? : self.config.workspace.path] != 0) {
        self.errorMessage = @"获取 Git 根目录失败！";
        return nil;
    }
    NSMutableArray *dirs = [NSMutableArray arrayWithObject:self.output];
    if (![self.config.workspace.path isEqualToString:self.output]) {
        [dirs addObject:self.config.workspace.path];
    }
    NSMutableArray *fileNames = [NSMutableArray arrayWithCapacity:2];
    [fileNames addObject:[NSString stringWithFormat:@"%@.podspec.json", self.config.podName]];
    [fileNames addObject:[NSString stringWithFormat:@"%@.podspec", self.config.podName]];
    for (NSString *dir in dirs) {
        for (NSString *fileName in fileNames) {
            NSString *path = [dir stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [self.config.logger logN:@"<INFO> 找到 %@ 文件！", path];
                return path;
            } else {
                [self.config.logger logN:@"<INFO> 未找到 %@ 文件！", path];
            }
        }
    }
    [self.config.logger logN:@"<INFO> 未找到任何 podspec 文件，跳过！"];
    return nil;
}

- (void)mergeSpecDictionariy:(NSMutableDictionary *)spec withValue:(id)value forKey:(NSString *)key {
    if (!value) return;
    if ([value isKindOfClass:[NSArray class]]) {
        if ([value count] == 0) return;
        NSMutableArray *v = [spec objectForKey:key];
        if (v) {
            if ([v isKindOfClass:[NSArray class]]) {
                v = [v mutableCopy];
                [spec setObject:v forKey:key];
            }
            [v addObjectsFromArray:value];
            v = [[v valueForKeyPath:@"@distinctUnionOfObjects.self"] mutableCopy];
        } else {
            v = [value mutableCopy];
        }
        [spec setObject:v forKey:key];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        if ([value count] == 0) return;
        NSMutableDictionary *v = [spec objectForKey:key];
        if (v) {
            if ([v isKindOfClass:[NSDictionary class]]) {
                v = [v mutableCopy];
                [spec setObject:v forKey:key];
            }
            [v setValuesForKeysWithDictionary:value];
        } else {
            v = [value mutableCopy];
        }
        [spec setObject:v forKey:key];
    } else if ([value isKindOfClass:[NSString class]]) {
        if ([value length] == 0) return;
        [spec setObject:value forKey:key];
    }
}

- (void)mergeSpecDictionariy:(NSMutableDictionary *)spec withDictionary:(NSDictionary *)dict {
    [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if ([blackKeys indexOfObject:key] == NSNotFound) {
            [self mergeSpecDictionariy:spec withValue:obj forKey:key];
        }
    }];
}

- (NSDictionary *)readUserSpec:(NSString *)path {
    NSData   *data      = nil;
    NSString *extension = [[path pathExtension] lowercaseString];
    if ([extension isEqualToString:@"json"]) {
        data = [NSData dataWithContentsOfFile:path];
    } else if ([extension isEqualToString:@"podspec"]) {
        if ([self executeCommand:[NSString stringWithFormat:@"bundle exec pod ipc spec '%@'", path]] != 0) {
            self.errorMessage = [NSString stringWithFormat:@"分析 %@ 文件失败：%@", path, self.shellTask.errorString];
            return nil;
        }
        data = self.shellTask.outputData;
    }
    NSError      *error;
    NSDictionary *userSpec = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
    if (error) {
        self.errorMessage = [NSString stringWithFormat:@"JSON 格式非法: %@", [error localizedDescription]];
        return nil;
    }
    return userSpec;
}

- (BOOL)applyUserSpecTo:(NSMutableDictionary *)spec {
    NSString *path = [self searchUserSpec];
    if (!path) {
        return YES;
    }
    NSDictionary *userSpec = [self readUserSpec:path];
    if (!userSpec) {
        return NO;
    }

    [self mergeSpecDictionariy:spec withDictionary:userSpec];
    NSArray *subspec = [spec objectForKey:@"subspecs"];

    for (NSDictionary *userSubspec in [userSpec objectForKey:@"subspecs"]) {
        NSString *name = [userSubspec objectForKey:@"name"];
        for (NSMutableDictionary *subspec1 in subspec) {
            if ([[subspec1 objectForKey:@"name"] isEqualToString:name]) {
                [self mergeSpecDictionariy:subspec1 withDictionary:userSubspec];
                break;
            }
        }
    }
    return YES;
}

- (BOOL)saveSpec:(NSDictionary *)spec {
    NSError *error;
    NSData  *data = [NSJSONSerialization dataWithJSONObject:spec options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        self.errorMessage = [NSString stringWithFormat:@"Convert to JSONString failed! Object: %@", spec];
        return NO;
    } else {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.config.logger logN:@"Saving spec.json to %@ :", self.config.specPath];
        [self.config.logger logN:string];
        return [string writeToFile:self.config.specPath
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:&error];
    }
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    NSDictionary *defaultSpec = @{
                                  @"version": self.config.version,
                                  @"authors": @{self.config.authorName: self.config.authorEmail},
                                  @"homepage": self.config.homePage ? : @"",
                                  @"description": self.config.podName,
                                  @"source": @{@"http": self.config.zipUrl}
                                  };
    NSMutableDictionary        *specDic = [NSMutableDictionary dictionaryWithDictionary:defaultSpec];
    NSArray<MYPackageTarget *> *targets = self.config.selectedScheme.targets;
    if ([targets count] == 1) {
        [specDic addEntriesFromDictionary:[self dictionaryForTarget:targets[0]]];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[targets count]];
        for (MYPackageTarget *target in targets) {
            [array addObject:[self dictionaryForTarget:target]];
        }
        [specDic setObject:array forKey:@"subspecs"];
    }
    [specDic setObject:self.config.podName forKey:@"name"];
    [self applyUserSpecTo:specDic];

    if (![specDic objectForKey:@"license"]) {
        [specDic setObject:@"MIT" forKey:@"license"];
    }

    if (self.config.gitUrl && self.config.commitHash) {
        [specDic setObject:@{@"git": self.config.gitUrl,
                             @"commit": self.config.commitHash}
                    forKey:@"source_code"];
    }

    return [self saveSpec:specDic];
}

@end
