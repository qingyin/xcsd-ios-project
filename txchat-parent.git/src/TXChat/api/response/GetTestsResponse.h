 

#import "BaseResponse.h"
#import "TestInfo.h"

@interface GetTestsResponse : BaseResponse


@property TestInfo<Optional> *result;

//{
//    errorCode = 0;
//    message = Success;
//    result =     {
//        description = "\U5b66\U4e60\U662f\U6709\U65b9\U6cd5\U7684\Uff0c\U5c24\U5176\U662f\U6570\U5b66\Uff0c\U4f60\U5e0c\U671b\U5b69\U5b50\U4e8b\U534a\U529f\U500d\U5417\Uff1f\U5feb\U95ee\U95ee\U6d4b\U8bd5\U5b66\U4e60\U6570\U5b66\U6709\U6ca1\U6709\U65b9\U6cd5\U5427\U3002\U6839\U636e\U5979\U7684\U56de\U7b54\Uff0c\U9009\U62e9\U76f8\U5e94\U7684\U7b54\U6848\U3002\U5982\U679c\U6d4b\U8bd5\U5b8c\U5168\U505a\U4e0d\U5230\Uff0c\U9009\U201c\U6211\U5b8c\U5168\U4e0d\U8fd9\U6837\U201d\Uff0c\U5982\U679c\U603b\U662f\U80fd\U505a\U5230\Uff0c\U9009\U201c\U6211\U591a\U6570\U662f\U8fd9\U6837\U201d\U3002";
//        id = 18;
//        name = "\U56db\U5e74\U7ea7\U6d4b\U8bd5\U80fd\U5b66\U597d\U6570\U5b66\U5417\Uff1f";
//        subjects =         (
//                            {
//                                id = 26;
//                                num = 1;
//                                options =                 (
//                                                           {
//                                                               id = 1;
//                                                               optionName = "\U5b8c\U5168\U4e0d\U8fd9\U6837";
//                                                           },
//                                                           {
//                                                               id = 2;
//                                                               optionName = "\U591a\U6570\U4e0d\U8fd9\U6837";
//                                                           },
//                                                           {
//                                                               id = 3;
//                                                               optionName = "\U6709\U65f6\U5019\U8fd9\U6837";
//                                                           },
//                                                           {
//                                                               id = 4;
//                                                               optionName = "\U591a\U6570\U662f\U8fd9\U6837";
//                                                           },
//                                                           {
//                                                               id = 5;
//                                                               optionName = "\U5b8c\U5168\U662f\U8fd9\U6837";
//                                                           }
//                                                           );
//                                subject = "\U65b0\U5b66\U7684\U6982\U5ff5\U5f88\U96be\U7406\U89e3\U65f6\Uff0c\U6d4b\U8bd5\U80fd\U591f\U4e3b\U52a8\U53bb\U56de\U5fc6\U8001\U5e08\U5728\U6559\U5b66\U65f6\U6240\U4e3e\U7684\U4f8b\U5b50\U3002";
//                            },
//                            
//                            );
//    };
//}
@end
