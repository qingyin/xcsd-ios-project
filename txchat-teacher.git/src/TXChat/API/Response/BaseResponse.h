
#import "BaseJSONModel.h"

@interface BaseResponse : BaseJSONModel

//errorCode	message
//0	success
//500	未知错误
//401	找不到对象
//402	数据重复插入
//600	Token过期   （需要重新登录）
//601	用户名或密码错误
//602	加密算法验证失败
//603	用户名或密码未输入
//604	用户名已存在
//701	没有操作权限

//702   您的账号已在其他设备上登录,请重新登录

#define kErrorCodeUserExist @"604"

//#define kErrorCodeOffline @"702"

@property NSString* errorCode;
@property NSString<Optional>* message;

@property(strong) NSError* error;

-(BOOL)isSuccess;
-(BOOL)isTokenExpired;
@end
