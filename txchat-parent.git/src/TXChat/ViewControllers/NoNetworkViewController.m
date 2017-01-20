//
//  NoNetworkViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoNetworkViewController.h"

@interface NoNetworkViewController ()
<UIWebViewDelegate,
UIActionSheetDelegate>
{
    UIWebView *_webView;
}
@end

@implementation NoNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavBar];
    self.titleStr = @"网络无连接";
    //创建webView
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY)];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    //加载本地html
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"networkconnectedfailed" ofType:@"html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filepath]];
    [_webView loadRequest:request];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnLeft setTitle:@"返回" forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    if ([request.URL.absoluteString hasPrefix:@"http"]) {
//        //打开连接
//        UIApplication *application = [UIApplication sharedApplication];
//        [application openURL:request.URL];
//        return NO;
//    }else if ([request.URL.absoluteString containsString:@"openTelNumber"]){
//        //打电话
//#warning 这里待修改为真实的座机号码
//        UIActionSheet *addPictureAS = [[UIActionSheet alloc] initWithTitle:nil
//                                                                  delegate:self
//                                                         cancelButtonTitle:@"取消"
//                                                    destructiveButtonTitle:nil
//                                                         otherButtonTitles:@"呼叫400-810-2010",nil];
//        addPictureAS.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        [addPictureAS showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//            if (buttonIndex == 0) {
//                UIApplication *application = [UIApplication sharedApplication];
//                [application openURL:[NSURL URLWithString:@"tel://4008102010"]];
//            }
//        }];
//        return NO;
//    }
    
    return YES;
}


@end
