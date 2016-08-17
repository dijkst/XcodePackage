//
//  MYPackageAnalyzeProductTask.m
//  Package
//
//  Created by Whirlwind on 15/5/6.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageAnalyzeProductTask.h"

@implementation MYPackageAnalyzeProductTask

- (NSString *)name {
    return @"分析系统依赖";
}

- (BOOL)analyzeProjectSettingInfo:(MYPackageProject *)project {
    if ([self executeRubyScript:@"xcode-analyze", project.filePath, nil] != 0) {
        return NO;
    }
    NSError      *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.shellTask.outputData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
    if (error) {
        self.errorMessage = [NSString stringWithFormat:@"JSON 格式非法: %@", [error localizedDescription]];
        return NO;
    }
    project.info = dic;
    return YES;
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSMutableArray *projects = [NSMutableArray array];
    [self.config.selectedScheme.targets enumerateObjectsUsingBlock:^(MYPackageTarget * _Nonnull target, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([projects indexOfObject:target.project] == NSNotFound) {
            [projects addObject:target.project];
        }
    }];
    for (MYPackageProject *project in projects) {
        if (![self analyzeProjectSettingInfo:project]) {
            return NO;
        }
    }

    return YES;
}

@end
