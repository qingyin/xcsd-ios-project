

#import "BaseJSONModel.h"

@protocol CategorySecondInfo

@end

@interface CategorySecondInfo : BaseJSONModel

//{
    //                      categoryFirstID = 17;
    //                      color = 7;
    //                      id = 18;
    //                      name = "\U6d4b\U8bd5\U80fd\U5b66\U597d\U6570\U5b66\U5417\Uff1f";
    //                      status = 0;
    //                      testID = 18;
    //                  },

@property NSString *colorValue;
//@property NSInteger color;
@property NSString* id;
@property NSString* name;

 //测试状态，0未完成，1已完成
@property NSInteger status;

@property NSString* testID;

@end
