
#import "BaseResponse.h"

#import "TaskInfo.h"

@interface GetTasksResponse : BaseResponse

    
@property NSArray<TaskInfo,Optional>* result;

//{
//    errorCode = 0;
//    message = Success;
//    result =     (
//                  {
//                      color = 3;
//                      count = "2\Uff0d3\U4eba";
//                      createTime = "<null>";
//                      description = "\U5728\U964c\U751f\U7684\U9152\U5e97\U91cc\U9080\U8bf7\U8001\U5927\U72ec\U7acb\U5b8c\U6210\U89c4\U5b9a\U7684\U4efb\U52a1\Uff0c\U953b\U70bc\U65b9\U4f4d\U611f\Uff0c\U57f9\U517b\U8001\U5927\U7684\U7a7a\U95f4\U80fd\U529b\U548c\U72ec\U7acb\U601d\U8003\U4e0e\U884c\U52a8\U7684\U80fd\U529b\U3002";
//                      detail = "1.\U5168\U5bb6\U4eba\U4e00\U8d77\U5230\U5927\U5802\Uff0c\U6b63\U5f0f\U7684\U544a\U8bc9\U8001\U5927\U8bf7\U5979\U5b8c\U6210\U4efb\U52a1\U6e05\U5355\U4e0a\U7684\U8981\U6c42\Uff1b
//                      \n2.\U5b8c\U6210\U540e\U8001\U5927\U62ff\U5230\U6240\U6709\U7269\U54c1\U56de\U5230\U5927\U5802\U4ea4\U7ed9\U6536\U8d27\U4eba\Uff08\U53ef\U4ee5\U662f\U5bb6\U91cc\U5176\U4ed6\U4eba\U626e\U6f14\Uff09\U6838\U5bf9\Uff1b
//                      \n3.\U6838\U5bf9\U7269\U54c1\U540e\Uff0c\U95ee\U95ee\U8001\U5927\U4efb\U52a1\U8fc7\U7a0b\U4e2d\U6709\U54ea\U4e9b\U6709\U8da3\U7684\U4e8b\U6216\U9047\U5230\U4e86\U4ec0\U4e48\U56f0\U96be\U3002
//                      \n";
//                      diary = "<null>";
//                      evaluation =             {
//                          description = "\U5728\U6570\U5b66\U5b66\U4e60\U4e0a\Uff0c\U8001\U5927\U6682\U65f6\U8fd8\U6bd4\U8f83\U7f3a\U5c11\U65b9\U6cd5\U548c\U7b56\U7565\Uff0c\U5f53\U7136\U5728\U76ee\U524d\U7684\U5b66\U4e60\U4e2d\U53ef\U80fd\U8fd8\U6ca1\U6709\U4ec0\U4e48\U56f0\U96be\Uff0c\U4f46\U968f\U7740\U5e74\U7ea7\U5347\U9ad8\U6570\U5b66\U96be\U5ea6\U52a0\U5927\Uff0c\U5982\U679c\U7f3a\U5c11\U5b66\U4e60\U7b56\U7565\Uff0c\U4f1a\U6781\U5927\U7684\U589e\U52a0\U5b69\U5b50\U7684\U5b66\U4e60\U8d1f\U62c5\U3002\U4e0b\U9762\U6709\U4e00\U4e9b\U5c0f\U6e38\U620f\Uff0c\U5e2e\U52a9\U8001\U5927\U63d0\U9ad8\U903b\U8f91\U601d\U7ef4\U80fd\U529b\Uff0c\U4fc3\U8fdb\U4e3b\U52a8\U601d\U8003\U548c\U591a\U89d2\U5ea6\U5f52\U7eb3\U7684\U80fd\U529b\Uff0c\U5bf9\U6570\U5b66\U5b66\U4e60\U6709\U5e2e\U52a9\U54e6\Uff0c\U5feb\U6765\U4e00\U8d77\U73a9\U73a9\U770b\U5427\U3002";
//                          id = 25;
//                          socialArticle = "<null>";
//                      };
//                      finishDate = "<null>";
//                      id = 78;
//                      lookOut = "1.\U4e3a\U5b89\U5168\U8d77\U89c1\Uff0c\U4f60\U53ef\U4ee5\U5168\U7a0b\U8ddf\U7740\U8001\U5927\Uff0c\U4f46\U662f\U4f60\U4e0d\U80fd\U7ed9\U5979\U4efb\U4f55\U5e2e\U52a9\Uff1b
//                      \n2.\U4efb\U52a1\U5b8c\U6210\U540e\Uff0c\U53ca\U65f6\U80af\U5b9a\U8001\U5927\U4ed8\U51fa\U7684\U52aa\U529b\Uff0c\U53ef\U4ee5\U5f15\U5bfc\U8be2\U95ee\Uff1a\U5982\U679c\U518d\U6765\U4e00\U6b21\Uff0c\U4f1a\U600e\U4e48\U505a\U554a\Uff1f
//                      \n3.\U7ed3\U675f\U540e\U4e5f\U53ef\U4ee5\U8ba9\U8001\U5927\U7ed9\U7238\U7238\U6216\U5988\U5988\U8bbe\U8ba1\U4efb\U52a1\U7ee7\U7eed\U73a9\Uff0c\U4efb\U52a1\U53ef\U4ee5\U5168\U5bb6\U4e00\U8d77\U8ba8\U8bba\U3002
//                      \n";
//                      name = "\U771f\U5b9e\U7684\U8ff7\U5bab";
//                      observation = "1.\U8001\U5927\U5b8c\U6210\U4efb\U52a1\U8fc7\U7a0b\U4e2d\U80fd\U4e0d\U80fd\U7528\U4e00\U4e9b\U65b9\U6cd5\Uff1a\U6bd4\U5982\U6307\U793a\U724c\U3001\U627e\U4eba\U8be2\U95ee\U3001\U501f\U52a9\U5730\U56fe\U7b49\U3002\U4efb\U52a1\U7ed3\U675f\U540e\U53ef\U4ee5\U63d0\U793a\Uff0c\U8ba9\U5979\U5728\U4e0b\U6b21\U4efb\U52a1\U4e2d\U8bd5\U8bd5\Uff1b
//                      \n2.\U8001\U5927\U4f1a\U4e0d\U4f1a\U8bb0\U5f97\U4e4b\U524d\U8d70\U8fc7\U7684\U8def\Uff1f\U53ef\U4ee5\U5f15\U5bfc\U5979\U501f\U52a9\U4e00\U4e9b\U6807\U5fd7\U6027\U4e8b\U7269\U8fdb\U884c\U8bb0\U5fc6\U3002
//                      \n";
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
//                  );
//}
@end
