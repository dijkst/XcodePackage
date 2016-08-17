//
//  MYPackageTableRowView.m
//  Package
//
//  Created by Whirlwind on 15/11/26.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageTableRowView.h"

@implementation MYPackageTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        [[NSColor cyanColor] setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:0 yRadius:0];
        [selectionPath fill];
    }
}

@end
