//
//  HelpViewController.m
//  TXChat
//
//  Created by lyt on 15-6-26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "HelpViewController.h"
#import <TXUser.h>
#import <TXChatClient.h>
#import <ZipArchive.h>
#import "AppDelegate.h"
#import <TXChatClient.h>
#import "TXEaseMobHelper.h"
#import "TXParentChatViewController.h"
#import "TXReportManager.h"
#define kCellContentViewBaseTag             213131

typedef enum : NSUInteger {
    HelpListType_feedbackOnline = 0,             //在线反馈
    HelpListType_uploadFileLogs,                  //诊断
} HelpListType;
@interface HelpViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_listTabelView;
    NSArray *_listArr;
}
@property(nonatomic, strong)UIViewController *a;

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"帮助与反馈";
    [self createCustomNavBar];
    
    _listArr = @[
                 @[@{@"title":@"在线反馈",@"type":@(HelpListType_feedbackOnline)}], @[@{@"title":@"诊断",@"type":@(HelpListType_uploadFileLogs)}],
                 ];
    
    _listTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_) style:UITableViewStylePlain];
    _listTabelView.backgroundColor = kColorBackground;
    _listTabelView.delegate = self;
    _listTabelView.dataSource = self;
    _listTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTabelView];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
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



#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = _listArr[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, 5)];
    view.backgroundColor = kColorBackground;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 5.f;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *arr = _listArr[indexPath.section];
//    NSNumber *type = arr[indexPath.row][@"type"];
   
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    NSArray *arr = _listArr[indexPath.section];
    NSNumber *type = arr[indexPath.row][@"type"];
    
    switch (type.intValue) {
        case HelpListType_feedbackOnline://在线反馈
        {
//            [self showMeiQiaView];
//            FeedBackViewController *feedback = [[FeedBackViewController alloc] init];
//            [self.navigationController pushViewController:feedback animated:YES];
            TXParentChatViewController *chatVc = [[TXParentChatViewController alloc] initWithChatter:KTXCustomerChatter isGroup:NO];
            chatVc.isNormalBack = YES;
            [self.navigationController pushViewController:chatVc animated:YES];
        }
            break;
        case HelpListType_uploadFileLogs://上传日志
        {
            [[TXReportManager shareInstance] updateLoggs:self complete:nil];

        }
            break;
        default:
            break;
    }
}

@end
