//
//  MYPackageTextViewLogger.m
//  Package
//
//  Created by Whirlwind on 15/8/25.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "MYPackageTextViewLogger.h"
#import "SafeThread.h"

@implementation MYPackageTextViewLogger

- (void)logMessage:(NSString *)message {
    if (!message) {
        return;
    }
    dispatch_main_async_safe(^{
        // Smart Scrolling
        BOOL scroll = self.textView.window.isVisible && (NSMaxY(self.textView.visibleRect) >= NSMaxY(self.textView.bounds) - 40);

        NSTextStorage *textStorage = [self.textView textStorage];
        [textStorage beginEditing];

        // Append string to textview
        [textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:message]];

        [textStorage endEditing];

        if (scroll) // Scroll to end of the textview contents
            [self.textView scrollRangeToVisible:NSMakeRange(self.textView.string.length, 0)];
    });
}

@end
