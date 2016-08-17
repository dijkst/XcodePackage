//
//  MYPackageFileLogger.h
//  Package
//
//  Created by Whirlwind on 15/5/12.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MYPackageLogger.h"

@interface MYPackageFileLogger : MYPackageLogger {
    NSFileHandle *logFile;
}

@property (nonatomic, strong) NSString *filePath;

- (void)close;

- (NSString *)logText;

@end
