//
//  GroupDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "GroupDetailHeader.h"
#import "UserDetailTableViewCell.h"
#import "UserListTableViewCell.h"
#import "GroupSwtichTableViewCell.h"
#import "TextTableViewCell.h"
#import <TXChatClient.h>
#import "EMSDImageCache.h"
#import "UIImageView+EMWebCache.h"
#import "TeacherListViewController.h"
#import "TParentsListViewController.h"
#import "TXEaseMobHelper.h"
#import "TXDepartment+Utils.h"
#import "NSDictionary+Utils.h"
#import "MuteViewController.h"
#import "TXUser+Utils.h"
#import <Reachability.h>
#import "MuteSelectMembersViewController.h"

#define KSECTIONHEIGHT1 10.0f
//#define KSECTIONHEIGHT2 20.0f
#define KCELLHIGHT 44.0f
#define KCELLHIGHT1 50.0f
#define KHeaderSection 132.0f
//清空聊天记录接口
#define KCLEARGROUPMSGTAG 900

#define kCellContentViewBaseTag 0x1000

#define KNAMEKEY @"name"
#define KTYPEKEY @"type"

typedef enum : NSUInteger {
    GroupDetailType_GradenName = 0,             //学校名字
    GroupDetailType_TeacherList,            //教师列表
    GroupDetailType_BabyList,             //孩子列表
    GroupDetailType_MuteSetting,             //禁言设置
    GroupDetailType_NoDisturb,             //群免打扰
    GroupDetailType_ClearCaches,             //清空群聊天记录
} GroupDetailType;

@interface GroupDetailViewController ()<UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    NSMutableArray *_teachers;
    NSMutableArray *_students;
    BOOL _isParent;
}
@property(nonatomic, strong)TXDepartment *currentDepart;
@end

@implementation GroupDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isParent = YES;
    }
    return self;
}

-(id)initWithParent:(BOOL)isParent groupId:(NSString * )groupId
{
    self = [super init];
    if(self)
    {
        _currentDepart = [[TXChatClient sharedInstance] getDepartmentByGroupId:groupId error:nil];
        _isParent = isParent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = _currentDepart.name;
    self.umengEventText = @"群详情";
    [self createCustomNavBar];
    [self createTitles];
    [self createUsers];
    [self setupViews];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchDepartmentMembers:_currentDepart.departmentId clearLocalData:NO onCompleted:^(NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf createUsers];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            });
        }
    }];
    [self setupRefresh];
}

-(void)setupViews
{
    UIView *superview = self.view;
    __weak __typeof(&*self) weakSelf=self;  //by sck
//    GroupDetailHeader *topView = [[[NSBundle mainBundle] loadNibNamed:@"GroupDetailHeader" owner:self options:nil] objectAtIndex:0];
//    [topView setViewModel:GROUPDETAILHEADER_GROUP];
////    [topView.name setText:_currentDepart.name];
//    [topView.bkImage setImage:[UIImage imageNamed:@"groupDetailHeaderBk"]];
//    [topView.headerImage sd_setImageWithURL:[NSURL URLWithString:[_currentDepart getFormatAvatarUrl:70.0f hight:70.0f]] placeholderImage:[UIImage imageNamed:@"classDefaultIcon"]];
//    topView.headerImage.layer.cornerRadius = 70.0f/2.0f;
//    topView.headerImage.layer.masksToBounds = YES;
//    [topView setBackgroundColor:[UIColor redColor]];
//    [superview addSubview:topView];
//    CGFloat padding = 100;
//    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
//        make.left.mas_equalTo(superview);
//        make.right.mas_equalTo(superview);
//        make.height.mas_equalTo(padding);
//    }];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.left.mas_equalTo(superview);
        make.right.mas_equalTo(superview);
        make.bottom.mas_equalTo(superview.mas_bottom);
    }];
    
}


-(void)createUsers
{
    NSArray *teachers = [[TXChatClient sharedInstance] getDepartmentMembers:_currentDepart.departmentId userType:TXPBUserTypeTeacher error:nil];
    NSArray *students =[[TXChatClient sharedInstance] getDepartmentMembers:_currentDepart.departmentId userType:TXPBUserTypeParent error:nil];
    NSMutableArray *mutablesTeacher = [NSMutableArray arrayWithCapacity:5];
    if(teachers)
    {
        [mutablesTeacher addObjectsFromArray:teachers];
    }
    NSMutableArray *mutablesStudent = [NSMutableArray arrayWithCapacity:5];
    if(students)
    {
        [mutablesStudent addObjectsFromArray:students];
    }
    
    @synchronized(_teachers)
    {
        _teachers = mutablesTeacher;
    }
    
    @synchronized(_students)
    {
        _students = mutablesStudent;
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



-(void)createTitles
{
    if(_isParent)
    {
        if(_currentDepart.showParent)
        {
            _titleArray = @[@[@{KNAMEKEY:@"学校", KTYPEKEY:@(GroupDetailType_GradenName)}, @{KNAMEKEY:@"教师", KTYPEKEY:@(GroupDetailType_TeacherList)}, @{KNAMEKEY:@"孩子家长", KTYPEKEY:@(GroupDetailType_BabyList)}], @[@{KNAMEKEY:@"消息免打扰", KTYPEKEY:@(GroupDetailType_NoDisturb)}], @[@{KNAMEKEY:@"清空聊天记录", KTYPEKEY:@(GroupDetailType_ClearCaches)}]];
        }
        else
        {
            _titleArray = @[@[@{KNAMEKEY:@"学校", KTYPEKEY:@(GroupDetailType_GradenName)}, @{KNAMEKEY:@"教师", KTYPEKEY:@(GroupDetailType_TeacherList)}], @[@{KNAMEKEY:@"消息免打扰", KTYPEKEY:@(GroupDetailType_NoDisturb)}], @[@{KNAMEKEY:@"清空聊天记录", KTYPEKEY:@(GroupDetailType_ClearCaches)}]];
        }
    }
    else
    {
        if(_currentDepart.departmentType == TXPBDepartmentTypeClazz)
        {
            _titleArray = @[@[@{KNAMEKEY:@"学校", KTYPEKEY:@(GroupDetailType_GradenName)}, @{KNAMEKEY:@"教师", KTYPEKEY:@(GroupDetailType_TeacherList)}, @{KNAMEKEY:@"孩子家长", KTYPEKEY:@(GroupDetailType_BabyList)}],@[@{KNAMEKEY:@"禁言设置", KTYPEKEY:@(GroupDetailType_MuteSetting)}], @[@{KNAMEKEY:@"消息免打扰", KTYPEKEY:@(GroupDetailType_NoDisturb)}], @[@{KNAMEKEY:@"清空聊天记录", KTYPEKEY:@(GroupDetailType_ClearCaches)}]];
        }
        else
        {
            _titleArray = @[@[@{KNAMEKEY:@"学校", KTYPEKEY:@(GroupDetailType_GradenName)}, @{KNAMEKEY:@"教师", KTYPEKEY:@(GroupDetailType_TeacherList)}], @[@{KNAMEKEY:@"消息免打扰", KTYPEKEY:@(GroupDetailType_NoDisturb)}],@[@{KNAMEKEY:@"清空聊天记录", KTYPEKEY:@(GroupDetailType_ClearCaches)}]];
        }
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
    NSArray *arr = [_titleArray objectAtIndex:indexPath.section];
    NSNumber *type = arr[indexPath.row][KTYPEKEY];
    NSString *title = arr[indexPath.row][KNAMEKEY];
    if(type.integerValue == GroupDetailType_GradenName)
    {
        static NSString *CellIdentifier = @"UserDetailTableViewCell";
        UserDetailTableViewCell *classCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (classCell == nil) {
            classCell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        [classCell.titleLabel setText:title];
//        [classCell.titleLabel setTextAlignment:NSTextAlignmentRight];
        [classCell.contentLabel setText:[_currentDepart getKindergartenName]];
        [classCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell = classCell;
    }
    else if(type.integerValue == GroupDetailType_TeacherList || type.integerValue == GroupDetailType_BabyList)
    {
        static NSString *CellIdentifier = @"UserListTableViewCell";
        UserListTableViewCell *userListCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (userListCell == nil) {
            userListCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        [userListCell.nameLabel setText:title];
//        [userListCell.nameLabel setTextAlignment:NSTextAlignmentRight];
        
        NSMutableArray *headerImages = [NSMutableArray arrayWithCapacity:4];
        NSInteger maxHeaderImages = 4;
        NSInteger count = 0;
        if(type.integerValue == GroupDetailType_TeacherList)
        {
            for(TXUser *index in _teachers)
            {
                if(!KISSTRNULL(index.avatarUrl))
                {
                    [headerImages addObject:[index getFormatAvatarUrl:40.0f hight:40.0f]];
                    count++;
                }
                if(count >= maxHeaderImages)
                {
                    break;
                }
            }
            if(count < maxHeaderImages)
            {
                for(TXUser *index in _teachers)
                {
                    if(KISSTRNULL(index.avatarUrl))
                    {
                        [headerImages addObject:@""];
                        count++;
                    }
                    if(count >= maxHeaderImages)
                    {
                        break;
                    }
                }
            }
            
        }
        else
        {
            for(TXUser *index in _students)
            {
                if(!KISSTRNULL(index.avatarUrl))
                {
                    [headerImages addObject:[index getFormatAvatarUrl:40.0f hight:40.0f]];
                    count++;
                }
                if(count >= maxHeaderImages)
                {
                    break;
                }
            }
            if(count < maxHeaderImages)
            {
                for(TXUser *index in _students)
                {
                    if(KISSTRNULL(index.avatarUrl))
                    {
                        [headerImages addObject:@""];
                        count++;
                    }
                    if(count >= maxHeaderImages)
                    {
                        break;
                    }
                }
            }
        }
        [userListCell setHeaderList:headerImages];
        if(indexPath.row == [(NSArray *)[_titleArray objectAtIndex:indexPath.section] count] -1)
        {
            [userListCell.seperatorLine setHidden:YES];
        }
//        [userListCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell = userListCell;
    
    }
    else if(type.integerValue == GroupDetailType_MuteSetting)
    {
        static NSString *CellIdentifier = @"TextTableViewCell";
        TextTableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (textCell == nil) {
            textCell = [[[NSBundle mainBundle] loadNibNamed:@"TextTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        [textCell.nameLabel setText:title];
        [textCell.seperatorLine setHidden:YES];
        cell = textCell;
    }
    else if(type.integerValue == GroupDetailType_NoDisturb)
    {
        static NSString *CellIdentifier = @"GroupSwtichTableViewCell";
        GroupSwtichTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (switchCell == nil) {
            switchCell = [[[NSBundle mainBundle] loadNibNamed:@"GroupSwtichTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        [switchCell.nameLabel setText:title];
        [switchCell.seperatorLine setHidden:YES];
        [switchCell.sw setOnTintColor:[UIColor redColor]];
        [switchCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        BOOL noDisturbValue = NO;
        noDisturbValue = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:_currentDepart.groupId];
        [switchCell.sw setOn:noDisturbValue];
        __weak typeof(switchCell) weakSwitchCell = switchCell;
        __weak __typeof(&*self) weakSelf=self;  //by sck
        switchCell.switchValueChanged = ^(id sender)
        {
            UISwitch *sw = (UISwitch *)sender;
            BOOL currentValue = sw.isOn;
            Reachability* reach = [Reachability reachabilityForInternetConnection];
            if(!reach.isReachable)
            {
                [weakSelf showFailedHudWithTitle:@"网络已断开"];
                [weakSwitchCell.sw setOn:!currentValue];
                return;
            }
            
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
            [[TXEaseMobHelper sharedHelper] ignoreGroupDisturbWithId:_currentDepart.groupId disturbStatus:currentValue completion:^(BOOL isSuccess) {
                [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if(!isSuccess)
                {
                    [weakSwitchCell.sw setOn:!currentValue];
                    [weakSelf showFailedHudWithTitle:@"更新群免打扰失败"];
                }
            }];
        };
        
        cell = switchCell;
    }
    else if(type.integerValue == GroupDetailType_ClearCaches)
    {
        static NSString *CellIdentifier = @"normalUITableViewCell";
        UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (normalCell == nil)
        {
            normalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(kEdgeInsetsLeft, 0, tableView.width_ - 2*kEdgeInsetsLeft, KCELLHIGHT)];
            titleLb.font = kFontTitle;
            titleLb.textColor = KColorTitleTxt;
            titleLb.tag = kCellContentViewBaseTag;
            titleLb.textAlignment = NSTextAlignmentLeft;
            [normalCell.contentView addSubview:titleLb];
        }
//        [normalCell.textLabel setText:title];
        UILabel *titleLb = (UILabel *)[normalCell.contentView viewWithTag:kCellContentViewBaseTag];
        [titleLb setText:title];
        cell = normalCell;
    }
    
    
    [cell.contentView setBackgroundColor:kColorWhite];
    return cell;
}




#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    CGFloat height = 0;
    switch (section) {
        case 0:
            height = KHeaderSection;
            break;
        case 1:
            height = KSECTIONHEIGHT1;
            break;
        case 2:
            height = KSECTIONHEIGHT1;
            break;
        case 3:
            height = KSECTIONHEIGHT1;
            break;
        default:
            break;
    }
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
    if(section == 0)
    {
        CGFloat padding = KHeaderSection;
        headerView = [[UIView alloc] init];
        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, padding);
        headerView.backgroundColor = kColorBackground;        
        GroupDetailHeader *topView = [[[NSBundle mainBundle] loadNibNamed:@"GroupDetailHeader" owner:self options:nil] objectAtIndex:0];
        [topView setViewModel:GROUPDETAILHEADER_GROUP];
        //    [topView.name setText:_currentDepart.name];
        [topView.bkImage setImage:[UIImage imageNamed:@"groupDetailHeaderBk"]];
        [topView.headerImage TX_setImageWithURL:[NSURL URLWithString:[_currentDepart getFormatAvatarUrl:75.0f hight:75.0f]] placeholderImage:[UIImage imageNamed:@"classDefaultIcon"]];
        [topView setBackgroundColor:[UIColor redColor]];
        [headerView addSubview:topView];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        return headerView;
    }
    headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
    headerView.backgroundColor = kColorBackground;

    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 1 || indexPath.row == 2)
        {
            return KCELLHIGHT1;
        }
    }
    return KCELLHIGHT;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [_titleArray objectAtIndex:indexPath.section];
    NSNumber *type = arr[indexPath.row][KTYPEKEY];
    if(type.integerValue == GroupDetailType_MuteSetting)
    {
//        MuteViewController *muteVC = [[MuteViewController alloc] initWithDepartmentId:_currentDepart.departmentId];
//        [self.navigationController pushViewController:muteVC animated:YES];
        MuteSelectMembersViewController *memberSelectedVC = [[MuteSelectMembersViewController alloc] initWithDepartmentId:_currentDepart.departmentId];
        [self.navigationController pushViewController:memberSelectedVC animated:YES];
    }
    else if(type.integerValue == GroupDetailType_TeacherList)
    {
        [self showTeachersList];
    }
    else if(type.integerValue == GroupDetailType_BabyList)
    {
        [self showBabysList:_currentDepart.departmentId];
    }
    else if(type.integerValue == GroupDetailType_ClearCaches)
    {
        [self showHighlightedSheetWithTitle:@"是否清空聊天记录？" normalItems:nil highlightedItems:@[@"确定"] otherItems:nil clickHandler:^(NSInteger index) {
            if (index == 0) {
                [[TXEaseMobHelper sharedHelper] removeConversationByChatter:_currentDepart.groupId deleteMessage:YES];
            }
        } completion:nil];
//        UIActionSheet *cleanRecordActionSheet = [[UIActionSheet alloc] initWithTitle:@"是否清空聊天记录？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
//        cleanRecordActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        cleanRecordActionSheet.tag = KCLEARGROUPMSGTAG;
//        cleanRecordActionSheet.delegate = self;
//        [cleanRecordActionSheet showInView:self.view];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)showTeachersList
{
    TeacherListViewController *teacherList = [[TeacherListViewController alloc] initWithDepartmentId:_currentDepart.departmentId];
    [self.navigationController pushViewController:teacherList animated:YES];
    
}

-(void)showBabysList:(int64_t)departmentId
{
    TParentsListViewController *babyList = [[TParentsListViewController alloc] initWithDepartmentId:departmentId];
    [self.navigationController pushViewController:babyList animated:YES];

}
#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == KCLEARGROUPMSGTAG)
    {
        if(buttonIndex == 0)
        {
            [[TXEaseMobHelper sharedHelper] removeConversationByChatter:_currentDepart.groupId deleteMessage:YES];
        }
    }

}

//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
}


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    __weak typeof(self)weakSelf = self;
    [[TXChatClient sharedInstance] fetchDepartmentMembers:_currentDepart.departmentId clearLocalData:YES onCompleted:^(NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf createUsers];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            });
        }
        else
        {
            [self showFailedHudWithError:error];
        }
        [_tableView.header endRefreshing];
    }];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = KHeaderSection;//section的高度
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
@end
