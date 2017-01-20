 

#import "BaseResponse.h"
#import "MemberInfo.h"
@interface GetFollowersResponse : BaseResponse

@property NSArray<MemberInfo>* result;

//{
//    errorCode = 0;
//    message = Success;
//    result =     (
//                  {
//                      id = 156;
//                      name = test5;
//                  }
//                  );
//}

@end
