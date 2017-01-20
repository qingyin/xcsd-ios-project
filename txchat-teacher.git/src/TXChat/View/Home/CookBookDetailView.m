//
//  CookBookDetailView.m
//  TXChat
//
//  Created by 陈爱彬 on 15/7/8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CookBookDetailView.h"
#import "TXSystemManager.h"

@interface CookBookDetailView()
<UIWebViewDelegate>
{
    UIButton *_reloadButton;
    BOOL _isHasRequested;
}
@property (nonatomic) SInt64 postId;
@property (nonatomic) TXHomePostType postType;
@end

@implementation CookBookDetailView

- (instancetype)initWithFrame:(CGRect)frame
                       postId:(SInt64)postId
                     postType:(TXHomePostType)postType
{
    self = [super initWithFrame:frame];
    if (self) {
        _postId = postId;
        _postType = postType;
        _isHasRequested = NO;
        //创建webView
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height)];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.scrollView.alwaysBounceVertical = YES;
        _webView.scrollView.alwaysBounceHorizontal = YES;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_webView];
    }
    return self;
}
//开始请求
- (void)startRecipeRequest
{
    if (_isHasRequested) {
        return;
    }
    _isHasRequested = YES;
    [self fetchRecipesWebContent];
}
- (void)onReloadButtonTapped
{
    _reloadButton.hidden = YES;
    [self fetchRecipesWebContent];
}
#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //禁止放大
    webView.scrollView.bouncesZoom = NO;
    webView.scrollView.maximumZoomScale = 1.f;
    webView.scrollView.minimumZoomScale = 1.f;
    webView.scrollView.directionalLockEnabled = YES;
}
#pragma mark - 请求网页h5内容
- (void)fetchRecipesWebContent
{
    NSString *requestUrl = @"";
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser) {
        return;
    }
    int64_t gardenId = currentUser.gardenId;
    if ([TXSystemManager sharedManager].isDevVersion) {
        NSString *baseUrl = [[TXSystemManager sharedManager] webBaseUrlString];
        requestUrl = [NSString stringWithFormat:@"%@cms/article.do?view&id=%@&channelId=5&gardenId=%@",baseUrl,@(_postId),@(gardenId)];
    }else{
        requestUrl = [NSString stringWithFormat:@"http://h5.tx2010.com/cms/article.do?view&id=%@&channelId=5&gardenId=%@",@(_postId),@(gardenId)];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [_webView loadRequest:request];
//    [[TXChatClient sharedInstance].postManager fetchPostDetail:_postId postType:(TXPBPostType)_postType onCompleted:^(NSError *error, NSString *htmlContent) {
////        NSLog(@"error:%@",error);
////        NSLog(@"htmlContent:%@",htmlContent);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (error) {
//                DDLogDebug(@"获取post详情error:%@",error);
//                if (!_reloadButton) {
//                    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                    _reloadButton.backgroundColor = [UIColor clearColor];
//                    _reloadButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
//                    _reloadButton.center = self.center;
//                    [_reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//                    [_reloadButton setTitle:@"加载失败，点击屏幕刷新" forState:UIControlStateNormal];
//                    [_reloadButton addTarget:self action:@selector(onReloadButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//                    [self addSubview:_reloadButton];
//                }
//                _reloadButton.hidden = NO;
//            }else{
////                [_webView loadHTMLString:htmlContent baseURL:nil];
//                NSData *htmlData = [htmlContent dataUsingEncoding:NSUTF8StringEncoding];
//                [_webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
//            }
//        });
//    }];
}
@end
