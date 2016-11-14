//
//  NSImage+CGImage.m
//  Package
//
//  Created by Whirlwind on 16/5/19.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "NSImage+CGImage.h"

@implementation NSImage (CGImage)

- (CGImageRef)CGImage {
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)[self TIFFRepresentation], NULL);
    return CGImageSourceCreateImageAtIndex(source, 0, NULL);
}

@end
