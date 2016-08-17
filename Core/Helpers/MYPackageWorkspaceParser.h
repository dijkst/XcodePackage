//
//  MYPackageWorkspaceParser.h
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYPackageWorkspaceParser : NSObject

+ (NSArray *)projectsInWorkspace:(NSString *)workspace;

@end
