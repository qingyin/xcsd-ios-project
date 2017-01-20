//
//  MailDetailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MailDetailViewController.h"
#import "NSDate+TuXing.h"
#import "MailResponseTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "UILabel+ContentSize.h"
#import "TXMessageInputView.h"
#import <TXChatClient.h>
#import <MJRefresh.h>
#import "ConvertToCommonEmoticonsHelper.h"
#import <TCCopyableLabel.h>

#define KVIEWMARGIN (5.0f)
//cell的高度
#define KCELLHIGHT 60

@interface MailDetailViewController ()<UITableViewDataSource,UITableViewDelegate,XHMessageInputViewDelegate,UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_contentView;//滚动条内的view;
    UITableView *_tableView;
    NSMutableArray *_mailResponse;//邮件反馈;
    TXGardenMail *_currentMail;
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    UIActivityIndicatorView *_indicator;//加载提示
}

@property (nonatomic, strong) TXMessageInputView *msgInputView;

@end

@implementation MailDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _mailResponse = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}
//用当前mail初始化
-(id)initWithMail:(TXGardenMail *)mail
{
    self = [super init];
    if(self)
    {
        _currentMail = mail;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"详情";
    [self createCustomNavBar];
//    [self createTestContent];
    [self setupViews];
    [self setupChatToolBarView];
    self.view.backgroundColor = kColorBackground;
    [self setupRefresh];
    [self loadFeedResponse];
    if(!_currentMail.isRead)
    {
        [[TXChatClient sharedInstance] markGardenMailAsRead:_currentMail.gardenMailId onCompleted:^(NSError *error) {
            DDLogDebug(@"error:%@",error);
            if(!error)
            {
                _currentMail.isRead = YES;
                NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
                if(unreadCountDic)
                {
                    NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_LEARN_GARDEN];
                    if([countValue integerValue] > 0)
                    {
                        [[TXChatClient sharedInstance] setCountersDictionaryValue:[countValue intValue]  - 1 forKey:TX_COUNT_LEARN_GARDEN];
                    }
                }        
            }
        }];
    }
}

-(void)setupViews
{

    CGFloat margin = KVIEWMARGIN;    
    UIScrollView *scrollView = UIScrollView.new;
    scrollView.delegate = self;
    _scrollView = scrollView;
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
    //反馈内容
    UIView *contentBackground = [UIView new];
    [contentBackground setBackgroundColor:kColorWhite];
    [_contentView addSubview:contentBackground];
    
    TCCopyableLabel *content = [TCCopyableLabel new];
    [content setFont:kFontMiddle];
    [content setTextColor:kColorGray];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_currentMail.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 0;
    style.lineSpacing = 7;//行距
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    [content setAttributedText:text];
    content.numberOfLines = 0;
    [contentBackground addSubview:content];
    content.preferredMaxLayoutWidth = CGRectGetWidth(self.view.frame)-kEdgeInsetsLeft * 2 ;
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentBackground).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(contentBackground).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(contentBackground).with.offset(kEdgeInsetsLeft);
    }];
    
    UILabel *timeLabel = [UILabel new];
    [timeLabel setText:[NSDate timeForNoticeStyle:[NSString stringWithFormat:@"%@", @(_currentMail.createdOn/1000)]]];
    [timeLabel setTextColor:kColorLightGray];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setFont:kFontSmall];
    [contentBackground addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(content.mas_bottom).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(content.mas_right).with.offset(-kEdgeInsetsLeft);
        make.size.mas_equalTo(CGSizeMake(117, 20));
    }];
    
    [contentBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView);
        make.right.mas_equalTo(contentView);
        make.top.mas_equalTo(contentView.mas_top);
        make.bottom.mas_equalTo(timeLabel.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];
    
    
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    _tableView.scrollEnabled = NO;
    [contentView addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentBackground.mas_bottom).with.offset(margin);
        make.left.mas_equalTo(contentView);
        make.right.mas_equalTo(contentView.mas_right);
        make.height.mas_equalTo(KCELLHIGHT*1);
    }];
    
    
    
    CGFloat padding1 = 20.0f;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [(UIActivityIndicatorView *)indicator startAnimating];
    _indicator = indicator;
    [indicator setColor:kColorBlack];
    [contentView addSubview:indicator];
    [indicator startAnimating];
    [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_contentView);
        make.top.mas_equalTo(contentBackground.mas_bottom).with.offset(padding1);
    }];
    
    _noDataLabel = [UILabel new];
    [_noDataLabel setFont:kFontMiddle];
    [_noDataLabel setTextColor:kColorLightGray];
    [_noDataLabel setText:@"园长还没有回复"];
    [_noDataLabel setBackgroundColor:[UIColor clearColor]];
    [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
    [contentView addSubview:_noDataLabel];
    [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_contentView);
        make.top.mas_equalTo(contentBackground.mas_bottom).with.offset(padding1);
        make.size.mas_equalTo(CGSizeMake(300, 31));
    }];
    
    [self setIndicatorStatus:NO];
    [self setNoDataLabelStatus:NO];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_tableView.mas_bottom);
    }];
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


-(void)updateTableViewConstraints
{
    
    CGFloat totalHight = 0;
    
    for (NSUInteger i = 0; i < [_mailResponse count]; i++ ) {
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
    if(index >= [_mailResponse count])
    {
        return KCELLHIGHT;
    }
    
    CGFloat hight = KCELLHIGHT;
    TXComment *feedResponse = [_mailResponse objectAtIndex:index];
    CGFloat labelWidth = kScreenWidth-(60.0f+kEdgeInsetsLeft);
    NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                convertToSystemEmoticons:feedResponse.content];
    CGFloat labelHight = [UILabel heightForLabelWithText:didReceiveText maxWidth:labelWidth font:kFontSubTitle];
    hight += labelHight - 21.0f;
    return hight;
}



-(void)loadFeedResponse
{
    DDLogDebug(@"fetchCommentsByTargetId");
    WEAKSELF
    [self setIndicatorStatus:YES];
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMail.gardenMailId targetType:TXPBTargetTypeGardenMail maxCommentId:LLONG_MAX onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        [self setIndicatorStatus:NO];
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            [_mailResponse addObjectsFromArray:comments];
            [weakSelf updateTableViewConstraints];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        [self setNoDataLabelStatus:[_mailResponse count] > 0?NO:YES];        
    }];
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


- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
    // 设置关联的scrollView
    self.msgInputView.associatedScrollView = _scrollView;

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
#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mailResponse count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MailResponseTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    MailResponseTableViewCell *mailCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (mailCell == nil) {
        mailCell = [[[NSBundle mainBundle] loadNibNamed:@"MailResponseTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXComment *feedResponse = [_mailResponse objectAtIndex:indexPath.row];
    [mailCell.headerImageview TX_setImageWithURL:[NSURL URLWithString:[feedResponse.userAvatarUrl getFormatPhotoUrl:40 hight:40]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    
    NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                convertToSystemEmoticons:feedResponse.content];
    [mailCell.contentLabel setText:didReceiveText];
    [mailCell.fromLabel setText:feedResponse.userNickname];
    [mailCell.timeLabel setText:[NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(feedResponse.createdOn/1000)]]];
    if(indexPath.row == [_mailResponse count] -1)
    {
        [mailCell.seperatorLine setHidden:YES];
    }
    mailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell = mailCell;
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


-(void) updateFeedResponse
{
    DDLogDebug(@"fetchCommentsByTargetId");
    WEAKSELF
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMail.gardenMailId targetType:TXPBTargetTypeGardenMail maxCommentId:LLONG_MAX onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            if([comments count] > 0)
            {
//                [_mailResponse removeAllObjects];
//                [_mailResponse addObjectsFromArray:comments];
                @synchronized(_mailResponse)
                {
                    _mailResponse = [NSMutableArray arrayWithArray:comments];
                }
                [weakSelf updateTableViewConstraints];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    [_scrollView scrollRectToVisible:_tableView.frame animated:YES];
                });
            }
        }
        [self setNoDataLabelStatus:[_mailResponse count] > 0?NO:YES];
    }];
}

-(void)sendMailResopnseComment:(NSString *)commentText
{
    WEAKSELF
    [[TXChatClient sharedInstance] sendComment:commentText commentType:TXPBCommentTypeReply toUserId:0 targetId:_currentMail.gardenMailId targetType:TXPBTargetTypeGardenMail onCompleted:^(NSError *error, int64_t commentId) {
        DDLogDebug(@"error:%@, commentId:%lld", error, commentId);
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateFeedResponse];
            });
            [MobClick event:@"mail_medicine_feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"园长信箱评论", nil] counter:1];
        }
        else
        {
            [self showFailedHudWithError:error];
            [MobClick event:@"mail_medicine_feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"园长信箱评论", nil] counter:1];
        }
    }];
}

#pragma mark - TXMessageEmotionViewDelegate methods
//发送表情
- (void)sendEmotionText:(NSString *)text
{
    if (text.length > 0) {
//        [self sendTextMessage:text];
        [self sendMailResopnseComment:text];
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
        [self sendMailResopnseComment:text];
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



//集成刷新控件
- (void)setupRefresh
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
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


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchNewFeedResponseRereshing];
    });
}
- (void)footerRereshing{
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf LoadLastPages];
    });
}


- (void)LoadLastPages
{
    int64_t beginMailResponseId = 0;
    if(_mailResponse != nil && [_mailResponse count] > 0)
    {
        TXComment *beginMailResponse = _mailResponse.lastObject;
        beginMailResponseId = beginMailResponse.id;
    }
    DDLogDebug(@"fetchCommentsByTargetId");
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    WEAKSELF
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMail.gardenMailId targetType:TXPBTargetTypeGardenMail maxCommentId:beginMailResponseId onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(error)
        {
            DLog(@"error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.footer endRefreshing];
            });
        }
        else
        {
            [weakSelf updateMailResponseAfterFooterReresh:comments];
            if(!hasMore)
            {
                [_tableView.footer setHidden:YES];
            }
        }
        [self setNoDataLabelStatus:[_mailResponse count] > 0?NO:YES];
    }];
}



-(void)updateMailResponseAfterFooterReresh:(NSArray *)medicines
{
    @synchronized(_mailResponse)
    {
        if(medicines != nil && [medicines count] > 0)
        {
            [_mailResponse addObjectsFromArray:medicines];
        }
    }
    [self updateTableViewConstraints];
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
    
}


- (void)fetchNewFeedResponseRereshing{
    DDLogDebug(@"fetchCommentsByTargetId");
    WEAKSELF
//        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_currentMail.gardenMailId targetType:TXPBTargetTypeGardenMail maxCommentId:LLONG_MAX onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore)  {
//        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(error)
        {
            DLog(@"error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
        }
        else
        {
            [weakSelf updateMailResponseAfterHeaderRefresh:comments];
            if(!hasMore)
            {
                [_tableView.footer setHidden:YES];
            }
        }
        [self setNoDataLabelStatus:[_mailResponse count] > 0?NO:YES];
    }];
}

- (void)updateMailResponseAfterHeaderRefresh:(NSArray *)medicines
{
    @synchronized(_mailResponse)
    {
        if(medicines != nil && [medicines count] > 0)
        {
//            [_mailResponse removeAllObjects];
//            [_mailResponse addObjectsFromArray:medicines];
             _mailResponse = [NSMutableArray arrayWithArray:medicines];
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
