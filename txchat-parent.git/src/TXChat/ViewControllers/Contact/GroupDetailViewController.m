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
#import "ShutUpOperateViewController.h"
#import <TXChatClient.h>
#import "EMSDImageCache.h"
#import "UIImageView+EMWebCache.h"
#import "TeacherListViewController.h"
#import "BabyListViewController.h"
#import "TXEaseMobHelper.h"
#import "TXDepartment+Utils.h"
#import "NSDictionary+Utils.h"
#import "TXUser+Utils.h"
#import <Reachability.h>
#import "TParentsListViewController.h"
#define KSECTIONHEIGHT1 10.0f
//#define KSECTIONHEIGHT2 20.0f
#define KCELLHIGHT 44.0f
#define KCELLHIGHT1 50.0f
//清空聊天记录接口
#define KCLEARGROUPMSGTAG 900

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
    UIView *superview = self.view;
    WEAKSELF
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
    
    [[TXChatClient sharedInstance] fetchDepartmentMembers:_currentDepart.departmentId clearLocalData:NO  onCompleted:^(NSError *error) {
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
            _titleArray = @[@[@"学校", @"教师", @"孩子家长"], @[@"消息免打扰"], @[@"清空聊天记录"]];
        }
        else
        {
            _titleArray = @[@[@"学校", @"教师"], @[@"消息免打扰"], @[@"清空聊天记录"]];
        }
    }
    else
    {
        if(_currentDepart.showParent)
        {
            _titleArray = @[@[@"学校", @"教师", @"孩子家长"],@[@"禁言设置"], @[@"消息免打扰"], @[@"清空聊天记录"]];
        }
        else
        {
            _titleArray = @[@[@"学校", @"教师", @"孩子家长"],@[@"禁言设置"], @[@"消息免打扰"], @[@"清空聊天记录"]];
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
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"UserDetailTableViewCell";
            UserDetailTableViewCell *gardenCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (gardenCell == nil) {
                gardenCell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
            NSString *title = [[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [gardenCell.titleLabel setText:title];
            [gardenCell.titleLabel setFont:kFontTitle];
            [gardenCell.titleLabel setTextColor:KColorTitleTxt];
            [gardenCell.contentLabel setFont:kFontTitle];
            [gardenCell.contentLabel setTextColor:KColorSubTitleTxt];
            [gardenCell.contentLabel setText:[_currentDepart getKindergartenName]];
            [gardenCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell = gardenCell;
        }
        else if(indexPath.row >= 1)
        {
            static NSString *CellIdentifier = @"UserListTableViewCell";
            UserListTableViewCell *userListCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (userListCell == nil) {
                userListCell = [[[NSBundle mainBundle] loadNibNamed:@"UserListTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
            NSString *title = [[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [userListCell.nameLabel setText:title];
            [userListCell.nameLabel setFont:kFontTitle];
            [userListCell.nameLabel setTextColor:KColorTitleTxt];
            NSMutableArray *headerImages = [NSMutableArray arrayWithCapacity:4];
            NSInteger maxHeaderImages = 4;
            NSInteger count = 0;
            if(indexPath.row == 1)
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
//            [userListCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell = userListCell;
        }
    }
    if(indexPath.section == 1)
    {
        static NSString *CellIdentifier = @"GroupSwtichTableViewCell";
        GroupSwtichTableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (switchCell == nil) {
            switchCell = [[[NSBundle mainBundle] loadNibNamed:@"GroupSwtichTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        NSString *title = [[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [switchCell.nameLabel setText:title];
        [switchCell.seperatorLine setHidden:YES];
        [switchCell.sw setOnTintColor:[UIColor redColor]];
        [switchCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        BOOL noDisturbValue = NO;
        noDisturbValue = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:_currentDepart.groupId];
        [switchCell.sw setOn:noDisturbValue];
//        __weak typeof(switchCell) weakSwitchCell = switchCell;
        // by mey
        __weak __typeof(&*switchCell) weakSwitchCell=switchCell;
        WEAKSELF
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
//                        [weakSelf showAlertViewWithMessage:@"更新群免打扰失败" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
                }
            }];
        };
        
        cell = switchCell;
    }
    else if(indexPath.section == 2)
    {
        
#define KNameLabelTag 0x1001
        static NSString *CellIdentifier1 = @"normalUITableViewCell";
        UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (normalCell == nil)
        {
            normalCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInsetsLeft, 0, tableView.frame.size.width-kEdgeInsetsLeft, KCELLHIGHT)];
            [nameLabel setFont:kFontTitle];
            [nameLabel setTextColor:KColorTitleTxt];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            nameLabel.tag = KNameLabelTag;
            [normalCell.contentView addSubview:nameLabel];
        }
        [normalCell setBackgroundColor:[UIColor whiteColor]];
        UILabel *nameLabel = nil;
        nameLabel = (UILabel *)[normalCell.contentView viewWithTag:KNameLabelTag];
        NSString *title = [[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [nameLabel setText:title];
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
            height = 132;
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
        CGFloat padding = 132;
        headerView = [[UIView alloc] init];
        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, padding);
        headerView.backgroundColor = kColorBackground;        
        GroupDetailHeader *topView = [[[NSBundle mainBundle] loadNibNamed:@"GroupDetailHeader" owner:self options:nil] objectAtIndex:0];
        [topView setViewModel:GROUPDETAILHEADER_GROUP];
        [topView.bkImage setImage:[UIImage imageNamed:@"groupDetailHeaderBk"]];
        [topView.headerImage TX_setImageWithURL:[NSURL URLWithString:[_currentDepart getFormatAvatarUrl:75.0f hight:75.0f]] placeholderImage:[UIImage imageNamed:@"classDefaultIcon"]];
        topView.headerImage.layer.cornerRadius = 4.0f/2.0f;
        topView.headerImage.layer.masksToBounds = YES;
        [topView setBackgroundColor:[UIColor redColor]];
        [headerView addSubview:topView];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView);
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(!_isParent)
    {
        if(indexPath.section == 1)
        {
            ShutUpOperateViewController *shutUpVc = [[ShutUpOperateViewController alloc] initWithNibName:nil bundle:nil];
            shutUpVc.leftTitle = @"111";
            NSArray *array = @[@"11", @"11",@"11",@"11",@"11",@"11",@"11",@"11",@"11"];
//            shutUpVc.deptId = _clazzID;
            shutUpVc.listMemberArr = array;
            [self.navigationController pushViewController:shutUpVc animated:YES];
//            __block typeof(shutUpVc)blockShutUp = shutUpVc;
            // by mey
            __block __typeof(&*shutUpVc) blockShutUp = shutUpVc;
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                NSLog(@"timer date 2== %@",[NSDate date]);
                [blockShutUp onGetShutUpListArr:array];
            });
        }
    }
    
    if(_isParent)
    {
        if(indexPath.row == 1)
        {
            [self showTeachersList];
        }
        else if(indexPath.row == 2)
        {
            [self showBabysList:_currentDepart.departmentId];
        }
        
    
    }
    
    

    if((indexPath.section == 2 && _isParent) || (indexPath.section == 3 && !_isParent))
    {
        [self showHighlightedSheetWithTitle:@"是否清空聊天记录？" normalItems:nil highlightedItems:@[@"确定"] otherItems:nil clickHandler:^(NSInteger index) {
            if(index == 0){
                [[TXEaseMobHelper sharedHelper] removeConversationByChatter:_currentDepart.groupId deleteMessage:YES];
            }
        } completion:nil];
//        UIActionSheet *cleanRecordActionSheet = [[UIActionSheet alloc] initWithTitle:@"是否清空聊天记录？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
//        cleanRecordActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        cleanRecordActionSheet.tag = KCLEARGROUPMSGTAG;
//        cleanRecordActionSheet.delegate = self;
//        [cleanRecordActionSheet showInView:self.view];
    }
}


-(void)showTeachersList
{
    TeacherListViewController *teacherList = [[TeacherListViewController alloc] initWithDepartmentId:_currentDepart.departmentId];
    [self.navigationController pushViewController:teacherList animated:YES];
    
}

-(void)showBabysList:(int64_t)departmentId
{
//    BabyListViewController *babyList = [[BabyListViewController alloc] initWithDepartmentId:departmentId];
//    [self.navigationController pushViewController:babyList animated:YES];
    TParentsListViewController *parentListVC = [[TParentsListViewController alloc] initWithDepartmentId:departmentId];
    [self.navigationController pushViewController:parentListVC animated:YES];

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
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
}


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
//    __weak typeof(self)weakSelf = self;
    WEAKSELF
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




@end
