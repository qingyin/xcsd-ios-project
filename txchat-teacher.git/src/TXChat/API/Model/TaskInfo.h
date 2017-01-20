

#import "BaseJSONModel.h"
#import "EvaluationInfo.h"
#import "RecommendInfo.h"

//状态（1表示任务已添加，2表示任务开始，3表示任务已结束）
#define kTaskStatusNew 1
#define kTaskStatusStart 2
#define kTaskStatusFinish 3
#define kTaskStatusInit 0 //未添加

@protocol TaskInfo

@end

@interface TaskInfo : BaseJSONModel


//{"errorCode":0,"message":"Success","result":{"recommends":[{"type":1,"picUrl":"","title":"北京龙城华美达酒店","detailUrl":"http://m.ctrip.com/webapp/hotel/#detail?hotelid=846998&allianceid=19208&sid=448166&ouid=test"},{"type":1,"picUrl":"","title":"北京和园景逸大酒店","detailUrl":"http://m.ctrip.com/webapp/hotel/#detail?hotelid=533005&allianceid=19208&sid=448166&ouid=test"},{"type":1,"picUrl":"","title":"北京顺景温泉酒店","detailUrl":"http://m.ctrip.com/webapp/hotel/#detail?hotelid=512969&allianceid=19208&sid=448166&ouid=test"}],"childID":310,"childTaskID":2320,"color":3,"status":2,"name":"神奇的小棍","description":"摆放6-10根小棍，请{*Lucy*}记住位置并正确摆放，锻炼孩子的空间知觉感和记忆力。\r\n\r\n","schoolAge":5,"schoolAgeStr":null,"count":"2－5人","time":"单次1－3分钟，可循环玩；一周1－2次","finishDate":1409047912000,"tool":"&lt;p&gt;6~10&#26681;&#23567;&#26829;&lt;/p&gt;\r\n","toolUrl":"","detail":null,"lookOut":null,"observation":null,"picUrl":"","videoUrl":"http://v.youku.com/v_show/id_XNzYxMDc2MzIw.html","type":8,"shareUrl":"","createTime":1408601587000,"tag1":"","tag2":"","tag3":"亲子出游","productType":1}}

//@property NSString* childTaskID;

@property NSString* name;

//状态（1表示任务已添加，2表示任务开始，3表示任务已结束）
@property NSInteger status;

//@property NSInteger color;


//@property NSInteger type;

@property NSString* colorValue;
@property NSString* animalPic;
//{
//    animalPic = "http://resource.bobzhou.cnnull";
//    animalType = 8;
//    childTaskID = 2320;
//    color = 3;
//    colorValue = f0e972;
//    name = "\U795e\U5947\U7684\U5c0f\U68cd";
//    status = 2;
//}


@property NSString* count;//参加人数
@property NSString<Optional>* createTime;
@property NSString* description;
@property NSString* detail;
@property NSString<Optional>* diary;
@property EvaluationInfo* evaluation;
@property NSString<Optional>* finishDate;
//@property NSString* id;
@property NSString* lookOut;

@property NSString* observation;
@property NSString* picUrl;
@property NSArray<RecommendInfo,Optional>* recommends;
@property NSString* schoolAge;
@property NSString<Optional>* schoolAgeStr;
@property NSString* shareUrl;


@property NSString* tag1;
@property NSString* tag2;
@property NSString* tag3;
@property NSString* time;
@property NSString<Optional>* tips;
@property NSString* tool;

@property NSString* toolUrl;

@property NSString<Optional>* uploadPic;

@property NSString* videoUrl;
@property NSString* videoScript;

@property NSInteger star;

/** 专题 */
@property NSString *tag;
@property NSString *displayTag;

/** 人数 */
@property NSString* pCountStr;
@property NSString* displayCount;

/** 场景 */
@property NSString* sceneStr;
@property NSString* displayScene;

@property NSString* taskID;

@property NSString* associateTag;

//{
//    "childID":
//    760,
//    "childTaskID":
//    10038,
//    "color":
//    4,
//    "colorValue":
//    "ff8d6e",
//    "name":
//    "沙滩按摩",
//    "pCount":
//    0,
//    "pCountStr":
//    null,
//    "parentTaskID":
//    161,
//    "scene":
//    0,
//    "sceneStr":
//    null,
//    "star":
//    0,
//    "status":
//    1,
//    "tag":
//    "",
//    "taskID":
//    162
//},

//{
    //                      color = 3;
    //                      count = "2\Uff0d3\U4eba";
    //                      createTime = "<null>";
    //                      description = " ";
    //                      detail = " ";
    //                      diary = "<null>";
    //                      evaluation =             {
    //                          description = " ";
    //                          id = 25;
    //                          socialArticle = "<null>";
    //                      };
    //                      finishDate = "<null>";
    //                      id = 78;
    //                      lookOut = " ";
    //                      name = " ";
    //                      picUrl = "";
    //                      recommends =             (
    //                                                {
    //                                                    detailUrl = "http://m.ctrip.com/webapp/hotel/#detail?hotelid=533005&allianceid=19208&sid=448166&ouid=test";
    //                                                    picUrl = "";
    //                                                    title = "\U5317\U4eac\U548c\U56ed\U666f\U9038\U5927\U9152\U5e97";
    //                                                    type = 1;
    //                                                },
    //                                                {
    //                                                    detailUrl = "http://m.ctrip.com/webapp/hotel/#detail?hotelid=457145&allianceid=19208&sid=448166&ouid=test";
    //                                                    picUrl = "";
    //                                                    title = "\U5317\U4eac\U9f99\U9510\U5c71\U5e84\U5ea6\U5047\U9152\U5e97\Uff08\U539f\U8d22\U653f\U5c40\U4e03\U6e21\U8d22\U4f1a\U57f9\U8bad\U4e2d\U5fc3\Uff09";
    //                                                    type = 1;
    //                                                },
    //                                                {
    //                                                    detailUrl = "http://m.ctrip.com/webapp/hotel/#detail?hotelid=89&allianceid=19208&sid=448166&ouid=test";
    //                                                    picUrl = "";
    //                                                    title = "\U5317\U4eac\U4e91\U6e56\U5ea6\U5047\U6751";
    //                                                    type = 1;
    //                                                }
    //                                                );
//"childTaskID": 2325,
    //                      schoolAge = 5;
    //                      schoolAgeStr = "\U5c0f\U5b66\U56db\U5e74\U7ea7";
    //                      shareUrl = "";
    //                      status = 1;
    //                      tag1 = "";
    //                      tag2 = "";
    //                      tag3 = "\U4f11\U95f2\U5ea6\U5047";
    //                      time = "\U5355\U6b2120\Uff0d30\U5206\U949f\Uff0c\U4e00\U54681\U6b21\U3002";
    //                      tips = "<null>";
    //                      tool = "\U63d0\U524d\U5236\U4f5c\U4efb\U52a1\U6e05\U5355\U4e00\U4efd\Uff1a \U8bf7\U4f60\U53bb\U524d\U53f0\U8981\U4e00\U5f20\U996d\U5e97\U7b80\U4ecb\U3001\U5230\U5c0f\U5356\U90e8\U4e70\U4e00\U526f\U6251\U514b\U724c\U3001\U6e38\U6cf3\U6c60\U62ff\U4e00\U6761\U6bdb\U5dfe\U3001\U9910\U5385\U53d6\U4e00\U53cc\U7b77\U5b50\U3002\Uff08\U83b7\U5f97\U7269\U54c1\U7684\U987a\U5e8f\U53ef\U4ee5\U53d8\U5316\Uff09";
    //                      toolUrl = "";
    //                      type = 8;
    //                      uploadPic = "<null>";
    //                      videoUrl = "";
    //                  }

@end
