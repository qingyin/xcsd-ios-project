

#import "BaseJSONModel.h"

@protocol RecommendInfo
@end

@interface RecommendInfo : BaseJSONModel



//{
//    detailUrl = "http://m.ctrip.com/webapp/ticket/dest/t141731.html?allianceID=19208&sid=448166&ext=a%3D1%26b%3D2%26c%3D3";
//    location = "";
//    picUrl = "<null>";
//    title = "\U4ed9\U897f\U5c71";
//    type = 2;
//},

@property NSString* detailUrl;
@property NSString<Optional>* picUrl;
@property NSString* title;
@property NSString* type;

@property NSString* location;
@end
