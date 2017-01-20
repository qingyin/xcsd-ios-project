

#import "BaseJSONModel.h"
#import "TestOptionInfo.h"

@protocol TestSubjectInfo

@end

@interface TestSubjectInfo : BaseJSONModel

@property NSString* id;
@property NSInteger num;
@property NSString* subject;
@property NSArray<TestOptionInfo>* options;

//{
    //                                id = 26;
    //                                num = 1;
    //                                options =                 (
    //                                                           {
    //                                                               id = 1;
    //                                                               optionName = "\U5b8c\U5168\U4e0d\U8fd9\U6837";
    //                                                           },
    //                                                           {
    //                                                               id = 2;
    //                                                               optionName = "\U591a\U6570\U4e0d\U8fd9\U6837";
    //                                                           },
    //                                                           {
    //                                                               id = 3;
    //                                                               optionName = "\U6709\U65f6\U5019\U8fd9\U6837";
    //                                                           },
    //                                                           {
    //                                                               id = 4;
    //                                                               optionName = "\U591a\U6570\U662f\U8fd9\U6837";
    //                                                           },
    //                                                           {
    //                                                               id = 5;
    //                                                               optionName = "\U5b8c\U5168\U662f\U8fd9\U6837";
    //                                                           }
    //                                                           );
    //                                subject = "\U65b0\U5b66\U7684\U6982\U5ff5\U5f88\U96be\U7406\U89e3\U65f6\Uff0c\U6d4b\U8bd5\U80fd\U591f\U4e3b\U52a8\U53bb\U56de\U5fc6\U8001\U5e08\U5728\U6559\U5b66\U65f6\U6240\U4e3e\U7684\U4f8b\U5b50\U3002";
    //                            },

@end
