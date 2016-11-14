//
//  MYPackageServer.h
//  Package
//
//  Created by Whirlwind on 16/5/19.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYPackageServer : NSObject

@property (nonatomic, assign) BOOL isRunning;

+ (instancetype)sharedInstance;

+ (NSString *)localFilePath;
- (NSString *)serverAddress;

- (BOOL)startup;
- (void)stop;

+ (BOOL)publishLocalFolder:(NSString *)path serverPath:(NSString *)serverPath error:(NSError **)error;

@end
