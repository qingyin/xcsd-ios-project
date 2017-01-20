
//
//  NoticeReadDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoticeReadDetailViewController.h"
#import "ReadUserListView.h"

@interface NoticeReadDetailViewController ()
{
    ReadUserListView *_unreadListView;
    ReadUserListView *_readListView;
    NSArray *_unreadUserList;
    NSArray *_readUserList;
    UIScrollView *_scrollView;
}
@end

@implementation NoticeReadDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"乐学堂_14班";
    [self createCustomNavBar];
    [self.btnRight setTitle:@"刷新" forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self createUserList];
    
    UIView *superview = self.view;
    
    _scrollView= [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.frame.size.width, self.view.frame.size.height - self.customNavigationView.maxY)];
    //    _scrollView = [UIScrollView new];
    _scrollView.backgroundColor = [UIColor grayColor];
    _scrollView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:_scrollView];
    
    _unreadListView = [[ReadUserListView alloc] initWithReadStatus:NO];
    [_unreadListView setBackgroundColor:[UIColor whiteColor]];
    _unreadListView.userList = _unreadUserList;
    [_unreadListView setupSubViews];
    [_scrollView addSubview:_unreadListView];
    
    CGFloat len = ceilf([_unreadUserList count]/3.0f);
    CGFloat padding = 50.0f;
    [_unreadListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_scrollView);
        make.left.mas_equalTo(_scrollView);
        make.size.mas_equalTo(CGSizeMake(superview.frame.size.width, padding+len*padding));
        
    }];
    
    
    _readListView = [[ReadUserListView alloc] initWithReadStatus:YES];
    [_readListView setBackgroundColor:[UIColor whiteColor]];
    _readListView.userList = _readUserList;
    [_readListView setupSubViews];
    [_scrollView addSubview:_readListView];
    CGFloat len1 = ceilf([_readUserList count]/3.0f);
    [_readListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_unreadListView.mas_bottom).with.offset(padding);
        make.left.mas_equalTo(_scrollView);
        make.size.mas_equalTo(CGSizeMake(superview.frame.size.width, padding+len1*padding));
        
    }];
    
}

-(void)createUserList
{
    _unreadUserList = @[@"庆庆", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清"];
    
    _readUserList = @[@"庆庆1", @"清清1", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清", @"清清"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, _readListView.frame.size.height+_readListView.frame.origin.y)];
    CGFloat contentLen = 0;
    CGFloat len1 = ceilf([_readUserList count]/3.0f);
    CGFloat len = ceilf([_unreadUserList count]/3.0f);
    CGFloat padding = 50.0f;
    contentLen += padding+len1*padding;
    contentLen += padding;
    contentLen +=padding+len*padding;
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, contentLen)];
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
