//
//  MYPackageFileLogger.m
//  Package
//
//  Created by Whirlwind on 15/5/12.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageFileLogger.h"

@implementation MYPackageFileLogger {
    NSMutableString *cacheLog;
}

- (void)dealloc {
    [self close];
}

- (void)close {
    [logFile closeFile];
    logFile = nil;
}

- (void)setFilePath:(NSString *)filePath {
    if (_filePath == filePath || [_filePath isEqualToString:filePath]) {
        return;
    }
    if (_filePath) {
        [self close];
    }
    _filePath = filePath;
    if (_filePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:nil];
        }
        [fileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:filePath
                             contents:nil
                           attributes:nil];
        logFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [logFile seekToEndOfFile];
        [self logMessage:cacheLog];
        cacheLog = nil;
    }
}

- (void)logMessage:(NSString *)message {
    if (logFile) {
        if ([message length] > 0) {
            [logFile writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
            [logFile synchronizeFile];
        }
    } else {
        if (!cacheLog) {
            cacheLog = [message mutableCopy];
        } else {
            [cacheLog appendString:message];
        }
    }
}

- (NSString *)logText {
    if (!_filePath) {
        return cacheLog;
    }
    return [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:nil];
}

@end
