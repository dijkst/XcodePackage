//
//  MYPackageCreateTagTask.m
//
//
//  Created by Whirlwind on 15/9/9.
//
//

#import "MYPackageCreateTagTask.h"

@implementation MYPackageCreateTagTask

- (NSString *)name {
    return @"创建 Tag";
}

- (NSString *)version {
    return self.config.version;
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }
    self.workingDirectory = self.config.selectedScheme.container ?: self.config.workspace.path;
    if ([self executeCommand:[NSString stringWithFormat:@"git tag -f %@", self.version]] != 0) {
        self.errorMessage = @"创建 Tag 出错!";
        return NO;
    }
    if ([self executeCommand:[NSString stringWithFormat:@"git push -f origin %@", self.version]] != 0) {
        self.errorMessage = @"提交 Tag 到远程服务器出错!";
        return NO;
    }
    return YES;
}

@end
