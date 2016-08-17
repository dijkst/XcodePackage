//
//  MYPackageLogger.m
//  Package
//
//  Created by Whirlwind on 15/8/25.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageLogger.h"

@implementation MYPackageLogger

- (void)logN:(NSString *)format, ...{
    if (!format) {
        return;
    }
    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    [self logMessage:[message stringByAppendingString:@"\n"]];
}

- (void)log:(NSString *)format, ...{
    if (!format) {
        return;
    }
    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    [self logMessage:message];
}

- (void)logMessage:(NSString *)message {
}

@end
