

#import "BaseRequest.h"

@interface AddTasksRequest : BaseRequest

//参数	类型	说明
//token	string	用户唯一标示
//childID	int	孩子ID
//tasks	string	任务ID，例如：1,2,3（英文逗号）

//@property NSString* token;

@property NSString* childID;

@property NSString<Optional>* tasks;

@property NSInteger ver;
@end
