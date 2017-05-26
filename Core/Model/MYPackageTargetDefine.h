//
//  MYPackageTargetDefine.h
//  Package
//
//  Created by Whirlwind on 2017/5/15.
//  Copyright © 2017年 taobao. All rights reserved.
//

#ifndef MYPackageTargetDefine_h
#define MYPackageTargetDefine_h

typedef NS_OPTIONS (NSInteger, MYPackageTargetType) {
    MYPackageTargetTypeUnknown            = 0,
    MYPackageTargetTypeStaticLibrary      = 1,
    MYPackageTargetTypeExecutable         = 1 << 1,
    MYPackageTargetTypeDynamicLibrary = 1 << 2,
    MYPackageTargetTypeBundle         = 1 << 3,
    MYPackageTargetTypeObjectFile     = 1 << 4
};

typedef NS_ENUM (NSInteger, MYPackageTargetPlatformType) {
    MYPackageTargetPlatformType_iOS = 1 << 0,
    MYPackageTargetPlatformType_macOS = 1 << 1,
    MYPackageTargetPlatformType_watchOS = 1 << 2,
    MYPackageTargetPlatformType_tvOS = 1 << 3
};

typedef NS_OPTIONS (NSInteger, MYPackageTargetPlatformSubType) {
    MYPackageTargetPlatformSubTypeDevice    = 1 << 0,
    MYPackageTargetPlatformSubTypeSimulator = 1 << 1,
    MYPackageTargetPlatformSubTypeBoth      = MYPackageTargetPlatformSubTypeDevice | MYPackageTargetPlatformSubTypeSimulator
};

MYPackageTargetPlatformType SDKTypeForName(NSString *platform);
NSString *SDKNameForType(MYPackageTargetPlatformType type);

MYPackageTargetPlatformType platformTypeForName(NSString *platform);
NSString *platformNameForType(MYPackageTargetPlatformType type);


#endif /* MYPackageTargetDefine_h */
