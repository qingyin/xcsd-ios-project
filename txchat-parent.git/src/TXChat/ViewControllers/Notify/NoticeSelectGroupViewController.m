//
//  NotifySelectGroupViewController.m
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoticeSelectGroupViewController.h"
#import "NotifySelectGroupTableViewCell.h"
#import "NoticeSelectMembersViewController.h"
#import "SendNotificationViewController.h"

@interface NoticeSelectGroupViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_groupList;
    NSInteger _selectedCount ;
}
@end

@implementation NoticeSelectGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"选择收件人";
    [self createCustomNavBar];
    NSString *selectStr= [NSString stringWithFormat:@"确定(%ld)", (long)_selectedCount];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self createUserList];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    UIView *superview = self.view;
//    WEAKSELF
    // by mey
    __weak __typeof(&*self) weakSelf=self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, 0));
    }];
}
-(void)createUserList
{
    _groupList = @[@"测试1班",@"测试2班",@"测试3班",@"测试4班",@"测试5班"];
}


-(void)updateRightTitle:(NSInteger)updateValue
{
    _selectedCount += updateValue;
    NSString *selectStr= [NSString stringWithFormat:@"确定(%ld)", (long)_selectedCount];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self showSendNotification];
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


#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotifySelectGroupTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    NotifySelectGroupTableViewCell *selectGroupCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (selectGroupCell == nil) {
        selectGroupCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifySelectGroupTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    [selectGroupCell.groupIcon setImage:[UIImage imageNamed:@"first_selected"]];
    [selectGroupCell.groupName setText:[_groupList objectAtIndex:indexPath.row]];
    WEAKSELF
//    __block NSInteger selectecCount = 0;
    selectGroupCell.selectedBock = ^(NSString *groupName, BOOL isSelected){
         NSInteger selectecCount = 0;
        if(isSelected)
        {
            selectecCount ++;
        }
        else
        {
            selectecCount--;
        }
        [weakSelf updateRightTitle:selectecCount];
    };
    cell = selectGroupCell;
    return cell;
}

#pragma mark-  UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self showSelectMembers];
}

//NotifySelectMembersViewController
-(void)showSelectMembers
{
    NoticeSelectMembersViewController *selectMembers = [[NoticeSelectMembersViewController alloc] init];
    WEAKSELF;
    selectMembers.updateMemberSelected = ^(NSArray *userArray, NSString *groupName)
    {
       [weakSelf updateRightTitle:[userArray count]];
    };
    [self.navigationController pushViewController:selectMembers animated:YES];
}

//SendNotificationViewController.h
-(void)showSendNotification
{
    SendNotificationViewController *sendNotification = [[SendNotificationViewController alloc] init];
    [self.navigationController pushViewController:sendNotification animated:YES];
}
@end
