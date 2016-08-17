//
//  MYPackageInitTask.m
//  Package
//
//  Created by Whirlwind on 16/3/30.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "MYPackageInitTask.h"
#import "GetPrimaryMACAddress.h"
#import "GetIPAddress.h"

@implementation MYPackageInitTask

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    [self logInfo];

    if ([self executeCommand:@"printenv" inWorkingDirectory:nil env:nil] != 0) {
        self.errorMessage = [NSString stringWithFormat:@"获取环境变量失败！%@", self.shellTask.errorString];
        return NO;
    }
    NSMutableDictionary *env = [NSMutableDictionary dictionary];
    [[self.output componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSInteger index = [obj rangeOfString:@"="].location;
        if (index != NSNotFound) {
            [env setObject:[obj substringFromIndex:index + 1] forKey:[obj substringToIndex:index]];
        }
    }];
    if ([env count] == 0) {
        self.errorMessage = @"获取的环境变量为空";
        return NO;
    }
    [env addEntriesFromDictionary:@{@"LANG": @"en_US.UTF-8",
                                    @"LANGUAGE": @"en_US.UTF-8",
                                    @"LC_ALL": @"en_US.UTF-8",
                                    @"BUNDLE_GEMFILE": [[[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"GemEnv/Gemfile"],
                                    @"MallocNanoZone": @"0",
                                    @"DISABLE_AUTO_UPDATE": @"true"}];
    shellEnv = env;
    [ObjCShell setSHELL:env[@"SHELL"]];

    return YES;
}

- (void)logInfo {

    [self.config.logger logN:@"Name:\t%@", [[NSHost currentHost] localizedName]];

    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];

    [self.config.logger logN:@"OS:\t%@", [NSString stringWithFormat:@"%zd.%zd.%zd", version.majorVersion, version.minorVersion, version.patchVersion]];
    [self.config.logger logN:@"MAC:\t%@", macAddress()];
    [self.config.logger logN:@"IP:\t%@", IPAddress()];

    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appBuild   = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [self.config.logger logN:@"App:\t%@ (%@)", appVersion, appBuild];
}

@end
