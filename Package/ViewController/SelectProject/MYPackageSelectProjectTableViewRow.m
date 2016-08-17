//
//  MYPackageSelectProjectTableViewRow.m
//  Package
//
//  Created by Whirlwind on 15/11/26.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageSelectProjectTableViewRow.h"

@implementation MYPackageSelectProjectTableViewRow

- (void)awakeFromNib {
    self.pathLabel.lineBreakMode = NSLineBreakByTruncatingHead;
}

- (void)setPath:(NSString *)path {
    _path = path;
    [self.nameLabel setStringValue:[path lastPathComponent]];
    [self.pathLabel setStringValue:[path stringByDeletingLastPathComponent]];
}

@end
