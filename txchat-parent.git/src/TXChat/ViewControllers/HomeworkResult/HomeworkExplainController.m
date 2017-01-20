//
//  HomeworkExplainController.m
//  TXChatParent
//
//  Created by gaoju on 16/7/13.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkExplainController.h"
#import "HomeworkExplainCell.h"
#import "HomeworkExplainDetailController.h"
#import "HomeworkExplainAbilityController.h"

@interface HomeworkExplainController ()<UITableViewDelegate,UITableViewDataSource>{

    UITableView *_tableView;
    NSArray *_dataArr;
}

@end

@implementation HomeworkExplainController

static NSString *ID = @"HomeworkExplainController";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.\
    
    [self setupData];
    
    [self setupUI];
}

- (void)setupData{
    
    _dataArr = @[@{@"icon" : @"lc_icon_mark", @"title" : @"学能成绩指标解释"},
                 @{@"icon" : @"LC_icon_science", @"title" : @"什么是学习能力"},
                 @{@"icon" : @"LC_icon_ability", @"title" : @"科学依据PBCCI"},
                 @{@"icon" : @"LC_icon_five", @"title" : @"五大学习能力"},
                 @{@"icon" : @"LC_icon_team", @"title" : @"我们的团队"}];
}

- (void)setupUI{
    
    [self createCustomNavBar];
    self.titleStr = @"权威解释";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.height_, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 64.5;
}

#pragma mark: - UITableViewDataSource && UItableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeworkExplainCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[HomeworkExplainCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    cell.dict = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row != 3 && indexPath.row != 0) {
        
        HomeworkExplainDetailController *vc = [[HomeworkExplainDetailController alloc] init];
        vc.titleStr = _dataArr[indexPath.row][@"title"];
        vc.selectedIdx = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        
        HomeworkExplainAbilityController *vc = [[HomeworkExplainAbilityController alloc] init];
        vc.selectIdx = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
