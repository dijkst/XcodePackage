//
//  MYPackageLogger.h
//  Package
//
//  Created by Whirlwind on 15/8/25.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYPackageLogger : NSObject

- (void)log:(NSString *)format, ...;
- (void)logN:(NSString *)format, ...;
- (void)logMessage:(NSString *)message;

@end
