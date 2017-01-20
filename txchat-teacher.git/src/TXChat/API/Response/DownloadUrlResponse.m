 
#import "DownloadUrlResponse.h"

@implementation DownloadUrlResponse

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"result.url": @"url"}];
}

@end
