//
//  MYPackageTargetDefine.m
//  Package
//
//  Created by Whirlwind on 2017/5/15.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYPackageTargetDefine.h"

MYPackageTargetPlatformType SDKTypeForName(NSString *sdk) {
    if ([sdk rangeOfString:@"macosx"].location != NSNotFound) {
        return MYPackageTargetPlatformType_macOS;
    }
    if ([sdk rangeOfString:@"iphone"].location != NSNotFound) {
        return MYPackageTargetPlatformType_iOS;
    }
    if ([sdk rangeOfString:@"appletv"].location != NSNotFound) {
        return MYPackageTargetPlatformType_tvOS;
    }
    if ([sdk rangeOfString:@"watch"].location != NSNotFound) {
        return MYPackageTargetPlatformType_watchOS;
    }
    return MYPackageTargetPlatformType_iOS;
}

NSString *SDKNameForType(MYPackageTargetPlatformType type) {
    switch (type) {
        case MYPackageTargetPlatformType_iOS:
            return @"iphone";
        case MYPackageTargetPlatformType_macOS:
            return @"macosx";
        case MYPackageTargetPlatformType_tvOS:
            return @"appletv";
        case MYPackageTargetPlatformType_watchOS:
            return @"watch";
        default:
            return @"iphone";
    }
}

MYPackageTargetPlatformType platformTypeForName(NSString *platform) {
    if ([platform rangeOfString:@"macos"].location != NSNotFound) {
        return MYPackageTargetPlatformType_macOS;
    }
    if ([platform rangeOfString:@"ios"].location != NSNotFound) {
        return MYPackageTargetPlatformType_iOS;
    }
    if ([platform rangeOfString:@"tvos"].location != NSNotFound) {
        return MYPackageTargetPlatformType_tvOS;
    }
    if ([platform rangeOfString:@"watchos"].location != NSNotFound) {
        return MYPackageTargetPlatformType_watchOS;
    }
    return MYPackageTargetPlatformType_iOS;
}

NSString *platformNameForType(MYPackageTargetPlatformType type) {
    switch (type) {
        case MYPackageTargetPlatformType_iOS:
            return @"ios";
        case MYPackageTargetPlatformType_macOS:
            return @"macos";
        case MYPackageTargetPlatformType_tvOS:
            return @"tvos";
        case MYPackageTargetPlatformType_watchOS:
            return @"watchos";
        default:
            return @"ios";
    }
}
