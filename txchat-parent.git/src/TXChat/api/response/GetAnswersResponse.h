
#import "BaseResponse.h"
#import "AnswerInfo.h"
@interface GetAnswersResponse : BaseResponse

@property NSArray<AnswerInfo,Optional>* result;

//{
//    errorCode = 0;
//    message = Success;
//    result =     (
//                  {
//                      option = 1;
//                      subjectID = 26;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 27;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 28;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 29;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 30;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 31;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 32;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 33;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 34;
//                  },
//                  {
//                      option = 1;
//                      subjectID = 35;
//                  }
//                  );
//}

@end
