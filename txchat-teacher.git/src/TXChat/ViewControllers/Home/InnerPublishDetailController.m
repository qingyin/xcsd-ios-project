//
//  InnerPublishDetailController.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "InnerPublishDetailController.h"
#import <NJKWebViewProgressView.h>
#import <NJKWebViewProgress.h>
#import "TXProgressHUD.h"
#import <TXChatCommon/UMSocial.h>
#import <TXChatCommon/UMSocialQQHandler.h>
#import <TXChatCommon/UMSocialControllerService.h>
#import "TXSystemManager.h"
#import "ShareSelectController.h"

static CGFloat const kBottomToolBarHeight = 44;
static NSString *const kWeiXueYuanPushLink = @"http://h5.tx2010.com/cms/article.do?view&channelId=0";

@interface InnerPublishDetailController ()
<UIWebViewDelegate,
UMSocialUIDelegate,
NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    UIView *_bottomView;
    //    UIButton *_reloadButton;
    BOOL _isBackRequest;
}
@property (nonatomic, copy) NSString *linkUrlString;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *forwardBtn;
@property (nonatomic) SInt64 postId;
@property (nonatomic) BOOL isHasUrlLink;
@property (nonatomic, copy) NSString *linkTitle;
@property (nonatomic,copy) NSString *userToken;

@end

@implementation InnerPublishDetailController

- (instancetype)initWithLinkURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        _isHasUrlLink = YES;
        _linkUrlString = urlString;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToken) name:KUpdateToken object:nil];
    }
    return self;
}

- (instancetype)initWithWXYPushId:(NSString *)pushId
{
    self = [super init];
    if (self) {
        _isHasUrlLink = YES;
        _linkUrlString = [NSString stringWithFormat:@"%@&id=%@",kWeiXueYuanPushLink,pushId];
    }
    return self;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    //添加分享
    [self.btnRight setImage:[UIImage imageNamed:@"bar_share"] forState:UIControlStateNormal];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), _addRequestToolView ? (CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY - kBottomToolBarHeight) : (CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY))];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 4.f;
    CGRect barFrame = CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progress = 0.f;
    
    if (_addRequestToolView) {
        [self setupBottomToolBar];
    }
    //加载文章内容
    if (_isHasUrlLink) {
        switch (_postType) {
            case TXHomePostType_Activity: {
                self.titleStr = @"活动";
                break;
            }
            case TXHomePostType_Announcement: {
                self.titleStr = @"公告";
                break;
            }
            case TXHomePostType_Learngarden: {
                self.titleStr = @"理解孩子";
                break;
            }
            case TXHomePostType_Intro: {
                self.titleStr = @"学校介绍";
                break;
            }
            case TXHomePostType_Recipes: {
                self.titleStr = @"食谱";
                break;
            }
            case TXHomePostType_ServiceAgreement: {
                self.titleStr = @"服务协议";
                break;
            }
            case TXHomePostType_WeiXueYuanPush: {
                self.titleStr = @"理解孩子";
            }
                break;
            case TXHomePostType_GardenPost: {
                TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
                if (currentUser && currentUser.gardenName && [currentUser.gardenName length]) {
                    self.titleStr = [currentUser.gardenName stringByAppendingString:@"公众号"];
                }else{
                    self.titleStr = @"详情";
                }
            }
                break;
            default: {
                self.titleStr = @"详情";
                break;
            }
        }
        [self loadPublishmentArticleData];
    }
}
- (void)setAddRequestToolView:(BOOL)addRequestToolView
{
    _addRequestToolView = addRequestToolView;
    if (_addRequestToolView) {
        [self setupBottomToolBar];
    }else{
        _bottomView.hidden = YES;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self.view addSubview:_progressView];
    
    if (self.articleId.length > 0) {
        [self reportEvent:XCSDPBEventTypeArticleIn bid:self.articleId];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
    
    if (self.articleId.length > 0) {
        [self reportEvent:XCSDPBEventTypeArticleOut bid:self.articleId];
    }
    
}

- (void)setupBottomToolBar
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_webView.frame), CGRectGetWidth(self.view.frame), kBottomToolBarHeight)];
    _bottomView.backgroundColor = RGBCOLOR(230, 231, 234);
    [self.view addSubview:_bottomView];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"WebView_Backward_disable.png"] forState:UIControlStateDisabled];
    [_backBtn setImage:[UIImage imageNamed:@"WebView_Backward.png"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.frame = CGRectMake(30, 5, 34, 34);
    [_bottomView addSubview:_backBtn];
    
    self.forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forwardBtn setImage:[UIImage imageNamed:@"WebView_Forward_disable.png"] forState:UIControlStateDisabled];
    [_forwardBtn setImage:[UIImage imageNamed:@"WebView_Forward.png"] forState:UIControlStateNormal];
    _forwardBtn.frame = CGRectMake(CGRectGetMaxX(_backBtn.frame)+30, 5, 34, 34);
    [_forwardBtn addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_forwardBtn];
    
    [self decideBottomBtnsState];
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setImage:[UIImage imageNamed:@"WebView_Refresh.png"] forState:UIControlStateNormal];
    refreshBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-30-34, 5, 34, 34);
    [refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:refreshBtn];
}

- (void)decideBottomBtnsState
{
    if (_webView.canGoBack) {
        [_backBtn setEnabled:YES];
    }
    else
    {
        [_backBtn setEnabled:NO];
    }
    
    if(_webView.canGoForward)
    {
        [_forwardBtn setEnabled:YES];
    }
    else
    {
        [_forwardBtn setEnabled:NO];
    }
    
}
#pragma mark - 按钮状态
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        if ([_webView canGoBack]) {
            _isBackRequest = YES;
            [_webView goBack];
        }else{
            //            [self.navigationController popViewControllerAnimated:YES];
            [(UINavigationController *)([UIApplication sharedApplication].keyWindow.rootViewController) popViewControllerAnimated:YES];
        }
    }else if (sender.tag == TopBarButtonRight) {
        [self shareLinkToSocial];
    }
}
- (void)goBack
{
    [_webView goBack];
}

- (void)goForward
{
    [_webView goForward];
}

- (void)refresh
{
    //    [_webView reload];
    [self reloadWebPageContent];
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
        InnerPublishDetailController *detailVc = (InnerPublishDetailController *)presentingController;
        if (detailVc) {
            //            NSLog(@"链接地址：%@",detailVc->_article.articleUrlString);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:detailVc.linkUrlString];
            //添加HUD效果
            [detailVc showSuccessHudWithTitle:@"复制链接成功"];
        }
    };
    
    // 添加内部分享
    
    UMSocialSnsPlatform *innerPlatform = [[UMSocialSnsPlatform alloc] initWithPlatformName:@"innerShare"];
    innerPlatform.displayName = @"班级";
    innerPlatform.bigImageName = @"articleShare_classes";
    innerPlatform.snsClickHandler = ^(UIViewController *vc, UMSocialControllerService *controllerService, BOOL isPresentInController){
        
        InnerPublishDetailController *detailVC = (InnerPublishDetailController *)vc;
        
        if (detailVC) {
            
            ShareSelectController *shareVC = [[ShareSelectController alloc] init];
            
            shareVC.url = self.linkUrlString;
            shareVC.articleTitle = self.articleTitle;
            shareVC.coverImageUrl = self.coverImageUrl;
            [detailVC.navigationController pushViewController:shareVC animated:YES];
        }
    };
    
    [UMSocialConfig addSocialSnsPlatform:@[snsPlatform, innerPlatform]];
    //设置你要在分享面板中出现的平台
    [UMSocialConfig setSnsPlatformNames:@[UMShareToWechatTimeline,UMShareToWechatSession,UMShareToQQ, @"innerShare",@"CopyLink"]];
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
    [UMSocialQQHandler setQQWithAppId:UMENG_QQAppId appKey:UMENG_QQAppKey url:URL];
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = self.titleStr;
    [UMSocialData defaultData].extConfig.qqData.url = URL;
    
    // 复制链接
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMENG_APPKEY
                                      shareText:title
                                     shareImage:[UIImage imageNamed:@"appLogo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ,@"innerShare",@"CopyLink"]
                                       delegate:self];
    
}

#pragma mark - UMSocialSnsService代理

- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData {
    
    if ([platformName isEqualToString:UMShareToWechatTimeline]) {   //朋友圈
        
        [[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeShareArticle bid:self.articleId userId:[TXApplicationManager sharedInstance].currentUser.userId extendedInfo:[NSString stringWithFormat:@"{\"type\" : %d}", 1]];
    }else if ([platformName isEqualToString:UMShareToWechatSession]) {  //好友
        [[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeShareArticle bid:self.articleId userId:[TXApplicationManager sharedInstance].currentUser.userId extendedInfo:[NSString stringWithFormat:@"{\"type\" : %d}", 2]];
    }else if([platformName isEqualToString:UMShareToQQ]) {  //QQ
        [[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeShareArticle bid:self.articleId userId:[TXApplicationManager sharedInstance].currentUser.userId extendedInfo:[NSString stringWithFormat:@"{\"type\" : %d}", 3]];
    }else { //复制链接
        [[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeShareArticle bid:self.articleId userId:[TXApplicationManager sharedInstance].currentUser.userId extendedInfo:[NSString stringWithFormat:@"{\"type\" : %d}", 4]];
    }
}


#pragma mark - 加载网页内容
-(void)loadPublishmentArticleData
{
    if (!_linkUrlString || ![_linkUrlString length]) {
        return;
    }
    NSDictionary *dict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (dict) {
        self.userToken = [dict valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN] ? dict[TX_PROFILE_KEY_CURRENT_TOKEN] : @"";
    }
    [self startRequestWithUserTokenByUrlString:_linkUrlString headerDict:nil];
    //    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_linkUrlString]];
    //    [_webView loadRequest:req];
}
//重新加载网页内容
- (void)reloadWebPageContent
{
    //    _reloadButton.hidden = YES;
    //    [_webView reload];
    //加载文章内容
    if (_isHasUrlLink) {
        [self loadPublishmentArticleData];
    }
}
//带上token开始请求
- (void)startRequestWithUserTokenByUrlString:(NSString *)urlString
                                  headerDict:(NSDictionary *)dict
{
    if (!urlString) {
        return;
    }
    //修改token
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    if (dict) {
        //设置header
        [request setAllHTTPHeaderFields:dict];
    }
    //    NSLog(@"之前header:%@",request.allHTTPHeaderFields);
    if (self.userToken) {
        [request setValue:self.userToken forHTTPHeaderField:@"token"];
    }
    //    NSLog(@"之后header:%@",request.allHTTPHeaderFields);
    [_webView loadRequest:request];
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    //    NSLog(@"progress:%@",@(progress));
    [_progressView setProgress:progress animated:YES];
}
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (_isBackRequest) {
        _isBackRequest = NO;
        return YES;
    }
    //    NSLog(@"请求url:%@",request.URL.absoluteString);
    //非土星的网页不拦截
    if ([TXSystemManager sharedManager].isDevVersion) {
        NSURL *baseUrl = [NSURL URLWithString:[[TXSystemManager sharedManager] webBaseUrlString]];
        if (![request.URL.absoluteString containsString:[baseUrl host]]) {
            return YES;
        }
    }else{
        if (![request.URL.absoluteString containsString:@"h5.tx2010.com"]) {
            return YES;
        }
    }
    NSDictionary *headerDict = request.allHTTPHeaderFields;
    if ([request valueForHTTPHeaderField:@"token"]) {
        return YES;
    }
    NSString *urlString = request.URL.absoluteString;
    [self startRequestWithUserTokenByUrlString:urlString headerDict:headerDict];
    return NO;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self decideBottomBtnsState];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self decideBottomBtnsState];
    //获取网页的标题
    NSString *documentTitleString = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //    if (documentTitleString && [documentTitleString length] > 0 && documentTitleString.length <= 8) {
    //        self.titleStr = documentTitleString;
    //    }
    self.linkTitle = documentTitleString;
}
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    //    NSLog(@"网页加载失败");
//    if (!_reloadButton) {
//        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _reloadButton.backgroundColor = [UIColor clearColor];
//        _reloadButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY);
//        _reloadButton.center = self.view.center;
//        [_reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [_reloadButton setTitle:@"加载失败，点击屏幕刷新" forState:UIControlStateNormal];
//        [_reloadButton addTarget:self action:@selector(reloadWebPageContent) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_reloadButton];
//    }
//    _reloadButton.hidden = NO;
//    //添加HUD
////    [TXProgressHUD showErrorMessage:self.view withMessage:@"好像出错啦，再试试吧"];
//}

- (void)updateToken
{
    NSDictionary *dict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (dict) {
        self.userToken = [dict valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN] ? dict[TX_PROFILE_KEY_CURRENT_TOKEN] : @"";
    }
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KUpdateToken
                                                  object:nil];
}
@end
