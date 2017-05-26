//
//  MYPackageTarget.m
//  Package
//
//  Created by Whirlwind on 15/5/7.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageTarget.h"
#import "MYPackageProject.h"


@interface MYPackageTarget ()

@end

@implementation MYPackageTarget
@synthesize resources = _resources;

- (id)initWithName:(NSString *)name {
    if (self = [super init]) {
        _name = name;
    }
    return self;
}

#pragma mark - user configurations
- (void)setUserConfigrations:(NSDictionary *)userConfigrations {
    _userConfigrations = userConfigrations;
    [self anlayzeTargetFrameworkPhases];
    self.userBuildSettings = [[self valueForKey:@"Release" inArray:self.userConfigrations[@"Build Configurations"]] objectForKey:@"Build Settings"];
}

- (id)valueForKey:(NSString *)key inArray:(NSArray *)array {
    for (NSDictionary *dic in array) {
        NSArray *allKeys = [dic allKeys];
        if ([allKeys count] > 0) {
            if ([allKeys[0] isEqualToString:key]) {
                return dic[key];
            }
        }
    }
    return nil;
}

- (NSArray *)resources {
    if (!_resources) {
        _resources = [self valueForKey:@"Resources" inArray:self.userConfigrations[@"Build Phases"]];
    }
    return _resources;
}

- (void)anlayzeTargetFrameworkPhases {
    NSArray        *frameworksBuildPhase = [self valueForKey:@"Frameworks" inArray:self.userConfigrations[@"Build Phases"]];
    NSString       *frameworkName        = [self.name hasSuffix:@"Demo"] ? [[self.name substringToIndex:[self.name length] - 4] stringByAppendingPathExtension:@"framework"] : nil;
    NSMutableArray *frameworks           = [NSMutableArray array];
    NSMutableArray *libraries            = [NSMutableArray array];
    for (id key in frameworksBuildPhase) {
        NSString *phase = nil;
        if ([key isKindOfClass:[NSString class]]) {
            phase = key;
        } else if ([key isKindOfClass:[NSDictionary class]]) {
            phase = [[key allKeys] objectAtIndex:0];
        } else {
            continue;
        }
        NSString *extension = [phase pathExtension];
        if ([extension isEqualToString:@"framework"]) {
            if (!frameworkName || ![phase isEqualToString:frameworkName]) {
                [frameworks addObject:[phase stringByDeletingPathExtension]];
            }
        } else if (([@[@"a", @"dylib", @"tbd"] indexOfObject:extension] != NSNotFound) && [phase hasPrefix:@"lib"]) {
            if (![phase hasPrefix:@"libPods"]) {
                [libraries addObject:[[phase stringByDeletingPathExtension] substringFromIndex:3]];
            }
        }
    }
    self.libraries  = libraries;
    self.frameworks = frameworks;

    // 只有动态库和静态库需要拷贝本地 framework
    if (self.type == MYPackageTargetTypeStaticLibrary || self.type == MYPackageTargetTypeDynamicLibrary) {
        NSMutableDictionary *local   = [NSMutableDictionary dictionaryWithCapacity:[self.frameworks count]];
        NSDictionary        *allFwks = self.project.info[@"Frameworks"];
        for (NSString *framework in self.frameworks) {
            NSString *path = [allFwks objectForKey:[framework stringByAppendingPathExtension:@"framework"]];
            if (path) {
                if ([path hasPrefix:@"/"]) {
                    if ([path rangeOfString:@"/usr/lib/"].location != NSNotFound || [path rangeOfString:@"/System/Library/Frameworks/"].location != NSNotFound) { // 系统库
                        continue;
                    }
                } else {
                    path = [[self.project.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:path];
                }
                BOOL isDirectory;
                if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
                    [local setObject:path forKey:[framework stringByAppendingPathExtension:@"framework"]];
                }
            }
        }
        self.localFrameworks = local;
    }
}

#pragma mark - configurations

- (void)setConfigurations:(NSDictionary *)configurations {
    _configurations = configurations;
    NSString *type = [configurations objectForKey:@"MACH_O_TYPE"];
    if ([type isEqualToString:@"staticlib"]) {
        _type = MYPackageTargetTypeStaticLibrary;
    } else if ([type isEqualToString:@"mh_execute"]) {
        _type = MYPackageTargetTypeExecutable;
    } else if ([type isEqualToString:@"mh_dylib"]) {
        _type = MYPackageTargetTypeDynamicLibrary;
    } else if ([type isEqualToString:@"mh_bundle"]) {
        _type = MYPackageTargetTypeBundle;
    } else if ([type isEqualToString:@"mh_object"]) {
        _type = MYPackageTargetTypeObjectFile;
    }
}

- (NSString *)configurationForKey:(NSString *)key {
    return [self.configurations objectForKey:key];
}

- (BOOL)isSharedLibrary {
    return (_type & (MYPackageTargetTypeDynamicLibrary|MYPackageTargetTypeObjectFile|MYPackageTargetTypeStaticLibrary)) > 0;
}

- (NSString *)bundleId {
    return [self configurationForKey:@"PRODUCT_BUNDLE_IDENTIFIER"];
}

- (NSString *)wrapperExtension {
    return [self configurationForKey:@"WRAPPER_EXTENSION"];
}

- (NSString *)productName {
    // like "testFramework"
    return [self configurationForKey:@"PRODUCT_NAME"];
}

- (NSString *)fullProductName {
    // like "testFramework.framework"
    return [self configurationForKey:@"FULL_PRODUCT_NAME"];
}

- (NSString *)originInfoPlistPath {
    // like "testFramework/Info.plist"
    // this is different with INFOPLIST_PATH
    return [self configurationForKey:@"INFOPLIST_FILE"];
}

- (NSString *)infoPlistPath {
    // like "testFramework.framework/Info.plist"
    return [self configurationForKey:@"INFOPLIST_PATH"];
}

- (NSString *)binaryPath {
    // like "testFramework.framework/testFramework"
    return [self configurationForKey:@"EXECUTABLE_PATH"];
}

- (NSString *)resourcePath {
    // like "testFramework.framework/Resources"
    if (!_resourcePath) {
        _resourcePath = [self configurationForKey:@"UNLOCALIZED_RESOURCES_FOLDER_PATH"];
    }
    return _resourcePath;
}

- (NSString *)publicHeaderPath {
    // like "testFramework.framework/Headers"
    return [self configurationForKey:@"PUBLIC_HEADERS_FOLDER_PATH"];
}

- (MYPackageTargetPlatformType)sdk {
    NSString *platform = [self configurationForKey:@"SDK_NAME"];
    return SDKTypeForName(platform);
}

- (NSString *)sdkName {
    return SDKNameForType(self.sdk);
}

- (MYPackageTargetPlatformSubType)sdkEnv {
    return MYPackageTargetPlatformSubTypeBoth;
}

- (BOOL)needLipo {
    if (![self isSharedLibrary]) {
        return NO;
    }
    return self.sdkEnv == MYPackageTargetPlatformSubTypeBoth;
}

- (NSString *)platformName {
    return platformNameForType(self.sdk);
}

- (NSString *)platformMinVersion {
    MYPackageTargetPlatformType type = self.sdk;
    if (type == MYPackageTargetPlatformType_macOS) {
        return [self configurationForKey:@"MACOSX_DEPLOYMENT_TARGET"];
    }
    if (type == MYPackageTargetPlatformType_watchOS) {
        return [self configurationForKey:@"WATCHOS_DEPLOYMENT_TARGET"];
    }
    if (type == MYPackageTargetPlatformType_iOS) {
        return [self configurationForKey:@"IPHONEOS_DEPLOYMENT_TARGET"];
    }
    if (type == MYPackageTargetPlatformType_tvOS) {
        return [self configurationForKey:@"WATCHOS_DEPLOYMENT_TARGET"];
    }
    return @"";
}

- (NSString *)zipFileName {
    return [self.name stringByAppendingString:@".zip"];
}

@end
