//
//  NoticeSelectMembersViewController.m
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoticeSelectMembersViewController.h"
#import "NotifySelectMembersTableViewCell.h"
#import <TXChatClient.h>
#import <TXDepartment.h>
#import <ChineseToPinyin.h>
#import "UIImageView+EMWebCache.h"
#import "TXUser+Utils.h"
#define KSECTIONHEIGHT1 20.0f
#define KCELLHIGHT 60.0f;
@interface NoticeSelectMembersViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSInteger _selectedCount ;
    int64_t _departmentId;
    NSMutableArray *_selectedUsers;
    TXDepartment *_currentDepartment;
    NSMutableArray *_userList;
}
@end

@implementation NoticeSelectMembersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedCount = 0;
        _updateMemberSelected = nil;
    }
    return self;
}
//根据 选择的人和部门 初始化选择列表
-(id)initWithDepartmentId:(int64_t)departmentId selectedUsers:(NSArray *)selectedUsers
{
    self = [super init];
    if(self)
    {
        _departmentId = departmentId;
        _selectedUsers = [NSMutableArray arrayWithCapacity:1];
        [_selectedUsers addObjectsFromArray:selectedUsers];
        _currentDepartment = [[TXChatClient sharedInstance] getDepartmentByDepartmentId:departmentId error:nil];
        _selectedCount = [selectedUsers count];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = _currentDepartment.name;
    [self createCustomNavBar];
    NSString *selectStr= [NSString stringWithFormat:@"选择(%ld)", (long)_selectedCount];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self createTitles];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    _tableView.sectionIndexColor = kColorGray;
    if(IOS7_OR_LATER)
    {
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:_tableView];
    
    
    UIView *superview = self.view;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, kEdgeInsetsLeft));
    }];
}
-(void)createTitles
{
    TXPBUserType userType = TXPBUserTypeChild;
    if(_currentDepartment.departmentType != TXPBDepartmentTypeClazz)
    {
        userType = TXPBUserTypeTeacher;
    }
    
    NSArray *users = [[TXChatClient sharedInstance]getDepartmentMembers:_departmentId userType:userType error:nil];
    if(userType == TXPBUserTypeTeacher)
    {
        TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
        //过滤掉自己
        if(currentUser != nil)
        {
            NSMutableArray *myMutableArray = [NSMutableArray arrayWithArray:users];
            [myMutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                TXUser *user = (TXUser *)obj;
                if(user.userId == currentUser.userId)
                {
                    [myMutableArray removeObject:user];
                    *stop = YES;
                }
            }];
            users = [NSArray arrayWithArray:myMutableArray];
        }
    }

    
//    if(users  != nil && [users count] > 0)
//    {
//        for(TXUser *user in users)
//        {
//            if(user.nickname != nil && [user.nickname length] > 0)
//            {
//                user.nicknameFirstLetter = [ChineseToPinyin pinyinFromChineseString:user.nickname];
//            }
//        }
//    }
    users = [users sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TXUser *user1 = (TXUser *)obj1;
        TXUser *user2 = (TXUser *)obj2;
        return [user1.nicknameFirstLetter compare:user2.nicknameFirstLetter options:NSCaseInsensitiveSearch];
    }];
    
    NSString *firstChat = nil;
    _userList = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *lastArray = [NSMutableArray arrayWithCapacity:5];
    for(TXUser *user in users)
    {
        if(!user)
        {
            continue;
        }
        
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
                if([tmpArray count] > 0)
                {
                    [_userList addObject:tmpArray];
                }
                firstChat = user.nicknameFirstLetter;
                tmpArray = nil;
                tmpArray = [NSMutableArray arrayWithCapacity:5];
                [tmpArray addObject:user];
            }
        }
    }
    if(tmpArray != nil && [tmpArray count] > 0)
    {
        [_userList addObject:tmpArray];
    }
    if(lastArray != nil && [lastArray count] > 0)
    {
        [_userList addObject:lastArray];
    }
    
}

-(BOOL)isSelected:(TXUser *)currentUser
{
    BOOL ret = NO;
    
    __block NSUInteger index = NSNotFound;
    int64_t userId = currentUser.userId;
    [_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TXUser *user = (TXUser *)obj;
        if(user.userId == userId)
        {
            *stop = YES;
            index = idx;
        }
    }];
    if(index != NSNotFound)
    {
        ret = YES;
    }
    
    return ret;
}


-(void)updateRightTitle
{
    NSString *selectStr= [NSString stringWithFormat:@"选择(%ld)", (long)[_selectedUsers count]];
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
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        _updateMemberSelected(_selectedUsers, _departmentId);
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
    static NSString *CellIdentifier = @"NotifySelectMembersTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    NotifySelectMembersTableViewCell *userSelectedCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (userSelectedCell == nil) {
        userSelectedCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifySelectMembersTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXUser *user = [[_userList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    userSelectedCell.userId = user.userId;
    [userSelectedCell.userNameLabel setText:user.nickname];
    [userSelectedCell.userIconImageView TX_setImageWithURL:[NSURL URLWithString:[user getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];

    __weak __typeof(&*self) weakSelf=self;  //by sck
    __block NSMutableArray *selectedUsers = _selectedUsers;
    
    userSelectedCell.selectedBock = ^(int64_t userId, BOOL isSelected){
        NSInteger selectecCount = 0;
        if(isSelected)
        {
            TXUser *selectedUser = [[TXChatClient sharedInstance] getUserByUserId:userId error:nil];
            if(selectedUser)
            {
                [selectedUsers addObject:selectedUser];
                selectecCount ++;
            }
        }
        else
        {
            [selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                TXUser *user = (TXUser *)obj;
                if(userId == user.userId)
                {
                    *stop = YES;
                    if(*stop)
                    {
                        [selectedUsers removeObject:obj];
                    }
                }
                return ;
            }];
            
            selectecCount--;
        }
        [weakSelf updateRightTitle];
    };
    
    if([self isSelected:user])
    {
        [userSelectedCell setCheckStatus:YES];
    }
    
    if(indexPath.row == [(NSArray *)[_userList objectAtIndex:indexPath.section] count] -1)
    {
        [userSelectedCell.seperatorLine setHidden:YES];
    }
    userSelectedCell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell = userSelectedCell;
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
            NSString *firstLetter = [user.nicknameFirstLetter substringToIndex:1];
            [sectionIndex addObject:[NSString stringWithFormat:@"%@",[firstLetter uppercaseStringWithLocale:[NSLocale currentLocale]]]];
        }
    }
    
    return sectionIndex;
}



#pragma mark-  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    CGFloat height = KSECTIONHEIGHT1;
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
    return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UIView *headerView = nil;
    headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
    headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInsetsLeft, 0, tableView.frame.size.width-kEdgeInsetsLeft, KSECTIONHEIGHT1)];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [label setTextColor:kColorGray];
//    NSString *title = [[_titleArray objectAtIndex:section] objectAtIndex:0];
    TXUser *user = [[_userList objectAtIndex:section] objectAtIndex:0];
    NSString *firstLetter = [user.nicknameFirstLetter substringToIndex:1];
    NSString *title = [NSString stringWithFormat:@"%@",[firstLetter uppercaseStringWithLocale:[NSLocale currentLocale]]];
    [label setText:title];
    [label setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:label];
//    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotifySelectMembersTableViewCell *userSelectedCell = (NotifySelectMembersTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    TXUser *currentSelectedUser = [(NSArray *)[_userList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row ];
    if(!currentSelectedUser)
    {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    if(![self isContainUser:currentSelectedUser.userId])
    {
        [userSelectedCell setCheckStatus:YES];
        [userSelectedCell layoutIfNeeded];
        [_selectedUsers addObject:currentSelectedUser];
    }
    else
    {
        [userSelectedCell setCheckStatus:NO];
        [userSelectedCell layoutIfNeeded];
        [self removeUser:currentSelectedUser.userId];
    }
    [self updateRightTitle];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(BOOL)isContainUser:(int64_t)userId
{
    __block BOOL ret = NO;
    [_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TXUser *user = (TXUser *)obj;
        if(userId == user.userId)
        {
            *stop = YES;
            ret = YES;
        }
    }];
    return ret;
}

-(void)removeUser:(int64_t)userId
{
    [_selectedUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TXUser *user = (TXUser *)obj;
        if(userId == user.userId)
        {
            *stop = YES;
            if(*stop)
            {
                [_selectedUsers removeObject:obj];
            }
        }
        return ;
    }];
}


@end
