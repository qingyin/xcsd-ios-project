

#import "BaseResponse.h"
#import "RankInfo.h"
@interface GetRankResponse : BaseResponse
@property RankInfo<Optional>* result;
//{
//    errorCode = 0;
//    message = Success;
//    result =     {
//        rank = 14;
//        total = 105;
//    };
//}

@end
