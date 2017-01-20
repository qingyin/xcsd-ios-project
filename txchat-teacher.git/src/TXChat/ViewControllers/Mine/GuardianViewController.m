//
//  GuardianViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "GuardianViewController.h"
#import "EditGuardianViewController.h"
#import "UIImageView+EMWebCache.h"
#import "QRCodeViewController.h"

#define kCellContentViewBaseTag                 1344545
#define KCellHight 50.0f

@interface GuardianViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL _debug;
}

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) UITableView *listTabelView;

@end

@implementation GuardianViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    if (_listArr.count) {
        [_listTabelView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"云卫士卡号";
#if DEBUG
    _debug = YES;
#else
    _debug = NO;
#endif
    [self createCustomNavBar];
    
    self.listArr = [NSMutableArray array];
    
    self.listTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY + 10, self.view.width_, self.view.height_ - self.customNavigationView.height_ - 10) style:UITableViewStylePlain];
    _listTabelView.backgroundColor = kColorBackground;
    _listTabelView.delegate = self;
    _listTabelView.dataSource = self;
    _listTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTabelView];
    
    [self fetchBindCards];
    
    // Do any additional setup after loading the view.
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnLeft setTitle:@"返回" forState:UIControlStateNormal];
//    if (_debug) {
//        [self.btnRight setTitle:@"二维码" forState:UIControlStateNormal];
//    }
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (!_debug) {
            return;
        }
        QRCodeViewController *avc = [[QRCodeViewController alloc] init];
        [self.navigationController pushViewController:avc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!_listArr.count) {
        return 0;
    }
    if (section == 0 ) {
        return 1;
    }
    return _listArr.count - 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return KCellHight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, 10)];
    view.backgroundColor = kColorBackground;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *portraitImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (KCellHight-40.0f)/2, 40, 40)];
        portraitImgView.tag = kCellContentViewBaseTag;
        portraitImgView.layer.cornerRadius = 8.0f/2.0f;
        portraitImgView.layer.masksToBounds = YES;
        portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
        portraitImgView.clipsToBounds = YES;
        [cell.contentView addSubview:portraitImgView];
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(portraitImgView.maxX + 10, 0, tableView.width_ - portraitImgView.maxX - 10, KCellHight)];
        titleLb.font = kFontMiddle;
        titleLb.textColor = kColorBlack;
        titleLb.tag = kCellContentViewBaseTag + 1;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UILabel *codeLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, tableView.width_ - 37, KCellHight)];
        codeLb.font = kFontMiddle;
        codeLb.textColor = kColorLightGray;
        codeLb.tag = kCellContentViewBaseTag + 2;
        codeLb.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:codeLb];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(15, KCellHight - kLineHeight, self.view.width_ - 30, kLineHeight)];
        lineView.tag = kCellContentViewBaseTag + 3;
        [cell.contentView addSubview:lineView];
    }
    
    UIImageView *portraitImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
    UILabel *codeLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 2];
    UIView *lineView = [cell.contentView viewWithTag:kCellContentViewBaseTag + 3];
    
    NSMutableDictionary *info = nil;
    if (indexPath.section == 0) {
        info = _listArr[indexPath.row];
        titleLb.textColor = kColorBlack;
    }else{
        info = _listArr[indexPath.row + 1];
        titleLb.textColor = kColorLightGray;
    }
    NSString *imgStr = [info[@"img"] getFormatPhotoUrl:40 hight:40];
    [portraitImgView TX_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    titleLb.text = info[@"name"];
    NSString *codeStr = info[@"code"];
    codeLb.text = codeStr.length?codeStr:@"未绑定";
    
    TXUser *userInfo = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSNumber *parentId = info[@"parentId"];
    if (userInfo.userId == parentId.integerValue) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.section == 0) {
        lineView.hidden = YES;
    }else if (indexPath.row != _listArr.count - 2){
        lineView.hidden = NO;
    }else{
        lineView.hidden = YES;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        EditGuardianViewController *editVC = [[EditGuardianViewController alloc] initWithDetailDic:_listArr[0]];
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

#pragma mark -获取卡号列表
- (void)fetchBindCards{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    [[TXChatClient sharedInstance] fetchBindCards:^(NSError *error, NSArray *txpbBindCardInfos) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }else{
            [txpbBindCardInfos enumerateObjectsUsingBlock:^(TXPBBindCardInfo *info, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:info.cardCode forKey:@"code"];
                [dic setValue:info.nickName forKey:@"name"];
                [dic setValue:info.avatar forKey:@"img"];
                [dic setValue:[NSNumber numberWithInteger:(NSInteger)(info.parentId)] forKey:@"parentId"];
                if (user.userId == info.parentId) {
                    if (tmpObject.listArr.count) {
                        [tmpObject.listArr insertObject:dic atIndex:0];
                    }else{
                        [tmpObject.listArr addObject:dic];
                    }
                }else{
                    [tmpObject.listArr addObject:dic];
                }
            }];
            [tmpObject.listTabelView reloadData];
        }
    }];
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
