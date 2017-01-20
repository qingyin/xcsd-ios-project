//
//  BabyDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BabyDetailViewController.h"
#import "GroupDetailHeader.h"
#import "UserDetailTableViewCell.h"
#import <TXUser.h>
#import <TXChatClient.h>
#import "TXUser+Utils.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#define KSECTIONHEIGHT1 10.0f
//#define KSECTIONHEIGHT2 20.0f
#define KCELLHIGHT 44.0f
@interface BabyDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    NSArray *_valueArray;
    TXUser *_babyUser;
}
@end

@implementation BabyDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithUserId:(int64_t)userId
{
    self = [super init];
    if(self)
    {
        _babyUser = [[TXChatClient sharedInstance] getUserByUserId:userId error:nil];
    
    
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"宝宝详情";
    [self createCustomNavBar];
    [self createTitles];
    UIView *superview = self.view;
    __weak typeof(self) weakSelf = self;
    GroupDetailHeader *topView = [[[NSBundle mainBundle] loadNibNamed:@"GroupDetailHeader" owner:self options:nil] objectAtIndex:0];
    [topView setViewModel:GROUPDETAILHEADER_BABY];
//    [topView.babyNameLabel setText:_babyUser.nickname];
    
//    NSString *sexStr = @"女";
//    if(_babyUser.sex == TXPBSexTypeFemale)
//    {
//        sexStr = @"男";
//    }    
//    [topView.babySexLabel setText:[_babyUser getSexStr]];
//    if(_babyUser.avatarUrl != nil && [_babyUser.avatarUrl length] > 0)
    {
        [topView.headerImage sd_setImageWithURL:[NSURL URLWithString:[_babyUser getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon_70"]];
    }
//    else
//    {
//        [topView.headerImage sd_setImageWithURL:[NSURL URLWithString:@"http://news.sctv.com/shxw/sjwx/201202/W020120214581133374322.jpg"] placeholderImage:[UIImage imageNamed:@"conversation_default"]];
//    }
    topView.headerImage.layer.cornerRadius = 70.0f/2.0f;
    topView.headerImage.layer.masksToBounds = YES;
    [superview addSubview:topView];
    CGFloat padding = 150;
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.left.mas_equalTo(superview);
        make.right.mas_equalTo(superview);
        make.height.mas_equalTo(padding);
    }];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom).with.offset(0);
        make.left.mas_equalTo(superview);
        make.right.mas_equalTo(superview);
        make.height.mas_equalTo(1*KSECTIONHEIGHT1 + 4*KCELLHIGHT);
    }];
    
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
-(void)createTitles
{
    _titleArray = @[@[@"班级", @"幼儿园", @"入园时间", @"生日"]];
//    _valueArray = @[@[KCONVERTSTRVALUE(_babyUser.className), KCONVERTSTRVALUE(_babyUser.gardenName),[NSDate timeForShortStyle:[NSString stringWithFormat:@"%@", @(_babyUser.enrollmentDate/1000)]],[NSDate timeForBirthDayStyle:[NSString stringWithFormat:@"%@", @(_babyUser.birthday/1000)]]]];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 4;
            break;
        default:
            break;
    }
    return rows;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;

    static NSString *CellIdentifier = @"UserDetailTableViewCell";
    UserDetailTableViewCell *classCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (classCell == nil) {
        classCell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    NSString *title = [[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [classCell.titleLabel setText:title];
    NSString *content = [[_valueArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [classCell.contentLabel setText:content];
    if(indexPath.row == [(NSArray *)[_titleArray objectAtIndex:indexPath.section] count] -1)
    {
        [classCell.seperatorLine setHidden:YES];
    }
    [classCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell = classCell;
    
    return cell;
}




#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    CGFloat height = 0;
    switch (section) {
        case 0:
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
    //    if(section == 0)
    //    {
    headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
    headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    
    //
    //    }
    //    else
    //    {
    //        headerView = [[UIView alloc] init];
    //        headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
    //        headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    //
    //
    //    }
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [self showChatVC];
    
}



@end
