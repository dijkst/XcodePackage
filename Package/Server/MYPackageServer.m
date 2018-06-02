//
//  MYPackageServer.m
//  Package
//
//  Created by Whirlwind on 16/5/19.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageServer.h"
#import <Criollo/CRHTTPServer.h>

#define kServerPort 8086

@interface MYPackageServer () <CRServerDelegate>

@property (nonatomic, strong) CRHTTPServer *webServer;
@property (nonatomic, assign) BOOL running;

@end

@implementation MYPackageServer

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MYPackageServer *__server;
    dispatch_once(&onceToken, ^{
        __server = [[[self class] alloc] init];
        [__server startup];
    });
    return __server;
}

+ (BOOL)publishLocalFolder:(NSString *)path serverPath:(NSString *)serverPath error:(NSError * *)error {
    NSFileManager *fm       = [NSFileManager defaultManager];
    NSString      *fullPath = [[self localDirectory] stringByAppendingPathComponent:serverPath];
    if ([fm fileExistsAtPath:fullPath]) {
        [fm removeItemAtPath:fullPath error:nil];
    }
    if (![fm createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]
       withIntermediateDirectories:YES
                        attributes:nil
                             error:error]) {
        return NO;
    }

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];

    if (![fm copyItemAtPath:path toPath:fullPath error:error]) {
        return NO;
    }
    return YES;
}

+ (NSString *)localDirectory {
    return [[[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"Server"];
}

- (CRHTTPServer *)webServer {
    if (!_webServer) {
        _webServer = [[CRHTTPServer alloc] initWithDelegate:self];
        [_webServer mount:@"/" directoryAtPath:[[self class] localDirectory]];
    }
    return _webServer;
}

- (NSURLComponents *)serverAddress {
    NSURLComponents *components = [[NSURLComponents alloc] init];
//    components.scheme = @"https";
    components.scheme = @"http";
    components.port = @(kServerPort);
    components.host = [[NSHost hostWithName:[[NSHost currentHost] name]] address];
    return components;
}

- (NSString *)downloadUrlForPath:(NSString *)path {
    NSURLComponents *components = [self serverAddress];
    components.path = [@"/" stringByAppendingPathComponent:path];
    return [[components URL] absoluteString];
}

- (BOOL)startup {
    if (_running) {
        return YES;
    }
    NSError *error = nil;
    if ([self.webServer startListening:&error portNumber:kServerPort]) {
        _running = YES;
        return YES;
    } else {
        NSLog(@"start server fail: %@", error);
        return NO;
    }
}

- (void)stop {
    _running = NO;
    [_webServer stopListening];
}

#pragma mark - CRServerDelegate
- (void)serverWillStopListening:(CRServer *)server {
    _running = NO;
}

@end
