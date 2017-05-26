//
//  MYPackageConfig.h
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYPackageMultiLogger.h"
#import "MYPackageWorkspace.h"

@interface MYPackageConfig : NSObject <NSCopying>

@property (nonatomic, strong) MYPackageMultiLogger *logger;

@property (nonatomic, readonly) MYPackageTarget *appTarget;
@property (nonatomic, readonly) NSString *xcconfig;

// IPA 放在本地服务器的路径
@property (nonatomic, strong) NSString *serverPath;

// for all
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bundleId;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, readonly) BOOL isSNAPSHOT;
@property (nonatomic, strong) NSString *configruation;
@property (nonatomic, strong) NSString *xcconfigSettings;
@property (nonatomic, strong) NSString *downloadUrl;

@property (nonatomic, strong) NSString        *selectedSchemeName;
@property (nonatomic, strong) MYPackageScheme *selectedScheme;

@property (nonatomic, strong) NSString           *workspaceFilePath;
@property (nonatomic, strong) MYPackageWorkspace *workspace;

// for pod
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *authorEmail;
@property (nonatomic, strong) NSString *homePage;
@property (nonatomic, strong) NSString *gitUrl;
@property (nonatomic, strong) NSString *commitHash;

// for app
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *teamID;
@property (nonatomic, strong) NSString *signType;

// 以下为绝对路径
@property (nonatomic, readonly) NSString *outputDir;
@property (nonatomic, readonly) NSString *productsDir;
@property (nonatomic, readonly) NSString *simulatorsDir;
@property (nonatomic, readonly) NSString *devicesDir;
@property (nonatomic, readonly) NSString *zipDir;
@property (nonatomic, readonly) NSString *logPath;
@property (nonatomic, readonly) NSString *specPath;
@property (nonatomic, readonly) NSString *bundlePath;

@property (nonatomic, strong) NSString *bundleHash;

- (NSString *)productPathForTarget:(MYPackageTarget *)target;
- (NSString *)simulatorPathForTarget:(MYPackageTarget *)target;
- (NSString *)devicePathForTarget:(MYPackageTarget *)target;

@end
