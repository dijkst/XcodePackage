//
//  SafeThread.h
//  Package
//
//  Created by Whirlwind on 15/5/5.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

@import Foundation;

void dispatch_main_sync_safe(dispatch_block_t block);
void dispatch_main_async_safe(dispatch_block_t block);
