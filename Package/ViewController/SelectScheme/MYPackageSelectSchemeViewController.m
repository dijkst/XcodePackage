//
//  MYPackageSelectSchemeViewController.m
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageSelectSchemeViewController.h"
#import "MYPackageContainerViewController.h"
#import "MYPackageSelectTaskViewController.h"

#import "MYPackageSelectSchemeTableViewRow.h"
#import "MYPackageTableRowView.h"

#import "MYPackageListSchemeTask.h"
#import "MYPackageAnalyzeSchemeTask.h"
#import "MYPackageAnalyzeProjectTask.h"
#import "MYPackageAnalyzeGitTask.h"
#import "MYPackageAnalyzeTargetTask.h"

@interface MYPackageSelectSchemeViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation MYPackageSelectSchemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView sizeLastColumnToFit];
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([MYPackageSelectSchemeTableViewRow class]) bundle:nil]
                 forIdentifier :@"row"];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.title = self.config.workspace.name;
    [self updateTableViewData];
}

- (void)updateTableViewData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self runTasks:@[NSStringFromClass([MYPackageListSchemeTask class])] autoOrder:NO]) {
            dispatch_main_async_safe(^{
                [self.tableView reloadData];
            });
        }
    });
}

#pragma mark - table view
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.config.workspace.schemes count];
}

- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[MYPackageTableRowView alloc] init];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    MYPackageSelectSchemeTableViewRow *rowView = (MYPackageSelectSchemeTableViewRow *)[tableView makeViewWithIdentifier:@"row" owner:self];
    [rowView.titleLabel setStringValue:[self.config.workspace.schemes[row] name]];
    return rowView;
}

- (IBAction)tableViewDoubleAction:(id)sender {
    [self selectScheme:self.config.workspace.schemes[self.tableView.selectedRow]];
}

#pragma mark - task
- (void)selectScheme:(MYPackageScheme *)scheme {
    self.config.selectedScheme = scheme;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self runTasks:@[NSStringFromClass([MYPackageAnalyzeSchemeTask class]),
                             NSStringFromClass([MYPackageAnalyzeProjectTask class]),
                             NSStringFromClass([MYPackageAnalyzeTargetTask class]) // 用于读取版本号
                             ]
                 autoOrder:YES]) {
            dispatch_main_async_safe(^{
                [self.containerVC pushViewController:[[MYPackageSelectTaskViewController alloc] init]];
            });
        }
    });
}

@end
