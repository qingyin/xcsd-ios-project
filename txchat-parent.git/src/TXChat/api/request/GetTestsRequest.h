

#import "BaseRequest.h"

@interface GetTestsRequest : BaseRequest

//参数	类型	说明
//token	string	用户唯一标示
//testID	int	测试ID
//childID	int	孩子ID

//@property NSString* token;
@property NSString* testID;
@property NSString* childID;

@end
