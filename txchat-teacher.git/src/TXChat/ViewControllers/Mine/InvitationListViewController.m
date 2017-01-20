//
//  InvitationListViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "InvitationListViewController.h"
#import "UIImageView+EMWebCache.h"
#import "InvitationNextViewController.h"
#import "TXContactManager.h"

#define kCellContentViewBaseTag         12288

@interface InvitationListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) UITableView *listTabelView;
@property (nonatomic, strong) NSMutableArray *parentTypeArr;
@property (nonatomic, assign) BOOL isMaster;

@end

@implementation InvitationListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"邀请家人";
    [self createCustomNavBar];
    
    _listTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_) style:UITableViewStylePlain];
    _listTabelView.backgroundColor = kColorBackground;
    _listTabelView.delegate = self;
    _listTabelView.dataSource = self;
    _listTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTabelView];
    
    [self fetchBoundParents];
    
    // Do any additional setup after loading the view.
}

- (void)onInvitationSuccess{
    [self fetchBoundParents];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)unbindParent:(TXPBBindingParentInfo *)info{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] UnbindParent:info.user.userId onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [MobClick event:@"mime_invite" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"解绑", nil] counter:1];
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
              [MobClick event:@"mime_invite" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"解绑", nil] counter:1];
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_UnBindUser];
            [tmpObject.parentTypeArr removeObject:info];
            [tmpObject.listTabelView reloadData];
        }
    }];
}

- (void)fetchBoundParents{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    NSError *error = nil;
    __weak TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:&error];
    [[TXChatClient sharedInstance] fetchBoundParents:^(NSError *error, NSArray *bindingParentInfos) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [MobClick event:@"mime_invite" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"获取绑定家人列表", nil] counter:1];
            [tmpObject showFailedHudWithError:error];
        }else{
            [MobClick event:@"mime_invite" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"获取绑定家人列表", nil] counter:1];
            tmpObject.listArr = [@[@(TXPBParentTypeFather),@(TXPBParentTypeMother),@(TXPBParentTypeFathersfather),@(TXPBParentTypeFathersmother),@(TXPBParentTypeMothersfather),@(TXPBParentTypeMothersmother),@(TXPBParentTypeOtherparenttype)] mutableCopy];
            [bindingParentInfos enumerateObjectsUsingBlock:^(TXPBBindingParentInfo *info, NSUInteger idx, BOOL *stop) {
                if (info.isMaster) {
                    [tmpObject.listArr removeObject:@(info.parentType)];
                    [tmpObject.listArr insertObject:@(info.parentType) atIndex:0];
                    if (info.user.userId == currentUser.userId) {
                        tmpObject.isMaster = YES;
                    }
                }
            }];
            tmpObject.parentTypeArr = [NSMutableArray arrayWithArray:bindingParentInfos];
            [tmpObject.listTabelView reloadData];
        }
    }];

}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, 20.f)];
    bgView.backgroundColor = kColorBackground;
    
    UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    label.font = kFontTiny;
    label.textColor = kColorGray1;
    label.text = @"邀请家人共同关注孩子成长";
    [bgView addSubview:label];
    [label sizeToFit];
    label.frame = CGRectMake(13, 0, label.width_, 20.f);
    return bgView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *portraitImgView  = [[UIImageView alloc] initWithFrame:CGRectMake(13, 11, 23, 23)];
        portraitImgView.layer.cornerRadius = 11;
        portraitImgView.layer.masksToBounds = YES;
        portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
        portraitImgView.clipsToBounds = YES;
        portraitImgView.tag = kCellContentViewBaseTag;
        [cell.contentView addSubview:portraitImgView];
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        titleLb.font = kFontMiddle;
        titleLb.textColor = kColorBlack;
        titleLb.tag = kCellContentViewBaseTag + 1;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UILabel *subTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, tableView.width_ - 14, 45)];
        subTitleLb.font = kFontMiddle;
        subTitleLb.hidden = YES;
        subTitleLb.textColor = kColorLightGray;
        subTitleLb.tag = kCellContentViewBaseTag + 2;
        subTitleLb.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:subTitleLb];
        
        UIButton *invitationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        invitationBtn.frame = CGRectMake(tableView.width_ - 14 - 60, 7, 60, 30);
        invitationBtn.layer.cornerRadius = 5.f;
        invitationBtn.hidden = YES;
        invitationBtn.layer.masksToBounds = YES;
        invitationBtn.layer.borderColor = KColorAppMain.CGColor;
        invitationBtn.layer.borderWidth = kLineHeight;
        [invitationBtn setTitle:@"+ 邀请" forState:UIControlStateNormal];
        [invitationBtn setTitleColor:KColorAppMain forState:UIControlStateNormal];
        invitationBtn.titleLabel.font = kFontSmall;
        invitationBtn.tag = kCellContentViewBaseTag + 3;
        [cell.contentView addSubview:invitationBtn];
        
        UIImageView *starView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zl_star"]];
        starView.hidden = YES;
        starView.tag = kCellContentViewBaseTag + 5;
        [cell.contentView addSubview:starView];

        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(14, 45 - kLineHeight, self.view.width_ - 14, kLineHeight)];
        lineView.tag = kCellContentViewBaseTag + 4;
        [cell.contentView addSubview:lineView];
    }
    
    NSNumber *type = _listArr[indexPath.row];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"parentType == %d",type.integerValue];
    NSArray *arr = [_parentTypeArr filteredArrayUsingPredicate:pre];
    
    UIImageView *portraitImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
    UILabel *subTitleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 2];
    UIButton *invitationBtn = (UIButton *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 3];
    UIView *lineView = [cell.contentView viewWithTag:kCellContentViewBaseTag + 4];
    UIImageView *starView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 5];

    
    titleLb.text = [NSString getParentTypeStr:(TXPBParentType)type.integerValue];
    [titleLb sizeToFit];
    titleLb.frame = CGRectMake(portraitImgView.maxX + 7, 0, titleLb.width_, 45);
    portraitImgView.image = [UIImage imageNamed:@"userDefaultIcon"];
    starView.hidden = YES;
    if (arr.count) {
        subTitleLb.hidden = NO;
        invitationBtn.hidden = YES;
        TXPBBindingParentInfo *info = arr[0];
        if (info.isMaster) {
            starView.hidden = NO;
            starView.frame = CGRectMake(titleLb.maxX + 7, 15, 16, 16);
        }
        titleLb.textColor = KColorAppMain;
        subTitleLb.text = info.user.mobile;
        NSString *imgStr = [info.user.avatar getFormatPhotoUrl:23 hight:23];
        [portraitImgView TX_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    }else{
        titleLb.textColor = kColorBlack;
        subTitleLb.hidden = YES;
        invitationBtn.hidden = NO;
        __weak typeof(self)tmpObject = self;
        [invitationBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            InvitationNextViewController *avc = [[InvitationNextViewController alloc] init];
            avc.invitationVC = tmpObject;
            avc.type = (TXPBParentType)(type.integerValue);
            [tmpObject.navigationController pushViewController:avc animated:YES];
        }];
    }
    
    if (indexPath.row != _listArr.count - 1) {
        lineView.hidden = NO;
    }else{
        lineView.hidden = YES;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *type = _listArr[indexPath.row];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"parentType == %d",type.integerValue];
    NSArray *arr = [_parentTypeArr filteredArrayUsingPredicate:pre];
    if (arr.count) {
        TXPBBindingParentInfo *info = arr[0];
        NSError *error = nil;
        __weak TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:&error];
        if (info.user.userId == currentUser.userId) {
            return NO;
        }
        return _isMaster;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSNumber *type = _listArr[indexPath.row];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"parentType == %d",type.integerValue];
        NSArray *arr = [_parentTypeArr filteredArrayUsingPredicate:pre];
        if (arr.count) {
            WEAKSELF
            ButtonItem *unbindItem = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                STRONGSELF
                [strongSelf unbindParent:arr[0]];
            }];
            NSString *unBindMsg;
            NSString *parentName = [NSString getParentTypeStr:(TXPBParentType)type.integerValue];
            TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
            if (!currentUser) {
                unBindMsg = [NSString stringWithFormat:@"您确定要解除%@与孩子的关系吗？",parentName];
            }else {
                TXUser *childUser = [[TXChatClient sharedInstance] getUserByUserId:currentUser.childUserId error:nil];
                if (!childUser) {
                    unBindMsg = [NSString stringWithFormat:@"您确定要解除%@与孩子的关系吗？",parentName];
                }else{
                    unBindMsg = [NSString stringWithFormat:@"您确定要解除%@与%@的关系吗？",parentName,childUser.realName];
                }
            }
            [self showAlertViewWithMessage:unBindMsg andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],unbindItem, nil];
        }
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"解除关系";
}


@end
