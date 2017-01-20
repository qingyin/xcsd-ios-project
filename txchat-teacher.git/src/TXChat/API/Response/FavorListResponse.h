

#import "BaseResponse.h"
#import "FavorListResult.h"
@interface FavorListResponse : BaseResponse

@property FavorListResult *result;

//{
//    errorCode = 0;
//    message = Success;
//    result =     {
//        pageSize = 1;
//        rows =         (
//                        {
//                            createDate = 1416292969000;
//                            id = 128;
//                            user =                 {
//                                id = 269;
//                                name = test11;
//                            };
//                        }
//                        );
//        total = 1;
//    };
//}
@end
