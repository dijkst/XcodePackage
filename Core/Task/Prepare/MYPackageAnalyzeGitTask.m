//
//  MYPackageAnalyzeGitTask.m
//
//
//  Created by Whirlwind on 15/9/9.
//
//

#import "MYPackageAnalyzeGitTask.h"

@implementation MYPackageAnalyzeGitTask

- (NSString *)name {
    return @"分析 Git 信息";
}

- (BOOL)launch {
    if (![super launch]) {
        return NO;
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:self.config.workspace.filePath]) {
        self.errorMessage = [NSString stringWithFormat:@"项目文件不存在：%@", self.config.workspace.filePath];
        return NO;
    }
    self.workingDirectory = self.config.selectedScheme.container ?: self.config.workspace.path;

    // Git Commit Hash
    if ([self executeCommand:@"git rev-parse HEAD"] != 0) {
        self.errorMessage = @"获取 Git Commit Hash 失败！";
    } else {
        self.config.commitHash = self.shellTask.outputString;
    }

    // 用户名
    if (!self.config.authorName) {
        if ([self executeCommand:@"git config user.name"] != 0) {
            self.errorMessage = @"获取 Git 用户名失败，请先设置用户信息！";
            return NO;
        }
        self.config.authorName = self.shellTask.outputString;
    }

    // 用户邮箱
    if (!self.config.authorEmail) {
        if ([self executeCommand:@"git config user.email"] != 0) {
            self.errorMessage = @"获取 Git 邮箱失败，请先设置用户信息！";
            return NO;
        }
        self.config.authorEmail = self.shellTask.outputString;
    }

    // 主页
    if ([self executeCommand:@"git config remote.origin.url"] != 0) {
        self.errorMessage = @"获取 Git 服务器地址失败，请先设置服务端地址！";
        return NO;
    } else {
        self.config.gitUrl = [self.shellTask.outputString lowercaseString];
        NSString *homePage = self.config.gitUrl;
        if ([homePage hasPrefix:@"git@"]) {
            homePage = [homePage substringFromIndex:4];
        }
        if ([homePage hasSuffix:@".git"]) {
            homePage = [homePage substringToIndex:[homePage length] - 4];
        }
        homePage = [homePage stringByReplacingOccurrencesOfString:@":(?=[^/])" withString:@"/" options:NSRegularExpressionSearch range:NSMakeRange(0, [homePage length])];
        if ([homePage rangeOfString:@"://"].location == NSNotFound) {
            homePage = [NSString stringWithFormat:@"http://%@", homePage];
        }
        NSURL *url = [NSURL URLWithString:homePage];
        NSString *scheme = url.scheme;
        if ([scheme isEqualToString:@"ssh"]) {
            scheme = @"http";
        }
        if ([self executeCommand:[NSString stringWithFormat:@"ssh -T -G \"%@\" | awk '/^hostname / { print $2 }'", url.host]] != 0) {
            self.errorMessage = @"解析 ssh Host 失败！";
            return NO;
        }
        url = [[NSURL alloc] initWithScheme:scheme host:self.shellTask.outputString path:url.path];
        self.config.homePage = [url absoluteString];
    }
    return YES;
}

@end
