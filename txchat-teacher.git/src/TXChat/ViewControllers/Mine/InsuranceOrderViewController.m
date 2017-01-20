//
//  InsuranceOrderViewController.m
//  TXChat
//
//  Created by 陈爱彬 on 15/7/27.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "InsuranceOrderViewController.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>
#import "TXSystemManager.h"

static NSString *const kInsuranceIntroUrlString = @"http://h5.tx2010.com/insurance.do?intro";
static NSString *const kInsuranceOrderUrlString = @"http://h5.tx2010.com/insurance.do?order";

@interface InsuranceOrderViewController ()
<UIWebViewDelegate,
NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    BOOL _isBackRequest;
}
@property (nonatomic) InsuranceOrderType type;
@property (nonatomic,copy) NSString *userToken;
@end

@implementation InsuranceOrderViewController

#pragma mark - LifeCycle
- (instancetype)initWithInsuranceType:(InsuranceOrderType)type
{
    self = [super init];
    if (self) {
        _type = type;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToken) name:KUpdateToken object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    [self.btnRight setTitle:@"关闭" forState:UIControlStateNormal];

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
    [self loadInsuranceOrderWebData];
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
#pragma mark - 按钮点击
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
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - 网络请求
- (void)loadInsuranceOrderWebData
{
    NSString *requestUrl;
    if (_type == InsuranceOrderType_Intro) {
        self.titleStr = @"在园无忧";
        if ([TXSystemManager sharedManager].isDevVersion) {
            NSString *baseUrl = [[TXSystemManager sharedManager] webBaseUrlString];
            requestUrl = [NSString stringWithFormat:@"%@insurance.do?intro",baseUrl];
        }else{
            requestUrl = kInsuranceIntroUrlString;
        }
    }else if (_type == InsuranceOrderType_Order) {
        self.titleStr = @"孩子保险";
        if ([TXSystemManager sharedManager].isDevVersion) {
            NSString *baseUrl = [[TXSystemManager sharedManager] webBaseUrlString];
            requestUrl = [NSString stringWithFormat:@"%@insurance.do?order",baseUrl];
        }else{
            requestUrl = kInsuranceOrderUrlString;
        }
    }
    //开始网络请求
    NSDictionary *dict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (dict) {
        self.userToken = [dict valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN] ? dict[TX_PROFILE_KEY_CURRENT_TOKEN] : @"";
        [self startRequestWithUserTokenByUrlString:requestUrl headerDict:nil];
    }
}
//带上token开始请求
- (void)startRequestWithUserTokenByUrlString:(NSString *)urlString
                                  headerDict:(NSDictionary *)dict
{
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
    if (![request.URL.absoluteString containsString:@"insurance.do"]) {
        return YES;
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
-(void)jsDidEnterBackground
{
    [_webView stringByEvaluatingJavaScriptFromString:@"goBackGround()"];
}

-(void)jsDidEnterForeground
{
    [_webView stringByEvaluatingJavaScriptFromString:@"goForeGround()"];
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
