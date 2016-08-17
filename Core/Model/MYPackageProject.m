//
//  MYPackageProject.m
//  Package
//
//  Created by Whirlwind on 15/5/7.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageProject.h"

@interface MYPackageTarget ()

@end

@implementation MYPackageProject

- (NSMutableDictionary<NSString *, MYPackageTarget *> *)targets {
    if (!_targets) {
        _targets = [[NSMutableDictionary alloc] init];
    }
    return _targets;
}

- (MYPackageTarget *)targetForName:(NSString *)name {
    return [self.targets objectForKey:name];
}

- (NSArray<MYPackageTarget *> *)targetsForTargetNames:(NSArray *)names {
    NSMutableArray<MYPackageTarget *> *targets = [NSMutableArray array];
    for (NSString *name in names) {
        MYPackageTarget *target = [self targetForName:name];
        if (target) {
            [targets addObject:target];
        }
    }
    return targets;
}

- (MYPackageTarget *)demoTargetForName:(NSString *)name {
    return [self targetForName:[NSString stringWithFormat:@"%@Demo", name]];
}

- (NSArray<MYPackageTarget *> *)demoTargetsForTargetNames:(NSArray *)names {
    NSMutableArray<MYPackageTarget *> *demoTargets = [NSMutableArray array];
    for (NSString *name in names) {
        MYPackageTarget *demoTarget = [self demoTargetForName:name];
        if (demoTarget) {
            [demoTargets addObject:demoTarget];
        }
    }
    return demoTargets;
}

- (void)setInfo:(NSDictionary *)info {
    _info = info;
    for (MYPackageTarget *target in [self.targets allValues]) {
        target.userConfigrations = [self valueForKey:target.name inArray:self.info[@"Targets"]];
    }
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

@end
