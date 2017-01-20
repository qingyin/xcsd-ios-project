

#import "BaseResponse.h"

@implementation BaseResponse


/** 全局 */
//+(BOOL)propertyIsOptional:(NSString*)propertyName
//{
//    return YES;
//}

-(BOOL)isSuccess
{
    return  [@"0" isEqualToString:self.errorCode];
}

-(BOOL)isTokenExpired
{
    return  [@"600" isEqualToString:self.errorCode];
}
@end
