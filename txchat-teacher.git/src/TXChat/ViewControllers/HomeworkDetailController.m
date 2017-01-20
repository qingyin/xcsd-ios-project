//
//  HomeworkDetailController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/6/27.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeworkDetailController.h"
#import "HomeworkDetailCell.h"
#import "XCSDGame.pb.h"

#define K_MARGIN 10

@interface HomeworkDetailController ()<UITableViewDataSource>{
    
    UITableView *_tableView;
    NSArray *_gameLevels;
    int64_t _class_Id;
    int64_t _childUserId;
}



@end

@implementation HomeworkDetailController

static NSString *ID = @"homeworkDetailController";

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    [self setupUI];
}

- (void)fetchData{
    
    [[TXChatClient sharedInstance].homeWorkManager fetchHomeGenerateDetailWithClass_ID:_class_Id childUserId:_childUserId onCompleted:^(NSError *error, NSArray *gameLevels) {
        if (error) {
            
            return ;
        }
        _gameLevels = gameLevels;
        [_tableView reloadData];
        
    }];
}

- (void (^)(int64_t, int64_t))setData{
    
    return ^(int64_t childUserId, int64_t class_Id){
        _childUserId = childUserId;
        _class_Id = class_Id;
        
        [self fetchData];
    };
}

- (void)setupUI{
    
    self.titleStr = @"定制作业详情";
    
    UILabel *homeworkLbl = [[UILabel alloc] init];
    homeworkLbl.frame = CGRectMake(15, self.customNavigationView.height_, kScreenWidth, 42);
    [self.view addSubview:homeworkLbl];
    
    homeworkLbl.textColor = RGBCOLOR(83, 83, 83);
    homeworkLbl.backgroundColor = RGBCOLOR(243, 243, 243);
    homeworkLbl.text = @"定制作业列表";
    homeworkLbl.font = [UIFont boldSystemFontOfSize:15];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, homeworkLbl.maxY, kScreenWidth, kScreenHeight - homeworkLbl.maxY - K_MARGIN) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.bounces = NO;
    _tableView.rowHeight = 65;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _gameLevels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeworkDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[HomeworkDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    XCSDPBGameLevel *gameLevel = _gameLevels[indexPath.row];
    
    cell.setData(gameLevel).showStarsView(NO);
    
    return cell;
}

- (void)onClickBtn:(UIButton *)sender{
    
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
