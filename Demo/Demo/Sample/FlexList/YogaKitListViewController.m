//
//  YogaKitListViewController.m
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/12/8.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "YogaKitListViewController.h"
#import "YogaKitListViewModel.h"
#import "ZDFlexCell.h"
#import <ZDFlexLayoutKit/ZDTemplateCellHandler.h>
#import <ZDToolKit/NSObject+ZDUtility.h>

@interface YogaKitListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) ZDTemplateCellHandler *cellHandler;
@end

@implementation YogaKitListViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
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
    self.dataSource = [YogaKitListViewModel yogaListModels];
    [_tableView reloadData];
}

#pragma mark - UITableViewDatasource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZDFlexCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
    TextureModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [self.cellHandler cellHeightWithTableView:tableView reuseIdentifier:[self reuseIdentifier] indexPath:indexPath configuration:^(UITableViewCell * _Nonnull templateCell) {
        TextureModel *model = self.dataSource[indexPath.row];
        [ZDFlexCell zd_cast:templateCell].model = model;
    }];
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (NSString *)reuseIdentifier {
    NSString *reuseId = NSStringFromClass(ZDFlexCell.class);
    return reuseId;
}

#pragma mark - Property

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.estimatedRowHeight = 0.f; // 禁用预估高度
        tableView.tableFooterView = [UIView new];
        [tableView registerClass:[ZDFlexCell class] forCellReuseIdentifier:NSStringFromClass([ZDFlexCell class])];
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
