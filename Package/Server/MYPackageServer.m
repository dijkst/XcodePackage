//
//  MYPackageServer.m
//  Package
//
//  Created by Whirlwind on 16/5/19.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageServer.h"
//#import "GCDWebServer.h"
//
//@interface MYPackageServer ()
//
//@property (nonatomic, strong) GCDWebServer *webServer;
//
//@end
//
@implementation MYPackageServer
//
//+ (instancetype)sharedInstance {
//    static dispatch_once_t onceToken;
//    static MYPackageServer *__server;
//    dispatch_once(&onceToken, ^{
//        __server = [[[self class] alloc] init];
//    });
//    return __server;
//}
//
//+ (BOOL)publishLocalFolder:(NSString *)path serverPath:(NSString *)serverPath error:(NSError * *)error {
//    NSFileManager *fm       = [NSFileManager defaultManager];
//    NSString      *fullPath = [[self localFilePath] stringByAppendingPathComponent:serverPath];
//    if ([fm fileExistsAtPath:fullPath]) {
//        [fm removeItemAtPath:fullPath error:nil];
//    }
//    if (![fm createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]
//       withIntermediateDirectories:YES
//                        attributes:nil
//                             error:error]) {
//        return NO;
//    }
//
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
//
//    if (![fm copyItemAtPath:path toPath:fullPath error:error]) {
//        return NO;
//    }
//    return YES;
//}
//
//+ (NSString *)localFilePath {
//    return [[[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"Server"];
//}
//
//- (GCDWebServer *)webServer {
//    if (!_webServer) {
//        _webServer = [[GCDWebServer alloc] init];
//        [_webServer addGETHandlerForBasePath:@"/" directoryPath:[[self class] localFilePath] indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
//    }
//    return _webServer;
//}
//
//- (BOOL)isRunning {
//    return _webServer.isRunning;
//}
//
//- (NSString *)serverAddress {
//    return [_webServer.serverURL absoluteString];
//}
//
//- (BOOL)startup {
//    return [self.webServer startWithPort:8090 bonjourName:nil];
//}
//
//- (void)stop {
//    [_webServer stop];
//}
//
@end
