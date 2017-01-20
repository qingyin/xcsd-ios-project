

#import "BaseRequest.h"

@interface GetEvaluationTasksRequest : BaseRequest

//    参数	类型	说明
//    token	string	用户唯一标示
//    evaluationID	int	评价ID
//    childID	int	孩子ID

//@property NSString* token;

@property NSString* childID;

@property NSString* evaluationID;

@end
