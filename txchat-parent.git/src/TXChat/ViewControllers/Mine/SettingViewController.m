//
//  SettingViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/5.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "RemindViewController.h"
#import "ServiceViewController.h"
#import "AboutViewController.h"
#import "TXEaseMobHelper.h"
#import "PublishmentDetailViewController.h"
#import "XGPush.h"
#import "UIImageView+EMWebCache.h"
#import "DebugViewController.h"
#import "TXSystemManager.h"

#define kCellContentViewBaseTag             213131
static NSInteger const kEMLogoutMaxRetryCount = 3;

typedef enum : NSUInteger {
    SettingListType_Remind = 0,             //消息提醒
    SettingListType_Clean,                  //清空缓存记录
    SettingListType_Service,                //服务协议
    SettingListType_About,                  //关于微家园
    SettingListType_Logout,                 //退出登录
    SettingListType_Debug,                 //内部测试
} SettingListType;

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_listTabelView;
    NSArray *_listArr;
    NSInteger _emLogoutRetryTime;
}
@property (nonatomic) NSInteger emLogoutRetryTime;
@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"设置";
    _emLogoutRetryTime = 0;
    [self createCustomNavBar];


    _listArr = @[
                 @[@{@"title":@"消息提醒",@"type":@(SettingListType_Remind)}],
                 @[@{@"title":@"清空缓存记录",@"type":@(SettingListType_Clean)}],
                 @[@{@"title":@"服务协议",@"type":@(SettingListType_Service)},@{@"title":@"关于乐学堂",@"type":@(SettingListType_About)}],
                 @[@{@"title":@"退出登录",@"type":@(SettingListType_Logout)}]
                 ];
    
    _listTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_) style:UITableViewStylePlain];
    _listTabelView.backgroundColor = kColorBackground;
    _listTabelView.delegate = self;
    _listTabelView.dataSource = self;
    _listTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTabelView];

    // Do any additional setup after loading the view.
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logoutEaseMob{
//    __weak typeof(self)tmpObject = self;
    
    WEAKTEMP
    //设置状态值
    [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLogoffStatus;
    //退出环信服务器
//    __weak typeof(TXEaseMobHelper) *weakHelper = [TXEaseMobHelper sharedHelper];
    [[TXEaseMobHelper sharedHelper] logOffFromEaseMobServerWithUnbindDeviceToken:YES logoffType:TXEaseMobUserLogoffType completion:^(NSDictionary *info, EMError *error, TXEaseMobLogoffType type) {
        [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedNormalStatus;
        //HUD消失
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            DDLogDebug(@"注销环信服务器失败:%@",error);
//            [tmpObject showAlertViewWithMessage:@"注销失败,请重试!" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            //bay gaoju
           // [tmpObject showFailedHudWithTitle:@"注销失败,请重试!"];
            tmpObject.emLogoutRetryTime += 1;
//            if (tmpObject.emLogoutRetryTime >= kEMLogoutMaxRetryCount) {
//                //注销成功,添加LOG记录
//                DDLogDebug(@"注销环信服务器失败超过2次,开始退出");
//                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
//                tmpObject.emLogoutRetryTime = 0;
//                //清空App角标
//                UIApplication *application = [UIApplication sharedApplication];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    application.applicationIconBadgeNumber = 0;
//                });
//                [[TXChatClient sharedInstance] cleanCurrentContext];
//                //强行进行注销逻辑
//                __strong typeof(weakHelper) strongHelper = weakHelper;
//                strongHelper.logoffBlock(nil,nil,TXEaseMobUserLogoffType);
//            }
        }else{
            
            //注销成功,添加LOG记录
            DDLogDebug(@"注销环信服务器成功");
//            [[EaseMob sharedInstance].chatManager disableAutoLogin];
//            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
            tmpObject.emLogoutRetryTime = 0;
            //清空App角标
            UIApplication *application = [UIApplication sharedApplication];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                application.applicationIconBadgeNumber = 0;
            });
            [[TXChatClient sharedInstance] cleanCurrentContext];
        }
    }];
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
    NSArray *arr = _listArr[indexPath.section];
    NSNumber *type = arr[indexPath.row][@"type"];
    if (type.intValue == SettingListType_Logout || type.intValue == SettingListType_Debug ) {
        return 60;
    }
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, 5)];
    view.backgroundColor = kColorBackground;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *arr = _listArr[indexPath.section];
    NSNumber *type = arr[indexPath.row][@"type"];
    
    if (type.intValue == SettingListType_Logout) {
        static NSString *Identifier = @"logoutCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.backgroundColor = kColorClear;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            logoutBtn.frame = CGRectMake(13, 10, tableView.width_ - 26, 40);
            logoutBtn.titleLabel.font = kFontLarge_1_b;
            logoutBtn.backgroundColor = KColorAppMain;
            logoutBtn.layer.cornerRadius = 5.f;
            logoutBtn.layer.masksToBounds = YES;
            [logoutBtn setTitle:arr[indexPath.row][@"title"] forState:UIControlStateNormal];
            [logoutBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
            [cell.contentView addSubview:logoutBtn];
            
//            __weak typeof(self)tmpObject = self;
            WEAKTEMP
            [logoutBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [TXProgressHUD showHUDAddedTo:tmpObject.view withMessage:@""];
				
                [[TXChatClient sharedInstance].dataReportManager reportEventNow:XCSDPBEventTypeAppLogout
																	  completed: ^(NSError *error) {
                    
                    DDLogDebug(@"logout");
                    [[TXChatClient sharedInstance] logout:^(NSError *error) {
                        
                        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
                        
                        if (error) {
                            TXAsyncRunInMain(^{
                                                            if (error.code == TX_STATUS_UNAUTHORIZED) {
                                //                                [tmpObject logoutEaseMob];
                                //                                [XGPush unRegisterDevice];
                                //                                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
                                                            }else{
                                                                [tmpObject showFailedHudWithError:error];
                                                            }
                                [tmpObject showFailedHudWithError:error];
                            });
                        }else{
                            //                        [XGPush unRegisterDevice];
                            [tmpObject logoutEaseMob];
                        }
                    }];
                }];
                
            }];
        }
        return cell;
    }
    else if (type.intValue == SettingListType_Debug) {
        static NSString *Identifier = @"DebugCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.backgroundColor = kColorClear;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            logoutBtn.frame = CGRectMake(13, 10, tableView.width_ - 26, 40);
            logoutBtn.titleLabel.font = kFontLarge_1_b;
            logoutBtn.backgroundColor = KColorAppMain;
            logoutBtn.layer.cornerRadius = 5.f;
            logoutBtn.layer.masksToBounds = YES;
            [logoutBtn setTitle:arr[indexPath.row][@"title"] forState:UIControlStateNormal];
            [logoutBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
            [cell.contentView addSubview:logoutBtn];
            
//            __weak typeof(self)tmpObject = self;
            WEAKTEMP
            [logoutBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                DebugViewController *debugVC = [[DebugViewController alloc]init];
                [tmpObject.navigationController presentViewController:debugVC animated:YES completion:nil];
            }];
        }
        return cell;
    }
    
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(13, 0, tableView.width_ - 26, 45)];
        titleLb.font = kFontMiddle;
        titleLb.textColor = kColorBlack;
        titleLb.tag = kCellContentViewBaseTag;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(0, 45 - kLineHeight, self.view.width_, kLineHeight)];
        lineView.tag = kCellContentViewBaseTag + 1;
        [cell.contentView addSubview:lineView];
    }
    
    
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    UIView *lineView = [cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
    
    titleLb.text = arr[indexPath.row][@"title"];
    
    if (indexPath.row != arr.count - 1) {
        lineView.hidden = NO;
    }else{
        lineView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = _listArr[indexPath.section];
    NSNumber *type = arr[indexPath.row][@"type"];
    
    switch (type.intValue) {
        case SettingListType_Logout://注销
        {
            return;
        }
            break;
        case SettingListType_Clean://清除缓存
        {
            WEAKSELF
            [self showAlertViewWithMessage:@"将删除所有个人、群等聊天记录（图片、文字、音频）" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                DDLogDebug(@"清空缓存记录");
                [[TXEaseMobHelper sharedHelper] removeAllConversations];
                [[TXChatClient sharedInstance] deleteLocalCache];
                [[EMSDWebImageManager sharedManager].imageCache clearDisk];
                [[EMSDWebImageManager sharedManager].imageCache cleanDisk];
                [[EMSDWebImageManager sharedManager].imageCache clearMemory];
                [[TXSystemManager sharedManager] clearAllUnusedCache];
                [weakSelf showFailedHudWithTitle:@"缓存清除成功"];
//                [weakSelf showAlertViewWithMessage:@"缓存清除成功" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action: nil], nil];
            }], nil];
        }
            break;
        case SettingListType_Remind://消息提醒
        {
            RemindViewController *remindVC = [[RemindViewController alloc] init];
            [self.navigationController pushViewController:remindVC animated:YES];
        }
            break;
        case SettingListType_Service://服务协议
        {
            PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:KSERVERAGREEMENTURL];
            detailVc.postType = TXHomePostType_ServiceAgreement;
            [self.navigationController pushViewController:detailVc animated:YES];            
        }
            break;
        case SettingListType_About://关于
        {
            AboutViewController *aboutVC = [[AboutViewController alloc] init];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
            break;
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
//