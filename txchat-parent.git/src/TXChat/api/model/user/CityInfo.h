

#import "BaseJSONModel.h"
#import "DistrictInfo.h"

@protocol CityInfo

@end

@interface CityInfo : BaseJSONModel


@property NSInteger id;
@property NSString* name;

@property NSArray<DistrictInfo,Optional>* districts;

@end
