//
//  MYPackageMultiLogger.m
//  Package
//
//  Created by Whirlwind on 15/8/25.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageMultiLogger.h"
#import "MYPackageFileLogger.h"
#import "MYPackageTextViewLogger.h"

@interface MYPackageMultiLogger ()

@property (nonatomic, strong) MYPackageFileLogger     *fileLogger;
@property (nonatomic, strong) MYPackageTextViewLogger *textViewLogger;

@end

@implementation MYPackageMultiLogger

- (MYPackageFileLogger *)fileLogger {
    if (!_fileLogger) {
        _fileLogger = [[MYPackageFileLogger alloc] init];
    }
    return _fileLogger;
}

- (void)setFilePath:(NSString *)filePath {
    [self.fileLogger setFilePath:filePath];
}

- (MYPackageTextViewLogger *)textViewLogger {
    if (!_textViewLogger && _textView) {
        _textViewLogger = [[MYPackageTextViewLogger alloc] init];
        [_textViewLogger setTextView:_textView];
    }
    return _textViewLogger;
}

- (void)logMessage:(NSString *)message {
    if (!message) {
        return;
    }
    printf("%s", [message UTF8String]);
    [self.fileLogger logMessage:message];
    [self.textViewLogger logMessage:message];
}

- (NSString *)logText {
    return [self.fileLogger logText];
}

@end
