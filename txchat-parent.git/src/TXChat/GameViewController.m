//
//  GameViewController.m
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "GameViewController.h"
#import "GameTableViewCell.h"

@interface GameViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    UITableView *_tableView;
    NSArray *_array;
}


@end

@implementation GameViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupUI];
    
    [self createCustomNavBar];
}

- (void)setupUI{
    
    self.titleStr = @"能力训练";
    //FIXME: frame效果未知
    CGRect frame = CGRectMake(0, self.customNavigationView.height_, kScreenWidth, kScreenHeight);
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"GameViewController";
    GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[GameTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
//    cell.setData(_array[indexPath.row]);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - 重载父类方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
    }
}

@end
