//
//  MYPackageCalculateMD5Task.m
//  Package
//
//  Created by Whirlwind on 2016/12/12.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageCalculateMD5Task.h"
#include <CommonCrypto/CommonDigest.h>

@implementation MYPackageCalculateMD5Task

- (NSString *)name {
    return @"计算 MD5";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:self.config.largeZipPath];
    if( handle== nil ) {
        self.errorMessage = @"计算 MD5 失败";
        return NO;
    }

    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);

    NSData* fileData;
    do {
        fileData = [handle readDataOfLength: 1024*1024*10 ];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
    } while ([fileData length] > 0);

    [handle closeFile];

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    self.config.largeZipHash = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                digest[0], digest[1],
                                digest[2], digest[3],
                                digest[4], digest[5],
                                digest[6], digest[7],
                                digest[8], digest[9],
                                digest[10], digest[11],
                                digest[12], digest[13],
                                digest[14], digest[15]];
    return YES;
}
@end
