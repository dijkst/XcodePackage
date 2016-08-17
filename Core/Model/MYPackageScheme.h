//
//  MYPackageScheme.h
//  Package
//
//  Created by Whirlwind on 15/11/20.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYPackageTarget.h"

@class MYPackageWorkspace;
@interface MYPackageScheme : NSObject

@property (nonatomic, weak) MYPackageWorkspace *workspace;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *container;

//! targetName->projectPath
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *targetNames;

@property (nonatomic, strong, readonly) NSArray<MYPackageTarget *>  *targets;
@property (nonatomic, strong, readonly) NSArray<MYPackageTarget *>  *libraryTargets;
@property (nonatomic, strong, readonly) NSArray<MYPackageProject *> *projects;

- (NSArray<MYPackageTarget *> *)targetsForType:(MYPackageTargetType)type;
@end
