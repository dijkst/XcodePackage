//
//  MYPackageContainerViewController.m
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageContainerViewController.h"
#import "MYPackagePrepareEnvironmentViewController.h"

#import "MYPackageTaskManager.h"

@interface MYPackageContainerViewController ()

@property (weak) IBOutlet NSView *contentView;
@property (weak) IBOutlet NSProgressIndicator *loadingView;
@property (weak) IBOutlet NSTextField *taskTextLabel;
@property (weak) IBOutlet NSView *rightButtonContainer;
@property (weak) IBOutlet NSView *bottomContainer;

@property (nonatomic, strong) MYPackageBaseViewController *currentViewController;

@end

@implementation MYPackageContainerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MYPackageTaskManagerWillRunTaskNotification object:nil];
}

- (void)awakeFromNib {
    self.backButton.showsBorderOnlyWhileMouseInside = YES;
    //    self.backButton.wantsLayer = YES;
    //    self.backButton.layer.cornerRadius = 0;
}

- (void)setRightButton:(NSButton *)rightButton {
    if (self.rightButton) {
        [self.rightButton removeFromSuperview];
    }
    [super setRightButton:rightButton];
    if (rightButton) {
        rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightButtonContainer addSubview:rightButton];
        [self.rightButtonContainer removeConstraints:self.rightButtonContainer.constraints];
        [self.rightButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[button]-0-|" options:0 metrics:0 views:@{@"button": rightButton}]];
        [self.rightButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button]-0-|" options:0 metrics:0 views:@{@"button": rightButton}]];
    }
}

- (MYPackageConfig *)config {
    if ([self.childViewControllers count] > 0) {
        return [[self.childViewControllers lastObject] config];
    }
    return [super config];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskWillRunNotification:)
                                                 name:MYPackageTaskManagerWillRunTaskNotification
                                               object:nil];
    MYPackagePrepareEnvironmentViewController *vc = [[MYPackagePrepareEnvironmentViewController alloc] init];
    [self pushViewController:vc animated:NO];
}

- (void)taskWillRunNotification:(NSNotification *)ntf {
    MYPackageBaseTask *task = [ntf.userInfo objectForKey:@"task"];
    [self showLoadingWithText:task.name ? [NSString stringWithFormat:@"正在%@...", task.name] : nil];
}

- (void)showNormalText:(NSString *)text {
    [self.taskTextLabel setTextColor:[NSColor grayColor]];
    [self.taskTextLabel setStringValue:text ? : @""];
}

- (void)showHighlightText:(NSString *)text {
    [self.taskTextLabel setTextColor:[NSColor redColor]];
    [self.taskTextLabel setStringValue:text ? : @""];
}

- (void)showLoadingWithText:(NSString *)text {
    dispatch_main_sync_safe(^{
        [self showNormalText:text];
        [self.loadingView startAnimation:nil];
    });
}

- (void)finishLoadingWithErrorText:(NSString *)text {
    dispatch_main_sync_safe(^{
        [self showHighlightText:text];
        [self.loadingView stopAnimation:nil];
    });
}

- (void)finishLoading {
    [self finishLoadingWithErrorText:nil];
}

- (void)changeTopViewController:(MYPackageBaseViewController *)vc {
    if (self.childViewControllers.count > 0) {
        [self removeChildViewControllerAtIndex:self.childViewControllers.count - 1];
    }
    [self pushViewController:vc];
}

- (void)pushViewController:(MYPackageBaseViewController *)vc {
    [self pushViewController:vc animated:YES];
}

- (void)pushViewController:(MYPackageBaseViewController *)vc animated:(BOOL)animated {
    vc.config = self.config;
    [self addChildViewController:vc];
    [vc.view setFrame:self.contentView.bounds];
    vc.containerVC = self;
    [self.backButton setHidden:!vc.showBackButton || [self.childViewControllers count] == 1];
    self.rightButton = vc.rightButton;
    id owner = nil;
    if (animated) {
        owner = [self.contentView animator];
        [NSAnimationContext beginGrouping];
        //        [[NSAnimationContext currentContext] setDuration:2.0];
    } else {
        owner = self.contentView;
    }
    if ([self.contentView.subviews count] > 0) {
        [owner replaceSubview:self.contentView.subviews[0] with:vc.view];
    } else {
        [owner addSubview:vc.view];
    }
    if (animated) {
        [NSAnimationContext endGrouping];
    }
    self.currentViewController = vc;
}

- (void)popViewController {
    [self popViewControllerWithAnimated:YES];
}

- (void)popViewControllerWithAnimated:(BOOL)animated {
    MYPackageBaseViewController *top = [self.childViewControllers lastObject];
    [self removeChildViewControllerAtIndex:self.childViewControllers.count - 1];
    MYPackageBaseViewController *prev = [self.childViewControllers lastObject];

    id owner = nil;
    if (animated) {
        owner = [self.contentView animator];
        [NSAnimationContext beginGrouping];
        //        [[NSAnimationContext currentContext] setDuration:2.0];
    } else {
        owner = self.contentView;
    }
    [owner replaceSubview:top.view with:prev.view];
    if (animated) {
        [NSAnimationContext endGrouping];
    }
    [self.backButton setHidden:!prev.showBackButton || self.childViewControllers.count == 1];
    self.rightButton = prev.rightButton;
    self.currentViewController = prev;
}

- (IBAction)backButtonAction:(id)sender {
    [self popViewControllerWithAnimated:YES];
}

@end
