//
//  SecureListViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SecureListViewController.h"
#import "MobileViewController.h"
#import "UpdatePasswordViewController.h"
#import "UpdateMobileViewController.h"

#define kCellContentViewBaseTag             213131

typedef enum : NSUInteger {
    SecureListType_Mobile = 0,
    SecureListType_Password,
} SecureListType;

@interface SecureListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_listTableView;
    NSArray *_listArr;
}

@end

@implementation SecureListViewController

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshUserInfo:) name:kRefreshUseInfo object:nil];
    }
    return self;
}

- (void)onRefreshUserInfo:(NSNotification *)notification{
    [_listTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"帐户安全";
    [self createCustomNavBar];
    
    _listArr = @[
                 @[@{@"title":@"手机号",@"type":@(SecureListType_Mobile)}, @{@"title":@"修改密码",@"type":@(SecureListType_Password)}],
                 ];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_) style:UITableViewStylePlain];
    _listTableView.backgroundColor = kColorBackground;
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = _listArr[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, 5)];
    view.backgroundColor = kColorBackground;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *arr = _listArr[indexPath.section];
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(13, 0, tableView.width_ - 26, 45)];
        titleLb.font = kFontMiddle;
        titleLb.textColor = kColorBlack;
        titleLb.tag = kCellContentViewBaseTag;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UILabel *subTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        subTitleLb.font = kFontSmall;
        subTitleLb.textColor = kColorBlack;
        subTitleLb.tag = kCellContentViewBaseTag + 1;
        subTitleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:subTitleLb];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(0, 45 - kLineHeight, self.view.width_, kLineHeight)];
        lineView.tag = kCellContentViewBaseTag + 2;
        [cell.contentView addSubview:lineView];
    }
    
    
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    UILabel *subTitleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
    UIView *lineView = [cell.contentView viewWithTag:kCellContentViewBaseTag + 2];
    
    titleLb.text = arr[indexPath.row][@"title"];
    NSNumber *type = arr[indexPath.row][@"type"];
    NSError *error = nil;
    if (type.integerValue == SecureListType_Mobile) {
        TXUser *txUser = [[TXChatClient sharedInstance] getCurrentUser:&error];
        subTitleLb.text = txUser.mobilePhoneNumber;
    }else{
        subTitleLb.text = @"";
    }
    [subTitleLb sizeToFit];
    subTitleLb.frame = CGRectMake(tableView.width_ - 35 - subTitleLb.width_, 0, subTitleLb.width_, 45);
    
    if (indexPath.row != arr.count - 1) {
        lineView.hidden = NO;
    }else{
        lineView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = _listArr[indexPath.section];
    NSNumber *type = arr[indexPath.row][@"type"];
    
    switch (type.intValue) {
        case SecureListType_Mobile://手机号
        {
//            MobileViewController *mobileVC = [[MobileViewController alloc] init];
//            [self.navigationController pushViewController:mobileVC animated:YES];
            UpdateMobileViewController *presentViewController = [[UpdateMobileViewController alloc] init];
            presentViewController.mobileVC = self;
            [self.navigationController pushViewController:presentViewController animated:YES];
        }
            break;
        case SecureListType_Password://修改密码
        {
            UpdatePasswordViewController *updatePwd = [[UpdatePasswordViewController alloc] init];
            [self.navigationController pushViewController:updatePwd animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
