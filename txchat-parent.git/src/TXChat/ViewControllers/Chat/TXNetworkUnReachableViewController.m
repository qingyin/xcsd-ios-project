//
//  TXNetworkUnReachableViewController.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXNetworkUnReachableViewController.h"

@interface TXNetworkUnReachableViewController ()
<UIWebViewDelegate,
UIActionSheetDelegate>
{
    UIWebView *_webView;
}
@end

@implementation TXNetworkUnReachableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    self.titleStr = @"网络无连接";
    //创建webView
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY)];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.alwaysBounceVertical = YES;
    _webView.scrollView.alwaysBounceHorizontal = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    //加载本地html
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"networkconnectedfailed" ofType:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filepath]];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"http"]) {
        //打开连接
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:request.URL];
        return NO;
    }else if ([request.URL.absoluteString hasPrefix:@"openTelNumber"]){
        //打电话
        NSString *phoneNumber = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"openTelNumber" withString:@""];
        UIActionSheet *addPictureAS = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"呼叫400-810-2010",nil];
        addPictureAS.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [addPictureAS showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                UIApplication *application = [UIApplication sharedApplication];
                [application openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]];
            }
        }];
        return NO;
    }
//    <p>3.如果微家园仍然无法连接网络，请访问 <a href="http://www.weijiayuan.im/">客服网站</a> 或者呼叫 <a href="openTelNumber4008102010">400-810-2010</a> 联系微家园团队。</p>

    return YES;
}

@end
