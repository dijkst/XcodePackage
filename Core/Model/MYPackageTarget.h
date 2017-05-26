//
//  MYPackageTarget.h
//  Package
//
//  Created by Whirlwind on 15/5/7.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

@import Foundation;
#import "MYPackageTargetDefine.h"

@class MYPackageProject;

@interface MYPackageTarget : NSObject

@property (nonatomic, weak) MYPackageProject *project;

@property (nonatomic, copy) NSString *name;

/// 项目中的配置，存在配置变量
@property (nonatomic, strong) NSDictionary *userConfigrations;
@property (nonatomic, strong) NSDictionary *userBuildSettings;


@property (nonatomic, strong) NSArray *libraries;
@property (nonatomic, strong) NSArray *frameworks;

// 本地链接的 framework，因为 XCode 不会将 framework link 到静态库中
@property (nonatomic, strong) NSDictionary *localFrameworks;

/// 输出的最终 Configurations，变量被解析了
@property (nonatomic, strong) NSDictionary *configurations;

@property (nonatomic, readonly) NSArray<NSString *> *resources;

@property (nonatomic, readonly) NSString *bundleId;
@property (nonatomic, readonly) NSString *wrapperExtension;
@property (nonatomic, readonly) NSString *productName;
@property (nonatomic, readonly) NSString *fullProductName;
@property (nonatomic, readonly) NSString *binaryPath;
@property (nonatomic, readonly) NSString *originInfoPlistPath;
@property (nonatomic, readonly) NSString *infoPlistPath;

@property (nonatomic, strong)   NSString *resourcePath;
@property (nonatomic, readonly) NSString *publicHeaderPath;

@property (nonatomic, readonly) NSString *sdkName;
@property (nonatomic, readonly) MYPackageTargetPlatformType sdk;
@property (nonatomic, readonly) MYPackageTargetPlatformSubType sdkEnv;

@property (nonatomic, readonly) BOOL needLipo;

@property (nonatomic, readonly) NSString *platformName;
@property (nonatomic, readonly) NSString *platformMinVersion;

@property (nonatomic, readonly) MYPackageTargetType type;
- (BOOL)isSharedLibrary;

@property (nonatomic, readonly) NSString *zipFileName;

- (id)initWithName:(NSString *)name;
- (NSString *)configurationForKey:(NSString *)key;

@end
