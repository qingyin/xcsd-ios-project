//
//  NoticeSelectMembersViewController.m
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MuteSelectMembersViewController.h"
#import "NotifySelectMembersTableViewCell.h"
#import <TXChatClient.h>
#import <TXDepartment.h>
#import <ChineseToPinyin.h>
#import "UIImageView+EMWebCache.h"
#import "TXUser+Utils.h"
#import "TXEaseMobHelper.h"
#import <UIImageView+Utils.h>
#define KSECTIONHEIGHT1 20.0f
#define KCELLHIGHT 60.0f;
#define KBOTTOMBARHIGHT 75.0f
@interface MuteSelectMembersViewController ()<UITableViewDataSource,UITableViewDelegate, UITabBarDelegate>
{
    UITableView *_tableView;
    NSInteger _selectedCount ;
    int64_t _departmentId;
    NSMutableArray *_selectedUsers;  //当前选中列表
    NSMutableArray *_muteListUsers;
    TXDepartment *_currentDepartment;
    NSMutableArray *_userList;
    UITabBarItem *_leftItem;
    UITabBarItem *_rightItem;
    UITabBar *_tabbar;
    NSInteger _selectedIndex;
    UIButton *_confirmBtn;
    BOOL _isSelectedChanged;
}
@end

@implementation MuteSelectMembersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedCount = 0;
        _updateMemberSelected = nil;
        _isSelectedChanged = NO;
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

-(id)initWithDepartmentId:(int64_t)departmentId
{
    self = [super init];
    if(self)
    {
        _departmentId = departmentId;
        _selectedUsers = [NSMutableArray arrayWithCapacity:1];
        _muteListUsers = [NSMutableArray arrayWithCapacity:1];
        _currentDepartment = [[TXChatClient sharedInstance] getDepartmentByDepartmentId:departmentId error:nil];
        _isSelectedChanged = NO;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = _currentDepartment.name;
    [self createCustomNavBar];
    self.btnLeft.showBackArrow = YES;
    [self.btnLeft setTitle:@"返回" forState:UIControlStateNormal];
    [self setupViews];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    TXAsyncRunInMain(^{
        [weakSelf createTitles];
    });
    [self updateMuteList];
}

-(void)setupViews
{
    [self createTabbar];
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
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.right.mas_equalTo(@(0));
        make.top.mas_equalTo(_tabbar.mas_bottom);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(0);
    }];
    
    
    UIView *btmView = [[UIView alloc] init];
    btmView.backgroundColor =  RGBACOLOR(0, 0, 0, 0.7);
    btmView.userInteractionEnabled = YES;
    [self.view addSubview:btmView];
    [btmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.right.mas_equalTo(@(0));
        make.top.mas_equalTo(_tableView.mas_bottom).with.offset(-KBOTTOMBARHIGHT);
        make.bottom.mas_equalTo(@(0));
    }];
    
    UIButton * confirmBtn = [[UIButton alloc] init];
    _confirmBtn = confirmBtn;
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setBackgroundColor:kColorWhite];
    [confirmBtn setTitleColor:kColorGray forState:UIControlStateNormal];
    confirmBtn.layer.cornerRadius = 5.0f;
    confirmBtn.layer.masksToBounds = YES;
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [btmView addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(@(-20));
        make.left.mas_equalTo(@(20));
        make.height.mas_equalTo(@(40));
        make.centerY.mas_equalTo(btmView);
    }];
    [self.view bringSubviewToFront:btmView];
}

-(void)updateConfirmStatus
{
    NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",_muteListUsers];
    NSArray * filter = [_selectedUsers filteredArrayUsingPredicate:filterPredicate];
    if([filter count] > 0 || _muteListUsers.count != _selectedUsers.count)
    {
        [_confirmBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
        _confirmBtn.backgroundColor = KColorAppMain;
        _isSelectedChanged = YES;
    }
    else
    {
        [_confirmBtn setBackgroundColor:kColorWhite];
        [_confirmBtn setTitleColor:kColorGray forState:UIControlStateNormal];
        _isSelectedChanged = NO;
    }
}


-(void)createTitles
{
    NSArray *users = [[TXChatClient sharedInstance]getDepartmentMembers:_departmentId userType:TXPBUserTypeChild error:nil];

    __weak __typeof(&*self) weakSelf=self;  //by sck
    NSMutableArray *myMutableArray = [NSMutableArray arrayWithCapacity:1];
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TXUser *user = (TXUser *)obj;
        if(![weakSelf isSelected:user] && user)
        {
            [myMutableArray addObject:user];
        }
    }];
    [_selectedUsers removeAllObjects];
    users = [NSArray arrayWithArray:myMutableArray];

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
        if( user.nicknameFirstLetter == nil || [user.nicknameFirstLetter length] == 0)
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
                if(tmpArray != nil && [tmpArray count] > 0)
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

-(void)updateMuteList
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchMutedUserIds:_departmentId muteType:[self muteType] onCompleted:^(NSError *error, NSArray *childUserIds, TXPBMuteType txpbMuteType) {
        if(error)
        {
            [weakSelf showFailedHudWithError:error];
        }
        else
        {
            if([weakSelf muteType] != txpbMuteType)
            {
                return ;
            }
            NSMutableArray *muteList = [NSMutableArray arrayWithCapacity:1];
            if([childUserIds count] > 0)
            {
                for(NSArray *array in _userList)
                {
                    for(TXUser *user in array)
                    {
                        if([childUserIds containsObject:@(user.userId)])
                            {
                                [muteList addObject:user];
                            }
                    }
                }
            }
            _muteListUsers = [muteList copy];
            _selectedUsers = muteList;
            [_tableView reloadData];
            [weakSelf updateConfirmStatus];
        }
    }];
}



-(TXPBMuteType )muteType
{
    if(_selectedIndex == 0)
    {
        return TXPBMuteTypeMuteChat;
    }
    return TXPBMuteTypeMuteFeed;
}

-(void)createTabbar
{
    UIView *superview = self.view;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    UITabBar *tabbar = [[UITabBar alloc] init];
    UITabBarItem *leftItem = nil;
    if(IOS7_OR_LATER)
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"聊天" image:nil selectedImage:nil];
    }
    else
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"聊天" image:nil tag:0];
    }
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      KColorSubTitleTxt, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateNormal];
    
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      KColorAppMain, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [leftItem setTitlePositionAdjustment:UIOffsetMake(0, -6)];
    _leftItem = leftItem;
    
    
    UITabBarItem *rightItem = nil;
    if(IOS7_OR_LATER)
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"亲子圈" image:nil selectedImage:nil];
    }
    else
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"亲子圈" image:nil tag:0];
    }
    
    
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       KColorSubTitleTxt, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateNormal];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       KColorAppMain, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [rightItem setTitlePositionAdjustment:UIOffsetMake(0, -6)];
    _rightItem = rightItem;
    NSArray *tabBarItemArray = [[NSArray alloc] initWithObjects: leftItem, rightItem,nil];
    [tabbar setItems: tabBarItemArray];
    CGFloat tabbarHight = 35.0f;
    [tabbar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(kScreenWidth/2, 0, kLineHeight, tabbarHight)]];
    [tabbar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)]];
    [tabbar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, tabbarHight - kLineHeight, kScreenWidth, kLineHeight)]];
    [tabbar setBackgroundImage:[UIImageView createImageWithColor:kColorWhite]];
    [[UITabBar appearance] setShadowImage:[UIImageView createImageWithColor:kColorWhite]];
    tabbar.delegate = self;
    [self.view addSubview:tabbar];
    _tabbar = tabbar;
    [tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.centerX.mas_equalTo(superview);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, tabbarHight));
    }];
    
    [tabbar setSelectedItem:_leftItem];
}



-(BOOL)isSelected:(TXUser *)currentUser
{
    BOOL ret = NO;
    
    DDLogDebug(@"userid:%lld, nickname:%@", currentUser.userId, currentUser.nickname);
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
//        if([_selectedUsers count] == 0)
//        {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else
//        {
//            [self sendMutesToServer];
//        }
    }
}


-(void)sendMutesToServer
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    NSMutableArray *mutesUsers = [NSMutableArray arrayWithCapacity:1];
    for(TXUser *user in _selectedUsers)
    {
        [mutesUsers addObject:@(user.userId)];
    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] mute:_departmentId childUserIds:mutesUsers muteType:[self muteType] onCompleted:^(NSError *error) {
        TXAsyncRunInMain(^{
            DDLogDebug(@"is mainThread :%@", @([NSThread isMainThread]));
            [TXProgressHUD hideHUDForView:weakSelf.view animated:NO];
            if(error)
            {
                [MobClick event:@"mute" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"禁言", nil] counter:1];
                [self showFailedHudWithError:error];
            }
            else
            {
                [self showFailedHudWithTitle:@"修改成功"];
                [MobClick event:@"mute" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"禁言", nil] counter:1];
                [[TXEaseMobHelper sharedHelper] sendCMDMessageWithType:TXCMDMessageType_GagUser];
                _muteListUsers = [_selectedUsers copy];
                [weakSelf updateConfirmStatus];
            }
        });

    }];
}

-(void)backToLastView
{
    _updateMemberSelected(_selectedUsers, _departmentId);
    _updateMemberSelected = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

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

    __block NSMutableArray *selectedUsers = _selectedUsers;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    userSelectedCell.selectedBock = ^(int64_t userId, BOOL isSelected){
        NSInteger selectecCount = 0;
        if(isSelected)
        {
            [selectedUsers addObject:user];
            selectecCount ++;
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
        [weakSelf updateConfirmStatus];
    };
    
    if([_selectedUsers containsObject:user])
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
    if(section == [_userList count] -1)
    {
        height = KBOTTOMBARHIGHT;
    }
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
    TXUser *user = [[_userList objectAtIndex:section] objectAtIndex:0];
    NSString *title = [user.nicknameFirstLetter substringToIndex:1];
    title = [NSString stringWithFormat:@"%@",[title uppercaseStringWithLocale:[NSLocale currentLocale]]];
    [label setText:title];
    [headerView addSubview:label];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *footerView = nil;
    if(section == [_userList count] -1)
    {
        footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, KBOTTOMBARHIGHT)];
        footerView.backgroundColor = [UIColor clearColor];
    }
    return footerView;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotifySelectMembersTableViewCell *userSelectedCell = (NotifySelectMembersTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    TXUser *currentSelectedUser = [(NSArray *)[_userList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row ];
    if(!currentSelectedUser)
    {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        return ;
    }
    if(![_selectedUsers containsObject:currentSelectedUser])
    {
        [userSelectedCell setCheckStatus:YES];
        [userSelectedCell layoutIfNeeded];
        [_selectedUsers addObject:currentSelectedUser];
    }
    else
    {
        [userSelectedCell setCheckStatus:NO];
        [userSelectedCell layoutIfNeeded];
        [_selectedUsers removeObject:currentSelectedUser];
    }
    [self updateConfirmStatus];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark-  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item // called when a new view is selected by the user (but not programatically)
{
    if(item == _leftItem)
    {
        if(_selectedIndex != 0)
        {
            _selectedIndex = 0;
        }
    }
    else if (item == _rightItem)
    {
        if(_selectedIndex != 1)
        {
            _selectedIndex = 1;
        }
    }
    [_tableView reloadData];
    _selectedUsers = [NSMutableArray arrayWithCapacity:1];
    _muteListUsers = [NSMutableArray arrayWithCapacity:1];
    [self updateMuteList];
}

-(void)confirm:(id)sender
{
    if(!_isSelectedChanged)
    {
        return ;
    }
    [self sendMutesToServer];

}
@end
