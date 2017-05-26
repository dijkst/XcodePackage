//
//  MYPackageCommandLine.m
//  Package
//
//  Created by Whirlwind on 15/10/22.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageCommandLine.h"
#import "MYPackageTaskManager.h"

#if __has_include(<ObjCCommandLine/ObjCShell.h>)
#   import <ObjCCommandLine/ObjCShell.h>
#else
#   import "ObjCShell.h"
#endif

@implementation MYPackageCommandLine

+ (BOOL)canRunWithCommandLineMode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [ObjCShell setIsCMDEnvironment:[defaults objectForKey:@"task"] != nil];
    return [ObjCShell isCMDEnvironment];
}

+ (int)run {
    NSDictionary *map = @{
                          @"setup": @[@"prepareEnvironment"],
                          @"check": @[@"checkEnvironment"],
                          @"package": @[@"analyzeProject", @"listScheme", @"analyzeScheme", @"analyzeTarget", @"clean", @"build", @"lipo", @"updateVersionNumber", @"zip"],
                          @"createSpec": @[@"checkGit", @"analyzeProject", @"analyzeProduct", @"analyzeGit", @"calculateMD5Task", @"createSpec", @"uploadStatistics"],
                          @"upload": @[@"upload", @"createTag"],
                          @"clean": @[@"cleanIntermediateProduct"],
                          @"cleanAll": @[@"cleanIntermediateProduct", @"cleanFinalProduct"]
                          };

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    MYPackageConfig *config = [[MYPackageConfig alloc] init];

    config.workspaceFilePath  = [self getProjectPath:[defaults stringForKey:@"workspace"] ? : [defaults stringForKey:@"project"] ];
    config.selectedSchemeName = [defaults stringForKey:@"scheme"];
    config.authorName         = [defaults stringForKey:@"author-name"];
    config.authorEmail        = [defaults stringForKey:@"author-email"];
    config.version            = [defaults stringForKey:@"version"];
    config.name            = [defaults stringForKey:@"pod-name"];
    config.configruation      = [defaults stringForKey:@"configuration"];
    config.xcconfigSettings   = [defaults stringForKey:@"xcconfig"];

    NSString *task  = [defaults stringForKey:@"task"];
    NSArray  *tasks = [task componentsSeparatedByString:@","];
    if ([tasks count] == 0) {
        tasks = @[@"package", @"createSpec", @"upload", @"clean"];
    }
    NSMutableArray *execTasks = [NSMutableArray array];
    for (NSString *t in tasks) {
        NSArray *ts = map[t];
        if (ts) {
            [execTasks addObjectsFromArray:ts];
        } else {
            [config.logger logN:@"⚠️ 任务 %@ 不存在，将被忽略", t];
        }
    }
    [execTasks addObject:@"init"];
    [execTasks addObject:@"checkEnvironment"];
    NSArray *ts = [execTasks valueForKeyPath:@"@distinctUnionOfObjects.self"];

    // 跳过任务
    NSString *skipTask = [defaults stringForKey:@"skip-task"];
    if (skipTask) {
        NSArray *skipTasks = [skipTask componentsSeparatedByString:@","];
        ts = [ts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (id _Nonnull evaluatedObject, NSDictionary < NSString *, id > *_Nullable bindings) {
            return [skipTasks indexOfObject:evaluatedObject] == NSNotFound;
        }]];
    }

    MYPackageTaskManager *manager = [[MYPackageTaskManager alloc] init];
    manager.config = config;
    BOOL result = [manager runTasks:ts];
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
