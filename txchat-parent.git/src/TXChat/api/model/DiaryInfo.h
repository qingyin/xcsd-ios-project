
#import "BaseJSONModel.h"

/** 1-任务型日记 4-taskID*/
#define kDiaryTypeTask @"4"
#define kDiaryTypeNormal @"2"
#define kDiaryTypeTest @"3"


@protocol DiaryInfo
@end

@interface DiaryInfo : BaseJSONModel

@property NSString* userID;
@property NSString* userName;
@property NSString* userNickName;
@property NSString* userProfileUrl;

@property NSString* childID;
@property NSString* childName;
@property NSString* childPic;

@property NSString* schoolAge;

//{
//    childTaskID = 1873;
//    color = 5;
//    colorValue = a1e4ff;
//    diary = 11111111111;
//    diaryType = 1;
//    id = 269;
//    picUrl = "http://resource.bobzhou.cn/pic/bb/bb36ca9d857141c5c96918df5af545c.jpg";
//    taskName = "<null>";
//    title = "\U5c0f\U563f\U563f\U6b63\U5728\U505a'\U4f60\U505a\U6211\U731c'\U4efb\U52a1!";
//    updateTime = 1408655387000;
//"upCount":0,
//"commentCount":0
//}

@property NSString* diaryType;

@property NSString *colorValue;

@property NSString *childTaskID;

@property NSString *taskName;

//@property NSInteger color;
@property NSString<Optional>* diary;
@property NSString* id;
@property NSString<Optional>* picUrl;
@property NSString<Optional>* title;
@property NSDate* updateTime;

@property BOOL up;
@property NSInteger upCount;
@property NSInteger commentCount;
@end
