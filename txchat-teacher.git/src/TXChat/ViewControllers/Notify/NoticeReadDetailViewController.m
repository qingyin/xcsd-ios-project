//
//  NoticeReadDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoticeReadDetailViewController.h"
#import "ReadUserListView.h"
#import <SDiPhoneVersion.h>


@interface NoticeReadDetailViewController ()
{
    int64_t _noticeId;
    TXDepartment *_department;
    ReadUserListView *_unreadListView;
    ReadUserListView *_readListView;
    NSMutableArray *_unreadUserList;
    NSMutableArray *_readUserList;
    UIScrollView *_scrollView;
    UIView *_contentView;
}
@end

@implementation NoticeReadDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _unreadUserList = [NSMutableArray arrayWithCapacity:1];
        _readUserList = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

-(id)initWithNoticeId:(int64_t)noticeId departmentId:(int64_t)departmentId
{
    self = [super init];
    if(self)
    {
        _noticeId = noticeId;
        _department = [[TXChatClient sharedInstance] getDepartmentByDepartmentId:departmentId error:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = _department.name;
    [self createCustomNavBar];
    [self.btnRight setTitle:@"刷新" forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self setupViews];
    self.view.backgroundColor = kColorBackground;
    [self refreshUnreadCount];
}
-(void)setupViews
{
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.userInteractionEnabled = YES;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    contentView.userInteractionEnabled = YES;
    contentView.clipsToBounds = YES;
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    CGFloat scaleSize = 1.0;
    if ([SDiPhoneVersion deviceSize] == iPhone55inch)
    {
        scaleSize = 1.5;
    }
    _unreadListView = [[ReadUserListView alloc] initWithReadStatus:NO];
    [_unreadListView setBackgroundColor:kColorWhite];
    _unreadListView.userList = nil;
    [_unreadListView setupSubViews];
    [_contentView addSubview:_unreadListView];
    
    CGFloat len = ceilf([_unreadUserList count]/_unreadListView.countByLine);
    CGFloat userViewHight = 70.0f*scaleSize;
    CGFloat topPadding = 10.0f;
    CGFloat titleHight = 30.0f;
    [_unreadListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_contentView);
        make.left.mas_equalTo(_contentView);
        make.right.mas_equalTo(_contentView);
        make.height.mas_equalTo(titleHight + topPadding +len*(userViewHight + topPadding));
    }];
    
    _readListView = [[ReadUserListView alloc] initWithReadStatus:YES];
    [_readListView setBackgroundColor:[UIColor whiteColor]];
    _readListView.userList = nil;
    [_readListView setupSubViews];
    [_contentView addSubview:_readListView];
    CGFloat len1 = ceilf([_readUserList count]/_readListView.countByLine);
    [_readListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_unreadListView.mas_bottom).with.offset(5.0f);
        make.left.mas_equalTo(_contentView);
        make.right.mas_equalTo(_contentView);
        make.height.mas_equalTo(titleHight + topPadding +len1*(userViewHight + topPadding));
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_readListView.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];
}

-(void)updateLocalViewConstraints
{
    _unreadListView.userList = _unreadUserList;
    [_unreadListView setupSubViews];
    CGFloat len = ceilf([_unreadUserList count]/(_unreadListView.countByLine *1.0f));
    CGFloat scaleSize = 1.0f;
    if ([SDiPhoneVersion deviceSize] == iPhone55inch)
    {
        scaleSize = 1.5;
    }
    CGFloat userViewHight = 70.0f*scaleSize;
    CGFloat topPadding = 10.0f;
    CGFloat titleHight = 30.0f;
    [_unreadListView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(titleHight + topPadding +(len)*(userViewHight + topPadding ));
    }];
    
    _readListView.userList = _readUserList;
    [_readListView setupSubViews];
    CGFloat len1 = ceilf([_readUserList count]/(_readListView.countByLine*1.0f));
    [_readListView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(titleHight + topPadding +len1*(userViewHight + topPadding));
    }];
    
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_readListView.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];

}
-(void)refreshUnreadCount
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] fetchNoticeMembers:_noticeId departmentId:_department.departmentId onCompleted:^(NSError *error, NSArray *txpbNoticeMembers) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
        }
        else
        {
            @synchronized(self)
            {
                [_unreadUserList removeAllObjects];
                [_readUserList removeAllObjects];
                for(TXPBNoticeMember *notice in txpbNoticeMembers)
                {
                    if(notice.isRead)
                    {
                        [_readUserList addObject:notice];
                    }
                    else
                    {
                        [_unreadUserList addObject:notice];
                    }
                }
            }

            TXAsyncRunInMain(^{
                [weakSelf updateLocalViewConstraints];
            });
        }
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
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
    else
    {
        [self refreshUnreadCount];
    }
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


@end
