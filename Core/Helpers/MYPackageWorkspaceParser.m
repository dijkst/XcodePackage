//
//  MYPackageWorkspaceParser.m
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageWorkspaceParser.h"

@implementation MYPackageWorkspaceParser

+ (NSArray *)projectsInWorkspace:(NSString *)workspace {
    NSError *error = nil;
    NSString *xcworkspace = [[NSString alloc] initWithContentsOfFile:[workspace stringByAppendingPathComponent:@"contents.xcworkspacedata"] encoding:NSUTF8StringEncoding error:&error];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"location *= *[\"']group:(.+?)[\"']"
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];

    if (error) return nil;
    NSMutableArray *array = [NSMutableArray array];
    [regex enumerateMatchesInString:xcworkspace
                            options:0
                              range:NSMakeRange(0, [xcworkspace length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             NSRange matchRange = [result rangeAtIndex:1];
                             NSString *project = [xcworkspace substringWithRange:matchRange];
                             [array addObject:project];
                         }];
    return array;
}

@end
