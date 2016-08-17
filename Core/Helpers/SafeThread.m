//
//  SafeThread.h
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import "SafeThread.h"

void dispatch_main_sync_safe(dispatch_block_t block) {
    if ([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void dispatch_main_async_safe(dispatch_block_t block) {
    if ([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

