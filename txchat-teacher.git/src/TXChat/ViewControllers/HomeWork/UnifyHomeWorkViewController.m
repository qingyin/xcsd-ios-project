//
//  UnifyHomeWorkViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/4/7.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "UnifyHomeWorkViewController.h"
#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>
#import "TXSystemManager.h"
#import "GxqAlertView.h"

@interface UnifyHomeWorkViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    BOOL _isBackRequest;
}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)bindPan:(UIButton *)imgVCustom;
@property (nonatomic,copy) NSString *userToken;
@property (nonatomic,copy) NSString *urlString;

@end

@implementation UnifyHomeWorkViewController

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
    [self.view addSubview:_button];
    [_button setBackgroundImage:[UIImage imageNamed:@"btn_task"] forState:UIControlStateNormal];
    _button.frame = CGRectMake(CGRectGetWidth(self.view.frame)-51, CGRectGetHeight(self.view.frame)/10, 50, 50);
    [_button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _button.layer.cornerRadius = _button.bounds.size.width/2;
    _button.layer.masksToBounds = YES;
    [self bindPan:_button];
}

/**
 *  关闭悬浮的
 */
- (void)btnClick:(UIButton *)btn
{
    [GxqAlertView showWithTipText:@"提示" descText:@"您确定要离开，回到作业列表吗？" LeftText:@"取消" second:10 rightText:@"确定" LeftBlock:^{
        NSLog(@"点击了取消");
        
    } RightBlock:^{
        NSLog(@"点击了确定");
        //bay gaoju
        [[NSNotificationCenter defaultCenter] postNotificationName:HomeWorkPostNotification object:nil];
        
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        
        
        //add by sck
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
}
#pragma mark - 处理手势操作
/**
 *  处理拖动手势
 *
 *  @param recognizer 拖动手势识别器对象实例
 */
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    //视图前置操作
    [recognizer.view.superview bringSubviewToFront:recognizer.view];
    
    CGPoint center = recognizer.view.center;
    CGFloat cornerRadius = recognizer.view.frame.size.width / 2;
    CGPoint translation = [recognizer translationInView:self.view];
    //NSLog(@"%@", NSStringFromCGPoint(translation));
    recognizer.view.center = CGPointMake(self.view.bounds.size.width - cornerRadius, center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        //CGPoint velocity = [recognizer velocityInView:self.view];
        
        CGPoint finalPoint = CGPointMake(self.view.bounds.size.width,
                                         center.y );
        //限制最小［cornerRadius］和最大边界值［self.view.bounds.size.width - cornerRadius］，以免拖动出屏幕界限
        finalPoint.x = MIN(MAX(finalPoint.x, cornerRadius),
                           self.view.bounds.size.width - cornerRadius);
        finalPoint.y = MIN(MAX(finalPoint.y, 3*cornerRadius),
                           self.view.bounds.size.height -3* cornerRadius);
        
        //使用 UIView 动画使 view 滑行到终点
        [UIView animateWithDuration:.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             recognizer.view.center = finalPoint;
                         }
                         completion:nil];
    }
}
#pragma mark - 绑定手势操作
/**
 *  绑定拖动手势
 *
 *  @param imgVCustom 绑定到图片视图对象实例
 */
- (void)bindPan:(UIImageView *)imgVCustom {
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePan:)];
    [imgVCustom addGestureRecognizer:recognizer];
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidEnterBackground) name:@"WebViewApplicationDidEnterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidEnterForeground) name:@"WebViewApplicationWillEnterForeground" object:nil];
    
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
    
    requestUrl = [KURL_H5_HOST stringByAppendingString:[NSString stringWithFormat:@"?action=10002&memberId=%lld",self.classId]];
    
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
    NSString *tokenUrlString=[urlString stringByAppendingString:[NSString stringWithFormat:@"&token=%@&isTaskState=2",self.userToken]];
    //修改token
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:tokenUrlString]];
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

