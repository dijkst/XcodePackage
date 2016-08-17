//
//  MYPackageContainerViewController.h
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageBaseViewController.h"
#import "MYPackageConfig.h"

@interface MYPackageContainerViewController : MYPackageBaseViewController

@property (nonatomic, readonly) MYPackageBaseViewController *currentViewController;

@property (weak) IBOutlet NSButton *backButton;

@property (strong) IBOutlet NSWindow              *logWindow;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

- (void)showNormalText:(NSString *)text;
- (void)showHighlightText:(NSString *)text;

- (void)showLoadingWithText:(NSString *)text;
- (void)finishLoadingWithErrorText:(NSString *)text;
- (void)finishLoading;

- (void)changeTopViewController:(MYPackageBaseViewController *)vc;
- (void)pushViewController:(MYPackageBaseViewController *)vc;
- (void)popViewController;

@end
