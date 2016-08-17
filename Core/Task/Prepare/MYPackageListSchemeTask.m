//
//  MYPackageListSchemeTask.m
//  Package
//
//  Created by Whirlwind on 15/12/17.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageListSchemeTask.h"

@implementation MYPackageListSchemeTask

// 分析 Scheme 列表
// 只列出 Shared 的，所以不取 xcodebuild 输出的列表
- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSMutableArray<MYPackageScheme *> *schemes = [NSMutableArray array];
    [schemes addObjectsFromArray:[self sharedSchemesAtPath:self.config.workspace.filePath]];
    if (PathIsWorkspace(self.config.workspace.filePath)) {
        for (NSString *path in self.config.workspace.projectPaths) {
            [schemes addObjectsFromArray:[self sharedSchemesAtPath:path]];
        }
    }
    if (self.errorMessage) {
        return NO;
    }
    if ([schemes count] == 0) {
        self.errorMessage = @"无 Shared 的 Scheme！";
        return NO;
    }
    [self.config.workspace setSchemes:schemes];
    return YES;
}

- (NSArray *)sharedSchemesAtPath:(NSString *)path {
    NSString *schemeDir = [path stringByAppendingPathComponent:@"xcshareddata/xcschemes"];
    [self.config.logger log:@"扫描 %@ ...", schemeDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:schemeDir]) {
        [self.config.logger logN:@"不存在!"];
        return nil;
    }
    NSError             *error;
    NSArray<NSString *> *schemes = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:schemeDir error:&error];
    if (error) {
        self.errorMessage = [error localizedDescription];
        return nil;
    }
    schemes = [schemes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH '.xcscheme'"]];
    if ([schemes count] == 0) {
        [self.config.logger logN:@"不包含 scheme !"];
        return nil;
    }
    [self.config.logger logN:@""];// 换行
    [self.config.logger logN:@"%@", schemes];
    NSMutableArray *s = [NSMutableArray arrayWithCapacity:[schemes count]];
    [schemes enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        MYPackageScheme *scheme = [[MYPackageScheme alloc] init];
        scheme.filePath = [schemeDir stringByAppendingPathComponent:obj];
        scheme.container = path;
        [s addObject:scheme];
    }];
    return s;
}

@end
