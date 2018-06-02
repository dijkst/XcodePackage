//
//  MYPackageProfile.h
//  Package
//
//  Created by Whirlwind on 2017/2/8.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, MYPackageProfileType) {
    MYPackageProfileTypeDevelopment = 0,
    MYPackageProfileTypeEnterprise  = 1,
    MYPackageProfileTypeAdhoc       = 2,
    MYPackageProfileTypeAppStore    = 3,
};

NSString *profileTypeNameForType(MYPackageProfileType type);

@interface MYPackageProfile : NSObject

@property (nonatomic, strong) NSString *AppIDName;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *UUID;

@property (nonatomic, strong) NSArray *ApplicationIdentifierPrefix;
@property (nonatomic, strong) NSArray *TeamIdentifier;
@property (nonatomic, strong) NSString *TeamName;
@property (nonatomic, strong) NSDictionary *Entitlements;
@property (nonatomic, readonly) NSString *ApplicationIdentifier;

@property (nonatomic, strong) NSString *CreationDate;
@property (nonatomic, strong) NSString *ExpirationDate;

@property (nonatomic, strong) NSArray *Platform;
@property (nonatomic, strong) NSDictionary *DeveloperCertificates;
@property (nonatomic, readonly) NSString *SignCertificate;
@property (nonatomic, assign) NSInteger ProvisionedDevices;

@property (nonatomic, strong) NSString *Path;

@property (nonatomic, readonly) MYPackageProfileType type;
@property (nonatomic, readonly) NSString *typeName;

- (BOOL)isMatchAppBundleID:(NSString *)bundleId;

+ (NSArray<MYPackageProfile *> *)arrayWithJSONObject:(NSArray *)json;

@end
