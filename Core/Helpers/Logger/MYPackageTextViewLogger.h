//
//  MYPackageTextViewLogger.h
//  Package
//
//  Created by Whirlwind on 15/8/25.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MYPackageLogger.h"

@interface MYPackageTextViewLogger : MYPackageLogger

@property (nonatomic, strong) NSTextView *textView;

@end
