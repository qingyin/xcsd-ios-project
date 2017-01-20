

#import "BaseResponse.h"

#import "SocialArticleInfo.h"

@interface SearchArticleResponse : BaseResponse

@property NSArray<SocialArticleInfo> *result;
//{
//    "errorCode":
//    0,
//    "message":
//    "Success",
//    "result":
//    [
//    {
//        "associateTag":
//        "",
//        "id":
//        5,
//        "introduction":
//        "你会不会担心，lucy的注意力不集中、总爱东张西望，学东西比别的孩子慢怎么办？ 今天就介绍几招对容易分心的孩子依旧适用的学习策略，可以在这些方面多多观察和思考哦！",
//        "pic":
//        null,
//        "tag":
//        "tag4;tag5;tag6",
//        "title":
//        "容易分心？针对性策略让您的孩子更出色！"
//    },
//    {
//        "associateTag":
//        "",
//        "id":
//        6,
//        "introduction":
//        "乐观开朗是一种积极、向上的情绪，如果孩子在生活、学习中都保持乐观的态度，保持活泼快乐的天性，那么他们在成长中会更懂得感恩、如何与他人相处、懂得如何面对困难。今天，我们一起来学习一下如何培养乐观活泼的宝宝吧。",
//        "pic":
//        null,
//        "tag":
//        "tag1;tag2;tag3",
//        "title":
//        "不要埋没孩子的活泼天性哦！"
//    },
//    {
//        "associateTag":
//        "",
//        "id":
//        4,
//        "introduction":
//        " 好奇与好问是儿童的天性。求知欲是人的探索精神的体现，是人类一切发现、发明和创造活动的精神动力。所以，不要因为孩子每天十几次的发问而呵斥，不要用一句“你自己查去”来敷衍，用正确的方法来维护和培养孩子的求知欲与好奇心，会让他拥有更多的财富哦！",
//        "pic":
//        null,
//        "tag":
//        "tag1;tag2;tag3",
//        "title":
//        "好奇与好问是孩子宝贵的财富哦！"
//    }
//     ]
//}
@end
