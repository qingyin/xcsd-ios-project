//
//  TParentsListViewController.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TParentsListViewController.h"
#import "ParentsDetailViewController.h"
#import "UIImageView+EMWebCache.h"
#import <TXChatClient.h>
#import <TXUser.h>
#import "TXUser+Utils.h"
#import "NSString+ParentType.h"
#import <ChineseToPinyin.h>
#import "UILabel+ContentSize.h"
#import "UIButton+EMWebCache.h"
#import <BlockUI.h>
#import <extobjc.h>
#import "BabyInfoNormalTableViewCell.h"
#import "BabyInfoNoParentTableViewCell.h"
#import "ParnentInfoTableViewCell.h"

#define KPARENTCELLBASETAG 0x1000
#define KHEADERVIEWBASETAG 0x2000
#define KCELLHIGHT (54.0f*kScale1)
#define KBabyViewHight 30.0f*kScale1
#define KSECTIONHEIGHT (12.0f*kScale1)
#define KRightMargin 0.0f

@interface TParentsListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    int64_t _departmentId;
    NSMutableArray *_babyList;
    NSMutableArray *_sectionList;
    NSMutableArray *_invtedList;
}
@end

@implementation TParentsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _babyList = [NSMutableArray arrayWithCapacity:5];
        _sectionList = [NSMutableArray arrayWithCapacity:5];
        _invtedList = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

-(id)initWithDepartmentId:(int64_t )departmentId
{
    self = [super init];
    if(self)
    {
        _departmentId = departmentId;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"孩子家长";
    [self createCustomNavBar];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
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
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    TXAsyncRun(^{
        [weakSelf createUser];
        TXAsyncRunInMain(^{
            [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [_tableView reloadData];
        });
    });
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




#pragma mark-- private

-(void)createUser
{
    NSArray *babysList = [[TXChatClient sharedInstance] getDepartmentMembers:_departmentId userType:TXPBUserTypeChild  error:nil];
    if(babysList != nil )
    {
        babysList = [babysList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            TXUser *user1 = (TXUser *)obj1;
            TXUser *user2 = (TXUser *)obj2;
            return [user1.nicknameFirstLetter compare:user2.nicknameFirstLetter options:NSCaseInsensitiveSearch];
        }];
        
        NSString *firstChat = nil;
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *lastArray = [NSMutableArray arrayWithCapacity:5];
        for(TXUser *user in babysList)
        {
            if(!user)
            {
                continue;
            }
            NSArray *parents = [[TXChatClient sharedInstance] getParentUsersByChildUserId:user.userId error:nil];
            NSMutableArray *parentArray = [NSMutableArray arrayWithCapacity:3];
            [parentArray addObject:user];
            for(TXUser *index in parents)
            {
                if(index)
                {
                    [parentArray addObject:index];
                }
            }
            
            if(user.nicknameFirstLetter == nil || [user.nicknameFirstLetter length] == 0)
            {
                if(parentArray)
                {
                    [lastArray addObject:parentArray];
                }
                tmpArray = nil;
                continue;
            }
            
            if(firstChat == nil)
            {
                firstChat = user.nicknameFirstLetter;
                if(parentArray)
                {
                    [tmpArray addObject:parentArray];
                }
            }
            else
            {
                if([[firstChat substringToIndex:1] isEqualToString:[user.nicknameFirstLetter substringToIndex:1] ])
                {
                    if(parentArray)
                    {
                        [tmpArray addObject:parentArray];
                    }
                }
                else
                {
                    if(tmpArray != nil && [tmpArray count] > 0)
                    {
                        [_sectionList addObject:tmpArray];
                    }
                    firstChat = user.nicknameFirstLetter;
                    tmpArray = nil;
                    tmpArray = [NSMutableArray arrayWithCapacity:5];
                    if(parentArray)
                    {
                        [tmpArray addObject:parentArray];
                    }
                }
            }
            parentArray = nil;
        }
        if(tmpArray!= nil && [tmpArray count] > 0)
        {
            [_sectionList addObject:tmpArray];
        }
        if(lastArray!= nil && [lastArray count] > 0)
        {
            [_sectionList addObject:lastArray];
        }
        
        
        
        for(TXUser *index in babysList)
        {
            NSArray *parents = [[TXChatClient sharedInstance] getParentUsersByChildUserId:index.userId error:nil];
            NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:3];
            if(index)
            {
                [tmpArray addObject:index];
            }
            for(TXUser *user in parents)
            {
                if(user)
                {
                    [tmpArray addObject:user];
                }
            }
            if(tmpArray)
            {
                [_babyList addObject:tmpArray];
            }
            tmpArray = nil;
        }
    }
}

#pragma mark-  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_babyList count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[_babyList objectAtIndex:section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section >= [_babyList count])
    {
        return nil;
    }
    UITableViewCell *cell = nil;
    NSArray *BabyInfoList = (NSArray *)[_babyList objectAtIndex:indexPath.section];
    if(indexPath.row == 0)//孩子信息
    {
        TXUser *babyUser = [BabyInfoList objectAtIndex:indexPath.row];
        if([BabyInfoList count] == 1)//没有绑定家长
        {
            static NSString *babyInfoCellIdentifier1 = @"babyInfoCellIdentifier1";
            BabyInfoNoParentTableViewCell *babyInfoCell = [tableView dequeueReusableCellWithIdentifier:babyInfoCellIdentifier1];
            if(babyInfoCell == nil)
            {
                babyInfoCell = [[BabyInfoNoParentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:babyInfoCellIdentifier1];
                
            }
            babyInfoCell.babyNameLabel.text =babyUser.nickname;
            babyInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = babyInfoCell;
        }
        else
        {
            static NSString *babyInfoCellIdentifier2 = @"babyInfoCellIdentifier2";
            BabyInfoNormalTableViewCell *babyInfoCell = [tableView dequeueReusableCellWithIdentifier:babyInfoCellIdentifier2];
            if(babyInfoCell == nil)
            {
                babyInfoCell = [[BabyInfoNormalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:babyInfoCellIdentifier2];
            }
            babyInfoCell.babyNameLabel.text =babyUser.nickname;
            babyInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = babyInfoCell;
        }
    }
    else
    {
        TXUser *parentUser = [BabyInfoList objectAtIndex:indexPath.row];
        static NSString *parentInfoCellIdentifier = @"parentInfoCellIdentifier";
        ParnentInfoTableViewCell *parentInfoCell = [tableView dequeueReusableCellWithIdentifier:parentInfoCellIdentifier];
        if(parentInfoCell == nil)
        {
            parentInfoCell = [[ParnentInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentInfoCellIdentifier];
        }
        [parentInfoCell.headerImgView TX_setImageWithURL:[NSURL URLWithString:[parentUser.avatarUrl getFormatPhotoUrl:40 hight:40]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        parentInfoCell.parentNameLabel.text = parentUser.nickname;
        if(parentUser.activated)
        {
            parentInfoCell.parentStatusValue = ParentStatus_Actived;
        }
        else
        {
            if(parentUser.mobilePhoneNumber == nil || [parentUser.mobilePhoneNumber length] == 0)
            {
                parentInfoCell.parentStatusValue = ParentStatus_NoCallNumber;
            }
            else  if(![self isInvitedByUserId:parentUser.userId])
            {
                parentInfoCell.parentStatusValue = ParentStatus_InActived;
            }
            else
            {
                parentInfoCell.parentStatusValue = ParentStatus_Invited;
            }
        }
        @weakify(self);
        NSString *mobile = parentUser.mobilePhoneNumber;
        [parentInfoCell.callBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            @strongify(self);
            if(mobile != nil && [mobile length] > 0)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",mobile]]];
            }
            else
            {
                [self showFailedHudWithTitle:@"该用户暂未绑定手机号"];
            }
        }];
        
        [parentInfoCell.inviteBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            @strongify(self);
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
            [[TXChatClient sharedInstance].userManager inviteUser:parentUser.userId onCompleted:^(NSError *error) {
                [TXProgressHUD hideHUDForView:self.view animated:YES];
                if(error)
                {
                    [self showFailedHudWithError:error];
                }
                else
                {
                    [self showSuccessHudWithTitle:@"邀请成功"];
                    @synchronized(_invtedList)
                    {
                        [_invtedList addObject:@(parentUser.userId)];
                        parentInfoCell.parentStatusValue = ParentStatus_Invited;
                    }
                }
            }];
        }];
        cell = parentInfoCell;
    }
    return cell;
}


-(BOOL)isInvitedByUserId:(int64_t)userId
{
    if([_invtedList containsObject:@(userId)])
    {
        return YES;
    }
    return NO;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    NSMutableArray *sectionIndex = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *array = [NSArray arrayWithArray:_sectionList];
    for(NSArray *index in array)
    {
        if([index count] > 0)
        {
            TXUser *user = [[index objectAtIndex:0] objectAtIndex:0];
            if([user.nicknameFirstLetter length] > 0)
            {
                NSString *firstLetter = [user.nicknameFirstLetter substringToIndex:1];
                [sectionIndex addObject:[NSString stringWithFormat:@"%@",[firstLetter uppercaseStringWithLocale:[NSLocale currentLocale]]]];
            }
        }
    }
    return sectionIndex;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    int count = 0;
    for(NSInteger i = 0; i < index && i < [_sectionList count]; i++)
    {
        NSArray *array = [_sectionList objectAtIndex:i];
        count += [array count];
    }
    return count;
}
#pragma mark-  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *BabyInfoList = (NSArray *)[_babyList objectAtIndex:indexPath.section];
    if(BabyInfoList == nil || [BabyInfoList count] == 0)
    {
        return 0;
    }
    if([BabyInfoList count] == 1)
    {
        return KCELLHIGHT;
    }
    else
    {
        if(indexPath.row == 0)
        {
            return KBabyViewHight;
        }
        return KCELLHIGHT;
    }
    return KCELLHIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return KSECTIONHEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UIView *headerView = [[UIView alloc] init];
    headerView.clipsToBounds = YES;
    headerView.backgroundColor = kColorClear;
    CGFloat width = tableView.frame.size.width-KRightMargin;
    headerView.frame = CGRectMake(0, 0, width, KSECTIONHEIGHT);
    if(section != 0)
    {
        UIView *beginLine = [[UIView alloc] init];
        beginLine.frame = CGRectMake(0, 0, width, kLineHeight);
        beginLine.backgroundColor = kColorLine;
        [headerView addSubview:beginLine];
    }
    return headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row == 0)
    {
        return;
    }
    TXUser *parentUser = [[_babyList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row ];
    [self showParentsDetailVC:parentUser.userId];
}

-(void)showParentsDetailVC:(int64_t)userId
{
    ParentsDetailViewController *chatVc = [[ParentsDetailViewController alloc] initWithIdentity:userId];
    [self.navigationController pushViewController:chatVc animated:YES];
    
}



@end
