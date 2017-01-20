//
//  AttendanceViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/2.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "AttendanceViewController.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>
#import "TXSystemManager.h"
#import "VoiceSpeechViewController.h"

static NSString *const kAttendanceUrlString = @"http://123.57.43.111/t/attendance/children.do";

@interface AttendanceViewController ()
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

@implementation AttendanceViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToken) name:KUpdateToken object:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"考勤";
    [self createCustomNavBar];
    
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
    [self loadAttendanceWebContentData];
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
//创建导航视图
- (void)createCustomNavBar
{
    [super createCustomNavBar];
    self.btnLeft.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, 60, kNavigationHeight);
    [self.btnRight setTitle:@"语音播报" forState:UIControlStateNormal];
    //添加关闭按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(self.btnLeft.maxX, self.btnLeft.minY, 50, kNavigationHeight);
    backBtn.titleLabel.font = kFontMiddle;
    [backBtn setTitleColor:kColorNavigationTitle forState:UIControlStateNormal];
    [backBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavigationView addSubview:backBtn];
}
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        if ([_webView canGoBack]) {
            _isBackRequest = YES;
            [_webView goBack];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if(sender.tag == TopBarButtonRight){
        VoiceSpeechViewController *vc = [[VoiceSpeechViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)onBackButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 网络请求
- (void)loadAttendanceWebContentData
{
    NSDictionary *dict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (dict) {
        self.userToken = [dict valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN] ? dict[TX_PROFILE_KEY_CURRENT_TOKEN] : @"";
    }
    NSString *requestUrl;
    if ([TXSystemManager sharedManager].isDevVersion) {
//        NSString *baseUrl = [[TXSystemManager sharedManager] webBaseUrlString];
//        requestUrl = [NSString stringWithFormat:@"%@t/attendance/child.do",baseUrl];
        requestUrl = kAttendanceUrlString;
    }else{
        requestUrl = kAttendanceUrlString;
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
//    if ([TXSystemManager sharedManager].isDevVersion) {
//        NSURL *baseUrl = [NSURL URLWithString:[[TXSystemManager sharedManager] webBaseUrlString]];
//        if (![request.URL.absoluteString containsString:[baseUrl host]]) {
//            return YES;
//        }
//    }else{
//        if (![request.URL.absoluteString containsString:@"h5.tx2010.com"]) {
//            return YES;
//        }
//    }
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
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    //    NSLog(@"请求成功:%@",webView.request);
//    //获取网页的标题
//    NSString *documentTitleString = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    self.titleStr = documentTitleString;
//}

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
