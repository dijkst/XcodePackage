//
//  MYPackageScheme.m
//  Package
//
//  Created by Whirlwind on 15/11/20.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageScheme.h"
#import "MYPackageWorkspace.h"

@implementation MYPackageScheme

@synthesize targets        = _targets;
@synthesize projects       = _projects;
@synthesize libraryTargets = _libraryTargets;

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    self.name = [[filePath lastPathComponent] stringByDeletingPathExtension];
}

- (void)setTargetNames:(NSDictionary<NSString *, NSString *> *)targetNames {
    _targetNames = targetNames;
    _targets     = nil;
    _projects    = nil;
}

- (NSArray<MYPackageTarget *> *)targets {
    if (_targets) {
        return _targets;
    }
    if ([self.targetNames count] == 0) {
        return nil;
    }
    if (!_targets) {
        _targets = [self.workspace targetsWithDictionary:self.targetNames];
    }
    return _targets;
}

- (NSArray<MYPackageTarget *> *)libraryTargets {
    if (!_libraryTargets) {
        _libraryTargets = [self targetsForType:MYPackageTargetTypeStaticLibrary|MYPackageTargetTypeObjectFile|MYPackageTargetTypeDynamicLibrary];
    }
    return _libraryTargets;
}

- (NSArray<MYPackageProject *> *)projects {
    if (!_projects) {
        _projects = [self.workspace projectsWithPaths:[_targetNames allValues]];
    }
    return _projects;
}

- (NSArray<MYPackageTarget *> *)targetsForType:(MYPackageTargetType)type {
    return [self.targets filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (MYPackageTarget *_Nonnull target, NSDictionary < NSString *, id > *_Nullable bindings) {
        return (target.type & type) > 0;
    }]];
}

@end
