//
//  TeacherListViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TeacherListViewController.h"
#import "TParentTableViewCell.h"
#import "ParentsDetailViewController.h"
#import <TXChatClient.h>
#import <TXUser.h>
#import <ChineseToPinyin.h>
#import "UIImageView+EMWebCache.h"
#import "TXUser+Utils.h"
#define KSECTIONHEIGHT1 20.0f
#define KCELLHIGHT (54.0f*kScale1)

@interface TeacherListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_userList;
    int64_t _departmentId;
}
@end

@implementation TeacherListViewController

//通过classid初始化
-(id)initWithDepartmentId:(int64_t)departmentId
{
    self = [super init];
    if(self)
    {
        _departmentId = departmentId;
    }
    return self;
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
    self.titleStr = @"教师";
    [self createCustomNavBar];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.rowHeight = KCELLHIGHT;
    _tableView.sectionIndexColor = kColorGray;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:_tableView];
    
    
    UIView *superview = self.view;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, 0));
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf createUserList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
    
    
    
}

-(void)createUserList
{
    NSArray *users = [[TXChatClient sharedInstance]getDepartmentMembers:_departmentId userType:TXPBUserTypeTeacher error:nil];
    users = [users sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TXUser *user1 = (TXUser *)obj1;
        TXUser *user2 = (TXUser *)obj2;
        return [user1.nicknameFirstLetter compare:user2.nicknameFirstLetter options:NSCaseInsensitiveSearch];
    }];
    
    NSString *firstChat = nil;
    _userList = [NSMutableArray arrayWithCapacity:5];
//    [_userList addObjectsFromArray:users];
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *lastArray = [NSMutableArray arrayWithCapacity:5];
    for(TXUser *user in users)
    {
        if(user.nicknameFirstLetter == nil || [user.nicknameFirstLetter length] == 0)
        {
            [lastArray addObject:user];
            continue;
        }
        
        if(firstChat == nil)
        {
            firstChat = user.nicknameFirstLetter;
            [tmpArray addObject:user];
        }
        else
        {
            if([[firstChat substringToIndex:1] isEqualToString:[user.nicknameFirstLetter substringToIndex:1] ])
            {
                [tmpArray addObject:user];
                
            }
            else
            {
                [_userList addObject:tmpArray];
                firstChat = user.nicknameFirstLetter;
                tmpArray = nil;
                tmpArray = [NSMutableArray arrayWithCapacity:5];
                [tmpArray addObject:user];
            }
        }
    }
    if([tmpArray count] > 0)
    {
        [_userList addObject:tmpArray];
    }
    if([lastArray count] > 0)
    {
        [_userList addObject:lastArray];
    }
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
    return [(NSArray *)[_userList objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_userList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TParentTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    TParentTableViewCell *classCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (classCell == nil) {
        classCell = [[[NSBundle mainBundle] loadNibNamed:@"TParentTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXUser *user = [[_userList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row ] ;
    [classCell.userNameLabel setText:user.nickname];
    [classCell.userImageView TX_setImageWithURL:[NSURL URLWithString:[user getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    [classCell.inActiveBtn setHidden:user.activated];
    NSString *mobile = user.mobilePhoneNumber;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    classCell.callBlock = ^(NSInteger viewTag)
    {
        if(mobile != nil && [mobile length] > 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",mobile]]];
        }
        else
        {
            [weakSelf showFailedHudWithTitle:@"该用户暂未绑定手机号"];
        }
    };
    
    [classCell.seperatorLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(classCell.contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(classCell.contentView).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(classCell.contentView.mas_bottom).with.offset(-kLineHeight);
    }];
    
    if(indexPath.row == [_userList count] -1)
    {
        [classCell.seperatorLine setHidden:YES];
    }
    cell = classCell;
    [cell.contentView setBackgroundColor:kColorWhite];
    return cell;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    NSMutableArray *sectionIndex = [[NSMutableArray alloc] initWithCapacity:5];
    for(NSArray *index in _userList)
    {
        if([index count] > 0)
        {
            TXUser *user = [index objectAtIndex:0];
            if([user.nicknameFirstLetter length] > 0)
            {
                NSString *firstLetter = [user.nicknameFirstLetter substringToIndex:1];
                [sectionIndex addObject:[NSString stringWithFormat:@"%@",[firstLetter uppercaseStringWithLocale:[NSLocale currentLocale]]]];
            }
        }
    }
    return sectionIndex;
}

#pragma mark-  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
//    CGFloat height = KSECTIONHEIGHT1;
//    return height;
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
    return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UIView *headerView = nil;
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TXUser *user = [[_userList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row ] ;
    [self showTeacherDetailVC:user.userId];
    
}

-(void)showTeacherDetailVC:(int64_t)userId
{
    ParentsDetailViewController *chatVc = [[ParentsDetailViewController alloc] initWithIdentity:userId];
    [self.navigationController pushViewController:chatVc animated:YES];
}


@end
