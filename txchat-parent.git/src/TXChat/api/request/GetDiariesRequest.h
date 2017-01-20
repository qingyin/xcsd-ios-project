 

#import "BaseRequest.h"

@interface GetDiariesRequest : BaseRequest
//    参数	类型	说明
//    token	string	用户唯一标示
//    childID	int	孩子
//    lastID	上一页最后一个ID，第一页为0
//    size	int	每一页的大小
@property NSString *token;
@property NSString *childID;
@property NSString* lastID;
@property NSInteger size;
@property NSInteger ver;
@end
