//
//  MYPackageCreateDistributePlistTask.m
//  Package
//
//  Created by Whirlwind on 16/5/19.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageCreateDistributePlistTask.h"

@implementation MYPackageCreateDistributePlistTask

- (NSString *)name {
    return @"创建 Plist";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    
    return YES;
}
@end
