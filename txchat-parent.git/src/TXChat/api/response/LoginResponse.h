

#import "BaseResponse.h"
#import "LoginResult.h"

@interface LoginResponse : BaseResponse

//{
//    
//    "errorCode": 0,
//    "message": "Success",
//    "result": {
//        "token": "CePPKt6S6m8XGp4nhCeKdybIlvMWc9Vnfq35QgDy1VCuzymXjw4oR8iJZg/BOuFIoXZ3mSbScT/Bgq/KRh1l4A==",
//        "districtID": 711,
//        "districtName": "新华区",
//        "provinceID": 8,
//        "provinceName": "河北",
//        "cityID": 292,
//        "cityName": "石家庄"
//    }
//    
//}
@property LoginResult<Optional>* result;
@end
