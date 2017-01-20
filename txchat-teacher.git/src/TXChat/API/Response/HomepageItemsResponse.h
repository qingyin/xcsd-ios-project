

#import "BaseResponse.h"
#import "HomepageItemInfo.h"

@interface HomepageItemsResponse : BaseResponse

@property NSArray<HomepageItemInfo>* result;
//{
//    "errorCode":
//    0,
//    "message":
//    "Success",
//    "result":
//    [
//    {
//        "id":
//        36,
//        "pic":
//        "",
//        "tag":
//        "",
//        "title":
//        "一年级小学生的心理发展及入学适应的几点讨论",
//        "type":
//        1
//    },
//    {
//        "id":
//        35,
//        "pic":
//        "",
//        "tag":
//        "",
//        "title":
//        "浅谈小学一年级新生规则意识的培养",
//        "type":
//        1
//    },
//    {
//        "id":
//        254,
//        "pic":
//        null,
//        "tag":
//        "",
//        "title":
//        "钓瓶子",
//        "type":
//        2
//    }
//     ]
//}
@end
