//
//  NSView+Enable.m
//  MYBLELock
//
//  Created by Whirlwind on 15/1/13.
//  Copyright (c) 2015年 luobo. All rights reserved.
//

#import "NSView+Enable.h"
#import <objc/runtime.h>

@implementation NSView (Enable)

- (void)setOriginEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(setOriginEnabled:), @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)originEnabled {
    NSNumber *v = objc_getAssociatedObject(self, @selector(setOriginEnabled:));
    if (v) {
        return [v boolValue];
    }
    return YES;
}

- (void)setEnabled:(BOOL)enabled bySuperView:(BOOL)bySuperView {
    if (!bySuperView) {
        [self setOriginEnabled:enabled];
    }
    enabled = enabled & [self originEnabled];
    if ([self isKindOfClass:[NSControl class]]) {
        NSControl *control = (NSControl *)self;
        NSNumber *v = objc_getAssociatedObject(self, @selector(setOriginEnabled:));
        if (!v) {
            [self setOriginEnabled:control.enabled];
        }
        [control setEnabled:enabled];
    } else {
        for (NSView *view in self.subviews) {
            [view setEnabled:enabled bySuperView:YES];
        }
    }
    objc_setAssociatedObject(self, @selector(setEnabled:), @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
