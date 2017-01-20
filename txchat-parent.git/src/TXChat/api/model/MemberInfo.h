

#import "BaseJSONModel.h"

@protocol  MemberInfo
@end

@interface MemberInfo : BaseJSONModel

//id = 132;
//name = test;
//nickName = "ha\U54c8\U5475\U5475";
//picUrl = "http://resource.elooking.cn/pic/3e/3e50456f7b2487ceab5e99bb9693dc.jpg";

@property NSString* id;
@property NSString* name;

@property NSString* nickName;
@property NSString* picUrl;


@end
