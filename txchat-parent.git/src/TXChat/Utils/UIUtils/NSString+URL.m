

#import "NSString+URL.h"

@implementation NSString (URL)



//1.非ARC模式下
//
//- (NSString *)encodeToPercentEscapeString: (NSString *) input
//{
//    // Encode all the reserved characters, per RFC 3986
//    // (<http://www.ietf.org/rfc/rfc3986.txt>)
//    NSString *outputStr = (NSString *)
//    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                            (CFStringRef)input,
//                                            NULL,
//                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                            kCFStringEncodingUTF8);
//    return outputStr;
//}
//
//- (NSString *)decodeFromPercentEscapeString: (NSString *) input
//{
//    NSMutableString *outputStr = [NSMutableString stringWithString:input];
//    [outputStr replaceOccurrencesOfString:@"+"
//                               withString:@" "
//                                  options:NSLiteralSearch
//                                    range:NSMakeRange(0, [outputStr length])];
//    
//    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//}
//
//


//2. ARC模式下
- (NSString *)encodeToPercentEscapeString
{
    NSString*
    outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                             
                                                                             NULL,
                                                                             
                                                                             (__bridge CFStringRef)self,
                                                                             
                                                                             NULL,
                                                                             
                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                             
                                                                             kCFStringEncodingUTF8);
    
    
    return
    outputStr;
}
- (NSString *)decodeFromPercentEscapeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0,
                                                      [outputStr length])];
    
    return
    [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
