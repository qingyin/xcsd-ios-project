

#import "BaseJSONModel.h"
#import "SchoolAgeInfo.h"

// childType	byte	1表示可操作的孩子，2表示观察的孩子,0返回全部
#define kChildTypeAll 0
#define kChildTypeWritable 1
#define kChildTypeReadable 2

//孩子性别 1(male) ,2(female)
#define kChildGenderMale @"1"
#define kChildGenderFemale @"2"


//血型1(A), 2 (B),3(O),(4)AB,(5)other
#define kChildBloodA @"1"
#define kChildBloodB @"2"
#define kChildBloodO @"3"
#define kChildBloodAB @"4"
#define kChildBloodOther @"5"


@protocol ChildInfo

@end

@interface ChildInfo : BaseJSONModel
//{
    //                      birthday = 1407211200000;
    //                      blood = 0;
    //                      childName = "\U6d4b\U8bd5";
    //                      childType = 1;
    //                      gender = 2;
    //                      id = 257;
    //                      parent = test;
    //                      picture = "";
    //                      relation = daughter;
    //                      schoolAge =             {
    //                          name = "\U5c0f\U5b66\U56db\U5e74\U7ea7";
    //                          value = 5;
    //                      };
    //                      userID = 132;
    //                  },

@property NSDate* birthday;


//血型1(A), 2 (B),3(O),(4)AB,(5)other
@property NSString* blood;

@property NSString* childName;

@property NSInteger childType;

//孩子性别 1(male) ,2(female)
@property NSString* gender;

@property NSString* id;

@property NSString* parent;

@property NSString<Optional>* picture;

@property NSString<Optional>* relation;


@property SchoolAgeInfo* schoolAge;

@property NSString* schoolName;
@property NSString* realName;
@end
