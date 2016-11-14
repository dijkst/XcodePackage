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

- (NSString *)podName {
    return _podName ? : _workspace.name;
}

- (NSString *)configruation {
    if ([_configruation length] == 0) {
        return @"Release";
    }
    return _configruation;
}

- (NSString *)xcconfig {
    if (self.IPA) {
        return [[NSBundle mainBundle] pathForResource:@"build-ipa" ofType:@".xcconfig"];
    }
    return [[NSBundle mainBundle] pathForResource:@"build-static-framework" ofType:@".xcconfig"];
}

- (BOOL)IPA {
    for (MYPackageTarget *target in self.selectedScheme.targets) {
        if (target.type == MYPackageTargetTypeExecutable) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)serverPath {
    if (!_serverPath) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        _serverPath =  [self.podName stringByAppendingPathComponent:[dateFormat stringFromDate:[NSDate date]]];
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
- (NSString *)outputDir {
    return [self.workspace.path stringByAppendingPathComponent:@"build"];
}

- (NSString *)lipoDir {
    return [self.outputDir stringByAppendingPathComponent:@"lipo"];
}

- (NSString *)zipDir {
    return [self.lipoDir stringByAppendingPathComponent:@"zip"];
}

- (NSString *)logPath {
    return [self.outputDir stringByAppendingPathComponent:@"log"];
}

- (NSString *)specPath {
    return [self.lipoDir stringByAppendingPathComponent:[self.podName stringByAppendingPathExtension:@"podspec.json"]];
}

- (NSString *)largeZipPath {
    return [self.lipoDir stringByAppendingPathComponent:[self.podName stringByAppendingString:@".library.zip"]];
}

#pragma mark - workspace
- (void)setWorkspaceFilePath:(NSString *)workspacePath {
    self.workspace.filePath = workspacePath;
    [self.logger setFilePath:self.logPath];
}

- (NSString *)workspaceFilePath {
    return self.workspace.filePath;
}

- (MYPackageWorkspace *)workspace {
    if (!_workspace) {
        _workspace = [[MYPackageWorkspace alloc] init];
    }
    return _workspace;
}

#pragma mark - copy protocol
- (id)copyWithZone:(NSZone *)zone {
    MYPackageConfig *config = [[MYPackageConfig alloc] init];

    config.logger    = _logger;
    config.workspace = _workspace;

    config.serverPath = _serverPath;

    config.version       = _version;
    config.authorName    = _authorName;
    config.authorEmail   = _authorEmail;
    config.homePage      = _homePage;
    config.commitHash    = _commitHash;
    config.configruation = _configruation;

    config.selectedSchemeName = _selectedSchemeName;
    config.selectedScheme     = _selectedScheme;
    return config;
}

@end
