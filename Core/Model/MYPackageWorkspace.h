//
//  MYPackageWorkspace.h
//  Package
//
//  Created by Whirlwind on 16/3/15.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYPackageProject.h"

@interface MYPackageWorkspace : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, strong) NSString   *path;  // if not set, use filePath dirname
@property (nonatomic, strong) NSString   *filePath;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MYPackageProject *> *projects;

@property (nonatomic, strong) NSArray<NSString *> *projectPaths;

@property (nonatomic, strong) NSArray<MYPackageScheme *> *schemes;

/*! 根据字典信息获取 targets
 *
 *  dict 的 key 是 target 名称，value 是 target 所在项目的路径
 */
- (NSArray<MYPackageTarget *> *)targetsWithDictionary:(NSDictionary<NSString *, NSString *> *)dict;
- (NSArray<MYPackageTarget *> *)demoTargetsWithDictionary:(NSDictionary<NSString *, NSString *> *)dict;

- (NSArray<MYPackageProject *> *)projectsWithPaths:(NSArray *)paths;

@end
