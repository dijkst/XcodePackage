//
//  UIColor+GDQrCode.m
//  Package
//
//  Created by Whirlwind on 16/4/24.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "NSColor+GDQrCode.h"

@implementation NSColor (GDQrCode)

- (GDColorRGBA)getRGBA {
    CGFloat r = 0, g = 0, b = 0, a = 0;

    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        NSColor *aColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        [aColor getRed:&r green:&g blue:&b alpha:&a];
    } else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    GDColorRGBA rgba = {r * 255.0, g * 255.0, b * 255.0, a * 255.0};
    return rgba;
}

@end
