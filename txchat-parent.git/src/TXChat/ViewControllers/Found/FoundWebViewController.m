//
//  FoundWebViewController.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/16.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "FoundWebViewController.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>
#import "TXSystemManager.h"

static NSString *const kFoundEventUrlString = @"http://h5.tx2010.com/activity.do";
static NSString *const kFoundShopUrlString = @"http://h5.tx2010.com/shop.do";
static NSString *const kFoundRecordDrawUrlString = @"http://h5.tx2010.com/activity.do?recordDraw";

@interface FoundWebViewController ()
<UIWebViewDelegate,
NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    BOOL _isBackRequest;
}
@property (nonatomic,copy) NSString *userToken;
@property (nonatomic,copy) NSString *urlString;

@end

@implementation FoundWebViewController

- (instancetype)initWithURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
		_urlString = urlString;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToken) name:KUpdateToken object:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    if (_foundType == FoundType_Event) {
        //抽奖记录
        [self.btnRight setTitle:@"获奖记录" forState:UIControlStateNormal];
        // by mey
//    }
//    else if(_foundType == FoundType_Game){
    
//        self.btnLeft.hidden = YES;
//        [self.btnRight setTitle:@"家园" forState:UIControlStateNormal];
//        self.customNavigationView.hidden = YES;
        
    }else{
        [self.btnRight setTitle:@"关闭" forState:UIControlStateNormal];
    }
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY)];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 4.f;
    CGRect barFrame = CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progress = 0.f;
    
    //开始请求
    [self loadFoundWebContentData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
    
}
#pragma mark - UI视图创建
//- (void)createCustomNavBar
//{
//    switch (_foundType) {
//        case FoundType_Event: {
//            self.titleStr = @"活动专区";
//            break;
//        }
//        case FoundType_Shop: {
//            self.titleStr = @"微豆商城";
//            break;
//        }
//        case FoundType_RecordDraw: {
//            self.titleStr = @"抽奖记录";
//        }
//            break;
//        default: {
//            self.titleStr = @"详情";
//            break;
//        }
//    }
//    [super createCustomNavBar];
//}
#pragma mark - 按钮点击响应
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        if ([_webView canGoBack]) {
            _isBackRequest = YES;
            [_webView goBack];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        if (_foundType == FoundType_Event) {
            //抽奖记录
            FoundWebViewController *vc = [[FoundWebViewController alloc] init];
            vc.foundType = FoundType_RecordDraw;
            vc.enterVc = _enterVc;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (_foundType == FoundType_RecordDraw) {
            NSArray *vcs = self.navigationController.viewControllers;
            if ([vcs containsObject:_enterVc]) {
                [self.navigationController popToViewController:_enterVc animated:YES];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark - 网络请求
- (void)loadFoundWebContentData
{
    NSDictionary *dict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (dict) {
        self.userToken = [dict valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN] ? dict[TX_PROFILE_KEY_CURRENT_TOKEN] : @"";
    }
    NSString *requestUrl;
    if (_foundType == FoundType_Event) {
        //活动专区
        if ([TXSystemManager sharedManager].isDevVersion) {
            NSString *baseUrl = [[TXSystemManager sharedManager] webBaseUrlString];
            requestUrl = [NSString stringWithFormat:@"%@activity.do",baseUrl];
            //            //添加token
            //            if (self.userToken && [self.userToken length]) {
            //                requestUrl = [NSString stringWithFormat:@"%@?token=%@",requestUrl,self.userToken];
            //            }
        }else{
            requestUrl = kFoundEventUrlString;
        }
    }else if (_foundType == FoundType_Shop) {
        //积分商城
        if ([TXSystemManager sharedManager].isDevVersion) {
            NSString *baseUrl = [[TXSystemManager sharedManager] webBaseUrlString];
            requestUrl = [NSString stringWithFormat:@"%@shop.do",baseUrl];
            //            //添加token
            //            if (self.userToken && [self.userToken length]) {
            //                requestUrl = [NSString stringWithFormat:@"%@?token=%@",requestUrl,self.userToken];
            //            }
        }else{
            requestUrl = kFoundShopUrlString;
        }
    }else if (_foundType == FoundType_RecordDraw) {
        //抽奖记录
        if ([TXSystemManager sharedManager].isDevVersion) {
            NSString *baseUrl = [[TXSystemManager sharedManager] webBaseUrlString];
            requestUrl = [NSString stringWithFormat:@"%@activity.do?recordDraw",baseUrl];
            //            //添加token
            //            if (self.userToken && [self.userToken length]) {
            //                requestUrl = [NSString stringWithFormat:@"%@?recordDraw&token=%@",requestUrl,self.userToken];
            //            }
        }else{
            requestUrl = kFoundRecordDrawUrlString;
        }
        
    }else{
        requestUrl = _urlString;
    }
    //开始网络请求
    [self startRequestWithUserTokenByUrlString:requestUrl headerDict:nil];
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
    if (_foundType != FoundType_None) {
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
    }
    NSDictionary *headerDict = request.allHTTPHeaderFields;
    //    NSLog(@"headers:%@",headerDict);
    if ([request valueForHTTPHeaderField:@"token"]) {
        return YES;
    }
    //    if ([[headerDict allKeys] containsObject:@"token"]) {
    //        return YES;
    //    }
    NSString *urlString = request.URL.absoluteString;
    [self startRequestWithUserTokenByUrlString:urlString headerDict:headerDict];
    return NO;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    NSLog(@"请求成功:%@",webView.request);
    //获取网页的标题
    NSString *documentTitleString = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.titleStr = documentTitleString;
}
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
