

#import "BaseJSONModel.h"

#import "CityInfo.h"

@protocol ProvinceInfo

@end

@interface ProvinceInfo : BaseJSONModel

@property NSInteger id;
@property NSString* name;

@property NSArray<CityInfo,Optional>* cities;

@end
