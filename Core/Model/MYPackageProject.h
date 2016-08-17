//
//  MYPackageProject.h
//  Package
//
//  Created by Whirlwind on 15/5/7.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageTarget.h"
#import "MYPackageScheme.h"

@interface MYPackageProject : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSArray<NSString *> *targetNames;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MYPackageTarget *> *targets;

@property (nonatomic, strong) NSArray<NSString *> *configrations;

/// 项目文件信息
@property (nonatomic, strong) NSDictionary *info;

- (MYPackageTarget *)targetForName:(NSString *)name;
- (NSArray<MYPackageTarget *> *)targetsForTargetNames:(NSArray *)names;

- (MYPackageTarget *)demoTargetForName:(NSString *)name;
- (NSArray<MYPackageTarget *> *)demoTargetsForTargetNames:(NSArray *)names;

@end
