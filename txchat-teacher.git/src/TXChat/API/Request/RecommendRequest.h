

#import "BaseRequest.h"

@interface RecommendRequest : BaseRequest

@property NSString* productType;
@property NSInteger num;
//参数	类型	说明
//token	string	用户唯一标示
//productType	byte	产品类型(1.酒店。2.门票。3.团购)
//num	byte	返回产品数量（小于500）

@end
