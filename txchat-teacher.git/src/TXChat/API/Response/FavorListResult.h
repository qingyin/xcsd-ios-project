 

#import "BaseJSONModel.h"
#import "FavorInfo.h"

@interface FavorListResult : BaseJSONModel
@property NSInteger total;
@property NSArray<FavorInfo>* rows;
//{
//    "errorCode": 0,
//    "message": "Success",
//    "result": {
//        "pageSize": 1,
//        "rows": [
//                 {
//                     "createDate": 1422337780000,
//                     "id": 428,
//                     "user": {
//                         "id": 132,
//                         "name": "test"
//                     }
//                 }
//                 ],
//        "total": 1
//    }
//}
@end
