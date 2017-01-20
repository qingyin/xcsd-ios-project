 

#import "BaseRequest.h"

@interface LoginV1Request : BaseRequest

@property NSString* user;
@property NSString* sp;
@property NSString* ch;
@property NSString* nickName;
@property NSString* pic;

@property NSString* deviceType;
@property NSString* accessToken;
@end
