

#import "BaseJSONModel.h"

#define kSchoolAge6 @"6"
#define kSchoolAge7 @"7"

#define kSchoolAge0 @"1"
#define kSchoolAge1 @"2"
#define kSchoolAge2 @"3"
#define kSchoolAge3 @"4"
#define kSchoolAge4 @"5"


@protocol SchoolAgeInfo
@end

@interface SchoolAgeInfo : BaseJSONModel

//               {
//                   "value": 1,
//                   "name": "幼儿园大班"
//               },
@property NSString *value;
@property NSString *name;
@end



//{
//    "name":
//    "幼儿园小班",
//    "value":
//    6
//},
//{
//    "name":
//    "幼儿园中班",
//    "value":
//    7
//},
//{
//    "name":
//    "幼儿园大班",
//    "value":
//    1
//},
//{
//    "name":
//    "小学一年级",
//    "value":
//    2
//},
//{
//    "name":
//    "小学二年级",
//    "value":
//    3
//},
//{
//    "name":
//    "小学三年级",
//    "value":
//    4
//},
//{
//    "name":
//    "小学四年级",
//    "value":
//    5
//}

