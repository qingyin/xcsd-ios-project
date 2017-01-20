//
//  TeacherNoticeListViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TeacherNoticeListViewController.h"
#import "NoticeDetailViewController.h"
#import "NotifyTableViewCell.h"
#import "SenderNoticeDetailViewController.h"
#import "NoticeSelectGroupViewController.h"
@interface TeacherNoticeListViewController ()<UITabBarDelegate>
{
    NSInteger _selectedIndex;
    UITabBarItem *_leftItem;
    UITabBarItem *_rightItem;
    NSArray *_msgList;
}
@end

@implementation TeacherNoticeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTitles];
    [self.btnRight setTitle:@"发通知" forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIView *superview = self.view;
    WEAKSELF
    
    
    
    UITabBar *tabbar = [[UITabBar alloc] init];
    UITabBarItem *leftItem = [[UITabBarItem alloc] initWithTitle:@"收件箱" image:[UIImage imageNamed:@"third_normal"] selectedImage:[UIImage imageNamed:@"third_selecteds"]];
    _leftItem = leftItem;
    UITabBarItem *rightItem = [[UITabBarItem alloc] initWithTitle:@"发件箱" image:[UIImage imageNamed:@"third_normal"] selectedImage:[UIImage imageNamed:@"third_selecteds"]];
    _rightItem = rightItem;
     NSArray *tabBarItemArray = [[NSArray alloc] initWithObjects: leftItem, rightItem,nil];
    [tabbar setItems: tabBarItemArray];
    tabbar.delegate = self;
    [self.view addSubview:tabbar];
    
    [tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.centerX.mas_equalTo(superview);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    
    [tabbar setSelectedItem:_leftItem];
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(64+44, 0, 0, 0));
    }];
    
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self showSelectGroup];
    }
}
-(void)showSelectGroup
{
    NoticeSelectGroupViewController *selectGroup = [[NoticeSelectGroupViewController alloc] init];
    [self.navigationController pushViewController:selectGroup animated:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_msgList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotifyTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    NotifyTableViewCell *notifyCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (notifyCell == nil) {
        notifyCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifyTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    [notifyCell.messageLabel setText:[_msgList objectAtIndex:indexPath.row]];
    if(_selectedIndex == 0)
    {
        [notifyCell.toUserLabel setText:@"乐学堂14班"];
    }
    else
    {
        [notifyCell.toUserLabel setText:@"自己"];
    }
    
    cell = notifyCell;
    return cell;
}

#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_selectedIndex == 0)
    {
        [self showNotifyDetail];
    }
    else
    {
        [self showSenderNotifyDetail];
    }
    
}


-(void)showNotifyDetail
{
    NoticeDetailViewController *NoticeDetail = [[NoticeDetailViewController alloc] init];
    [self.navigationController pushViewController:NoticeDetail animated:YES];
}
//SenderNotifyDetailViewController.h
-(void)showSenderNotifyDetail
{
    SenderNoticeDetailViewController *senderNoticeDetail = [[SenderNoticeDetailViewController alloc] init];
    [self.navigationController pushViewController:senderNoticeDetail animated:YES];
}


#pragma mark-  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item // called when a new view is selected by the user (but not programatically)
{
    if(item == _leftItem)
    {
        if(_selectedIndex != 0)
        {
            _selectedIndex = 0;
            [self createTitles];
            [_tableView reloadData];
        }
    }
    else if (item == _rightItem)
    {
        if(_selectedIndex != 1)
        {
            _selectedIndex = 1;
            [self createTitles];
            [_tableView reloadData];
        }
    }
}


-(void)createTitles
{
    if(_selectedIndex == 0)
    {
        _msgList = @[@"通知内容1", @"通知内容1", @"通知内容1", @"通知内容1", @"通知内容1", @"通知内容1", @"通知内容1", @"通知内容1", @"通知内容1"];
        [self.btnRight setHidden:YES];
    }
    else if(_selectedIndex == 1)
    {
        _msgList = @[@"发送内容1", @"发送内容1", @"发送内容1", @"发送内容1", @"发送内容1", @"发送内容1", @"发送内容1", @"发送内容1", @"发送内容1", @"发送内容1"];
        [self.btnRight setHidden:NO];
    }
}


@end
