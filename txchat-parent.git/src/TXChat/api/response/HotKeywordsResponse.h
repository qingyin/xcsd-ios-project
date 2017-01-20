

#import "BaseResponse.h"

#import "HotKeywordInfo.h"

@interface HotKeywordsResponse : BaseResponse

@property NSArray<HotKeywordInfo>* result;

//{
//    "errorCode":
//    0,
//    "message":
//    "Success",
//    "result":
//    [
//    {
//        "word":
//        "游戏关键词1"
//    },
//    {
//        "word":
//        "游戏关键词2"
//    },
//    {
//        "word":
//        "游戏关键词3"
//    }
//     ]
//}
@end
