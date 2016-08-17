//
//  MYPackageDetailLabel.m
//  Package
//
//  Created by Whirlwind on 15/11/27.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageDetailLabel.h"

@implementation MYPackageDetailLabel

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.autoWidth = NO;
    }
    return self;
}
- (void)awakeFromNib {
    self.cell.font = [NSFont boldSystemFontOfSize:16];
    self.textColor = [NSColor lightGrayColor];
}

- (NSSize)intrinsicContentSize {
    if (![self.cell wraps] || !self.autoWidth) {
        return [super intrinsicContentSize];
    }
    NSRect frame = NSMakeRect(0, 0, CGFLOAT_MAX, CGFLOAT_MAX);
    return [self.cell cellSizeForBounds:frame];
}

@end
