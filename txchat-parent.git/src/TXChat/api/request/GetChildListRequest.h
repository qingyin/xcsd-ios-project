

#import "BaseRequest.h"



@interface GetChildListRequest : BaseRequest

//@property NSString* token;

// childType	byte	1表示可操作的孩子，2表示观察的孩子,0返回全部
@property NSInteger childType;
@property NSInteger ver;
@end
