

#import "BaseJSONModel.h"
#import "DistrictInfo.h"
#import "ProvinceInfo.h"
#import "CityInfo.h"

@interface LoginResult : BaseJSONModel

//{
    //        "token": "CePPKt6S6m8XGp4nhCeKdybIlvMWc9Vnfq35QgDy1VCuzymXjw4oR8iJZg/BOuFIoXZ3mSbScT/Bgq/KRh1l4A==",
    //        "districtID": 711,
    //        "districtName": "新华区",
    //        "provinceID": 8,
    //        "provinceName": "河北",
    //        "cityID": 292,
    //        "cityName": "石家庄"
    //    }

@property NSString *token;
@property NSInteger districtID;
@property NSString *districtName;
@property NSInteger provinceID;
@property NSString *provinceName;
@property NSInteger cityID;
@property NSString *cityName;
//@property DistrictInfo *district;
//@property CityInfo *city;
//@property ProvinceInfo *province;



@property NSDate* birthDay;

//孩子性别 1(male) ,2(female)
@property NSString* gender;

@property NSString* nickName;

@property NSString* pic;

@property NSString* userName;

@end
