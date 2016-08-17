//
//  MYPackageCheckGitTask.m
//  Package
//
//  Created by Whirlwind on 15/12/8.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageCheckGitTask.h"

@implementation MYPackageCheckGitTask

- (NSString *)name {
    return @"检测 Git 状态";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    self.workingDirectory = self.config.selectedScheme.container ?: self.config.workspace.path;

    if ([self executeCommand:@"git fetch"] != 0) {
        self.errorMessage = @"更新 Git 失败!";
        return NO;
    }

    // 检查 git 是否都已提交
    if ([self executeCommand:@"{ git diff --name-only ; git diff --name-only --staged ; } | sort"] != 0) {
        self.errorMessage = @"检查 Git 状态失败！";
        return NO;
    }
    if ([self.shellTask.outputString length] > 0) {
        self.errorMessage = @"有代码未 Commit，请先 Commit 并 Push！";
        return NO;
    }

    // 检查 git 是否和远程同步
    if ([self executeCommand:@"git branch -r --contains $(git rev-parse --short HEAD)"] != 0) {
        self.errorMessage = @"检查 Git 同步状态失败！";
        return NO;
    }
    if ([self.shellTask.outputString length] == 0) {
        self.errorMessage = @"Git 本地和远程不同步，请先保持同步！";
        return NO;
    }

    return YES;
}

@end
