//
//  MYPackageShellTask.h
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageBaseTask.h"

#if __has_include(<ObjCCommandLine/ObjCShell.h>)
#   import <ObjCCommandLine/ObjCShell.h>
#else
#   import "ObjCShell.h"
#endif


extern NSDictionary *shellEnv;

@interface MYPackageShellTask : MYPackageBaseTask

@property (nonatomic, strong) ObjCShell *shellTask;
@property (nonatomic, strong) NSString  *workingDirectory;

- (NSString *)scriptForName:(NSString *)name ofType:(NSString *)type;
- (NSString *)command:(NSString *)command withAdministrator:(BOOL)administrator;
- (int)executeCommand:(NSString *)command;
- (int)executeCommand:(NSString *)command inWorkingDirectory:(NSString *)path;
- (int)executeCommand:(NSString *)command inWorkingDirectory:(NSString *)path env:(NSDictionary *)env;

- (int)executeRubyScript:(NSString *)script, ... NS_REQUIRES_NIL_TERMINATION;

- (BOOL)updateGit:(NSString *)git local:(NSString *)local name:(NSString *)name isInit:(BOOL *)isInit;

@end
