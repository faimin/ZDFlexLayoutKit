//
//  YogaKitListViewController.m
//  ZDOpenSourceOCDemo
//
//  Created by Zero.D.Saber on 2017/12/8.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "YogaKitListViewController.h"
#import "YogaKitListViewModel.h"
#import "YogaCell.h"
#import "ZDFlexCell.h"
#import "ZDTemplateCellHandler.h"
#import <ZDToolKit/NSObject+ZDUtility.h>

#define USE_ZDFlex (1)

@interface YogaKitListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) ZDTemplateCellHandler *cellHandler;
@end

@implementation YogaKitListViewController

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
    self.navigationItem.title = @"YogaKitListDemo";
    self.view.backgroundColor = [UIColor whiteColor];
    
    /** Test Yoga constraint
    YogaCell *cell = [[YogaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 100);
    cell.contentView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:cell];
    cell.model = [TextureViewModel textureModels].firstObject;
    */
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
    YogaCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
    TextureModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [self.cellHandler cellHeightWithTableView:tableView reuseIdentifier:[self reuseIdentifier] indexPath:indexPath configuration:^(UITableViewCell * _Nonnull templateCell) {
        TextureModel *model = self.dataSource[indexPath.row];
#if USE_ZDFlex
        [ZDFlexCell zd_cast:templateCell].model = model;
#else
        [YogaCell zd_cast:templateCell].model = model;
#endif
    }];
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (NSString *)reuseIdentifier {
    NSString *reuseId = nil;
#if USE_ZDFlex
    reuseId = NSStringFromClass(ZDFlexCell.class);
#else
    reuseId = NSStringFromClass(YogaCell.class);
#endif
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
        [tableView registerClass:[YogaCell class] forCellReuseIdentifier:NSStringFromClass([YogaCell class])];
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

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
