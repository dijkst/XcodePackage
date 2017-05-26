//
//  MYPackageQRCodeViewController.h
//  Package
//
//  Created by Whirlwind on 2017/2/13.
//  Copyright © 2017年 taobao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MYPackageQRCodeViewController : NSViewController

@property (weak) IBOutlet NSImageView *imageView;

@property (nonatomic, strong) NSImage *image;

@end
