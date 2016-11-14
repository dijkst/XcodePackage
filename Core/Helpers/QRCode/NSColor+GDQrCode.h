//
//  UIColor+GDQrCode.h
//  Package
//
//  Created by Whirlwind on 16/4/24.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import <AppKit/AppKit.h>

typedef struct {
    CGFloat R;
    CGFloat G;
    CGFloat B;
    CGFloat alpa;
} GDColorRGBA;

@interface NSColor (GDQrCode)

- (GDColorRGBA)getRGBA;

@end
