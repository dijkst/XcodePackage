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

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *authorEmail;
@property (nonatomic, strong) NSString *homePage;
@property (nonatomic, strong) NSString *gitUrl;
@property (nonatomic, strong) NSString *commitHash;
@property (nonatomic, strong) NSString *podName;
@property (nonatomic, strong) NSString *configruation;
@property (nonatomic, strong) NSString *xcconfigSettings;


@property (nonatomic, strong) NSString        *selectedSchemeName;
@property (nonatomic, strong) MYPackageScheme *selectedScheme;

@property (nonatomic, strong) NSString           *workspaceFilePath;
@property (nonatomic, strong) MYPackageWorkspace *workspace;

// 以下为绝对路径
@property (nonatomic, readonly) NSString *outputDir;
@property (nonatomic, readonly) NSString *lipoDir;
@property (nonatomic, readonly) NSString *zipDir;
@property (nonatomic, readonly) NSString *logPath;
@property (nonatomic, readonly) NSString *specPath;
@property (nonatomic, readonly) NSString *largeZipPath;

@end
