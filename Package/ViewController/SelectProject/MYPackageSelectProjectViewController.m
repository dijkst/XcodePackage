//
//  MYPackageSelectProjectViewController.m
//  Package
//
//  Created by Whirlwind on 15/11/23.
//  Copyright © 2015年 taobao. All rights reserved.
//

#import "MYPackageSelectProjectViewController.h"
#import "MYPackageSelectSchemeViewController.h"
#import "MYPackageContainerViewController.h"

#import "MYPackageListOpenedProjectTask.h"

#import "MYPackageSelectProjectTableViewHeader.h"
#import "MYPackageSelectProjectTableViewRow.h"
#import "MYPackageTableRowView.h"

@interface MYPackageSelectProjectViewController () <NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSArray *openedProjects;
@property (nonatomic, strong) NSArray *openHistories;
@property (nonatomic, strong) NSArray *tableData;

@end

@implementation MYPackageSelectProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showBackButton = NO;
    [self.tableView sizeLastColumnToFit];
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([MYPackageSelectProjectTableViewHeader class]) bundle:nil]
                 forIdentifier :@"header"];
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass([MYPackageSelectProjectTableViewRow class]) bundle:nil]
                 forIdentifier :@"row"];
    [self loadOpenedProjects];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    self.config.workspaceFilePath = nil;
}

- (void)loadOpenedProjects {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self runTasks:@[NSStringFromClass([MYPackageListOpenedProjectTask class])] autoOrder:NO]) {
            dispatch_main_async_safe(^{
                // 处理打开 project 里面的 workspace
                NSArray *opened = nil;
                if ([self.taskManager.output length] > 0) {
                    opened = [NSJSONSerialization JSONObjectWithData:[self.taskManager.output dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                }
                NSMutableArray *openedProjects = [NSMutableArray arrayWithCapacity:[opened count]];
                for (NSString *path in opened) {
                    if ([[[path pathExtension] lowercaseString] isEqualToString:@"xcworkspace"]) {
                        NSRange range = [[path lowercaseString] rangeOfString:@".xcodeproj"];
                        if (range.location == NSNotFound) {
                            [openedProjects addObject:path];
                        } else {
                            [openedProjects addObject:[path substringToIndex:NSMaxRange(range)]];
                        }
                    } else {
                        [openedProjects addObject:path];
                    }
                }
                self.openedProjects = openedProjects;
                [self updateTableViewData];
            });
        }
    });
}

- (void)updateTableViewData {
    NSMutableArray *data = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"# 打开的项目 (%zd)", [self.openedProjects count]]];
    [data addObjectsFromArray:self.openedProjects];

    // 过滤历史中正在打开的项目
    NSArray *histories = [self.openHistories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (id _Nonnull evaluatedObject, NSDictionary < NSString *, id > *_Nullable bindings) {
        return [self.openedProjects indexOfObject:evaluatedObject] == NSNotFound;
    }]];

    if ([histories count] > 0) {
        [data addObject:[NSString stringWithFormat:@"# 历史项目 (%zd)", [histories count]]];
        [data addObjectsFromArray:histories];
    }

    self.tableData = data;
    [self.tableView reloadData];
}

- (NSArray *)openHistories {
    if (!_openHistories) {
        NSArray *histories = [[NSUserDefaults standardUserDefaults] arrayForKey:@"openHistories"];
        if (!histories) {
            _openHistories = @[];
        } else {
            _openHistories = [histories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (id _Nonnull evaluatedObject, NSDictionary < NSString *, id > *_Nullable bindings) {
                return [[NSFileManager defaultManager] fileExistsAtPath:evaluatedObject];
            }]];
            [[NSUserDefaults standardUserDefaults] setObject:_openHistories forKey:@"openHistories"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return _openHistories;
}

- (void)addHistory:(NSString *)path {
    if (!path) {
        return;
    }
    NSMutableArray *histories = [self.openHistories mutableCopy];
    NSInteger      index      = [histories indexOfObject:path];
    if (index != NSNotFound) {
        [histories removeObjectAtIndex:index];
    }
    [histories insertObject:path atIndex:0];
    if ([histories count] > 10) {
        self.openHistories = [histories subarrayWithRange:NSMakeRange(0, 10)];
    } else {
        self.openHistories = histories;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.openHistories forKey:@"openHistories"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateTableViewData];
}

- (void)deleteHistory:(NSButton *)btn {
    if (![btn.superview isKindOfClass:[MYPackageSelectProjectTableViewRow class]]) {
        return;
    }
    MYPackageSelectProjectTableViewRow *row   = (MYPackageSelectProjectTableViewRow *)(btn.superview);
    NSMutableArray                     *array = [_openHistories mutableCopy];
    [array removeObject:row.path];
    _openHistories = array;
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"openHistories"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateTableViewData];
}

- (void)cleanHistory {
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:@"openHistories"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.openHistories = @[];
    [self updateTableViewData];
}

#pragma mark - table view
- (BOOL)isHeaderForRow:(NSInteger)row {
    return [self.tableData[row] hasPrefix:@"# "];
}

- (NSString *)pathForRow:(NSInteger)row {
    return self.tableData[row];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.tableData count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self isHeaderForRow:row]) {
        return 18;
    }
    return 60;
}

- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[MYPackageTableRowView alloc] init];
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([self isHeaderForRow:row]) {
        MYPackageSelectProjectTableViewHeader *headerView = [tableView makeViewWithIdentifier:@"header" owner:self];
        headerView.titleLabel.stringValue = [self pathForRow:row];
        if (row == 0) {
            [headerView.otherButton setImage:[NSImage imageNamed:NSImageNameRefreshTemplate]];
            [headerView.otherButton setTarget:self];
            [headerView.otherButton setAction:@selector(loadOpenedProjects)];
        } else {
            [headerView.otherButton setImage:[NSImage imageNamed:NSImageNameTrashEmpty]];
            [headerView.otherButton setTarget:self];
            [headerView.otherButton setAction:@selector(cleanHistory)];
        }
        return headerView;
    }
    MYPackageSelectProjectTableViewRow *rowView = [tableView makeViewWithIdentifier:@"row" owner:self];
    rowView.path = [self pathForRow:row];
    [rowView.deleteButton setHidden:row <= [self.openedProjects count]];
    [rowView.deleteButton setTarget:self];
    [rowView.deleteButton setAction:@selector(deleteHistory:)];
    return rowView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return ![self isHeaderForRow:row];
}

#pragma mark - action
- (IBAction)tableViewDoubleAction:(id)sender {
    if ([self.tableData count] > self.tableView.selectedRow) {
        [self openProject:[self pathForRow:self.tableView.selectedRow]];
    }
}

- (IBAction)openOtherProjectAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"xcworkspace", @"xcodeproj"]];
    NSInteger clicked = [panel runModal];
    if (clicked != NSFileHandlingPanelOKButton) {
        return;
    }
    NSString *url = [[panel URL] path];
    [self openProject:url];
}

- (void)openProject:(NSString *)path {
    if (self.busy) {
        return;
    }
    [self.config setWorkspaceFilePath:path];
    dispatch_main_async_safe(^{
        MYPackageSelectSchemeViewController *vc = [[MYPackageSelectSchemeViewController alloc] init];
        [self.containerVC pushViewController:vc];
        [self addHistory:path];
    });
}

@end
