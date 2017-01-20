

#import "BaseJSONModel.h"
#import "TestSubjectInfo.h"

@protocol TestInfo
@end

#define kTestStatusFinish 1

@class XCSDTestInfo;

@interface TestInfo : BaseJSONModel

//description = "\U5b66\U4e60\U662f\U6709\U65b9\U6cd5\U7684\Uff0c\U5c24\U5176\U662f\U6570\U5b66\Uff0c\U4f60\U5e0c\U671b\U5b69\U5b50\U4e8b\U534a\U529f\U500d\U5417\Uff1f\U5feb\U95ee\U95ee\U6d4b\U8bd5\U5b66\U4e60\U6570\U5b66\U6709\U6ca1\U6709\U65b9\U6cd5\U5427\U3002\U6839\U636e\U5979\U7684\U56de\U7b54\Uff0c\U9009\U62e9\U76f8\U5e94\U7684\U7b54\U6848\U3002\U5982\U679c\U6d4b\U8bd5\U5b8c\U5168\U505a\U4e0d\U5230\Uff0c\U9009\U201c\U6211\U5b8c\U5168\U4e0d\U8fd9\U6837\U201d\Uff0c\U5982\U679c\U603b\U662f\U80fd\U505a\U5230\Uff0c\U9009\U201c\U6211\U591a\U6570\U662f\U8fd9\U6837\U201d\U3002";
//        id = 18;
//        name = "\U56db\U5e74\U7ea7\U6d4b\U8bd5\U80fd\U5b66\U597d\U6570\U5b66\U5417\Uff1f";
//        subjects =

@property NSString* description;
@property NSString* id;
@property NSString* name;

@property NSString* associateTag;

@property NSString* animalPic;
@property NSInteger status;

@property NSString* colorValue;

@property NSArray<TestSubjectInfo>* subjects;

- (XCSDTestInfo *)changeIntoXCSDTestInfo;
+ (instancetype)fromXCSDTestInfo:(XCSDTestInfo *) xcsdTestInfo;

@end
