//
//  MYPackageIPAInfoTask.m
//  Package
//
//  Created by Whirlwind on 2017/2/8.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import "MYPackageIPAInfoTask.h"

@implementation MYPackageIPAInfoTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    NSData *data = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.config.bundlePath]) {
        data = [self infoDataInIPA:self.config.bundlePath];
    } else {
        data = [self infoDataInArchive:[[self.config.bundlePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"archive.xcarchive"]];
    }
    if (!data) {
        return NO;
    }

    NSError *errorDesc = nil;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&errorDesc];
    if (errorDesc) {
        self.errorMessage = [errorDesc localizedDescription];
        return NO;
    }
    self.config.displayName = dict[@"CFBundleDisplayName"];
    self.config.appBundleId = dict[@"CFBundleIdentifier"];
    self.config.version = dict[@"CFBundleShortVersionString"];
    return YES;
}

- (NSData *)infoDataInArchive:(NSString *)path {
    MYPackageTarget *target = [self.config.selectedScheme.targets firstObject];
    NSString *plistPath = [[[self.config.workspace.productDir stringByAppendingPathComponent:@"archive.xcarchive/Products"] stringByAppendingPathComponent:target.installPath] stringByAppendingPathComponent:target.infoPlistPath];
    return [NSData dataWithContentsOfFile:plistPath];
}

- (NSData *)infoDataInIPA:(NSString *)path {
    if ([self executeCommand:[NSString stringWithFormat:@"zipinfo -1 \"%@\" \"Payload/*.app/\" \"Payload/*.appex/\"", path]] != 0) {
        self.errorMessage = self.shellTask.errorString;
        return nil;
    }
    if ([self.shellTask.outputString length] == 0) {
        self.errorMessage = @"分析 IPA 出错，未找到 app";
        return nil;
    }
    NSString *infoPath = [[self.shellTask.outputString componentsSeparatedByString:@"\n"] firstObject];
    if ([self executeCommand:[NSString stringWithFormat:@"unzip -p \"%@\" \"%@Info.plist\"", self.config.bundlePath, infoPath]] != 0) {
        self.errorMessage = self.shellTask.errorString;
        return nil;
    }
    return self.shellTask.outputData;
}

@end
