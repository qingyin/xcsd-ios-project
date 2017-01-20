//
//  HomeworkResultCompareController.m
//  TXChatParent
//
//  Created by gaoju on 12/27/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import "HomeworkResultCompareController.h"
#import "LeftInsetLabel.h"
#import "UIColor+Hex.h"
#import "HomeworkCompareCell.h"

@interface HomeworkResultCompareController ()<UITableViewDelegate, UITableViewDataSource>



@end

@implementation HomeworkResultCompareController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    [self createCustomNavBar];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.height_, kScreenWidth, kScreenHeight - self.customNavigationView.height_) style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = [self createHeaderView];
//    tableView.sectionHeaderHeight = 44;
    tableView.rowHeight = 52;
}

- (void)createCustomNavBar {
    [super createCustomNavBar];
    self.titleStr = @"对比";
}

- (UIView *)createHeaderView {
    UIView *headerV = [[UIView alloc] init];
    headerV.layer.backgroundColor = [UIColor colorWithHexRGB:@"F3F3F3"].CGColor;
    
    LeftInsetLabel *titleLbl = [[LeftInsetLabel alloc] init];
    titleLbl.leftInset = 10;
    
    titleLbl.text = @"选择不同群体, 与他们的平均学能成绩进行对比.";
    titleLbl.textColor = [UIColor colorWithHexRGB:@"484848"];
    titleLbl.backgroundColor = [UIColor whiteColor];
    titleLbl.font = [UIFont systemFontOfSize:14];
    
    titleLbl.frame = CGRectMake(0, 9, kScreenWidth, 30);
    
    [headerV addSubview:titleLbl];
    headerV.frame = CGRectMake(0, 0, kScreenWidth, 44);
    
    return headerV;
}

#pragma mark: - TableViewDataSource && TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"HomeworkResultCompareController";
    
    HomeworkCompareCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[HomeworkCompareCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.onCompleted) {
        self.onCompleted(indexPath.row);
    }
}




- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[
                     @"学前",
                     @"一年级",
                     @"二年级",
                     @"三年级",
                     @"四年级",
                     @"五年级",
                     @"六年级",
                     ];
    }
    return _dataArr;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
