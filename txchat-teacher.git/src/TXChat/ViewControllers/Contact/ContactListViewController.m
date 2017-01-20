//
//  ContactListViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ContactListViewController.h"
#import "UIImageView+EMWebCache.h"
#import "TXParentChatViewController.h"
#import "ContactDetaiListViewController.h"

#define KCELLHIGHT 60.0f
#define kCellContentBaseTag             23123


@interface ContactListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_classList;
}

@property (nonatomic, strong) UITableView *listTableView;

@end

@implementation ContactListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createCustomNavBar];
    [self loadClassList];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    [_listTableView setDelegate:self];
    [_listTableView setDataSource:self];
    [_listTableView setShowsVerticalScrollIndicator:YES];
    [_listTableView setBackgroundColor:self.view.backgroundColor];
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] fetchDepartments:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [tmpObject loadClassList];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tmpObject.listTableView reloadData];
            });
        });
    }];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 *  加载班级列表列表
 */

-(void)loadClassList
{
    _classList = [[TXChatClient sharedInstance] getAllDepartments:nil];
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    return _classList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return KCELLHIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (KCELLHIGHT-40.0f)/2, 40, 40)];
        iconImgView.tag = kCellContentBaseTag;
        iconImgView.layer.cornerRadius = 8.0f/2.0f;
        iconImgView.layer.masksToBounds = YES;
        [cell.contentView addSubview:iconImgView];
        
//        UIImageView *iconBgView = [[UIImageView alloc] initWithFrame:iconImgView.frame];
//        iconBgView.image = [UIImage imageNamed:@"conversation_mask"];
//        [cell.contentView addSubview:iconBgView];
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + kEdgeInsetsLeft, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT)];
        titleLb.font = kFontTitle;
        titleLb.textColor = KColorTitleTxt;
        titleLb.tag = kCellContentBaseTag + 1;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
        lineView.frame = CGRectMake(10, KCELLHIGHT - kLineHeight, kScreenWidth - 20, kLineHeight);
        lineView.tag = kCellContentBaseTag + 2;
        [cell.contentView addSubview:lineView];
    }
    
    UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentBaseTag];
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 1];
    UIView *lineView = [cell.contentView viewWithTag:kCellContentBaseTag + 2];
    
    if (!indexPath.section) {
        titleLb.text = !indexPath.row?@"学校通讯录":@"家长通讯录";
        lineView.hidden = indexPath.row == 1?YES:NO;
        NSString *addressIcon = !indexPath.row?@"gardenAddressIcon":@"parentAddressIcon";
        iconImgView.image = [UIImage imageNamed:addressIcon];
    }else{
        TXDepartment *department = _classList[indexPath.row];
        titleLb.text = department.name;
        lineView.hidden = indexPath.row == _classList.count - 1?YES:NO;
        NSString *urlStr = [department.avatarUrl getFormatPhotoUrl:40.0f hight:40.0f];
        [iconImgView TX_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        }
    
    [cell.contentView setBackgroundColor:kColorWhite];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
////    return !section?10:0;
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, section?0:10)];
//    view.backgroundColor = kColorBackground;
//    return view;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    view.backgroundColor = kColorBackground;
    if(section)
    {
        UIView *beginLine = [[UIView alloc] init];
        beginLine.frame = CGRectMake(0, 0, kScreenWidth, kLineHeight);
        beginLine.backgroundColor = kColorLine;
        [view addSubview:beginLine];
    }
    
    UIView *endLine = [[UIView alloc] init];
    endLine.frame = CGRectMake(0, 10-kLineHeight, kScreenWidth, kLineHeight);
    endLine.backgroundColor = kColorLine;
    [view addSubview:endLine];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!indexPath.section) {
        ContactDetaiListViewController *avc = [[ContactDetaiListViewController alloc] init];
        avc.titleStr = !indexPath.row?@"学校通讯录":@"家长通讯录";
        [self.navigationController pushViewController:avc animated:YES];
        return;
    }
    TXDepartment *department = _classList[indexPath.row];
    TXParentChatViewController *chat = [[TXParentChatViewController alloc] initWithChatter:department.groupId isGroup:YES];
    chat.isNormalBack = YES;
    chat.titleStr = department.name;
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 10;//section的高度
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


@end
