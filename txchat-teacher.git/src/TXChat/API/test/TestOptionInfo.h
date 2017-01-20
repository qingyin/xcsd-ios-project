 

#import "BaseJSONModel.h"

@protocol TestOptionInfo
@end

@interface TestOptionInfo : BaseJSONModel

//{
    //        id = 1;
    //        optionName = "\U5b8c\U5168\U4e0d\U8fd9\U6837";
    //                                                           },

@property NSString* id;
@property NSString* optionName;
@end
