//
//  MYPackageCommandLine.h
//  Package
//
//  Created by Whirlwind on 15/10/22.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 -workspace <workspace绝对路径>
 -project <project绝对路径>
 -target <target 列表，用逗号分割，第一个为 default subspec>
 -task <task 列表，用逗号分割>
 */
@interface MYPackageCommandLine : NSObject

+ (BOOL)canRunWithCommandLineMode;
+ (int)run;

@end
