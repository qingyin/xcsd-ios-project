
#import "BaseResponse.h"
#import "SchoolAgeInfo.h"

@interface GetSchoolAgesResponse : BaseResponse
//{
//    
//    "errorCode": 0,
//    "message": "Success",
//    "result": [
//               {
//                   "value": 1,
//                   "name": "幼儿园大班"
//               },

@property NSArray<SchoolAgeInfo,Optional>* result;
@end
