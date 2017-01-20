//
//  CircleDepartmentViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleDepartmentViewController.h"
#import "CirclePublishViewController.h"

#define kCellContentViewBaseTag             121212

@interface CircleDepartmentViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_listTableView;
}

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) NSMutableArray *selectedArr;

@end

@implementation CircleDepartmentViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavBar];
    
    self.listArr = [NSMutableArray arrayWithObject:@"全部"];
    [_listArr addObjectsFromArray:[[TXChatClient sharedInstance] getAllDepartments:nil]];
    
    self.selectedArr = [NSMutableArray array];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    [_listArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TXDepartment *department = nil;
        if (idx != 0) {
            department = obj;
        }
        if (tmpObject.publishVC.departmentIds.count) {
            if (department &&
                [tmpObject.publishVC.departmentIds containsObject:@(department.departmentId)]) {
                [_selectedArr addObject:@(idx)];
            }
        }else{
            [_selectedArr addObject:@(idx)];

        }
    }];
    
    if (_selectedArr.count == _listArr.count - 1) {
        [_selectedArr addObject:@(0)];
    }
    
    [self.btnRight setTitle:[NSString stringWithFormat:@"选择（%@）",@(_selectedArr.count - 1)] forState:UIControlStateNormal];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    _listTableView.backgroundColor = kColorBackground;
    _listTableView.showsHorizontalScrollIndicator = NO;
    _listTableView.showsVerticalScrollIndicator = NO;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    [self.view addSubview:_listTableView];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnRight setTitle:@"选择" forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        if (!_selectedArr.count) {
            [self showFailedHudWithTitle:@"请至少选择一项"];
//            [self showAlertViewWithMessage:@"请至少选择一项" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            return;
        }
        
        NSMutableArray *arr = [NSMutableArray array];
        __block NSMutableString *str = [NSMutableString string];
        [_selectedArr enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL *stop) {
            if (![_listArr[index.integerValue] isKindOfClass:[NSString class]]) {
                TXDepartment *department = _listArr[index.integerValue];
                [arr addObject:@(department.departmentId)];
                [str appendFormat:@"%@,",department.name];
            }
        }];
        if ([_selectedArr containsObject:@(0)]) {
            str = [NSMutableString stringWithString:@"全部"];
        }
        if ([str hasSuffix:@","]) {
            [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
        }
        _publishVC.rcvUsersLabel.text = str;
        _publishVC.departmentIds = arr;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(14, 0, tableView.width_ - 28, 45)];
        titleLb.font = kFontMiddle;
        titleLb.tag = kCellContentViewBaseTag;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UIImageView *maskImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_mask_1"]];
        maskImgView.frame = CGRectMake(tableView.width_ - 14 - 22, 23/2, 22, 22);
        maskImgView.tag = kCellContentViewBaseTag + 1;
        [cell.contentView addSubview:maskImgView];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(14, 45 - kLineHeight, self.view.width_ - 28, kLineHeight)];
        lineView.tag = kCellContentViewBaseTag + 2;
        [cell.contentView addSubview:lineView];
    }
    
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    UIImageView *maskImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
    UIView *lineView = [cell.contentView viewWithTag:kCellContentViewBaseTag + 2];
    
    if ([_listArr[indexPath.row] isKindOfClass:[NSString class]]) {
        titleLb.text = @"全部";
    }else{
        TXDepartment *department = _listArr[indexPath.row];
        titleLb.text = department.name;
        
    }
    
    maskImgView.image = [_selectedArr containsObject:@(indexPath.row)]?[UIImage imageNamed:@"btn_mask"]:[UIImage imageNamed:@"btn_mask_1"];
    
    if (indexPath.row != _listArr.count - 1) {
        lineView.hidden = NO;
    }else{
        lineView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!indexPath.row) {
        if ([_selectedArr containsObject:@(indexPath.row)]) {
            [_selectedArr removeAllObjects];
            [_listTableView reloadData];
        }else{
            [_selectedArr removeAllObjects];
            [_listArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_selectedArr addObject:@(idx)];
            }];
            [_listTableView reloadData];
        }
    }else{
        if ([_selectedArr containsObject:@(0)]) {
            [_selectedArr removeObject:@(0)];
            [_selectedArr removeObject:@(indexPath.row)];
        }else if([_selectedArr containsObject:@(indexPath.row)]){
            [_selectedArr removeObject:@(indexPath.row)];
        }else{
            [_selectedArr addObject:@(indexPath.row)];
            if (_selectedArr.count == _listArr.count - 1) {
                [_selectedArr addObject:@(0)];
            }
        }
        [_listTableView reloadData];
    }
    if ([_selectedArr containsObject:@(0)]) {
        [self.btnRight setTitle:[NSString stringWithFormat:@"选择（%@）",@(_selectedArr.count - 1)] forState:UIControlStateNormal];
    }else{
        if (_selectedArr.count) {
            [self.btnRight setTitle:[NSString stringWithFormat:@"选择（%@）",@(_selectedArr.count)] forState:UIControlStateNormal];
        }else{
            [self.btnRight setTitle:@"选择" forState:UIControlStateNormal];
        }
    }
}



@end
