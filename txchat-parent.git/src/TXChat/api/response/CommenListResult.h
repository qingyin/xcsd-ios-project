

#import "BaseJSONModel.h"
#import "CommentInfo.h"

@interface CommenListResult : BaseJSONModel

@property NSInteger total;


@property NSArray<CommentInfo>* rows;

@end
