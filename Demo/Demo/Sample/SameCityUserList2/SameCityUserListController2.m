//
//  SameCityUserListController2.m
//  Demo
//
//  Created by Zero.D.Saber on 2022/02/27.
//  Copyright © 2022 Zero.D.Saber. All rights reserved.
//

#import "SameCityUserListController2.h"
#import "SameCityUserListViewModel.h"
#import "UserTableViewCell2.h"

@interface SameCityUserListController2 ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<UserModel *> *dataSource;
@end

@implementation SameCityUserListController2

- (void)dealloc {
    printf("%s\n", __PRETTY_FUNCTION__);
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
    self.navigationItem.title = @"FlexLayoutListDemo2";
    self.view.backgroundColor = UIColor.purpleColor;
    
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
    UserTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (NSString *)reuseIdentifier {
    NSString *reuseId = NSStringFromClass(UserTableViewCell2.class);
    return reuseId;
}

#pragma mark - Property

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor cyanColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.dataSource = self;
        tableView.delegate = self;
        //tableView.estimatedRowHeight = 110;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.tableFooterView = [UIView new];
        [tableView registerClass:[UserTableViewCell2 class] forCellReuseIdentifier:[self reuseIdentifier]];
        _tableView = tableView;
    }
    return _tableView;
}

@end
