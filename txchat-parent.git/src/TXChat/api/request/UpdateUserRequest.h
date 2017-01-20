

#import "BaseRequest.h"

@interface UpdateUserRequest : BaseRequest

//@property NSString* token;


@property NSInteger district;


@property NSDate* birthday;

//孩子性别 1(male) ,2(female)
@property NSString* gender;

@property NSString* nickName;

@property NSString* pic;

@end
