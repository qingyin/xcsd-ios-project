

#import "BaseResponse.h"

#import "ChildInfo.h"

@interface GetChildListResponse : BaseResponse

//{
//    errorCode = 0;
//    message = Success;
//    result =     (
//                  {
//                      birthday = 1407211200000;
//                      blood = 0;
//                      childName = "\U6d4b\U8bd5";
//                      childType = 1;
//                      gender = 2;
//                      id = 257;
//                      parent = test;
//                      picture = "";
//                      relation = daughter;
//                      schoolAge =             {
//                          name = "\U5c0f\U5b66\U56db\U5e74\U7ea7";
//                          value = 5;
//                      };
//                      userID = 132;
//                  },
//                  {
//                      birthday = 1407211200000;
//                      blood = 0;
//                      childName = "\U6d4b\U8bd5";
//                      childType = 1;
//                      gender = 2;
//                      id = 256;
//                      parent = test;
//                      picture = "";
//                      relation = daughter;
//                      schoolAge =             {
//                          name = "\U5c0f\U5b66\U56db\U5e74\U7ea7";
//                          value = 5;
//                      };
//                      userID = 132;
//                  }
//                  );
//}

@property NSArray<ChildInfo,Optional>* result;

@end
