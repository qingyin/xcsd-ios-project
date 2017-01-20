

#import "BaseRequest.h"

@interface UploadPicRequest : BaseRequest

@property NSString* base64Pic;
@property NSString* picFormat;

//参数	类型	说明
//token	string	用户唯一标示
//base64Pic	string	Base64编码后的图片
//picFormat	string	jpg/png/git

@end
