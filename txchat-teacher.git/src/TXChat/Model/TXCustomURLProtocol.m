//
//  TXCustomURLProtocol.m
//  TXChat
//
//  Created by 陈爱彬 on 15/7/19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXCustomURLProtocol.h"
#import "TXSystemManager.h"

static NSString *const kURLProtocolHandledKey = @"urlProtocolHandledKey";

@interface TXCustomURLProtocol()
<NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end


@implementation TXCustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    NSString *urlString = [[request URL] absoluteString];
    //判断是否包含http_invoke，如果包含则是土星服务器，替换请求
    if (([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) && [urlString containsString:@"http_invoke"])
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:kURLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    return NO;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}
//修改请求Host
- (NSMutableURLRequest*)redirectHostInRequset:(NSMutableURLRequest*)request
{
    if ([request.URL host].length == 0) {
        return request;
    }
    NSString *originUrlString = [request.URL absoluteString];
    NSString *originHostString = [request.URL host];
    NSNumber *port = [request.URL port];
    NSRange hostRange = [originUrlString rangeOfString:originHostString];
    if (hostRange.location == NSNotFound) {
        return request;
    }
    //重定向请求Host
    NSString *ip = [[TXSystemManager sharedManager] requestHost];
    // 替换域名
    NSString *urlString = [originUrlString stringByReplacingCharactersInRange:hostRange withString:ip];
    //修改端口号
    urlString = [urlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",port] withString:[[TXSystemManager sharedManager] requestPort]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    request.URL = url;
    
    return request;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}
- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    //标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:kURLProtocolHandledKey inRequest:mutableReqeust];
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];

}
- (void)stopLoading
{
    [self.connection cancel];
}
#pragma mark - NSURLConnectionDelegate
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}
@end
