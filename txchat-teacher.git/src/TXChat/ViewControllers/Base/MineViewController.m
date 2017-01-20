//
//  MineViewController.m
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#import "MineViewController.h"
#import "SettingViewController.h"
#import "InfoViewController.h"
#import "GuardianViewController.h"
#import "HelpViewController.h"
#import "SecureListViewController.h"
#import "UIImageView+EMWebCache.h"
#import "InvitationListViewController.h"
#import "InsuranceOrderViewController.h"
#import "ReaderCodeViewController.h"
#import "TXParentChatViewController.h"
#import "HelpWebViewController.h"
#define kCellContentViewBaseTag                     1212121

typedef enum : NSUInteger {
    MineviewListType_Info = 0,              //信息
    MineviewListType_MyBaby,                //我的孩子
    MineviewListType_Invitation,            //邀请家人
    MineviewListType_Guardian,              //云卫士卡号
    MineviewListType_Safe,                  //孩子无忧
    MineviewListType_Follow,                //我的关注
    MineviewListType_Secure,                //账户安全
    MineviewListType_Help,                  //帮助与反馈
    MineviewListType_Setting,               //设置
} MineviewListType;

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_listTabelView;
    
    NSArray *_listArr;
}

@end

@implementation MineViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshUserInfo:) name:kRefreshUseInfo object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"我";
    [self createCustomNavBar];
    
//    NSDictionary *userProfiles = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
//    NSArray *cateArray;
//    if(userProfiles != nil)
//    {
//      NSNumber *value = (NSNumber *)[userProfiles objectForKey:TX_PROFILE_KEY_OPTION_INSURANCE];
//        if ([value boolValue]) {
//            cateArray = @[@{@"title":@"云卫士卡号",@"img":@"mine_guardian",@"type":@(MineviewListType_Guardian)},@{@"title":@"孩子保险",@"img":@"mine_safe",@"type":@(MineviewListType_Safe)}];
//        }else{
//            cateArray = @[@{@"title":@"云卫士卡号",@"img":@"mine_guardian",@"type":@(MineviewListType_Guardian)}];
//        }
//    }else {
//        cateArray = @[@{@"title":@"云卫士卡号",@"img":@"mine_guardian",@"type":@(MineviewListType_Guardian)}];
//    }

    _listArr = @[@[@{@"type":@(MineviewListType_Info)}],//顶部信息
                 //cateArray,
                 @[@{@"title":@"帐户安全",@"img":@"mine_secure",@"type":@(MineviewListType_Secure)},
                   @{@"title":@"帮助与反馈",@"img":@"mine_help",@"type":@(MineviewListType_Help)}],
                 @[@{@"title":@"设置",@"img":@"mine_setting",@"type":@(MineviewListType_Setting)}]];
    
    _listTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_ - kTabBarHeight) style:UITableViewStylePlain];
    _listTabelView.backgroundColor = kColorBackground;
    _listTabelView.delegate = self;
    _listTabelView.dataSource = self;
    _listTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTabelView.bounces = NO;
    [self.view addSubview:_listTabelView];
    // Do any additional setup after loading the view.
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.hidden = YES;
//#if DEBUG
//    [self.btnRight setTitle:@"扫一扫" forState:UIControlStateNormal];
//#else
//#endif
}

- (void)onClickBtn:(UIButton *)sender{
//#if DEBUG
//    if (sender.tag == TopBarButtonRight) {
//        ReaderCodeViewController *avc = [[ReaderCodeViewController alloc] init];
//        [self.navigationController pushViewController:avc animated:YES];
//    }
//#else
//#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//刷新用户信息
- (void)onRefreshUserInfo:(NSNotification *)notification{
    [_listTabelView reloadData];
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = _listArr[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 67;
    }
    
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 10 * kScale)];
    view.backgroundColor = kColorClear;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.f * kScale;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //用户信息
        static NSString *Identifier = @"headerCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UIImageView *portraitImgView = [[UIImageView alloc] init];
            portraitImgView.tag = kCellContentViewBaseTag;
            portraitImgView.layer.cornerRadius = 3;
            portraitImgView.layer.masksToBounds = YES;
            portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
            portraitImgView.clipsToBounds = YES;
            portraitImgView.frame = CGRectMake(14, 11, 45, 45);
            [cell.contentView addSubview:portraitImgView];
            
            UILabel *nameLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            nameLb.font = kFontMiddle;
            nameLb.textColor = kColorBlack;
            nameLb.tag = kCellContentViewBaseTag + 1;
            nameLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:nameLb];
            
            UILabel *accountLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            accountLb.font = kFontSmall;
            accountLb.textColor = kColorLightGray;
            accountLb.tag = kCellContentViewBaseTag + 2;
            accountLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:accountLb];
            
            UIImageView *twoDimensionCodeView = [[UIImageView alloc] initWithFrame:CGRectZero];
            twoDimensionCodeView.image = [UIImage imageNamed:@"mime_twodimensioncode"];
            twoDimensionCodeView.tag = kCellContentViewBaseTag + 3;
            [cell.contentView addSubview:twoDimensionCodeView];
            
            [cell.contentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)]];
            [cell.contentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 67 - kLineHeight, kScreenWidth, kLineHeight)]];
        }
        
        NSError *error = nil;
        //昵称
        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
        UIImageView *portraitImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
        UILabel *nameLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
        UILabel *accountLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 2];
        [portraitImgView TX_setImageWithURL:[NSURL URLWithString:[user.avatarUrl getFormatPhotoUrl:54 hight:54]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        UIImageView *twoDimensionCodeView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 3];
        
        nameLb.text = user.nickname.length?user.nickname:user.username;
        [nameLb sizeToFit];
        nameLb.frame = CGRectMake(portraitImgView.maxX + 20, portraitImgView.minY + 3, nameLb.width_, nameLb.height_);
        
        //账号
        accountLb.text = [NSString stringWithFormat:@"帐号：%@",user.mobilePhoneNumber];;
        [accountLb sizeToFit];
        accountLb.frame = CGRectMake(nameLb.minX, portraitImgView.maxY - 3 - accountLb.height_, accountLb.width_, accountLb.height_);
#ifdef KSingCodeKey
        twoDimensionCodeView.frame = CGRectMake(self.view.width_-35-20, (65-20)*0.5, 20, 20);
#else
        [twoDimensionCodeView setHidden:YES];
#endif
        
        return cell;
    }else{
        static NSString *Identifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.contentView.clipsToBounds = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 11, 21, 21)];
            iconImgView.tag = kCellContentViewBaseTag + 3;
            [cell.contentView addSubview:iconImgView];
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + 14, 0, tableView.width_ - iconImgView.maxX - 15, 44)];
            titleLb.font = kFontMiddle;
            titleLb.textAlignment = NSTextAlignmentLeft;
            titleLb.textColor = kColorBlack;
            titleLb.tag = kCellContentViewBaseTag + 4;
            [cell.contentView addSubview:titleLb];
            
            UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
            lineView.tag = kCellContentViewBaseTag + 5;
            [cell.contentView addSubview:lineView];
            
            UIView *lineView1 = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)];
            lineView1.tag = kCellContentViewBaseTag + 6;
            [cell.contentView addSubview:lineView1];
        }
        
        NSArray *arr = _listArr[indexPath.section];
        NSDictionary *dic = arr[indexPath.row];
        UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 3];
        iconImgView.image = [UIImage imageNamed:dic[@"img"]];
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 4];
        titleLb.text = dic[@"title"];
        
        UIView *lineView = [cell.contentView viewWithTag:kCellContentViewBaseTag + 5];
        UIView *lineView1 = [cell.contentView viewWithTag:kCellContentViewBaseTag + 6];
        lineView1.hidden = (indexPath.row == 0)?NO:YES;
        if (indexPath.row != arr.count - 1) {
            lineView.frame = CGRectMake(10, 44 - kLineHeight, self.view.width_ - 10, kLineHeight);
        }else{
            lineView.frame = CGRectMake(0, 44 - kLineHeight, kScreenWidth, kLineHeight);
        }
        
        
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = _listArr[indexPath.section];
    NSNumber *type = arr[indexPath.row][@"type"];
    switch (type.intValue) {
        case MineviewListType_Info:
        {
            InfoViewController *infoVC = [[InfoViewController alloc] init];
            [self.navigationController pushViewController:infoVC animated:YES];
        }
            break;
        case MineviewListType_Setting:
        {
            //设置
            SettingViewController *settingVC = [[SettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
        }
            break;
        case MineviewListType_Guardian:
        {
            //云卫士卡号
            GuardianViewController *guardianVC = [[GuardianViewController alloc] init];
            [self.navigationController pushViewController:guardianVC animated:YES];
        }
            break;
        case MineviewListType_Help:
        {
            //帮助与反馈
            TXParentChatViewController *chatVc = [[TXParentChatViewController alloc] initWithChatter:KTXCustomerChatter isGroup:NO];
            chatVc.isNormalBack = YES;
            chatVc.titleStr = @"乐学堂客服";
            [self.navigationController pushViewController:chatVc animated:YES];
//            HelpWebViewController *help=[[HelpWebViewController alloc]init];
//            [self.navigationController pushViewController:help animated:YES];
        }
            break;
        case MineviewListType_Secure:
        {
            SecureListViewController *secureVC = [[SecureListViewController alloc] init];
            [self.navigationController pushViewController:secureVC animated:YES];
        }
            break;
        case MineviewListType_Invitation:
        {
            InvitationListViewController *invitationVC = [[InvitationListViewController alloc] init];
            [self.navigationController pushViewController:invitationVC animated:YES];
        }
            break;
        case MineviewListType_Safe:
        {
            InsuranceOrderViewController *orderVc = [[InsuranceOrderViewController alloc] initWithInsuranceType:InsuranceOrderType_Order];
            [self.navigationController pushViewController:orderVc animated:YES];
        }
            break;
        default:
            break;
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat sectionHeaderHeight = 10 * kScale;
//    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y >= sectionHeaderHeight)
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
