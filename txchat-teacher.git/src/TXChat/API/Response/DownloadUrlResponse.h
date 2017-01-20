

#import "BaseResponse.h"
#import "DownloadUrlResponse.h"

@interface DownloadUrlResponse : BaseResponse
//{
//    errorCode = 0;
//    message = Success;
//    result =     {
//        url = "http://ec2-54-187-141-195.us-west-2.compute.amazonaws.com/tripeducation/service/download";
//    };
//}

//@property DownloadUrlResponse* result;
@property NSString<Optional>* url;


@end
