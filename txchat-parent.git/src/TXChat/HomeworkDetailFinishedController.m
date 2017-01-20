//
//  HomeworkDetailFinishedController.m
//  TXChatParent
//
//  Created by gaoju on 16/6/21.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkDetailFinishedController.h"
#import "HomeworkDescriptionView.h"
#import "HomeworkDetailCell.h"

@interface HomeworkDetailFinishedController ()<UITableViewDelegate,UITableViewDataSource>
{
    HomeworkDescriptionView *_descriptionView;
    UITableView *_tableView;
    XCSDHomeWork *_homework;
    NSArray *_array;
}


@end

@implementation HomeworkDetailFinishedController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupUI];
    
    [self addTableView];
}

- (void)setupUI{
    
    _descriptionView = [[HomeworkDescriptionView alloc] init].setHomework(_homework);
}

- (void)addTableView{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
    _tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, navHeight, kScreenWidth, kScreenHeight - navHeight) style:UITableViewStyleGrouped];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.bounces = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    _tableView.rowHeight = 60;
    
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDelegate & UITableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"homeworkDetailFinished";
    
    HomeworkDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[HomeworkDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    cell.setData(nil);
    
    return cell;
}


@end
