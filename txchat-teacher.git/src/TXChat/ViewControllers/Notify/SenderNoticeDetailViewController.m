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
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "TXPhotoBrowserViewController.h"
#import "TXDepartment+Utils.h"
#import "NSString+Photo.h"
#import <TCCopyableLabel.h>

#define KSECTIONHEIGHT1 10.0f
#define KCELLHIGHT 60.0f
//图片tag的基数
#define KIMAGETAGBASE (0x1000)
@interface SenderNoticeDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_contentView;
    UILabel *_timerLabel;
    UITableView *_tableView;
    TXNotice *_currentNotice;
    NSMutableArray *_departmentList;
}

@end

@implementation SenderNoticeDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _departmentList = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

-(id)initWithNotice:(TXNotice *)currentNotice
{
    self = [super init];
    if(self)
    {
        _currentNotice = currentNotice;
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
    [self setupViews];
//    [self updateUnreadDepartments];
    self.view.backgroundColor = kColorBackground;
}


-(void)setupViews
{
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.userInteractionEnabled = YES;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    contentView.userInteractionEnabled = YES;
    contentView.clipsToBounds = YES;
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    
    UIView *txtBackView = [UIView new];
    txtBackView.backgroundColor = kColorWhite;
    [_contentView addSubview:txtBackView];
    
    //文字
    TCCopyableLabel *notifyTextBodyLabel = [[TCCopyableLabel alloc] init];
    notifyTextBodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    notifyTextBodyLabel.numberOfLines = 0;
    notifyTextBodyLabel.textColor = kColorGray;
    [notifyTextBodyLabel setFont:kFontMiddle];
    [notifyTextBodyLabel setBackgroundColor:kColorWhite];
    [txtBackView addSubview:notifyTextBodyLabel];
    notifyTextBodyLabel.text = _currentNotice.content;
//    CGSize notifyTextBodySize;
//    if(IOS7_OR_LATER)
//    {
//        notifyTextBodySize = [notifyTextBodyLabel.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:notifyTextBodyLabel.font} context:nil].size;
//    }
//    else
//    {
//        notifyTextBodySize = [notifyTextBodyLabel.text sizeWithFont:notifyTextBodyLabel.font constrainedToSize:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)  lineBreakMode:NSLineBreakByWordWrapping];
//    }
    CGFloat topPadding = 10.0f;
    [notifyTextBodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_contentView).with.offset(topPadding);
        make.left.mas_equalTo(_contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(_contentView).with.offset(-kEdgeInsetsLeft);
//        make.height.mas_equalTo(notifyTextBodySize.height);
    }];
    //图片
    UIImageView *lastView = nil;
    NSInteger rowNumbers = 3;
    CGFloat photoHight = 86.0f;
    CGFloat padding1 = 8;
    CGFloat padding2 = padding1;
    CGFloat margin = 12.0f;
    if((kScreenWidth- 2*(margin)- (rowNumbers -1)*padding1)  / photoHight >= 4.0)
    {
        rowNumbers = 4;
    }
    photoHight = (kScreenWidth - 2*(margin) - (rowNumbers -1)*padding1)/rowNumbers;
    for(NSInteger index = 0; index < [_currentNotice.attaches count]; index++)
    {
        UIImageView *photoImage  = [UIImageView new];
        NSString *imageUrl = [_currentNotice.attaches objectAtIndex:index];
        photoImage.contentMode = UIViewContentModeScaleAspectFill;
        photoImage.clipsToBounds = YES;
        [photoImage TX_setImageWithURL:[NSURL URLWithString:[imageUrl getFormatPhotoUrl:photoHight hight:photoHight]] placeholderImage:[UIImage imageNamed:@"noticeImageDefault"]];
        [photoImage setBackgroundColor:kColorCircleBg];
        photoImage.tag = KIMAGETAGBASE +index;
        [txtBackView addSubview:photoImage];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FromViewTapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = NO;
        photoImage.userInteractionEnabled = YES;
        [photoImage addGestureRecognizer:tap];
        //第一个
        if(lastView == nil)
        {
            [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.mas_equalTo(notifyTextBodyLabel.mas_bottom).with.offset(kEdgeInsetsLeft);
                make.left.mas_equalTo(_contentView.mas_left).with.offset(margin);
                make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %rowNumbers == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_contentView.mas_left).with.offset(margin);
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding2);
                    make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
                    
                }];
            }
            else//左排第2，3
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(lastView.mas_right).with.offset(padding1);
                    make.top.mas_equalTo(lastView.mas_top).with.offset(0);
                    make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
                    
                }];
            }
            
        }
        lastView = photoImage;
    }
    
    UILabel *timeLabel = [UILabel new];
    _timerLabel = timeLabel;
    [timeLabel setText:[NSDate timeForNoticeStyle:[NSString stringWithFormat:@"%@", @(_currentNotice.sentOn/1000)]]];
    [timeLabel setTextColor:kColorLightGray];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [_timerLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setFont:kFontSmall];
    [txtBackView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if(lastView == nil)
        {
            make.top.mas_equalTo(notifyTextBodyLabel.mas_bottom).with.offset(padding1);
        }
        else
        {
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
        }
        make.right.mas_equalTo(_contentView).with.offset(-kEdgeInsetsLeft);
        make.size.mas_equalTo(CGSizeMake(280, 44));
    }];
    
    [txtBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView);
        make.right.mas_equalTo(_contentView);
        make.top.mas_equalTo(_contentView);
        make.bottom.mas_equalTo(_timerLabel.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    _tableView.scrollEnabled = NO;
    [_contentView addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(txtBackView.mas_bottom).with.offset(5);
        make.left.mas_equalTo(_contentView.mas_left);
        make.size.mas_equalTo(CGSizeMake(weakSelf.view.frame.size.width,  KSECTIONHEIGHT1));
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_bottom);
    }];
}

-(void)updateUnreadDepartments
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] fetchNoticeDepartments:_currentNotice.noticeId onCompleted:^(NSError *error, NSArray *txpbNoticesDepartments) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            TXAsyncRunInMain(^{
                @synchronized(_departmentList)
                {
                    [_departmentList removeAllObjects];
                    [_departmentList addObjectsFromArray:txpbNoticesDepartments];
                }
                [_tableView reloadData];
                [weakSelf updateLocalViewConstraints];
            });
        }
    }];
}

-(void)updateLocalViewConstraints
{
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(KSECTIONHEIGHT1 + [_departmentList count]*KCELLHIGHT);
    }];
    
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_bottom);
    }];
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
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self updateUnreadDepartments];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self updateUnreadDepartments];
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
    return [_departmentList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotifyRcverTableViewCell";
//    DLog(@"section:%d, rows:%d", indexPath.section, indexPath.row);
    UITableViewCell *cell = nil;
    NotifyRcverTableViewCell *notifyRcverCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (notifyRcverCell == nil) {
        notifyRcverCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifyRcverTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    TXPBNoticeDepartment *noticeDepartment = [_departmentList objectAtIndex:indexPath.row];
    TXDepartment *department = [[TXChatClient sharedInstance] getDepartmentByDepartmentId:noticeDepartment.departmentId error:nil];
    [notifyRcverCell.groupNamelLabel setText:department.name];
    [notifyRcverCell.countLabel setText:[NSString stringWithFormat:@"%d", (int)(noticeDepartment.memberCount - noticeDepartment.readedCount)]];
    [notifyRcverCell.groupIcon TX_setImageWithURL:[NSURL URLWithString:[department getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"classDefaultIcon"]];
    if(indexPath.row == [_departmentList count] -1)
    {
        [notifyRcverCell.seperatorLine setHidden:YES];
    }
    
    cell = notifyRcverCell;
    return cell;
}

#pragma mark-  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
    return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
//    UIView *headerView = nil;
//    headerView = [[UIView alloc] init];
//    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
//    headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
//    return headerView;
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXPBNoticeDepartment *noticeDepartment = [_departmentList objectAtIndex:indexPath.row];
    [self showReadDetail:noticeDepartment.noticeId departmentId:noticeDepartment.departmentId];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//NotifyReadDetailViewController.h
-(void)showReadDetail:(int64_t)noticeId departmentId:(int64_t)departmentId
{
    NoticeReadDetailViewController *readDetail = [[NoticeReadDetailViewController alloc] initWithNoticeId:noticeId departmentId:departmentId];
    [self.navigationController pushViewController:readDetail animated:YES];
}

-(void)FromViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    NSInteger index = recognizer.view.tag - KIMAGETAGBASE;
    DLog(@"tag:%ld", (long)index);
    
    NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:2];
    for(NSString *photoIndexUrl in _currentNotice.attaches)
    {
        [imageUrls addObject:[NSURL URLWithString:[photoIndexUrl getFormatPhotoUrl]]];
    }
    
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:imageUrls currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}



@end
