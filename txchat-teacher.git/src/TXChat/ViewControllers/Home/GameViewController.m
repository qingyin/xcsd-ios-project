//
//  GameViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/6/17.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "GameViewController.h"
#import "GameTableViewCell.h"

@interface GameViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *array;

@end

@implementation GameViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    [self setupUI];
}

- (void)setupUI{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.titleStr = @"能力训练";
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark: UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"GameTableViewCell";
    
    GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[GameTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    id source = self.array[indexPath.row];
    
    return cell;
}


- (UITableView *)tableView{
    if (_tableView == nil) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView = tableView;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
@end
