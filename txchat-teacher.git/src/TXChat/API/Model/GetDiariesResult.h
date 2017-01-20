 

#import "BaseJSONModel.h"
#import "DiaryInfo.h"

@interface GetDiariesResult : BaseJSONModel

@property NSInteger pageSize;
@property NSInteger total;
@property NSArray<DiaryInfo>* rows;

//{
    //        pageSize = 2;
    //        rows =         (
    //                        {
    //                            color = 5;
    //                            diary = "2014\U5e7408\U670807\U65e5 15\U65f645\U520658\U79d2";
    //                            id = 35;
    //                            picUrl = "<null>";
    //                            title = "<null>";
    //                            updateTime = 1407397662000;
    //                        },
    //                        {
    //                            color = 5;
    //                            diary = "\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566\U5566";
    //                            id = 34;
    //                            picUrl = "<null>";
    //                            title = "<null>";
    //                            updateTime = 1407397488000;
    //                        }
    //                        );
    //        total = 3;
    //    };
    
@end
