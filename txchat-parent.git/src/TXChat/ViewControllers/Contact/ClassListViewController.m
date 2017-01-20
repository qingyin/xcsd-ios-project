//
//  ClassListViewController.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ClassListViewController.h"
#import "ClassTableViewCell.h"
#import "TXParentChatViewController.h"
#import "ParentsDetailViewController.h"
#import "GroupDetailViewController.h"
#import "TeacherListViewController.h"
#import "BabyListViewController.h"
#import "NoticeDetailViewController.h"
#import "ParentNoticeListViewController.h"
#import "TeacherNoticeListViewController.h"
#import <TXChatClient.h>
#import "TXDepartment.h"
#import "UIImageView+EMWebCache.h"
#import "TXParentChatViewController.h"
#import "TXDepartment+Utils.h"
#define KCELLHIGHT 50.0f;

@interface ClassListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_classList;
}
@end

@implementation ClassListViewController

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
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
    self.titleStr = @"联系人";    
    [self createCustomNavBar];
    [self loadClassList];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    UIView *superview = self.view;
//    WEAKSELF
//    by mey
    __weak __typeof(&*self)weakSelf=self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, 0));
    }];
    
    [[TXChatClient sharedInstance] fetchDepartments:^(NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadClassList];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            });
        }
    }];
}




-(void)loadClassList
{
    _classList = [[TXChatClient sharedInstance] getAllDepartments:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
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
    return [_classList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ClassTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    ClassTableViewCell *classCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (classCell == nil) {
        classCell = [[[NSBundle mainBundle] loadNibNamed:@"ClassTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXDepartment *department = [_classList objectAtIndex:indexPath.row];
    [classCell.classNameLabel setText:department.name];
    [classCell.classIconImageView TX_setImageWithURL:[NSURL URLWithString:[department getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"classDefaultIcon"]];
    [classCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(indexPath.row == [_classList count] -1)
    {
        [classCell.seperatorLine setHidden:YES];
    }
    
    cell = classCell;
    return cell;
}

#pragma mark-  UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TXDepartment *department = [_classList objectAtIndex:indexPath.row];
//    [self showChatVC];
//    [self showParentsDetailVC];
//    [self showGroupDetailVC:department.id];
//    [self showBabyDetailVC];
//    [self showTeacherListVC];
//    [self showBabyListVC];
//    [self showNotifyDetailVC];
//    [self showParentListVC];
//    [self showTeacherNotifyListVC];
    [self enterChatVC:department.groupId departName:department.name];
    
    
}

//KCELLHIGHT
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCELLHIGHT;
}

-(void)showChatVC
{
    TXParentChatViewController *chatVc = [[TXParentChatViewController alloc] initWithChatter:@"aibin2" isGroup:NO];
    chatVc.isNormalBack = YES;
    [self.navigationController pushViewController:chatVc animated:YES];

}

-(void)showParentsDetailVC
{
    ParentsDetailViewController *chatVc = [[ParentsDetailViewController alloc] init];
    [self.navigationController pushViewController:chatVc animated:YES];
    
}

-(void)showGroupDetailVC:(NSString *)groupId
{
    GroupDetailViewController *groupDetailVc = [[GroupDetailViewController alloc] initWithParent:YES groupId:groupId];
    [self.navigationController pushViewController:groupDetailVc animated:YES];
    
}

//BabyDetailViewController.h
-(void)showBabyDetailVC
{
//    BabyDetailViewController *babyDetailVc = [[BabyDetailViewController alloc] init];
//    [self.navigationController pushViewController:babyDetailVc animated:YES];
    
}
//TeacherListViewController
-(void)showTeacherListVC
{
    TeacherListViewController *teacherListVc = [[TeacherListViewController alloc] init];
    [self.navigationController pushViewController:teacherListVc animated:YES];
    
}
//#import "BabyListViewController.h"
-(void)showBabyListVC
{
    BabyListViewController *babyListVc = [[BabyListViewController alloc] init];
    [self.navigationController pushViewController:babyListVc animated:YES];
    
}
//NotifyDetailViewController.h
-(void)showNotifyDetailVC
{
    NoticeDetailViewController *notifyDetailVc = [[NoticeDetailViewController alloc] init];
    [self.navigationController pushViewController:notifyDetailVc animated:YES];
    
}

//ParentNotifyListViewController.h
-(void)showParentListVC
{
    ParentNoticeListViewController *parentListVc = [[ParentNoticeListViewController alloc] init];
    [self.navigationController pushViewController:parentListVc animated:YES];
    
}
//TeacherNotifyListViewController
-(void)showTeacherNotifyListVC
{
    TeacherNoticeListViewController *teacherNoticeListVc = [[TeacherNoticeListViewController alloc] init];
    [self.navigationController pushViewController:teacherNoticeListVc animated:YES];
    
}
-(void)enterChatVC:(NSString *)groupId departName:(NSString *)departName
{
    TXParentChatViewController *chat = [[TXParentChatViewController alloc] initWithChatter:groupId isGroup:YES];
    chat.isNormalBack = YES;
    chat.titleStr = departName;
    [self.navigationController pushViewController:chat animated:YES];
}


@end
