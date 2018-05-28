//
//  MYPackageCommandLine.m
//  Package
//
//  Created by Whirlwind on 15/10/22.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageCommandLine.h"
#import "MYPackageTaskManager.h"
#import "MYPackageTaskManager+TaskList.h"

#if __has_include(<ObjCCommandLine/ObjCShell.h>)
#   import <ObjCCommandLine/ObjCShell.h>
#else
#   import "ObjCShell.h"
#endif

@implementation MYPackageCommandLine

+ (BOOL)canRunWithCommandLineMode {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    for (NSString *arg in @[@"-project", @"-workspace", @"setup", @"export"]) {
        if ([args containsObject:arg]) {
            [ObjCShell setIsCMDEnvironment:YES];
            break;
        }
    }
    return [ObjCShell isCMDEnvironment];
}

+ (MYPackageConfig *)createConfig {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    MYPackageConfig *config = [[MYPackageConfig alloc] init];

    // for all
    config.workspaceFilePath  = [self getProjectPath:[defaults stringForKey:@"workspace"] ? : [defaults stringForKey:@"project"] ];
    config.selectedSchemeName = [defaults stringForKey:@"scheme"];
    config.name               = [defaults stringForKey:@"name"];
    config.bundleId           = [defaults stringForKey:@"bundle-id"];
    config.version            = [defaults stringForKey:@"version"];
    config.configruation      = [defaults stringForKey:@"configuration"];
    config.xcconfigSettings   = [defaults stringForKey:@"xcconfig"];
    config.outputDir          = [defaults stringForKey:@"output"];

    // for pod
    config.authorName         = [defaults stringForKey:@"author-name"];
    config.authorEmail        = [defaults stringForKey:@"author-email"];

    // for app
    config.archivePath        = [defaults stringForKey:@"archive-path"];
    config.teamID             = [defaults stringForKey:@"team-id"];
    config.signType           = [defaults stringForKey:@"sign-type"];

    return config;
}

+ (int)run {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    MYPackageConfig *config = [self createConfig];

    MYPackageTaskManager *manager = [[MYPackageTaskManager alloc] init];
    manager.config = config;

    [config.logger logN:@"从命令行模式启动"];

    BOOL result;
    if ([args containsObject:@"setup"]) {
        result = [manager runTaskClassNames:taskClassOrderSetup];
    } else if ([args containsObject:@"export"]) {
        result = [manager runTaskClassNames:taskClassOrderExportIPA];
    } else {
        NSMutableArray *tasks = [taskClassOrderPrefix mutableCopy];
        if ([args containsObject:@"-no-remote-git"]) {
            [tasks removeObject:@"MYPackageCheckGitTask"];
        }
        result = [manager runTaskClassNames:tasks];
        if (!result) {
            return 1;
        }

        if (config.appTarget) {
            tasks = [taskClassOrderForApp mutableCopy];
            if ([config.teamID length] == 0 || [config.signType length] == 0) {
                [tasks removeObject:@"MYPackageResignAppTask"];
            }
        } else {
            tasks = [taskClassOrderForLib mutableCopy];
        }
        if ([args containsObject:@"-no-remote-git"]) {
            [tasks removeObject:@"MYPackageCreateTagTask"];
        }
        result = [manager runTaskClassNames:tasks];
        if (!result) {
            return 1;
        }
        
        result = [manager runTaskClassNames:taskClassOrderSuffix];
    }
    return result ? 0 : 1;
}

+ (NSString *)getProjectPath:(NSString *)filePath {
    NSArray *extensions = @[@".xcworkspace", @".xcodeproj"];
    for (NSString *ext in extensions) {
        if ([[filePath lowercaseString] hasSuffix:ext]) {
            return filePath;
        }
    }

    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *ext in extensions) {
        NSString *path = [filePath stringByAppendingString:ext];
        if ([fm fileExistsAtPath:path]) {
            return path;
        }
    }

    BOOL isDirectory = YES;
    if (![fm fileExistsAtPath:filePath isDirectory:&isDirectory] || !isDirectory) {
        return filePath;
    }

    NSArray *contents = [fm contentsOfDirectoryAtPath:filePath error:nil];
    if ([contents count] == 0) {
        return filePath;
    }

    for (NSString *ext in extensions) {
        NSArray *xcworkspaces = [contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] %@", ext]];
        if ([xcworkspaces count] > 0) {
            return [filePath stringByAppendingPathComponent:xcworkspaces[0]];
        }
    }
    return filePath;
}

@end
