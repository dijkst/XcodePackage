//
//  MYPackageConfig.m
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageConfig.h"
#import "MYPackageWorkspaceParser.h"

@interface MYPackageConfig ()

@end

@implementation MYPackageConfig

@synthesize logPath = _logPath;

- (NSString *)name {
    return _name ? : _workspace.name;
}

- (BOOL)isSNAPSHOT {
    return [[self.version lowercaseString] hasSuffix:@"snapshot"];
}

- (NSString *)configruation {
    if ([_configruation length] == 0) {
        return @"Release";
    }
    return _configruation;
}

- (NSString *)xcconfig {
    if (self.appTarget) {
        return [[NSBundle mainBundle] pathForResource:@"build-app" ofType:@".xcconfig"];
    }
    return [[NSBundle mainBundle] pathForResource:@"build-library" ofType:@".xcconfig"];
}

- (MYPackageTarget *)appTarget {
    for (MYPackageTarget *target in self.selectedScheme.targets) {
        if (target.type == MYPackageTargetTypeExecutable) {
            return target;
        }
    }
    return nil;
}

- (NSString *)serverPath {
    if (!_serverPath) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        _serverPath =  [self.name stringByAppendingPathComponent:[dateFormat stringFromDate:[NSDate date]]];
    }
    return _serverPath;
}

#pragma mark - scheme
- (NSString *)selectedSchemeName {
    if (!_selectedSchemeName) {
        return self.selectedScheme.name;
    }
    return _selectedSchemeName;
}

- (MYPackageScheme *)selectedScheme {
    if (!_selectedScheme && _selectedSchemeName) {
        for (MYPackageScheme *scheme in self.workspace.schemes) {
            if ([scheme.name isEqualToString:_selectedSchemeName]) {
                _selectedScheme = scheme;
                break;
            }
        }
    }
    return _selectedScheme;
}

#pragma mark - logger
- (MYPackageMultiLogger *)logger {
    if (!_logger) {
        _logger = [[MYPackageMultiLogger alloc] init];
    }
    return _logger;
}

#pragma mark - path
- (NSString *)productPathForTarget:(MYPackageTarget *)target {
    return [self.productsDir stringByAppendingPathComponent:target.sdkName];
}

- (NSString *)simulatorPathForTarget:(MYPackageTarget *)target {
    return [self.simulatorsDir stringByAppendingPathComponent:target.sdkName];
}

- (NSString *)devicePathForTarget:(MYPackageTarget *)target {
    return [self.devicesDir stringByAppendingPathComponent:target.sdkName];
}

- (NSString *)outputDir {
    return [self.workspace.path stringByAppendingPathComponent:@"build"];
}

- (NSString *)productsDir {
    return [self.outputDir stringByAppendingPathComponent:@"products"];
}

- (NSString *)simulatorsDir {
    return [self.outputDir stringByAppendingPathComponent:@"simulator"];
}

- (NSString *)devicesDir {
    return [self.outputDir stringByAppendingPathComponent:@"os"];
}

- (NSString *)zipDir {
    return [self.outputDir stringByAppendingPathComponent:@"zip"];
}

- (NSString *)logPath {
    if (!_logPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            _logPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName] stringByAppendingPathComponent:@"log.log"];
        }
    }
    return _logPath;
}

- (NSString *)specPath {
    return [self.outputDir stringByAppendingPathComponent:[self.name stringByAppendingPathExtension:@"podspec.json"]];
}

- (NSString *)bundlePath {
    return [self.outputDir stringByAppendingPathComponent:[self.name stringByAppendingString:@".zip"]];
}

- (NSString *)downloadUrl {
    if (_downloadUrl) {
        return _downloadUrl;
    }
    return @"服务器 zip 地址";
}

#pragma mark - workspace
- (void)setWorkspaceFilePath:(NSString *)workspacePath {
    self.workspace = [[MYPackageWorkspace alloc] init];
    self.workspace.filePath = workspacePath;
    [self.logger setFilePath:self.logPath];
}

- (NSString *)workspaceFilePath {
    return self.workspace.filePath;
}

#pragma mark - copy protocol
- (id)copyWithZone:(NSZone *)zone {
    MYPackageConfig *config = [[MYPackageConfig alloc] init];

    config.logger    = _logger;
    config.workspace = _workspace;

    config.serverPath = _serverPath;

    config.name          = _name;
    config.bundleId      = _bundleId;
    config.version       = _version;
    config.configruation = _configruation;
    config.xcconfigSettings = _xcconfigSettings;
    config.downloadUrl   = _downloadUrl;

    config.authorName    = _authorName;
    config.authorEmail   = _authorEmail;
    config.homePage      = _homePage;
    config.commitHash    = _commitHash;
    config.gitUrl        = _gitUrl;

    config.displayName   = _displayName;
    config.teamID        = _teamID;

    config.bundleHash    = _bundleHash;

    config.selectedSchemeName = _selectedSchemeName;
    config.selectedScheme     = _selectedScheme;
    return config;
}

@end
