//
//  MYPackageWorkspace.m
//  Package
//
//  Created by Whirlwind on 16/3/15.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageWorkspace.h"
#import "MYPackageWorkspaceParser.h"

@implementation MYPackageWorkspace

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    _name     = [[filePath lastPathComponent] stringByDeletingPathExtension];
    self.path = [filePath stringByDeletingLastPathComponent];
    if (PathIsProject(filePath)) {
        self.projectPaths = @[filePath];
    } else if (PathIsWorkspace(filePath)) {
        NSArray        *projects = [MYPackageWorkspaceParser projectsInWorkspace:filePath];
        NSMutableArray *paths    = [NSMutableArray arrayWithCapacity:projects.count];
        [projects enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [paths addObject:[[self.path stringByAppendingPathComponent:obj] stringByStandardizingPath]];
        }];
        self.projectPaths = paths;
    }
}

- (void)setSchemes:(NSArray<MYPackageScheme *> *)schemes {
    _schemes = schemes;
    [schemes setValue:self forKeyPath:@"workspace"];
}

- (NSMutableDictionary<NSString *, MYPackageProject *> *)projects {
    if (!_projects) {
        _projects = [[NSMutableDictionary alloc] init];
    }
    return _projects;
}

#pragma mark - targets
- (NSArray<MYPackageTarget *> *)targetsWithDictionary:(NSDictionary<NSString *, NSString *> *)dict {
    NSMutableArray *targets = [NSMutableArray arrayWithCapacity:dict.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull name, NSString *_Nonnull path, BOOL *_Nonnull stop) {
        MYPackageProject *project = [self.projects objectForKey:path];
        MYPackageTarget *target = [project targetForName:name];
        if (target) {
            [targets addObject:target];
        }
    }];
    return targets;
}

- (NSArray<MYPackageTarget *> *)demoTargetsWithDictionary:(NSDictionary<NSString *, NSString *> *)dict {
    NSMutableArray *targets = [NSMutableArray arrayWithCapacity:dict.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull name, NSString *_Nonnull path, BOOL *_Nonnull stop) {
        MYPackageProject *project = [self.projects objectForKey:path];
        MYPackageTarget *target = [project demoTargetForName:name];
        if (target) {
            [targets addObject:target];
        }
    }];
    return targets;
}

#pragma mark - projects
- (NSArray<MYPackageProject *> *)projectsWithPaths:(NSArray *)paths {
    NSArray        *p     = [paths valueForKeyPath:@"@distinctUnionOfObjects.self"];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[p count]];
    [p enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        MYPackageProject *project = [self.projects objectForKey:obj];
        if (project) {
            [array addObject:project];
        }
    }];
    return array;
}

@end
