//
//  SenderNotifyDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SenderNoticeDetailViewController.h"
#import "NotifyRcverTableViewCell.h"
#import "NoticeReadDetailViewController.h"
#import <TXChatClient.h>
#define KSECTIONHEIGHT1 10.0f
#define KCELLHIGHT 44.0f
@interface SenderNoticeDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView *_scrollView;
    NSArray *_photoList;//附带 图片列表
    UILabel *_timerLabel;
    UITableView *_tableView;
    NSArray *_groupList;
}

@end

@implementation SenderNoticeDetailViewController

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
    self.titleStr = @"发件详情";
    [self createCustomNavBar];
    [self.btnRight setTitle:@"刷新" forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self createPhotoList];
    [self createGroupList];
    _scrollView= [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.frame.size.width, self.view.frame.size.height - self.customNavigationView.maxY)];
    //    _scrollView = [UIScrollView new];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:_scrollView];
    
    WEAKSELF
    UIView *superView1 = self.view;
    __weak UIView *superview = _scrollView;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView1).with.offset(weakSelf.customNavigationView.maxY);
        make.left.mas_equalTo(superView1);
        make.right.mas_equalTo(superView1.mas_right);
        make.bottom.mas_equalTo(superView1);
        
    }];

    //文字
    UILabel *notifyTextBodyLabel = [[UILabel alloc] init];
    notifyTextBodyLabel.text = @"国务院常务会议再次要求要结合医疗体制改革，并提出五大举措来进一步推进社会办医，说明当下社会办医仍面临着不小的阻力需要破解。此前就有媒体报道称，社会资本举办发展医疗机构普遍面临准入门槛高、经营压力大、发展空间小、技术人才缺乏、监管机制不健全、社会氛围不佳等困难和问题。纵观这次常务会议提出的几大举措，都可谓对此的对症下药。";
    notifyTextBodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    notifyTextBodyLabel.numberOfLines = 0;
    notifyTextBodyLabel.textColor = [UIColor lightGrayColor];
    //    [notifyTextBodyLabel setBackgroundColor:[UIColor redColor]];
    [_scrollView addSubview:notifyTextBodyLabel];
    notifyTextBodyLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.view.frame) - kEdgeInsetsLeft * 2;
    CGFloat padding = 10.0f;
    [notifyTextBodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(padding);
        make.left.mas_equalTo(superview).with.offset(padding);
        make.width.mas_equalTo(CGRectGetWidth(superView1.frame) - 2*padding);
    }];
    //图片
    UIImageView *lastView = nil;
    CGFloat padding1 = 10.0f;
    CGFloat photoHight = 60.0f;
    for(NSInteger index = 0; index < [_photoList count]; index++)
    {
        UIImageView *photoImage  = [UIImageView new];
        [photoImage setImage:[UIImage imageNamed:[_photoList objectAtIndex:index]]];
        [photoImage setBackgroundColor:[UIColor lightGrayColor]];
        [_scrollView addSubview:photoImage];
        //第一个
        if(lastView == nil)
        {
            [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.mas_equalTo(notifyTextBodyLabel.mas_bottom).with.offset(padding1);
                make.left.mas_equalTo(superview.mas_left).with.offset(padding1);
                make.size.mas_equalTo(CGSizeMake((superview.frame.size.width-5*padding1)/3.0f, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %3 == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(superview.mas_left).with.offset(padding1);
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
                    make.size.mas_equalTo(CGSizeMake((superview.frame.size.width-5*padding1)/3.0f, photoHight));
                    
                }];
            }
            else//左排第2，3
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(lastView.mas_right).with.offset(padding1);
                    make.top.mas_equalTo(lastView.mas_top).with.offset(0);
                    make.size.mas_equalTo(CGSizeMake((superview.frame.size.width-5*padding1)/3.0f, photoHight));
                    
                }];
            }
            
        }
        lastView = photoImage;
    }
    
    
    UILabel *timeLabel = [UILabel new];
    _timerLabel = timeLabel;
    [timeLabel setText:@"今天 09：45"];
    [timeLabel setTextColor:[UIColor grayColor]];
    //    [timeLabel setBackgroundColor:[UIColor greenColor]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [_scrollView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if(lastView == nil)
        {
            make.top.mas_equalTo(notifyTextBodyLabel.mas_bottom).with.offset(padding1);
        }
        else
        {
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
        }
        make.left.mas_equalTo(_scrollView.mas_left).with.offset(padding1);
        make.size.mas_equalTo(CGSizeMake(280, 44));
    }];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_scrollView addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(timeLabel.mas_bottom).with.offset(0);
        make.left.mas_equalTo(_scrollView.mas_left);
        make.size.mas_equalTo(CGSizeMake(weakSelf.view.frame.size.width, KCELLHIGHT*[_groupList count] + KSECTIONHEIGHT1));
    }];
    
    
}
-(void)createPhotoList
{
    _photoList = @[@"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected"];
}

-(void)createGroupList
{
    _groupList = @[@"乐学堂_14", @"乐学堂_13",@"乐学堂_12"];
}
-(void)viewDidLayoutSubviews
{
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, _tableView.frame.origin.y + _tableView.frame.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotifyRcverTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    NotifyRcverTableViewCell *notifyRcverCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (notifyRcverCell == nil) {
        notifyRcverCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifyRcverTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    [notifyRcverCell.groupNamelLabel setText:[_groupList objectAtIndex:indexPath.row]];
    if(indexPath.row == [_groupList count] -1)
    {
        [notifyRcverCell.seperatorLine setHidden:YES];
    }
    
    cell = notifyRcverCell;
    return cell;
}

#pragma mark-  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    CGFloat height = KSECTIONHEIGHT1;
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
    headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
    headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showReadDetail];
}

//NotifyReadDetailViewController.h
-(void)showReadDetail
{
    NoticeReadDetailViewController *readDetail = [[NoticeReadDetailViewController alloc] init];
    [self.navigationController pushViewController:readDetail animated:YES];
}

@end
