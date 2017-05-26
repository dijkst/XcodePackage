//
//  MYPackageCreateSpecTask.m
//  Package
//
//  Created by Whirlwind on 15/5/6.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageCreateSpecTask.h"

static NSArray *blackKeys;

@implementation MYPackageCreateSpecTask

- (instancetype)init {
    if (self = [super init]) {
        if (!blackKeys) {
            blackKeys = @[@"version", @"authors", @"source", @"prepare_command", @"platforms", @"requires_arc", @"compiler_flags", @"pod_target_xcconfig", @"prefix_header_contents", @"prefix_header_file", @"module_name", @"header_dir", @"header_mappings_dir", @"source_files", @"resource_bundles", @"resources", @"exclude_files", @"preserve_paths", @"module_map", @"subspecs"];
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

    NSMutableDictionary *dynamticallyFrameworks = [NSMutableDictionary dictionary];
    NSMutableDictionary *staticFrameworks = [NSMutableDictionary dictionary];

    NSMutableArray *libraries  = [NSMutableArray array];
    NSMutableArray *resources  = [NSMutableArray array];
    NSMutableArray *headers    = [NSMutableArray array];
    NSFileManager  *fm         = [NSFileManager defaultManager];

    NSString *productPath = [target.sdkName stringByAppendingPathComponent:target.fullProductName];

    // 判断是否是链接库
    if ([target isSharedLibrary]) {
        if ([target.wrapperExtension isEqualToString:@"framework"]) {
            NSMutableDictionary *frameworks = target.type == MYPackageTargetTypeDynamicLibrary ? dynamticallyFrameworks : staticFrameworks;
            [frameworks setObject:[[self.config productPathForTarget:target] stringByAppendingPathComponent:target.fullProductName]
                           forKey:productPath];
        } else {
            [libraries addObject:productPath];
        }
        [spec setObject:@{target.platformName: target.platformMinVersion}
                 forKey:@"platforms"];
    } else {
        // .bundle
        // Service 模式使用的是 Bundle 模版，
        // 但是实际上是一个空的 Framework
        if ([target.wrapperExtension isEqualToString:@"framework"]) {
            // 头文件路径
            NSString *headerPath = [[[self.config productPathForTarget:target] stringByAppendingPathComponent:target.fullProductName] stringByAppendingPathComponent:@"Headers"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:headerPath]) {
                [headers addObject:[productPath stringByAppendingPathComponent:@"Headers/*"]];
            }
        } else {
            [spec setObject:productPath forKey:@"resources"];
        }
    }

    // 本地 framework
    [target.localFrameworks enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *path, BOOL *_Nonnull stop) {
        NSString *fileName = [key stringByDeletingPathExtension];
        if ([fm fileExistsAtPath:path]) {
            if ([self executeCommand:[NSString stringWithFormat:@"file '%@/%@'", path, fileName]] == 0) {
                NSMutableDictionary *frameworks = nil;
                if ([self.output rangeOfString:@"dynamically linked shared"].location != NSNotFound) {
                    frameworks = dynamticallyFrameworks;
                } else {
                    frameworks = staticFrameworks;
                }
                [frameworks setObject:path forKey:key];
            }
        }
    }];

    [staticFrameworks enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *path, BOOL *stop) {
        BOOL isDirectory;

        // 获取资源路径
        if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:@"Resources"]
                     isDirectory:&isDirectory] && isDirectory) {
            // 存在 Resources 目录则直接使用该目录
            [resources addObject:[[key stringByAppendingPathComponent:@"Resources"] stringByAppendingPathComponent:@"*"]];
        } else {
            // 不再支持无 Resources 的情况
        }

        // 头文件路径
        NSString *headerPath = [path stringByAppendingPathComponent:@"Headers"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:headerPath]) {
            [headers addObject:[key stringByAppendingPathComponent:@"Headers/*"]];
        }
    }];

    NSArray *frameworks = [[dynamticallyFrameworks allKeys] arrayByAddingObjectsFromArray:[staticFrameworks allKeys]];
    if ([frameworks count] > 0) {
        [spec setObject:frameworks forKey:@"vendored_frameworks"];
    }
    if ([libraries count] > 0) {
        [spec setObject:libraries forKey:@"vendored_libraries"];
    }
    if ([headers count] > 0) {
        [spec setObject:headers forKey:@"source_files"];
    }
    if ([resources count] > 0) {
        [spec setObject:resources forKey:@"resources"];
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
    [fileNames addObject:[NSString stringWithFormat:@"%@.podspec.json", self.config.name]];
    [fileNames addObject:[NSString stringWithFormat:@"%@.podspec", self.config.name]];
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
                                  @"description": self.config.name,
                                  @"source": @{@"http": self.config.downloadUrl,
                                               @"sha1": self.config.bundleHash?:@""}
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
    [specDic setObject:self.config.name forKey:@"name"];
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
