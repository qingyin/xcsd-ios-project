//
//  BabyListViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BabyListViewController.h"
#import "ClassTableViewCell.h"
#import "ParentsDetailViewController.h"
#import "UIImageView+EMWebCache.h"
#import <TXChatClient.h>
#import <TXUser.h>
#import "TXUser+Utils.h"
#import "NSString+ParentType.h"
#import <ChineseToPinyin.h>
#import "UILabel+ContentSize.h"

#define KHEADERVIEWBASETAG 0x1000
#define KCELLHIGHT 50.0f
#define KSECTIONHEIGHT 28.f

@interface BabyListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    int64_t _departmentId;
    NSMutableArray *_babyList;
    NSMutableArray *_sectionList;
}
@end

@implementation BabyListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _babyList = [NSMutableArray arrayWithCapacity:5];
        _sectionList = [NSMutableArray arrayWithCapacity:5];
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
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    _tableView.sectionIndexColor = kColorGray;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:_tableView];
    
    
    UIView *superview = self.view;
    WEAKSELF
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, 0));
    }];
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf createUser];
        dispatch_async(dispatch_get_main_queue(), ^{
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

-(void)createUser
{
    NSArray *babysList = [[TXChatClient sharedInstance] getDepartmentMembers:_departmentId userType:TXPBUserTypeChild  error:nil];
    if(babysList != nil )
    {
//        if(babysList  != nil && [babysList count] > 0)
//        {
//            for(TXUser *user in babysList)
//            {
//                if(user.nickname != nil && [user.nickname length] > 0)
//                {
//                    user.nicknameFirstLetter = [ChineseToPinyin pinyinFromChineseString:user.nickname];
//                }
//            }
//        }
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
                if(tmpArray)
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
    return [_babyList count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[_babyList objectAtIndex:section] count] - 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ClassTableViewCell";
    ClassTableViewCell *classCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (classCell == nil) {
        classCell = [[[NSBundle mainBundle] loadNibNamed:@"ClassTableViewCell" owner:self options:nil] objectAtIndex:0];
        [classCell.contentView setBackgroundColor:kColorWhite];
//        [classCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    TXUser *parentUser = [[_babyList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row + 1] ;
    [classCell.classNameLabel setText: KCONVERTSTRVALUE(parentUser.nickname)];
    [classCell.classIconImageView TX_setImageWithURL:[NSURL URLWithString:[parentUser getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    [classCell.seperatorLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(classCell).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(classCell).with.offset(-kEdgeInsetsLeft - 5);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(classCell.mas_bottom).with.offset(-kLineHeight);
    }];
    [classCell.inActiveLabel setHidden:parentUser.activated];
    NSInteger count = [(NSArray *)[_babyList objectAtIndex:indexPath.section] count];
    if(indexPath.row == count - 2)
    {
        [classCell.seperatorLine setHidden:YES];
    }
    return classCell;
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
    return KCELLHIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *users = (NSArray *)[_babyList objectAtIndex:section];
    if ([users count] == 1) {
        //只有幼儿
        return KCELLHIGHT;
    }
    return KSECTIONHEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    NSInteger count = [(NSArray *)[_babyList objectAtIndex:section] count];
    UIView *headerView = [[UIView alloc] init];
    headerView.clipsToBounds = YES;
    headerView.backgroundColor = kColorSection;
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, count > 1 ? KCELLHIGHT : KSECTIONHEIGHT);
    //画线
    NSInteger previousUser = 0;
    if (section - 1 >= 0 && section - 1 <= [_babyList count] - 1) {
        previousUser = [(NSArray *)[_babyList objectAtIndex:section - 1] count];
    }
    if (previousUser == 1) {
        //上一个用户只有幼儿
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, kLineHeight)];
        lineView.backgroundColor = RGBCOLOR(0xb7, 0xb7, 0xb7);
        [headerView addSubview:lineView];
    }
    //填充内容
    TXUser *babyUser = [[_babyList objectAtIndex:section] objectAtIndex:0];
    if (count == 1) {
        //当前只有一个幼儿
        NSString *nameString = [NSString stringWithFormat:@"%@未绑定家长",babyUser.nickname];
        CGFloat nameSize = [UILabel widthForLabelWithText:nameString maxHeight:26 font:kFontChildSection];
        if (nameSize < 80) {
            nameSize = 80;
        }
        nameSize += 20;  //加上两边的间隔
        UIImage *image = [UIImage imageNamed:@"childUnbindSectionBg"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kEdgeInsetsLeft, 12, nameSize, 26)];
        imageView.image = image;
        [headerView addSubview:imageView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageView.width_, imageView.height_)];
        [label setFont:kFontChildSection];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:kColorGray1];
        [label setText:[NSString stringWithFormat:@"%@未绑定家长",babyUser.nickname]];
        [label setBackgroundColor:[UIColor clearColor]];
        [imageView addSubview:label];
    }else{
        //已经绑定家长
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInsetsLeft, 0, kScreenWidth, KSECTIONHEIGHT - 3)];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:kColorGray1];
        [label setText:babyUser.nickname];
        [label setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:label];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 21, 14, 7)];
        arrowImageView.image = [UIImage imageNamed:@"childBindSectionArrow"];
        [headerView addSubview:arrowImageView];
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
    TXUser *parentUser = [[_babyList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row + 1];
    [self showParentsDetailVC:parentUser.userId];
}

-(void)showParentsDetailVC:(int64_t)userId
{
    ParentsDetailViewController *chatVc = [[ParentsDetailViewController alloc] initWithIdentity:userId];
    [self.navigationController pushViewController:chatVc animated:YES];
    
}



//-(void)BabyViewTapEvent:(UITapGestureRecognizer*)recognizer
//{
//    
//    NSInteger section = recognizer.view.tag - KHEADERVIEWBASETAG;
//    TXUser *babyUser = nil;
//    if(section < [_babyList count])
//    {
//        NSArray *babyInfo = [_babyList objectAtIndex:section];
//        if([babyInfo count])
//        {
//            babyUser = [babyInfo objectAtIndex:0];
//        }
//    }
//    if(babyUser != nil)
//    {
//        [self showBabyDetailVC:babyUser.userId];
//    }
//}

-(void)showBabyDetailVC:(int64_t)babyUserId
{
//    BabyDetailViewController *babyDetailVc = [[BabyDetailViewController alloc] initWithUserId:babyUserId];
//    [self.navigationController pushViewController:babyDetailVc animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 40;//section的高度
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


@end
