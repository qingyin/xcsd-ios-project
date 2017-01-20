 

#import "BaseResponse.h"
#import "TestInfo.h"

@interface TestListResponse : BaseResponse


@property NSArray<TestInfo,Optional> *result;


@end
