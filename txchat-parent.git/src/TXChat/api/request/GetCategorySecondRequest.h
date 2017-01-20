 

#import "BaseRequest.h"

@interface GetCategorySecondRequest : BaseRequest

//参数	类型	说明
//token	string	用户唯一标示
//cf	int	一级分类ID
//childID	int	孩子ID

//@property NSString* token;
@property NSString* cf;
@property NSString* childID;


@end
