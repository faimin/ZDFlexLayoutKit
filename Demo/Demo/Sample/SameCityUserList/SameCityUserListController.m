//
//  SameCityUserListController.m
//  Demo
//
//  Created by Zero.D.Saber on 2019/10/22.
//  Copyright © 2019 Zero.D.Saber. All rights reserved.
//

#import "SameCityUserListController.h"
#import <ZDFlexLayoutKit/ZDTemplateCellHandler.h>
#import "SameCityUserListViewModel.h"
#import "UserTableViewCell.h"

@interface SameCityUserListController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<UserModel *> *dataSource;
@property (nonatomic, strong) ZDTemplateCellHandler *cellHandler;
@property (nonatomic, assign) CGFloat lastTableWidth;
@end

@implementation SameCityUserListController

- (void)dealloc {
    printf("%s\n", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    if (fabs(width - self.lastTableWidth) <= 0.5) {
        return;
    }
    BOOL hadWidth = self.lastTableWidth > 0;
    self.lastTableWidth = width;
    if (hadWidth) {
        [self.cellHandler invalidateHeightCache];
        [self.tableView reloadData];
    }
}

- (void)setup {
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    self.navigationItem.title = @"FlexLayoutListDemo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

- (void)setupData {
    self.dataSource = [SameCityUserListViewModel userListModels];
    [_tableView reloadData];
}

#pragma mark - UITableViewDatasource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [self.cellHandler cellHeightWithTableView:tableView reuseIdentifier:[self reuseIdentifier] indexPath:indexPath configuration:^(UITableViewCell * _Nonnull templateCell) {
        UserModel *model = self.dataSource[indexPath.row];
        if ([templateCell isKindOfClass:UserTableViewCell.self]) {
            ((UserTableViewCell *)templateCell).model = model;
        }
    }];

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (NSString *)reuseIdentifier {
    NSString *reuseId = NSStringFromClass(UserTableViewCell.class);
    return reuseId;
}

#pragma mark - Property

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.backgroundColor = [UIColor grayColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.estimatedRowHeight = 0.f;
        tableView.tableFooterView = [UIView new];
        [tableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:[self reuseIdentifier]];
        _tableView = tableView;
    }
    return _tableView;
}

- (ZDTemplateCellHandler *)cellHandler {
    if (!_cellHandler) {
        _cellHandler = [ZDTemplateCellHandler new];
    }
    return _cellHandler;
}

@end
