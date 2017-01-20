
#import "BaseResponse.h"

@interface UploadPicResponse : BaseResponse

//{
//    errorCode = 0;
//    message = Success;
//    result = "http://resource.bobzhou.cn/b7/b79c7c9b17a44570adc8acf85838ac77.png";
//}

@property NSString<Optional>* result;

@end
