

#import "BaseResponse.h"
#import "DiaryInfo.h"

@interface GetDiaryResponse : BaseResponse

@property DiaryInfo<Optional>* result;

@end
