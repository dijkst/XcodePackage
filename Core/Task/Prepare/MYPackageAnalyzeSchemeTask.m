//
//  MYPackageAnalyzeSchemeTask.m
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageAnalyzeSchemeTask.h"

@implementation MYPackageAnalyzeSchemeTask

- (NSString *)name {
    return [NSString stringWithFormat:@"分析 %@", self.config.selectedScheme.name];
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    if (!self.config.selectedScheme) {
        if (self.config.selectedSchemeName) {
            self.errorMessage = [NSString stringWithFormat:@"不存在 Scheme：%@", self.config.selectedSchemeName];
        } else {
            self.errorMessage = @"需要指明 Scheme！";
        }
        return NO;
    }

    if ([self executeRubyScript:@"analyze_scheme", self.config.selectedScheme.filePath, nil] != 0) {
        self.errorMessage = [NSString stringWithFormat:@"分析 Scheme 失败！%@", self.output];
        return NO;
    }

    NSError *error;

    NSDictionary<NSString *, NSString *> *targets = [NSJSONSerialization JSONObjectWithData:self.shellTask.outputData
                                                                                    options:0
                                                                                      error:&error];
    if (error) {
        self.errorMessage = [NSString stringWithFormat:@"JSON 格式非法: %@", [error localizedDescription]];
        return NO;
    }
    NSMutableDictionary *ts = [NSMutableDictionary dictionaryWithCapacity:targets.count];
    [targets enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        NSString *path = [[[self.config.selectedScheme.container stringByDeletingLastPathComponent] stringByAppendingPathComponent:obj] stringByStandardizingPath];
        [ts setObject:path forKey:key];
    }];
    self.config.selectedScheme.targetNames = ts;
    return YES;
}

@end
