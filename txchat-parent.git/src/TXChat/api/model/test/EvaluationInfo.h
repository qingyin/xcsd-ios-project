 

#import "BaseJSONModel.h"
#import "SocialArticleInfo.h"

#import "AuthorityInfo.h"

#define kEvaluationTypeGood @"1"
#define kEvaluationTypeBad @"2"


@interface EvaluationInfo : BaseJSONModel


@property NSString *evaluationType;

@property NSString* description;
@property NSString* id;
@property SocialArticleInfo<Optional>* socialArticle;

@property AuthorityInfo* authority;

@property NSInteger testSerialNumber;

//{ evaluationType = 2;
    //        description = "";
    //        id = 25;
    //        socialArticle =         {
    //            content = "";
    //            createTime = "2014-06-26 02:51:33";
    //            id = 4;
    //            introduction = "";
    //            title = "";
    //            updateTime = "2014-06-26 02:51:33";
    //        };
//authority =         {
//    author = "\U738b\U53cc\U5b8f";
//    createTime = "2014-06-25 05:35:02";
//    detail = "";
//    id = 27;
//    introduction = "";
//    journalName = "\U5f53\U4ee3\U6559\U80b2\U79d1\U5b66";
//    keywords = "\U6301\U7eed\U5b66\U4e60\U80fd\U529b\Uff1b\U5185\U90e8\U7ed3\U6784\Uff1b\U5929\U6027\Uff1b\U9002\U5ea6";
//    summary = "\U4e2d\U5c0f\U5b66\U751f\U6301\U7eed\U5b66\U4e60\U80fd\U529b\U7684\U57f9\U517b\Uff0c\U662f\U201c\U77e5\U60c5\U610f\U884c\U201d\U5168\U9762\U534f\U8c03\U53d1\U5c55\U7684\U7ed3\U679c\Uff0c\U662f\U5b66\U4e60\U4e3b\U4f53 \U201c\U51b3\U7b56\U7cfb\U7edf\U201d\U548c\U201c\U6267\U884c\U7cfb\U7edf\U201d\U548c\U8c10\U7edf\U4e00\U7684\U7ed3\U679c\U3002\U5173\U5207\U6301\U7eed\U5b66\U4e60\U80fd\U529b\U7684\U57f9\U517b\Uff0c\U5fc5\U987b\U4ece\U5c0a\U91cd\U5b66\U4e60\U8005\U81ea\U8eab\U5185\U90e8\U7ed3\U6784\U7684\U5168\U9762\U548c\U8c10\U53d1\U5c55\U505a\U8d77\U3002";
//    title = " \U5173\U5207\U513f\U7ae5\U6301\U7eed\U6027\U5b66\U4e60\U80fd\U529b\U7684\U57f9\U517b";
//    updateTime = "2014-06-25 17:35:02";
//};
@end
