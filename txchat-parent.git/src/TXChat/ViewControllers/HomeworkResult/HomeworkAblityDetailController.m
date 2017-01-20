//
//  HomeworkAblityDetailController.m
//  TXChatParent
//
//  Created by gaoju on 16/7/13.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkAblityDetailController.h"
#import "UILabel+ContentSize.h"
#import "UIImage+Rotate.h"
#import "UIColor+Hex.h"
#import "HomeworkAbilityDetailCell.h"
#import "XCSDLearningAbilityManager.h"
#import "HomeworkAbilityCell.h"

#define kTitle_Bar_height 30

@interface HomeworkAblityDetailController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic,strong) NSArray *dataArr;

@property (nonatomic, weak) UILabel *totalScoreLbl;

@end

@implementation HomeworkAblityDetailController

static NSString *ID = @"HomeworkAblityDetailController";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    [self setupTableView];
    
    [self fetchData];
    
//    [self addEmptyDataImage:YES showMessage:@"还没有获得学能积分，快去做游戏吧！"];
//    
//    [self updateEmptyDataImageStatus:YES];
    
    self.tableView.hidden = YES;
}
- (void)fetchData{
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] fetchChild:^(NSError *error, TXUser *childUser) {
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) {
            return ;
        }
        
        [[TXChatClient sharedInstance] GameStatus:childUser.userId ability:self.ability onCompleted:^(NSError *error, NSInteger totalScore, NSArray *gameList) {
            
            if (error) {
                [self showFailedHudWithError:error];
                return ;
            }
            
            if (gameList.count == 0) {
                return;
            }
//            [self updateEmptyDataImageStatus:NO];
            self.tableView.hidden = NO;
            self.totalScoreLbl.text = [NSString stringWithFormat:@"%@  %ld分",self.totalScoreLbl.text, (long)totalScore];
            self.dataArr = gameList;
            [self.tableView reloadData];
        }];
    }];
    
    
}

- (void)setupTableView{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, kScreenWidth, kScreenHeight - navHeight) style:UITableViewStylePlain];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.rowHeight = 243.5;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = NO;
    
//    tableView.tableHeaderView = [self createHeaderView];
}

#pragma mark: - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    HomeworkAbilityDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    
//    if (!cell) {
//        cell = [[HomeworkAbilityDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
//    }
//    
//    cell.gameScore = self.dataArr[indexPath.row];
//    
//    return cell;
    
    HomeworkAbilityCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[HomeworkAbilityCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    cell.gameScore = self.dataArr[indexPath.row];
    
    return cell;
}

- (UIView *)createHeaderView{
    
    UIView *view = UIView.new;
    view.frame = CGRectMake(0, 0, kScreenWidth, kTitle_Bar_height);
    view.layer.backgroundColor = RGBCOLOR(247, 247, 247).CGColor;
    
    UILabel *label = UILabel.new;
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textColor = [UIColor colorWithHexRGB:@"fd9a37"];
    [label sizeToFit];
    label.text = @"学能总积分:";
    
    self.totalScoreLbl = label;
    
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(12);
        make.centerY.equalTo(view.mas_centerY);
    }];
    
    return view;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
