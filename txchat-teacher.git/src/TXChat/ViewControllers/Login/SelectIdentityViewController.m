//
//  SelectIdentityViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SelectIdentityViewController.h"
#import "NSString+ParentType.h"
#import "IdentityViewController.h"
#import "InfoViewController.h"
#import "TXContactManager.h"

#define kCellContentViewBaseTag         123134

@interface SelectIdentityViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *listArr;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *parentTypeArr;

@end

@implementation SelectIdentityViewController

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"我是孩子的";
    
    [self createCustomNavBar];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY - kTabBarHeight) style:UITableViewStylePlain];
    _listTableView.backgroundColor = kColorBackground;
    _listTableView.showsHorizontalScrollIndicator = NO;
    _listTableView.showsVerticalScrollIndicator = NO;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    [self.view addSubview:_listTableView];
    
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] fetchBoundParents:^(NSError *error, NSArray *bindingParentInfos) {
        if (error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
            tmpObject.listArr = [@[@(TXPBParentTypeFather),@(TXPBParentTypeMother),@(TXPBParentTypeFathersfather),@(TXPBParentTypeFathersmother),@(TXPBParentTypeMothersfather),@(TXPBParentTypeMothersmother),@(TXPBParentTypeOtherparenttype)] mutableCopy];
            tmpObject.parentTypeArr = bindingParentInfos;
            dispatch_async(dispatch_get_main_queue(), ^{
                [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
                [tmpObject.listTableView reloadData];
            });
        }
    }];

    // Do any additional setup after loading the view.
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        if (_isEditInfo) {
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
            __weak typeof(self)tmpObject = self;
            [[TXChatClient sharedInstance] updateBindInfo:_txUser.userId parentType:(TXPBParentType)_selected onCompleted:^(NSError *error) {
                [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
                if (error) {
//                    [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
                    [tmpObject showFailedHudWithError:error];
                }else{
                    [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
                    InfoViewController *infoVC = (InfoViewController *)_parentVC;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [infoVC reloadData];
                        [tmpObject.navigationController popViewControllerAnimated:YES];
                    });

                }
            }];
        }else{
            IdentityViewController *idenVC = (IdentityViewController *)_parentVC;
            [idenVC updateParentType:_selected];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(14, 0, tableView.width_ - 28, 45)];
        titleLb.font = kFontMiddle;
        titleLb.tag = kCellContentViewBaseTag;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UIImageView *maskImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_mask_1"]];
        maskImgView.frame = CGRectMake(tableView.width_ - 14 - 22, 23/2, 22, 22);
        maskImgView.tag = kCellContentViewBaseTag + 1;
        [cell.contentView addSubview:maskImgView];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(14, 45 - kLineHeight, self.view.width_ - 28, kLineHeight)];
        lineView.tag = kCellContentViewBaseTag + 2;
        [cell.contentView addSubview:lineView];
    }
    
    NSNumber *type = _listArr[indexPath.row];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"parentType == %d",type.integerValue];
    NSArray *arr = [_parentTypeArr filteredArrayUsingPredicate:pre];
    
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    UIImageView *maskImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
    UIView *lineView = [cell.contentView viewWithTag:kCellContentViewBaseTag + 2];
    
    titleLb.textColor = arr.count?kColorLightGray:kColorBlack;
    
//    if (arr.count && _isEditInfo) {
//        TXPBBindingParentInfo *info = arr[0];
//        if (info.user.userId == _txUser.userId) {
//            titleLb.textColor = kColorBlack;
//        }
//    }
    
    titleLb.text = [NSString getParentTypeStr:(TXPBParentType)type.integerValue];
    if (_selected == -1 && arr.count) {
        [arr enumerateObjectsUsingBlock:^(TXPBBindingParentInfo *info, NSUInteger idx, BOOL *stop) {
            if (info.user.userId == _txUser.userId) {
                _selected = info.parentType;
            }
        }];
    }
    
    maskImgView.image = _selected == type.integerValue?[UIImage imageNamed:@"btn_mask"]:[UIImage imageNamed:@"btn_mask_1"];

    if (arr.count) {
        maskImgView.image = [UIImage imageNamed:@"my_identity"];
    }
    
    
    if (indexPath.row != _listArr.count - 1) {
        lineView.hidden = NO;
    }else{
        lineView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *type = _listArr[indexPath.row];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"parentType == %d",type.integerValue];
    NSArray *arr = [_parentTypeArr filteredArrayUsingPredicate:pre];
    if (arr.count) {
        return;
    }
    _selected = type.integerValue;
    [_listTableView reloadData];
}



@end
