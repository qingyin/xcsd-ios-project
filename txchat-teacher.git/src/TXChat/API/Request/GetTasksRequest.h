

#import "BaseRequest.h"

@interface GetTasksRequest : BaseRequest

//    参数	类型	说明
//    token	string	用户唯一标示
//    childID	int	孩子ID
//    status	byte(可选,默认为全部)	状态（1表示任务已添加，2表示任务开始，3表示任务已结束）


//@property NSString* token;

@property NSString* childID;

@property NSString<Optional>* status;


@end
