

#import "BaseJSONModel.h"


@protocol SocialArticleInfo
@end

@interface SocialArticleInfo : BaseJSONModel
@property NSString* content;
@property NSString* createTime;
@property NSString* id;
@property NSString* introduction;
@property NSString* title;
@property NSString* updateTime;

@property NSString* associateTag;
@property NSString* tag;
@property NSString* pic;

@property NSInteger commentCount;
@property NSInteger upCount;
@property BOOL up;
//{
    //            content = "";
    //            createTime = "2014-06-26 02:51:33";
    //            id = 4;
    //            introduction = "";
    //            title = "";
    //            updateTime = "2014-06-26 02:51:33";
    //        };


//{
//    "associateTag":
//    "",
//    "id":
//    5,
//    "introduction":
//    "你会不会担心，lucy的注意力不集中、总爱东张西望，学东西比别的孩子慢怎么办？ 今天就介绍几招对容易分心的孩子依旧适用的学习策略，可以在这些方面多多观察和思考哦！",
//    "pic":
//    null,
//    "tag":
//    "tag4;tag5;tag6",
//    "title":
//    "容易分心？针对性策略让您的孩子更出色！"
//},
@end
