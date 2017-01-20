

#import "BaseResponse.h"
#import "RecommendInfo.h"

@interface RecommendResponse : BaseResponse

@property NSArray<RecommendInfo,Optional>* result;

@end
