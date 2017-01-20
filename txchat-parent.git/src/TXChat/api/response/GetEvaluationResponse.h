

#import "BaseResponse.h"
#import "EvaluationInfo.h"

@interface GetEvaluationResponse : BaseResponse

@property EvaluationInfo<Optional>* result;

//{
//    errorCode = 0;
//    message = Success;
//    result =     {
//        description = "";
//        id = 25;
//        socialArticle =         {
//            content = "";
//            createTime = "2014-06-26 02:51:33";
//            id = 4;
//            introduction = "";
//            title = "";
//            updateTime = "2014-06-26 02:51:33";
//        };
//    };
//}


@end
