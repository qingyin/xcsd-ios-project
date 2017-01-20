//
//  NotifyDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoticeDetailViewController.h"
#import "NotifyFromView.h"
#import "ParentsDetailViewController.h"
#import <Masonry.h>
#import <TXChatClient.h>
#import <TXNotice.h>
#import "TXPhotoBrowserViewController.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "UILabel+ContentSize.h"
#import "NSString+Photo.h"
#import <TCCopyableLabel.h>
#import <UIImageView+TXSDImage.h>

//图片tag的基数
#define KIMAGETAGBASE (0x1000)
@interface NoticeDetailViewController ()<UIGestureRecognizerDelegate, NotifyFromViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_contentView;
    UILabel *_timerLabel; //时间
    NotifyFromView *_fromUserView;//发件人 信息
    TXNotice *_currentNotice;
    TXUser *_fromUser;
    
}
@end

@implementation NoticeDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithNotice:(TXNotice *)notice
{
    self = [super init];
    if(self)
    {
        NSError *error = nil;
        _currentNotice = notice;
        if(error)
        {
            DLog(@"error:%@", error);
        }
        error = nil;
        _fromUser = [[TXChatClient sharedInstance] getUserByUserId:_currentNotice.fromUserId error:&error];
        if(error)
        {
            DLog(@"error:%@", error);
        }
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"通知";
    [self createCustomNavBar];
    [self setupViews];
    if(!_currentNotice.isRead)
    {
        [[TXChatClient sharedInstance] markNoticeHasRead:_currentNotice.noticeId onCompleted:^(NSError *error) {
            DLog(@"error:%@", error);
            if(!error)
            {
                _currentNotice.isRead = YES;
                NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
                if(unreadCountDic)
                {
                    NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_NOTICE];
                    if([countValue integerValue] > 0)
                    {
                        [[TXChatClient sharedInstance] setCountersDictionaryValue:[countValue intValue]  - 1 forKey:TX_COUNT_NOTICE];
                    }
                }
                
                [[TXChatClient sharedInstance].dataReportManager reportEventBid:XCSDPBEventTypeReadNotice bid:[NSString stringWithFormat:@"%lld", _currentNotice.noticeId]];
            }
        }];
    }
    
    if(_fromUser == nil)
    {
        __weak __typeof(&*self) weakSelf=self;  //by sck
        [[TXChatClient sharedInstance] fetchUserByUserId:_currentNotice.fromUserId onCompleted:^(NSError *error, TXUser *txUser) {
            if(error)
            {
                DDLogDebug(@"error:%@",error);
            }
            else
            {
                _fromUser = txUser;
                [weakSelf updateFromUser];
            }
        }];
    }
}


-(void)setupViews
{
    
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
//    _scrollView.delegate = self;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorWhite];
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    //发送人
    NotifyFromView *fromView =  [[[NSBundle mainBundle] loadNibNamed:@"NotifyFromView" owner:self options:nil] objectAtIndex:0];
    [fromView.fromLabel setText:_fromUser.nickname];
    [fromView setBackgroundColor:[UIColor clearColor]];
    [fromView setDelegate:self];
    _fromUserView = fromView;
    [_contentView addSubview:fromView];
    [fromView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_contentView).with.offset(0);
        make.left.mas_equalTo(_contentView);
        make.right.mas_equalTo(_contentView);
        make.height.mas_equalTo(44);
    }];
    //文字
    TCCopyableLabel *notifyTextBodyLabel = [[TCCopyableLabel alloc] init];
    notifyTextBodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    notifyTextBodyLabel.numberOfLines = 0;
    notifyTextBodyLabel.textColor = KColorTitleTxt;
    [notifyTextBodyLabel setBackgroundColor:[UIColor clearColor]];
    notifyTextBodyLabel.font = kFontTitle;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_currentNotice.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 0;
    style.lineSpacing = 7;//行距
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    [notifyTextBodyLabel setAttributedText:text];
    [_contentView addSubview:notifyTextBodyLabel];
    CGFloat padding = kEdgeInsetsLeft;
    
    [notifyTextBodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(fromView.mas_bottom).with.offset(kEdgeInsetsLeft);
        make.left.mas_equalTo(_contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(_contentView).with.offset(-kEdgeInsetsLeft);
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
        photoImage.backgroundColor = kColorCircleBg;
        NSString *imageUrl = [_currentNotice.attaches objectAtIndex:index];
        __weak typeof(photoImage) weakPhotoImage = photoImage;
        [photoImage TX_setImageWithURL:[NSURL URLWithString:[imageUrl getFormatPhotoUrl:photoHight hight:photoHight]] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            if(error)
            {
                [weakPhotoImage setImage:[UIImage imageNamed:@"tp_148x148"] ];
            }
        }];
        photoImage.tag = KIMAGETAGBASE +index;
        photoImage.contentMode = UIViewContentModeScaleAspectFill;
        photoImage.clipsToBounds = YES;
        [_contentView addSubview:photoImage];
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
                
                make.top.mas_equalTo(notifyTextBodyLabel.mas_bottom).with.offset(padding1);
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
    [_contentView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_contentView.mas_right).with.offset(- kEdgeInsetsLeft);
        if(lastView == nil)
        {
            make.top.mas_equalTo(notifyTextBodyLabel.mas_bottom).with.offset(padding);
        }
        else
        {
            make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding);
        }
        
        make.size.mas_equalTo(CGSizeMake(117, 20));
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(timeLabel.mas_bottom).with.offset(kEdgeInsetsLeft);
        
    }];
}
//获取联系人后更新信息
-(void)updateFromUser
{
    if(_fromUser != nil)
    {
        [_fromUserView.fromLabel setText:_fromUser.nickname];
    }
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
        [self.navigationController popViewControllerAnimated:YES];
        
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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    
    return YES;
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

-(void)FromViewTapEvent1:(UITapGestureRecognizer*)recognizer
{
    
//    NSInteger section = recognizer.view.tag - KHEADERVIEWBASETAG;
//    DLog(@"section:%ld", (long)section);
    [self showFromDetailVC];
    
}

-(void)showFromDetailVC
{
    ParentsDetailViewController *FromDetailVc = [[ParentsDetailViewController alloc] initWithIdentity:_fromUser.userId];
    [self.navigationController pushViewController:FromDetailVc animated:YES];
    
}


-(void)FromViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    NSInteger index = recognizer.view.tag - KIMAGETAGBASE;
    DLog(@"tag:%ld", (long)index);
    
    NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:2];
    for(NSString *photoUrlIndex in _currentNotice.attaches)
    {
        if (photoUrlIndex && [photoUrlIndex length]) {
            [imageUrls addObject:[NSURL URLWithString:[photoUrlIndex getFormatPhotoUrl]]];
        }
    }
    
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:imageUrls currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}
#pragma mark - NotifyFromViewDelegate

-(void)UserTouchUpInView
{
    [self showFromDetailVC];
}



@end
