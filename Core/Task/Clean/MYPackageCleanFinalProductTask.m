//
//  MYPackageCleanFinalProductTask.m
//  Package
//
//  Created by Whirlwind on 15/8/9.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageCleanFinalProductTask.h"

@implementation MYPackageCleanFinalProductTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSError *error;
    for (NSString *path in @[self.config.logPath, self.config.lipoDir]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:path
                                                       error:&error]) {
            self.errorMessage = [NSString stringWithFormat:@"delete failed: %@ %@", path, [error description]];
            return NO;
        }
    }
    return YES;
}

@end
