
#import "BaseJSONModel.h"

@protocol VacationInfo
@end

@interface VacationInfo : BaseJSONModel

@property NSString* vacationId;
@property NSString* vacationPic;

@property NSString* vacationPrice;
@property NSString* vacationPriceTag;

@property NSString* vacationTag;
@property NSString* vacationTitle;

@property NSString* vacationUrl;

@end
