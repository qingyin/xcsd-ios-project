//
//  ParentsDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ParentsDetailViewController.h"
#import "UserDetailTableViewCell.h"
#import "BabyDetailTableViewCell.h"
#import "TXParentChatViewController.h"
#import <TXChatClient.h>
#import <TXUser.h>
#import "TXUser+Utils.h"
#import "UIImageView+EMWebCache.h"
#import "TXPhotoBrowserViewController.h"
#import <SDiPhoneVersion.h>

typedef enum : NSUInteger {
    ParentDetailType_Sex = 0,             //性别
    ParentDetailType_Class,            //班级
    ParentDetailType_Position,             //职位
    ParentDetailType_Garden,             //幼儿园
    ParentDetailType_Mobile,             //手机
} ParentDetailType;

#define KSECTIONHEIGHT1 37.0f
#define KSECTIONHEIGHT2 132.0f
#define KCELLHIGHT 50.0f

#define KNAMEKEY @"name"
#define KTYPEKEY @"type"

@interface ParentsDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    BOOL _isParent;
    TXUser *_user;
    NSMutableArray *_childs;
    int64_t _userId;
    
}
@end

@implementation ParentsDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isParent = NO;

    }
    return self;
}

-(id)initWithIdentity:(int64_t)userId
{
    self = [super init];
    if(self)
    {
        _userId = userId;
        _user = [[TXChatClient sharedInstance] getUserByUserId:userId error:nil];
        if(_user.userType == TXPBUserTypeParent)
        {
            _isParent = YES;
            _childs = [NSMutableArray arrayWithCapacity:2];
            TXUser *child = [[TXChatClient sharedInstance] getUserByUserId:_user.childUserId error:nil];
            if(child)
            {
                [_childs addObject:child];
            }
        }
        else
        {
            _isParent = NO;
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = _user.nickname;
    self.umengEventText = @"联系人详情";
    [self createCustomNavBar];
    if(_user == nil)
    {
        [self createUser];
    }
    [self createTitles];
//    _isParent = YES;
//    _isParent = NO;
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];

    UIView *superview = self.view;
//    by mey 
//    WEAKSELF
    __weak __typeof(&*self)weakSelf=self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.left.mas_equalTo(superview);
        make.right.mas_equalTo(superview);
        make.height.mas_equalTo(KSECTIONHEIGHT1 + KSECTIONHEIGHT2 + 4*KCELLHIGHT);
    }];
    
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if(currentUser.userId != _user.userId && _user.activated)
    {
        UIButton *sendMessageBtn = [UIButton new];
        [sendMessageBtn setTitle:@"发消息" forState:UIControlStateNormal];
        [sendMessageBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [sendMessageBtn setBackgroundColor:KColorAppMain];
        [sendMessageBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
        [sendMessageBtn setTitleColor:kColorGray forState:UIControlStateHighlighted];
        [sendMessageBtn setImage:[UIImage imageNamed:@"sendMsgIcon"] forState:UIControlStateNormal];
        [sendMessageBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [sendMessageBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        [self.view addSubview:sendMessageBtn];
        
        CGFloat btnHight = 40.0f;
        if([SDiPhoneVersion deviceSize] == iPhone55inch)
        {
            btnHight = 44.0f;
        }

        [sendMessageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(superview.mas_bottom).with.offset(-btnHight);
            make.left.mas_equalTo(superview).with.offset(0);
            make.right.mas_equalTo(superview).with.offset(0);
            make.height.mas_equalTo(btnHight);
        }];
    }
    [[TXChatClient sharedInstance] fetchUserByUserId:_userId onCompleted:^(NSError *error, TXUser *txUser) {
        if(error)
        {
            ButtonItem *backItem = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            [weakSelf showAlertViewWithMessage:error.userInfo[kErrorMessage] andButtonItems:backItem, nil];
        }
    }];
    
}

-(void)createTitles
{
    if(_isParent)
    {
        NSMutableArray *children = [NSMutableArray arrayWithCapacity:2];
        for(TXUser *index in _childs)
        {
            if(index)
            {
                [children addObject:index];
            }
        }
        
        _titleArray = @[@[ @{KNAMEKEY:@"孩子性别", KTYPEKEY:@(ParentDetailType_Sex)}, @{KNAMEKEY:@"班级", KTYPEKEY:@(ParentDetailType_Class)}, @{KNAMEKEY:@"学校", KTYPEKEY:@(ParentDetailType_Garden)}]];
    }
    else
    {
        _titleArray = @[@[ @{KNAMEKEY:@"职位", KTYPEKEY:@(ParentDetailType_Position)}, @{KNAMEKEY:@"学校", KTYPEKEY:@(ParentDetailType_Garden)}]];
    }
}
-(void)createUser
{
    _user = [[TXChatClient sharedInstance] getUserByUserId:[_emChatterId longLongValue] error:nil];
    if(_user.userType == TXPBUserTypeParent)
    {
        _childs = [NSMutableArray arrayWithCapacity:2];
        TXUser *child = [[TXChatClient sharedInstance] getUserByUserId:_user.childUserId error:nil];
        [_childs addObject:child];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_titleArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[_titleArray objectAtIndex:section] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    if(indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"UserDetailTableViewCell";
        UserDetailTableViewCell *UserDetailCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (UserDetailCell == nil) {
            UserDetailCell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        NSDictionary *dic = [[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString *title = dic[KNAMEKEY];
        NSNumber *type = dic[KTYPEKEY];
        [UserDetailCell.titleLabel setText:title];
        [UserDetailCell.titleLabel setFont:kFontTitle];
        [UserDetailCell.titleLabel setTextColor:KColorTitleTxt];
        NSString *content = nil;
        if(_isParent)
        {
            switch (type.integerValue) {
                case ParentDetailType_Sex:
                    content = [_user getSexStr];
                    break;
                case ParentDetailType_Class:
                    content = _user.className;
                    break;
                case ParentDetailType_Garden:
                    content = _user.gardenName;
                    break;
                default:
                    break;
            }
        }
        else
        {
            switch (type.integerValue) {
                case ParentDetailType_Sex:
                    content = [_user getSexStr];
                    break;
                case ParentDetailType_Position:
                    content = [_user positionName];
                    break;
                case ParentDetailType_Garden:
                    content = _user.gardenName;
                    break;
                default:
                    break;
            }
        
        }
        [UserDetailCell.contentLabel setText:content];
        [UserDetailCell.contentLabel setFont:kFontTitle];
        [UserDetailCell.contentLabel setTextColor:KColorSubTitleTxt];
        if(indexPath.row == [(NSArray *)[_titleArray objectAtIndex:indexPath.section] count] -1)
        {
            [UserDetailCell.seperatorLine setHidden:YES];
        }
        [UserDetailCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell = UserDetailCell;
    }
    return cell;
}




#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return KSECTIONHEIGHT2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
    return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UIView *headerView = nil;
    if(section == 0)
    {
        headerView = [[UIView alloc] init];
        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT2);
        headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
        UIImageView *bkView = [UIImageView new];
        [bkView setImage:[UIImage imageNamed:@"groupDetailHeaderBk"]];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FromViewTapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = NO;
        bkView.userInteractionEnabled = YES;
        [bkView addGestureRecognizer:tap];
        [headerView addSubview:bkView];
        [bkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(headerView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        CGFloat imageWidth = 70.0f;
        
        UIImageView *headImage = [[UIImageView alloc] init];
        [headImage TX_setImageWithURL:[NSURL URLWithString:[_user getFormatAvatarUrl:imageWidth hight:imageWidth]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon_70"]];
        headImage.layer.cornerRadius = 8.0f/2.0f;
        headImage.layer.masksToBounds = YES;
        [headerView addSubview:headImage];
        [headImage mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(headerView).with.offset(kEdgeInsetsLeft+2.2);
            make.centerX.mas_equalTo(@(0));
            make.centerY.mas_equalTo(headerView);
            make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
            
        }];
    }
    else
    {
        headerView = [[UIView alloc] init];
        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
        headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
        CGFloat hight = 20.0f;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInsetsLeft, 10.0f, tableView.frame.size.width-kEdgeInsetsLeft, hight)];
//        [label setFont:[UIFont systemFontOfSize:12.0f]];
        [label setFont:kFontSmall];
        [label setTextColor: KColorAppMain];
        if(_isParent)
        {
            [label setText:@"孩子"];

        }
        else
        {
            [label setText:@"行业"];
        }
        [headerView addSubview:label];
    
    }
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCELLHIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [self showChatVC];

    
    
    
}


-(void)showChatVC
{
//    TXParentChatViewController *chatVc = [[TXParentChatViewController alloc] initWithChatter:@"aibin2" isGroup:NO];
//    [self.navigationController pushViewController:chatVc animated:YES];
    
}

-(void)showBabyDetail:(int64_t)userId
{
//    BabyDetailViewController *babyDetail = [[BabyDetailViewController alloc] initWithUserId:userId];
//    [self.navigationController pushViewController:babyDetail animated:YES];
}



-(void)sendMessage:(id)sender
{
    TXParentChatViewController *chatVc = [[TXParentChatViewController alloc] initWithChatter:[NSString stringWithFormat:@"%lld", _user.userId] isGroup:NO];
    chatVc.isNormalBack = YES;
    [self.navigationController pushViewController:chatVc animated:YES];
    [MobClick event:@"userdetail" label:@"发送消息"];

}

-(void)call:(id)sender
{
    
}
-(void)FromViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    if(_user.avatarUrl == nil || [_user.avatarUrl length] <= 0)
    {
        return ;
    }
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:[NSArray arrayWithObjects:[NSURL URLWithString:[_user.avatarUrl getFormatPhotoUrl]], nil] currentIndex:0];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}


@end
