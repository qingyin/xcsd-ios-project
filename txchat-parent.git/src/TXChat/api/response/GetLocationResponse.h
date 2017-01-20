

#import "BaseResponse.h"

#import "GetLocationResult.h"

@interface GetLocationResponse : BaseResponse

@property GetLocationResult<Optional> *result;

//{
//    
//    "errorCode": 0,
//    "message": "Success",
//    "result": {
//        "provinces": [
//                      {
//                          "id": 1,
//                          "name": "北京",
//                          "cities": [
//                                     {
//                                         "id": 2,
//                                         "name": "北京",
//                                         "districts": [
//                                                       {
//                                                           "id": 1,
//                                                           "name": "西城区"
//                                                       },
@end
