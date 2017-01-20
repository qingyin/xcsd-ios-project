//
//  THGuideArticleDetailViewController.m
//  TXChatTeacher
//
//  Created by Cloud on 15/12/4.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THGuideArticleDetailViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "THArticleDetailCell.h"
#import <NJKWebViewProgressView.h>
#import <NJKWebViewProgress.h>
#import "TXMessageInputView.h"
#import "MJRefresh.h"
#import "NSObject+EXTParams.h"
#import <TXChatCommon/UMSocial.h>
#import <TXChatCommon/UMSocialQQHandler.h>

@interface THGuideArticleDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,NJKWebViewProgressDelegate,XHMessageInputViewDelegate,UIGestureRecognizerDelegate>
{
    UIWebView *_headerWebView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

@property (nonatomic, copy) NSString *linkTitle;
@property (nonatomic, copy) NSString *linkUrlString;
@property (nonatomic, strong) UILabel *commentLb;
@property (nonatomic, strong) UILabel *likeLb;
@property (nonatomic, strong) UIButton *loveBtn;
@property (nonatomic,strong) TXMessageInputView *commentToolView;
@property (nonatomic, strong) NSMutableArray *commentArr;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, assign) BOOL isWebFinished;
@property (nonatomic, assign) BOOL hasMore;

@end

@implementation THGuideArticleDetailViewController

- (void)viewDidLoad{
    self.titleStr = @"宝典详情";
    [super viewDidLoad];
    [self createCustomNavBar];
    
    
    _headerWebView = [[UIWebView alloc] init];
    _headerWebView.delegate = self;
    _headerWebView.scrollView.scrollEnabled = NO;
    _headerWebView.frame = CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, 0);
    [self.view addSubview:_headerWebView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _headerWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 4.f;
    CGRect barFrame = CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progress = 0.1f;
    [_headerWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_knowledge.contentUrl]]];
    _linkUrlString = _knowledge.contentUrl;
    [self fetchComments];
}

- (void)initTableView{
    
    [_headerWebView removeFromSuperview];
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.maxY - 44) style:UITableViewStylePlain];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_listTableView registerClass:[THArticleDetailCell class] forCellReuseIdentifier:@"CellIdentifier"];
//    [self.view addSubview:_listTableView];
    [self.view insertSubview:_listTableView belowSubview:_progressView];
    
    
    [self setupCommentToolBarView];
    [self setupToolView];
    [self setupRefresh];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    tapGesture.delegate = self;
    [_listTableView addGestureRecognizer:tapGesture];
    
    _listTableView.tableHeaderView = _headerWebView;
    
    [self reloadData];
}

- (void)onTapGesture:(UIGestureRecognizer *)gesture{
    [self.commentToolView endEdit];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _listTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
}

/**
 *  上拉刷新
 */
- (void)footerRereshing{
    [self fetchComments];
}


//创建回复+赞视图
- (void)setupToolView
{
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, _listTableView.maxY, self.view.width_, 44)];
    toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolView];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"fx-a"] forState:UIControlStateNormal];
    [shareBtn setImage:[UIImage imageNamed:@"fx-b"] forState:UIControlStateHighlighted];
    [toolView addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(19);
        make.height.mas_equalTo(44);
    }];
    
    CGFloat width = ((self.view.width_/2 - 20 - 19)/2);
    UIImage *commentImg = [UIImage imageNamed:@"jsb-comment-a"];
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setImage:[UIImage imageNamed:@"jsb-comment-a"] forState:UIControlStateNormal];
    [commentBtn setImage:[UIImage imageNamed:@"jsb-comment-b"] forState:UIControlStateHighlighted];
    [toolView addSubview:commentBtn];
    commentBtn.imageEdgeInsets = UIEdgeInsetsMake((44 - commentImg.size.height)/2, 0, (44 - commentImg.size.height)/2, width - commentImg.size.width);
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.width_/2 + 10);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(44);
    }];
    [commentBtn addTarget:self action:@selector(onCommentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loveBtn.adjustsImageWhenHighlighted = NO;
    [toolView addSubview:_loveBtn];
    _loveBtn.imageEdgeInsets = UIEdgeInsetsMake((44 - commentImg.size.height)/2, 0, (44 - commentImg.size.height)/2, width - commentImg.size.width);
    [_loveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(commentBtn.mas_right);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(commentBtn.mas_width);
        make.height.mas_equalTo(commentBtn.mas_height);
    }];
    
    NSNumber *isLoved = [_knowledge extParamForKey:@"hasLike"];
    if (isLoved) {
        [_loveBtn setImage:isLoved.boolValue?[UIImage imageNamed:@"jsb-like-c"]:[UIImage imageNamed:@"jsb-like-a"] forState:UIControlStateNormal];
    }else{
        [_loveBtn setImage:_knowledge.hasLiked?[UIImage imageNamed:@"jsb-like-c"]:[UIImage imageNamed:@"jsb-like-a"] forState:UIControlStateNormal];
    }
    
    __weak typeof(self)tmpObject = self;
    [_loveBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(UIButton * sender) {
        NSNumber *isLoved = [_knowledge extParamForKey:@"hasLike"];
        if (isLoved) {
            [tmpObject onFeedLikeResponse:!isLoved.boolValue];
        }else{
            [tmpObject onFeedLikeResponse:!tmpObject.knowledge.hasLiked];
        }
    }];
    
    NSNumber *extNumber = [_knowledge extParamForKey:@"replyNumber"];
    int commentNum = 0;
    if (extNumber) {
        commentNum = extNumber.intValue;
    }else{
        commentNum = (int)(_knowledge.replyNum);
    }
    _commentLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    _commentLb.text = [NSString stringWithFormat:@"%d",commentNum];
    _commentLb.textAlignment = NSTextAlignmentLeft;
    _commentLb.font = kFontSmall;
    _commentLb.textColor = kColorGray;
    [toolView addSubview:_commentLb];
    [_commentLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(commentBtn.mas_left).offset(commentImg.size.width + 10);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(commentBtn.mas_right);
        make.bottom.mas_equalTo(_loveBtn.mas_bottom);
    }];
    
    NSNumber *likeNumber = [_knowledge extParamForKey:@"likedNumer"];
    int likeNum = 0;
    if (likeNumber) {
        likeNum = likeNumber.intValue;
    }else{
        likeNum = (int)(_knowledge.likedNum);
    }
    _likeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    _likeLb.text = [NSString stringWithFormat:@"%d",likeNum];
    _likeLb.textAlignment = NSTextAlignmentLeft;
    _likeLb.font = kFontSmall;
    _likeLb.textColor = kColorGray;
    [toolView addSubview:_likeLb];
    [_likeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_loveBtn.mas_left).offset(commentImg.size.width + 10);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(_loveBtn.mas_right);
        make.bottom.mas_equalTo(_loveBtn.mas_bottom);
    }];
    
    [shareBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [tmpObject shareLinkToSocial];
    }];
    
    UIButton *replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    replayBtn.titleLabel.font = kFontSmall;
    replayBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [replayBtn setTitleColor:kColorGray forState:UIControlStateNormal];
    [replayBtn setTitle:@"  写评论..." forState:UIControlStateNormal];
    replayBtn.layer.cornerRadius = 3;
    replayBtn.layer.masksToBounds = YES;
    replayBtn.layer.borderColor = kColorLine.CGColor;
    replayBtn.layer.borderWidth = kLineHeight;
    [toolView addSubview:replayBtn];
    [replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(13);
        make.top.mas_equalTo(6);
        make.bottom.mas_equalTo(-6);
        make.right.mas_equalTo(commentBtn.mas_left).offset(-10);
    }];
    [replayBtn addTarget:self action:@selector(onCommentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //添加横分割线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, toolView.width_, kLineHeight)];
    topLineView.backgroundColor = RGBCOLOR(0xdb, 0xdb, 0xdb);
    [toolView addSubview:topLineView];
}



- (void)onCommentButtonTapped
{
    self.commentToolView.inputTextView.placeHolder = @"";
//    self.replyUserId = 0;
    [self.commentToolView.inputTextView becomeFirstResponder];
}

//创建聊天工具栏视图
- (void)setupCommentToolBarView
{
    _commentToolView = [[TXMessageInputView alloc] initWithFrame:CGRectMake(0, self.view.height_, self.view.width_, kChatToolBarHeight)];
    _commentToolView.delegate = self;
    _commentToolView.associatedScrollView = _listTableView;
    _commentToolView.contentViewController = self;
    _commentToolView.shouldShowInputViewWhenFinished = NO;
    [_commentToolView setupView];
    [self.view addSubview:_commentToolView];
    [self.view bringSubviewToFront:_commentToolView];
}

#pragma mark - 分享
- (void)shareLinkToSocial
{
    if (!_linkUrlString && ![_linkUrlString length]) {
        return;
    }
    //添加复制链接
    UMSocialSnsPlatform *snsPlatform = [[UMSocialSnsPlatform alloc] initWithPlatformName:@"CopyLink"];
    snsPlatform.displayName = @"复制链接";
    snsPlatform.bigImageName = @"share_icon_copy";
    snsPlatform.snsClickHandler = ^(UIViewController *presentingController, UMSocialControllerService * socialControllerService, BOOL isPresentInController){
        THGuideArticleDetailViewController *detailVc = (THGuideArticleDetailViewController *)presentingController;
        if (detailVc) {
            //            NSLog(@"链接地址：%@",detailVc->_article.articleUrlString);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:detailVc.linkUrlString];
            //添加HUD效果
            [detailVc showSuccessHudWithTitle:@"复制链接成功"];
        }
    };
    [UMSocialConfig addSocialSnsPlatform:@[snsPlatform]];
    //设置你要在分享面板中出现的平台
    [UMSocialConfig setSnsPlatformNames:@[UMShareToWechatTimeline,UMShareToWechatSession,UMShareToQQ,@"CopyLink"]];
    //分享
    NSString *title = _linkTitle ?: self.titleStr;
    NSString *URL   = _linkUrlString;
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = URL;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = self.titleStr;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = URL;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
    //    [UMSocialData defaultData].extConfig.title = self.titleStr;
    
    // 手机QQ相关设置
    [UMSocialQQHandler setQQWithAppId:@"1104834058" appKey:@"ZsOFbRmstSsZ0uaY" url:URL];
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = self.titleStr;
    [UMSocialData defaultData].extConfig.qqData.url = URL;
    
    // 复制链接
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMENG_APPKEY
                                      shareText:title
                                     shareImage:[UIImage imageNamed:@"appLogo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ,@"CopyLink"]
                                       delegate:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:_progressView];
    //添加输入框组件
    if (![_commentToolView isDescendantOfView:self.view]) {
        [self.view addSubview:_commentToolView];
        [self.view bringSubviewToFront:_commentToolView];
    }
    // 设置关联的scrollView
    self.commentToolView.associatedScrollView = _listTableView;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
    //移除输入框组件
    if ([_commentToolView isDescendantOfView:self.view]) {
        [_commentToolView removeFromSuperview];
    }
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onFeedLikeResponse:(BOOL)isLike{
    if (!isLike) {
        return;
    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    NSError *error = nil;
    __weak typeof(self)tmpObject = self;
    if (isLike) {
        //点赞
        [[TXChatClient sharedInstance] sendComment:nil commentType:TXPBCommentTypeLike toUserId:0 targetId:_knowledge.id targetType:TXPBTargetTypeKnowledge onCompleted:^(NSError *error, int64_t commentId) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"点赞", nil] counter:1];
                [tmpObject showFailedHudWithError:error];
            }else{
                [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"点赞", nil] counter:1];
                [tmpObject.loveBtn setImage:[UIImage imageNamed:@"jsb-like-c"] forState:UIControlStateNormal];
                NSNumber *extNumber = [tmpObject.knowledge extParamForKey:@"likedNumer"];
                SInt64 commentNum = 0;
                if (extNumber) {
                    commentNum = extNumber.intValue + 1;
                }else{
                    commentNum = tmpObject.knowledge.likedNum + 1;
                }
                [tmpObject.knowledge setTXExtParams:@(YES) forKey:@"hasLike"];
                [tmpObject.knowledge setTXExtParams:@(commentNum) forKey:@"likedNumer"];
                tmpObject.likeLb.text = [NSString stringWithFormat:@"%@",@(commentNum)];
                [[NSNotificationCenter defaultCenter] postNotificationName:TeacherHelpRefreshNewArticleNotification object:nil userInfo:@{@"knowledgeId":@(tmpObject.knowledge.id)}];
            }
        }];
        
    }
//    else{
//        BOOL isMine = NO;
//        int64_t commentId;
//        NSNumber *extNumber = [tmpObject.knowledge extParamForKey:@"myCommentId"];
//        if (extNumber) {
//            isMine = YES;
//            NSNumber *tmpCommentId = extNumber;
//            commentId = tmpCommentId.integerValue;
//        }else{
//            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
//            NSArray *arr1 = [feed.circleLikes filteredArrayUsingPredicate:predicate1];
//            if (arr1.count) {
//                TXPBLike *like = arr1[0];
//                commentId = like.commentId;
//            }else{
//                [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
//                return;
//            }
//        }
//        
//        [[TXChatClient sharedInstance] deleteComment:commentId onCompleted:^(NSError *error) {
//            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
//            if (error) {
//                [tmpObject showFailedHudWithError:error];
//                
//            }else{
//                if (isMine) {
//                    [feed.circleLikes removeObjectAtIndex:0];
//                }else{
//                    
//                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
//                    NSArray *arr1 = [feed.circleLikes filteredArrayUsingPredicate:predicate1];
//                    if (arr1.count) {
//                        [feed.circleLikes removeObject:arr1[0]];
//                    }
//                }
//                feed.likeLb = [CircleListViewController getNIAttributedLabelWith:feed.circleLikes];
//                feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:feed]];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [tmpObject reloadData];
//                });
//            }
//        }];
//    }
}

- (void)sendComment:(NSString *)comment{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] sendComment:comment commentType:TXPBCommentTypeReply toUserId:0 targetId:_knowledge.id targetType:TXPBTargetTypeKnowledge onCompleted:^(NSError *error, int64_t commentId) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }else{
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:comment forKey:@"comment"];
            [dic setValue:@(commentId) forKey:@"commentId"];
            [dic setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
            if (!tmpObject.commentArr) {
                tmpObject.commentArr = [NSMutableArray array];
            }
            [tmpObject.commentArr addObject:dic];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *extNumber = [tmpObject.knowledge extParamForKey:@"replyNumber"];
                int64_t commentNum = 0;
                if (extNumber) {
                    commentNum = extNumber.intValue + 1;
                }else{
                    commentNum = tmpObject.knowledge.replyNum + 1;
                }
                [tmpObject.knowledge setTXExtParams:@(commentNum) forKey:@"replyNumber"];
                tmpObject.commentLb.text = [NSString stringWithFormat:@"%@",@(commentNum)];
                [[NSNotificationCenter defaultCenter] postNotificationName:TeacherHelpRefreshNewArticleNotification object:@(tmpObject.knowledge.id)];
                [tmpObject reloadData];
                [tmpObject.commentToolView endEdit];
            });
        }
    }];
    
}

- (void)reloadData{
    [_listTableView reloadData];
    if (!_hasMore) {
        _listTableView.footer.hidden = YES;
        [_listTableView.footer noticeNoMoreData];
    }else{
        _listTableView.footer.hidden = NO;
        [_listTableView.footer resetNoMoreData];
    }
}


- (void)fetchComments{
    int64_t maxCommentId;
    if (!_commentArr) {
        maxCommentId = LLONG_MAX;
    }else if ([_commentArr.lastObject isKindOfClass:[NSMutableDictionary class]]) {
        NSDictionary *dic = _commentArr.lastObject;
        NSNumber *num = dic[@"commentId"];
        maxCommentId = num.integerValue;
    }else{
        TXComment *comment = _commentArr.lastObject;
        maxCommentId = comment.commentId;
    }
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_knowledge.id targetType:TXPBTargetTypeKnowledge maxCommentId:maxCommentId onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        [tmpObject.listTableView.footer endRefreshing];
        if (!error) {
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"commentType == %d",TXPBCommentTypeReply];
            NSArray *arr = [comments filteredArrayUsingPredicate:pre];
            if (!tmpObject.commentArr) {
                tmpObject.commentArr = [NSMutableArray array];
            }
            [tmpObject.commentArr addObjectsFromArray:arr];
            tmpObject.hasMore = hasMore;
            if (tmpObject.isWebFinished) {
                [tmpObject reloadData];
            }
        }
    }];
}

#pragma mark - TXMessageEmotionViewDelegate methods
//发送表情
- (void)sendEmotionText:(NSString *)text
{
    if (text.length > 0) {
        _commentToolView.inputTextView.text = @"";
        [self sendComment:text];
        [_commentToolView.inputTextView resignFirstResponder];
    }
}
//发送文字
- (void)didSendTextAction:(NSString *)text {
    //判断是否是空消息
    NSString *trimString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimString length] == 0) {
        //Alert提醒不能输入空白消息
        [self showFailedHudWithTitle:@"不能发送空白消息"];
    }else{
        //清空已发送文本
        _commentToolView.inputTextView.text = @"";
        [self sendComment:text];
        [_commentToolView.inputTextView resignFirstResponder];
    }
}

//底部insets改变
- (void)onBottomInsetsChanged:(CGFloat)bottom
               isShowKeyboard:(BOOL)isShow
{
    if (isShow)
        [self scrollToBottomAnimated:NO];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGFloat offsetY = _listTableView.contentSize.height - (_listTableView.bounds.size.height - _listTableView.contentInset.bottom);
    if (offsetY > 0) {
        [_listTableView setContentOffset:CGPointMake(0, _listTableView.contentSize.height - (_listTableView.bounds.size.height - _listTableView.contentInset.bottom)) animated:animated];
    }
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_commentToolView associatedScrollViewWillBeginDragging];
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _commentArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)tmpObject = self;
    return [tableView fd_heightForCellWithIdentifier:@"CellIdentifier" cacheByIndexPath:indexPath configuration:^(THArticleDetailCell *cell) {
        cell.listVC = tmpObject;
        cell.detailDic = _commentArr[indexPath.row];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    THArticleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.listVC = self;
    cell.detailDic = _commentArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //获取网页的标题
    NSString *documentTitleString = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.linkTitle = documentTitleString;
    
    if (IOS9_OR_LATER) {
        CGRect frame = webView.frame;
        frame.size.width = kScreenWidth;
        frame.size.height = 1;
        webView.frame = frame;
        _headerWebView.height_ = webView.scrollView.contentSize.height + 10;
    }else{
        CGFloat webViewHeight= [[webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"] floatValue];
        _headerWebView.height_ = webViewHeight + 10;
    }
    
    _headerWebView.minY = 0;
    [self initTableView];
    _isWebFinished = YES;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}



@end
