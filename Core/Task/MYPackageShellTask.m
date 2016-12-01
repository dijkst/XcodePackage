//
//  MYPackageShellTask.m
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageShellTask.h"

#if __has_include(<ObjCCommandLine/ObjCShell.h>)
#   import <ObjCCommandLine/ObjCShell.h>
#else
#   import "ObjCShell.h"
#endif

NSDictionary *shellEnv = nil;

@interface MYPackageShellTask () <ObjCShellDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, ObjCShell *> *shellTasks;

@end

@implementation MYPackageShellTask

- (instancetype)init {
    if (self = [super init]) {
        self.workingDirectory = [[NSBundle mainBundle] resourcePath];
        self.shellTasks       = [NSMutableDictionary dictionary];
    }
    return self;
}

- (ObjCShell *)shellTask {
    NSString *name = [self shellTaskNameForCurrentThread];
    return [self shellTaskForName:name];
}

- (NSString *)shellTaskNameForCurrentThread {
    return [[NSThread currentThread] name] ? : @"default";
}

- (ObjCShell *)shellTaskForName:(NSString *)name {
    return [self.shellTasks objectForKey:name];
}

- (void)setShellTask:(ObjCShell *)task forName:(NSString *)name {
    [self.shellTasks setObject:task forKey:name];
}

- (NSString *)scriptForName:(NSString *)name ofType:(NSString *)type {
    return [ObjCShell scriptForName:name ofType:type];
}

- (NSString *)command:(NSString *)command withAdministrator:(BOOL)administrator {
    if (administrator) {
        return [ObjCShell commandWithAdministrator:command];
    } else {
        return command;
    }
}

- (int)executeCommand:(NSString *)command {
    return [self executeCommand:command inWorkingDirectory:nil];
}

- (int)executeCommand:(NSString *)command inWorkingDirectory:(NSString *)path {
    return [self executeCommand:command inWorkingDirectory:path env:nil];
}

- (int)executeCommand:(NSString *)command inWorkingDirectory:(NSString *)path env:(NSDictionary *)env {
    if (!path) {
        path = self.workingDirectory;
    }
    [self.config.logger logN:@"\n$ cd '%@'\n$ %@", path, command];
    if (!env) {
        env = shellEnv;
    }
    ObjCShell *task = [[ObjCShell alloc] init];
    [task setDelegate:self];
    [self setShellTask:task forName:[self shellTaskNameForCurrentThread]];
    int status = [task executeCommand:command
                   inWorkingDirectory:path
                                  env:env];
    return status;
}

- (int)executeRubyScript:(NSString *)script, ...{
    NSString       *eachObject;
    va_list        argumentList;
    NSMutableArray *args = [NSMutableArray array];
    if (script) {
        [args addObject:[self scriptForName:script ofType:@"rb"]];
        va_start(argumentList, script);
        while ((eachObject = va_arg(argumentList, NSString *)))
            [args addObject:eachObject];
        va_end(argumentList);
    }
    return [self executeCommand:[NSString stringWithFormat:@"bundle exec ruby '%@'", [args componentsJoinedByString:@"' '"]]];
}

- (NSString *)output {
    return self.shellTask.outputString;
}

- (void)cancel {
    [self.shellTasks enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, ObjCShell *_Nonnull obj, BOOL *_Nonnull stop) {
        [obj cancel];
    }];
    [super cancel];
}

- (BOOL)updateGit:(NSString *)git local:(NSString *)local name:(NSString *)name isInit:(BOOL *)isInit {
    NSString *folder = [local stringByExpandingTildeInPath];
    NSString *path   = [folder stringByAppendingPathComponent:name];

    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if ([self executeCommand:@"git reset --hard HEAD 1>/dev/null && git pull 1>/dev/null" inWorkingDirectory:path] != 0) {
            [self.config.logger logN:@"Clone Failed! %@", self.errorMessage];
            return NO;
        }
        if (isInit) {
            *isInit = NO;
        }
    } else {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error]) {
            [self.config.logger logN:@"创建目录失败！%@", [error description]];
            return NO;
        }
        if ([self executeCommand:[NSString stringWithFormat:@"git clone '%@' '%@' 1>/dev/null", git, name] inWorkingDirectory:folder] != 0) {
            [self.config.logger logN:@"Clone Failed! %@", self.errorMessage];
            return NO;
        }
        if (isInit) {
            *isInit = YES;
        }
    }
    return YES;
}

#pragma mark - ObjCShellDelegate
- (void)logErrorString:(NSString *)string {
    [self.config.logger logMessage:string];
}

- (void)logOutputString:(NSString *)string {
    [self.config.logger logMessage:string];
}

@end
