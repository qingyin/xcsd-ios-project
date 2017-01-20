

#import "BaseJSONModel.h"

#import "MemberInfo.h"

@protocol FavorInfo
@end

@interface FavorInfo : BaseJSONModel

@property NSDate* createDate;
@property NSString* id;
@property MemberInfo* user;

//{
    //                     "createDate": 1422337780000,
    //                     "id": 428,
    //                     "user": {
    //                         "id": 132,
    //                         "name": "test"
    //                     }
    //                 }
@end
