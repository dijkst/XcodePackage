//
//  MYPackageSelectProjectTableViewRow.h
//  Package
//
//  Created by Whirlwind on 15/11/26.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MYPackageSelectProjectTableViewRow : NSView
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSTextField *pathLabel;
@property (weak) IBOutlet NSButton *deleteButton;

@property (nonatomic, strong) NSString *path;

@end
