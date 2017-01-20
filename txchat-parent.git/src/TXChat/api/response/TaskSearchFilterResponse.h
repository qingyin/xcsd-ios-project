
#import "BaseResponse.h"
#import "TaskSearchFilterResult.h"

@interface TaskSearchFilterResponse : BaseResponse

@property TaskSearchFilterResult *result;

//{
//    "errorCode":
//    0,
//    "message":
//    "Success",
//    "result":
//    {
//        "countFilter":
//        [
//         "人数1",
//         "人数2",
//         "人数3"
//         ],
//        "sceneFilter":
//        [
//         "场景1",
//         "场景2",
//         "场景3"
//         ],
//        "subjectFilter":
//        [
//         "主题1",
//         "主题2",
//         "主题3"
//         ]
//    }
//}
@end
