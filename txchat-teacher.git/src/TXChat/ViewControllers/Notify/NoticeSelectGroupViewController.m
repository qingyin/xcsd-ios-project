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
#import <TXChatClient.h>
#import <TXDepartment.h>
#import "UIImageView+EMWebCache.h"
#import "NoticeSelectedModel.h"
#import "TXDepartment+Utils.h"
#define KCELLHIGHT 60.0f;
@interface NoticeSelectGroupViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_groupList;
    NSInteger _selectedCount;
    NSMutableArray *_selectedDeparts;
    BOOL _reselected;
}
@end

@implementation NoticeSelectGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedCount = 0;
        _selectedDeparts = [NSMutableArray arrayWithCapacity:1];
        _reselected = NO;
        _groupSelectedUpdate = nil;
    }
    return self;
}
//重新选择接收人
-(id)initWithSelectedDepartments:(NSArray *)selectedDepartments 
{
    self = [super init];
    if(self)
    {
        [_selectedDeparts addObjectsFromArray:selectedDepartments];
        _reselected = YES;    
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"选择收件人";
    [self createCustomNavBar];
    NSString *selectStr= [NSString stringWithFormat:@"确定(%ld人)", (long)_selectedCount];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    CGRect btnFrame = self.btnRight.frame;
    btnFrame.origin.x -= 50;
    btnFrame.size.width+= 50;
    [self.btnRight setFrame:btnFrame];
    [self createUserList];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    [self.view addSubview:_tableView];
    
    UIView *superview = self.view;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY+kEdgeInsetsLeft, 0, 0, 0));
    }];
    [self autoUpdateRightTitle];
}

-(void)createUserList
{
    //    _groupList = [[TXChatClient sharedInstance] getAllDepartments:nil];
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:[[TXChatClient sharedInstance] getAllDepartments:nil]];
    
    [tmpArr enumerateObjectsUsingBlock:^(TXDepartment *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TXPBUserType userType = TXPBUserTypeChild;
        
        if(obj.departmentType != TXPBDepartmentTypeClazz)
        {
            userType = TXPBUserTypeTeacher;
        }
        
        NSArray *allUsers = [[TXChatClient sharedInstance] getDepartmentMembers:obj.departmentId userType:userType error:nil];
        
        if (allUsers.count <= 0) {
            [tmpArr removeObject:obj];
        }
    }];
    
    _groupList = tmpArr.copy;
}

-(void)autoUpdateRightTitle
{
    NSInteger count = 0;
    for(NoticeSelectedModel *index in _selectedDeparts)
    {
        count += [index.selectedUsers count];
    }
    [self updateRightTitle:count];
}

-(void)updateRightTitle:(NSInteger)updateValue
{
    _selectedCount = updateValue;
    NSString *selectStr= [NSString stringWithFormat:@"确定(%ld人)", (long)_selectedCount];
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
        
        if(_reselected)
        {
            _groupSelectedUpdate(_selectedDeparts);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            //        if(_selectedCount > 0)
            {
                [self showSendNotification];
            }
        }

    }
}
-(BOOL)isSelected:(TXDepartment *)currentDepart selectedCount:(NSInteger *)selectedCount
{
    BOOL ret = NO;
    
    __block NSUInteger index = NSNotFound;
    int64_t departmentId = currentDepart.departmentId;
    [_selectedDeparts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NoticeSelectedModel *user = (NoticeSelectedModel *)obj;
        if(user.departmentId == departmentId)
        {
            *stop = YES;
            index = idx;
            *selectedCount = [user.selectedUsers count];
        }
    }];
    if(index != NSNotFound)
    {
        ret = YES;
    }
    
    return ret;
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
//    DLog(@"section:%d, rows:%d", indexPath.section, indexPath.row);
    UITableViewCell *cell = nil;
    NotifySelectGroupTableViewCell *selectGroupCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (selectGroupCell == nil) {
        selectGroupCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifySelectGroupTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXDepartment *depart = [_groupList objectAtIndex:indexPath.row];
    [selectGroupCell.groupIcon TX_setImageWithURL:[NSURL URLWithString:[depart getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"conversation_default"]];
    [selectGroupCell.groupName setText:depart.name];
    selectGroupCell.departmentId = depart.departmentId;
    TXPBUserType userType = TXPBUserTypeChild;
    if(depart.departmentType != TXPBDepartmentTypeClazz)
    {
        userType = TXPBUserTypeTeacher;
    }
    __weak __typeof(&*self) weakSelf=self;  //by sck
    __block NSMutableArray *selectedDepartments = _selectedDeparts;
    __weak NotifySelectGroupTableViewCell *weakCell = selectGroupCell;
    __block NSInteger updateCount = 0;
    NSArray *allUsers = [[TXChatClient sharedInstance] getDepartmentMembers:depart.departmentId userType:userType error:nil];
    NSMutableArray *myMutableArray = [NSMutableArray arrayWithArray:allUsers];
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    //过滤掉自己
    if(userType == TXPBUserTypeTeacher && currentUser != nil)
    {
        [myMutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TXUser *user = (TXUser *)obj;
            if(user.userId == currentUser.userId)
            {
                [myMutableArray removeObject:user];
                *stop = YES;
            }
        }];
    }
    selectGroupCell.selectedBock = ^(int64_t  departmentId, BOOL isSelected){
        if(isSelected)
        {
            updateCount = [myMutableArray count];
            NoticeSelectedModel *selectedDepart = [[NoticeSelectedModel alloc] init];
            selectedDepart.departmentId = departmentId;
            selectedDepart.allDepartmentUsersCount = [allUsers count];
            selectedDepart.selectedUsers = myMutableArray;
            selectedDepart.departmentType = depart.departmentType;
            selectedDepart.departmentName = depart.name;
            if(selectedDepart)
            {
                [selectedDepartments addObject:selectedDepart];
            }
            [weakCell.selectedCount setText:[NSString stringWithFormat:@"%ld/%ld", (long)updateCount, (long)updateCount]];
        }
        else
        {
            updateCount = -[myMutableArray count];
            [selectedDepartments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NoticeSelectedModel *selectedDepart = (NoticeSelectedModel *)obj;
                if(departmentId == selectedDepart.departmentId)
                {
                    *stop = YES;
                    if(*stop )
                    {
                        [selectedDepartments removeObject:obj];
                    }
                }
            }];
            [weakCell.selectedCount setText:[NSString stringWithFormat:@"%d/%lu", 0, (unsigned long)[myMutableArray count]]];
        }
        [weakSelf autoUpdateRightTitle];
    };
    if(indexPath.row == [_groupList count] -1)
    {
        [selectGroupCell.seperatorLine setHidden:YES];
    }
    NSInteger selectedCount = 0;
    if([self isSelected:depart selectedCount:&selectedCount] && selectedCount)
    {
        [selectGroupCell setCheckStatus:YES];
        [selectGroupCell.selectedCount setText:[NSString stringWithFormat:@"%ld/%lu", (long)selectedCount, (unsigned long)[myMutableArray count]]];
    }
    else
    {
        [selectGroupCell.selectedCount setText:[NSString stringWithFormat:@"%d/%lu", 0, (unsigned long)[myMutableArray count]]];
    }
    
    cell = selectGroupCell;
    return cell;
}

#pragma mark-  UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXDepartment *depart = [_groupList objectAtIndex:indexPath.row];
    int64_t departmentId = depart.departmentId;
    NoticeSelectedModel *selectedModel = nil;
    NSUInteger index =  [_selectedDeparts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NoticeSelectedModel *model = (NoticeSelectedModel *)obj;
        if(model.departmentId == departmentId)
        {
            *stop = YES;
        }
        return *stop;
    }];
    if(index != NSNotFound)
    {
        selectedModel = [_selectedDeparts objectAtIndex:index];
    }
    [self showSelectMembers:selectedModel departmentId:depart];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//NotifySelectMembersViewController
-(void)showSelectMembers:(NoticeSelectedModel *)selectedModel departmentId:(TXDepartment *)depart
{
    NSArray *selectedUsers = selectedModel.selectedUsers;
    if(selectedUsers == nil && selectedModel != nil)
    {
        selectedUsers = [[TXChatClient sharedInstance] getDepartmentMembers:depart.departmentId userType:0 error:nil];
    }
    
    NoticeSelectMembersViewController *selectMembers = [[NoticeSelectMembersViewController alloc] initWithDepartmentId:depart.departmentId selectedUsers:selectedUsers];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    __block typeof(_selectedDeparts) selectedDeparts  = _selectedDeparts;
    selectMembers.updateMemberSelected = ^(NSArray *userArray, int64_t departmentId)
    {
        
        NoticeSelectedModel *selectedModel = nil;
        NSUInteger index =  [selectedDeparts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            NoticeSelectedModel *model = (NoticeSelectedModel *)obj;
            if(model.departmentId == departmentId)
            {
                *stop = YES;
            }
            return *stop;
        }];
        if(index != NSNotFound)
        {
            selectedModel = [_selectedDeparts objectAtIndex:index];
        }
//        NSInteger updateCount = 0;
        if(selectedModel == nil)
        {
            selectedModel = [[NoticeSelectedModel alloc] init];
            selectedModel.departmentId = departmentId;
            selectedModel.selectedUsers = userArray;
            selectedModel.departmentType = depart.departmentType;
            selectedModel.departmentName = depart.name;
            if(selectedModel && [selectedModel.selectedUsers count] > 0)
            {
                [selectedDeparts addObject:selectedModel];
            }
//            updateCount = [userArray count];
        }
        else
        {
//            updateCount = [userArray count] - [selectedModel.selectedUsers count];
            selectedModel.selectedUsers = userArray;
        }
       [weakSelf autoUpdateRightTitle];
        
        TXAsyncRunInMain(^{
            [_tableView reloadData];
        });
    };
    [self.navigationController pushViewController:selectMembers animated:YES];
}

//SendNotificationViewController.h
-(void)showSendNotification
{
    SendNotificationViewController *sendNotification = [[SendNotificationViewController alloc] initWithSelectedDeparts:[NSArray arrayWithArray:_selectedDeparts]];
    [self.navigationController pushViewController:sendNotification animated:YES];
}
@end
