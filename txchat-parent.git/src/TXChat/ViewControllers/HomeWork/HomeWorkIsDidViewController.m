//
//  HomeWorkIsDidViewController.m
//  TXChatParent
//
//  Created by gaoju on 16/3/15.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

//
//  GameWebViewController.m
//  TXChatParent
//
//  Created by yi.meng on 16/2/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//
#import "HomeWorkIsDidViewController.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>
#import "TXSystemManager.h"

@interface HomeWorkIsDidViewController()

<UIWebViewDelegate,NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    BOOL _isBackRequest;
}

@property (nonatomic,copy) NSString *userToken;
@property (nonatomic,copy) NSString *urlString;

@end

@implementation HomeWorkIsDidViewController


- (instancetype)initWithURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
		_urlString = urlString;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToken) name:KUpdateToken object:nil];
    }
    return self;
}

- (void)createButton
{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setTitle:@"家园" forState:UIControlStateNormal];
    _button.frame = CGRectMake(0, 0, 50, 50);
    [_button addTarget:self action:@selector(resignWindow) forControlEvents:UIControlEventTouchUpInside];
    _window = [[UIWindow alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*4/5+10, CGRectGetHeight(self.view.frame)/10, 50, 50)];
    _window.windowLevel = UIWindowLevelAlert+1;
    UIColor *testColor= [UIColor colorWithRed:255/255.0 green:165/255.0 blue:0/255.0 alpha:0.2];
    _window.backgroundColor = testColor;
    _window.layer.cornerRadius = _button.bounds.size.width/2;
    _window.layer.masksToBounds = YES;
    [_window addSubview:_button];
    [_window makeKeyAndVisible];//关键语句,显示window
    
}

/**
 *  关闭悬浮的window
 */
- (void)resignWindow
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    _window.hidden = YES;
    [_window resignKeyWindow];
    _window = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    
    //    self.btnLeft.hidden = YES;
    //    [self.btnRight setTitle:@"家园" forState:UIControlStateNormal];
    //    self.customNavigationView.hidden = YES;
    
    CGFloat x = 0;
    CGFloat y = 0;//self.customNavigationView.maxY;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(x, y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - y)];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 4.f;
    CGRect barFrame = CGRectMake(x, y, CGRectGetWidth(self.view.frame), progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.progress = 0.f;
    
    //开始请求
    [self loadFoundWebContentData];
    
    [self performSelector:@selector(createButton) withObject:nil afterDelay:1];
    
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
        
        [self.navigationController popViewControllerAnimated:YES];
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
    
    requestUrl = [KURL_H5_HOST stringByAppendingString:@"?action=10003"];;
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
    //NSLog(@"请求url:%@",request.URL.absoluteString);
    //非土星的网页不拦截
    if (_homeListType != FoundType_None) {
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

