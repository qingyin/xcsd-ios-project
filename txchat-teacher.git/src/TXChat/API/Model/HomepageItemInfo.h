

#import "BaseJSONModel.h"

@protocol HomepageItemInfo
@end

#define kHomepageItemTypeArticle 1
#define kHomepageItemTypeTask 2

@interface HomepageItemInfo : BaseJSONModel

//{
//    "description":
//    "乐观开朗是一种积极、向上的情绪，如果孩子在生活、学习中都保持乐观的态度，保持活泼快乐的天性，那么他们在成长中会更懂得感恩、如何与他人相处、懂得如何面对困难。今天，我们一起来学习一下如何培养乐观活泼的宝宝吧。",
//    "displayCount":
//    null,
//    "displayScene":
//    null,
//    "displayTag":
//    null,
//    "id":
//    6,
//    "pic":
//    "",
//    "tag":
//    "tag1",
//    "title":
//    "不要埋没孩子的活泼天性哦！",
//    "type":
//    1
//},

@property NSString* id;
@property NSString* pic;
@property NSString* tag;
@property NSString* title;
@property NSInteger type;

@property NSString* description;
@property NSString* displayCount;
@property NSString* displayScene;
@property NSString* displayTag;
@end
