

#import "BaseRequest.h"

@interface GetCategoryFirstRequest : BaseRequest

//参数	类型	说明
//token	string	用户唯一标示
//schoolAge	byte	学龄（为0时返回所有一级分类）1：幼儿园大班，2：小学一年级，3：小学二年级，4：小学三年级，5：小学四年级

//@property NSString* token;
@property NSString* schoolAge;

@end
