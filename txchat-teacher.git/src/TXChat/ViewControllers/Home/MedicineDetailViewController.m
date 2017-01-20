//
//  MedicineDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MedicineDetailViewController.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "TXPhotoBrowserViewController.h"
#import "MailResponseTableViewCell.h"
#import "UILabel+ContentSize.h"
#import <TXChatClient.h>
#import <MJRefresh.h>
#import "TXMessageInputView.h"
#import "NSString+Photo.h"
#import <TCCopyableLabel.h>

//图片tag的基数
#define KIMAGETAGBASE (0x1000)

//cell的高度
#define KCELLHIGHT 60
@interface MedicineDetailViewController ()<UITableViewDataSource,UITableViewDelegate,XHMessageInputViewDelegate, UIScrollViewDelegate>
{
    NSArray *_testPhotos;
    UIScrollView *_scrollView;
    UITableView *_tableView;
    UIView *_contentView;//滚动条内的view;
    TXFeedMedicineTask *_currentMedicine;
    NSMutableArray *_feedResponse;//喂药反馈
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    UIActivityIndicatorView *_indicator;//加载提示
}
@property (nonatomic, strong) TXMessageInputView *msgInputView;
@end

@implementation MedicineDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _feedResponse = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}
//根据 medicine初始化详情
-(id)initWithMedicine:(TXFeedMedicineTask *)medicine
{
    self = [super init];
    if(self)
    {
        _currentMedicine = medicine;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = _currentMedicine.parentUsername;
    self.umengEventText = @"喂药详情";
    [self createCustomNavBar];
    [self setupViews];
    [self setupChatToolBarView];
    [self setupRefresh];
    [self loadFeedResponse];
    //未读需要标记为已读
    if(!_currentMedicine.isRead)
    {
        [[TXChatClient sharedInstance] markFeedMedicineTaskAsRead:_currentMedicine.feedMedicineTaskId onCompleted:^(NSError *error) {
            DDLogDebug(@"error:%@", error);
            if(!error)
            {
                _currentMedicine.isRead = YES;
                NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
                if(unreadCountDic)
                {
                    NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_MEDICINE];
                    if([countValue integerValue] > 0)
                    {
                        [[TXChatClient sharedInstance] setCountersDictionaryValue:[countValue intValue]  - 1 forKey:TX_COUNT_MEDICINE];
                    }
                }
            }
        }];
    }
}

-(void)setupViews
{
    
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    
    UIView *superview = self.view;
    UIView *HeaderViewBackground = [UIView new];
    [HeaderViewBackground setBackgroundColor:kColorWhite];
    [contentView addSubview:HeaderViewBackground];
    
    UILabel *timeTitle = [UILabel new];
    [timeTitle setFont:kFontTitle];
    [timeTitle setText:@"喂药日期 :"];
    [timeTitle setTextColor:KColorTitleTxt];
    [HeaderViewBackground addSubview:timeTitle];
    [timeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HeaderViewBackground).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(HeaderViewBackground).with.offset(9.0f);
        make.size.mas_equalTo(CGSizeMake(90, 21));
    }];
    
    UILabel *timeContent = [UILabel new];
    [timeContent setFont:kFontTitle];
    [timeContent setText:[NSDate timeForMeidicineStyle:[NSString stringWithFormat:@"%@", @(_currentMedicine.beginDate/1000)]]];
    [timeContent setTextColor:KColorTitleTxt];
    [HeaderViewBackground addSubview:timeContent];
    [timeContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeTitle.mas_right).with.offset(4.0f);
        make.centerY.mas_equalTo(timeTitle);
        make.size.mas_equalTo(CGSizeMake(200, 21));
    }];
    UIView *line = [UIView new];
    [line setBackgroundColor:kColorLine];
    [HeaderViewBackground addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HeaderViewBackground).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(HeaderViewBackground).with.offset(-kEdgeInsetsLeft);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(HeaderViewBackground).with.offset(40.0f);
    }];
    
    TCCopyableLabel *content = [TCCopyableLabel new];
    [content setBackgroundColor:[UIColor clearColor]];
    [content setFont:kFontTitle];
    [content setTextColor:KColorTitleTxt];
    content.numberOfLines = 0;
    content.lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_currentMedicine.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 0;
    style.lineSpacing = 7;//行距
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    [content setAttributedText:text];
    content.preferredMaxLayoutWidth = CGRectGetWidth(self.view.frame) - kEdgeInsetsLeft * 2;
    [HeaderViewBackground addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HeaderViewBackground).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(HeaderViewBackground).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(line).with.offset(kEdgeInsetsLeft);
    }];
    //图片
    UIImageView *lastView = nil;
    NSInteger rowNumbers = 3;
    CGFloat photoHight = 86.0f;
    CGFloat padding1 = 8;
//    CGFloat padding2 = padding1;
    CGFloat margin = 12.0f;
    if((kScreenWidth- 2*(margin)- (rowNumbers -1)*padding1)  / photoHight >= 4.0)
    {
        rowNumbers = 4;
    }
    photoHight = (kScreenWidth - 2*(margin) - (rowNumbers -1)*padding1)/rowNumbers;
    for(NSInteger index = 0; index < [_currentMedicine.attaches count]; index++)
    {
        UIImageView *photoImage  = [UIImageView new];
        photoImage.backgroundColor = kColorCircleBg;
        NSString *imageUrl = [_currentMedicine.attaches objectAtIndex:index];
        photoImage.contentMode = UIViewContentModeScaleAspectFill;
        photoImage.clipsToBounds = YES;
         __weak typeof(photoImage) weakPhotoImage = photoImage;
        [photoImage TX_setImageWithURL:[NSURL URLWithString:[imageUrl getFormatPhotoUrl:photoHight hight:photoHight]] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            if(error)
            {
                [weakPhotoImage setImage:[UIImage imageNamed:@"tp_148x148"] ];
            }
        } ];
        photoImage.tag = KIMAGETAGBASE +index;
        [HeaderViewBackground addSubview:photoImage];
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
                
                make.top.mas_equalTo(content.mas_bottom).with.offset(padding1);
                make.left.mas_equalTo(HeaderViewBackground.mas_left).with.offset(margin);
                make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %rowNumbers == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(HeaderViewBackground.mas_left).with.offset(margin);
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
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
    
    [HeaderViewBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_scrollView);
        make.width.mas_equalTo(CGRectGetWidth(superview.frame));
        make.top.mas_equalTo(_scrollView).with.offset(0);
        if(lastView == nil)
        {
            make.bottom.mas_equalTo(content.mas_bottom).with.offset(padding1);
        }
        else
        {
            make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
        }
    }];
    
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
//    _tableView.rowHeight = KCELLHIGHT;
//    _tableView.scrollEnabled = NO;
    [contentView addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(HeaderViewBackground.mas_bottom).with.offset(5.0f);
        make.left.mas_equalTo(_scrollView);
        make.width.mas_equalTo(CGRectGetWidth(superview.frame));
        make.height.mas_equalTo(KCELLHIGHT*[_feedResponse count]);
    }];
    
    CGFloat padding3 = 20.0f;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [(UIActivityIndicatorView *)indicator startAnimating];
    _indicator = indicator;
    [indicator setColor:kColorBlack];
    [contentView addSubview:indicator];
    [indicator startAnimating];
    [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(contentView);
        make.top.mas_equalTo(HeaderViewBackground.mas_bottom).with.offset(padding3);
    }];
    
    _noDataLabel = [UILabel new];
    [_noDataLabel setFont:kFontMiddle];
    [_noDataLabel setTextColor:kColorLightGray];
    [_noDataLabel setText:@""];
    [_noDataLabel setBackgroundColor:[UIColor clearColor]];
    [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
    [contentView addSubview:_noDataLabel];
    [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_tableView);
        make.top.mas_equalTo(HeaderViewBackground.mas_bottom).with.offset(padding3);
        make.size.mas_equalTo(CGSizeMake(300, 31));
    }];
    
    [self setIndicatorStatus:NO];
    [self setNoDataLabelStatus:NO];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_bottom);

    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
    // 设置关联的scrollView
    self.msgInputView.associatedScrollView = _scrollView;
}
-(void)setIndicatorStatus:(BOOL)isShow
{
    [_indicator setHidden:!isShow];
    if(isShow)
    {
        [_indicator startAnimating];
    }
    else
    {
        [_indicator stopAnimating];
    }
}

-(void)setNoDataLabelStatus:(BOOL)isShow
{
    [_noDataLabel setHidden:!isShow];
}


-(void)loadFeedResponse
{
    DDLogDebug(@"fetchCommentsByTargetId");
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self setIndicatorStatus:YES];
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMedicine.feedMedicineTaskId targetType:TXPBTargetTypeFeedMedicinTask maxCommentId:LLONG_MAX onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        [self setIndicatorStatus:NO];
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            @synchronized(_feedResponse)
            {
                [_feedResponse removeAllObjects];
                [_feedResponse addObjectsFromArray:comments];
            }
            [weakSelf updateTableViewConstraints];
            [_tableView.footer setHidden:!hasMore];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        [self setNoDataLabelStatus:[_feedResponse count] > 0?NO:YES];        
    }];
}

-(void)updateTableViewConstraints
{
    
    CGFloat totalHight = 0;
    
    for (NSUInteger i = 0; i < [_feedResponse count]; i++ ) {
        totalHight += [self getHightFroRow:i];
    }
    
    
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(totalHight);
    }];
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_bottom);
    }];
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view layoutIfNeeded];
//    }];
}


-(CGFloat)getHightFroRow:(NSUInteger)index
{
    if(index >= [_feedResponse count])
    {
        return KCELLHIGHT;
    }
    
    CGFloat hight = KCELLHIGHT;
    TXComment *feedResponse = [_feedResponse objectAtIndex:index];
    CGFloat labelWidth = kScreenWidth-(60.0f+kEdgeInsetsLeft);
    CGFloat labelHight = [UILabel heightForLabelWithText:feedResponse.content maxWidth:labelWidth font:kFontSubTitle];
    hight += labelHight - 21.0f;
    return hight;
}




- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
    }
}

-(void)FromViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    NSInteger index = recognizer.view.tag - KIMAGETAGBASE;
    DLog(@"tag:%ld", (long)index);
    
    NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:2];
    for(NSString *photoIndexUrl in _currentMedicine.attaches)
    {
        [imageUrls addObject:[NSURL URLWithString:[photoIndexUrl getFormatPhotoUrl]]];
    }
    
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:imageUrls currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//创建聊天工具栏视图
- (void)setupChatToolBarView
{
    // 设置Message TableView 的bottom edg
    [self setTableViewInsetsWithBottomValue:kChatToolBarHeight];
    
    _msgInputView = [[TXMessageInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - kChatToolBarHeight, CGRectGetWidth(self.view.frame), kChatToolBarHeight)];
    _msgInputView.delegate = self;
    _msgInputView.associatedScrollView = _scrollView;
    _msgInputView.contentViewController = self;
    [_msgInputView setupView];
    [self.view addSubview:_msgInputView];
    [self.view bringSubviewToFront:_msgInputView];
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
    return [_feedResponse count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MailResponseTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    MailResponseTableViewCell *medicineCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (medicineCell == nil) {
        medicineCell = [[[NSBundle mainBundle] loadNibNamed:@"MailResponseTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXComment *feedResponse = [_feedResponse objectAtIndex:indexPath.row];
    [medicineCell.headerImageview TX_setImageWithURL:[NSURL URLWithString:[feedResponse.userAvatarUrl getFormatPhotoUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    [medicineCell.contentLabel setText:feedResponse.content];
    [medicineCell.fromLabel setText:feedResponse.userNickname];
    [medicineCell.timeLabel setText:[NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(feedResponse.createdOn/1000)]]];
    if(indexPath.row == [_feedResponse count] -1)
    {
        [medicineCell.seperatorLine setHidden:YES];
    }
    medicineCell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell = medicineCell;
    return cell;
}

#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getHightFroRow:indexPath.row];
}


//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    //    [self setTitle:MJRefreshAutoFooterIdleText forState:MJRefreshStateIdle];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    
}



-(void) updateFeedResponse
{
    DDLogDebug(@"fetchCommentsByTargetId");
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMedicine.feedMedicineTaskId targetType:TXPBTargetTypeFeedMedicinTask maxCommentId:LLONG_MAX onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            if([comments count] > 0)
            {
                [_feedResponse removeAllObjects];
                [_feedResponse addObjectsFromArray:comments];
                [weakSelf updateTableViewConstraints];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    [_scrollView scrollRectToVisible:_tableView.frame animated:YES];
                });
            }
        }
        [self setNoDataLabelStatus:[_feedResponse count] > 0?NO:YES];
    }];
}

-(void)senMedicineResopnseComment:(NSString *)commentText
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] sendComment:commentText commentType:TXPBCommentTypeReply toUserId:0 targetId:_currentMedicine.feedMedicineTaskId targetType:TXPBTargetTypeFeedMedicinTask onCompleted:^(NSError *error, int64_t commentId) {
        DDLogDebug(@"error:%@, commentId:%lld", error, commentId);
        if(!error)
        {
            
            [MobClick event:@"mail_medicine_feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"喂药评论", nil] counter:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateFeedResponse];
            });
        }
        else
        {
            [self showFailedHudWithError:error];
            [MobClick event:@"mail_medicine_feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"喂药评论", nil] counter:1];
        }
    }];
}

#pragma mark - TXMessageEmotionViewDelegate methods
//发送表情
- (void)sendEmotionText:(NSString *)text
{
    if (text.length > 0) {
        //        [self sendTextMessage:text];
        [self senMedicineResopnseComment:text];
        //清空已发送文本
        self.msgInputView.inputTextView.text = @"";
    }
    
}
//发送文字
- (void)didSendTextAction:(NSString *)text {
    //    if ([self.delegate respondsToSelector:@selector(didSendText:fromSender:onDate:)]) {
    //        [self.delegate didSendText:text fromSender:self.messageSender onDate:[NSDate date]];
    //    }
    //判断是否是空消息
    NSString *trimString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    //    headerData = [headerData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //    headerData = [headerData stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([trimString length] == 0) {
        //Alert提醒不能输入空白消息
        [self showFailedHudWithTitle:@"不能发送空白消息"];
        //        [self showAlertViewWithMessage:@"不能发送空白消息" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
    }else{
        [self senMedicineResopnseComment:text];
        //清空已发送文本
        self.msgInputView.inputTextView.text = @"";
        
    }
}

//底部insets改变
- (void)onBottomInsetsChanged:(CGFloat)bottom
               isShowKeyboard:(BOOL)isShow
{
    [self setTableViewInsetsWithBottomValue:bottom];
    if (isShow)
        [self scrollToBottomAnimated:NO];
}

#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    _scrollView.contentInset = insets;
    _scrollView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.bottom = bottom;
    return insets;
}
- (void)scrollToBottomAnimated:(BOOL)animated {
    //    NSInteger rows = [self.dataSource numberOfMessages];
    //
    //    if (rows > 0) {
    //        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
    //                                     atScrollPosition:UITableViewScrollPositionBottom
    //                                             animated:animated];
    //    }
    //TODO:
    
    [_scrollView scrollRectToVisible:_tableView.frame animated:YES];
}
#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.msgInputView associatedScrollViewWillBeginDragging];
}



#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchNewFeedResponseRereshing];
    });
}
- (void)footerRereshing{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf LoadLastPages];
    });
}


- (void)LoadLastPages
{
    int64_t beginFeedResponseId = 0;
    if(_feedResponse != nil && [_feedResponse count] > 0)
    {
        TXComment *beginFeedResponse = _feedResponse.lastObject;
        beginFeedResponseId = beginFeedResponse.id;
    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMedicine.feedMedicineTaskId targetType:TXPBTargetTypeFeedMedicinTask maxCommentId:beginFeedResponseId onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
            [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if(error)
            {
                DDLogDebug(@"error:%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.footer endRefreshing];
                });
            }
            else
            {
                [weakSelf updateFeedResponseAfterFooterReresh:comments];
                [_tableView.footer setHidden:!hasMore];
            }
            [self setNoDataLabelStatus:[_feedResponse count] > 0?NO:YES];
    }];
}



-(void)updateFeedResponseAfterFooterReresh:(NSArray *)medicines
{
    @synchronized(_feedResponse)
    {
        if(medicines != nil && [medicines count] > 0)
        {
            [_feedResponse addObjectsFromArray:medicines];
        }
    }
    [self updateTableViewConstraints];
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
    
}


- (void)fetchNewFeedResponseRereshing{
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMedicine.feedMedicineTaskId targetType:TXPBTargetTypeFeedMedicinTask maxCommentId:LLONG_MAX onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore)  {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
        }
        else
        {
            [weakSelf updateFeedResponseAfterHeaderRefresh:comments];
            [_tableView.footer setHidden:!hasMore];
        }
        [self setNoDataLabelStatus:[_feedResponse count] > 0?NO:YES];
    }];
}

- (void)updateFeedResponseAfterHeaderRefresh:(NSArray *)medicines
{
    @synchronized(_feedResponse)
    {
        if(medicines != nil && [medicines count] > 0)
        {
//            [_feedResponse removeAllObjects];
//            [_feedResponse addObjectsFromArray:medicines];
            _feedResponse = [NSMutableArray arrayWithArray:medicines];
        }
    }
    [self updateTableViewConstraints];
    [_tableView.header endRefreshing];
    [_tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView scrollsToTop];
    });
}



@end
