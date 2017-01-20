

#import "BaseRequest.h"

@interface UpdateDiaryRequest : BaseRequest

@property NSString* diaryID;
@property NSString<Optional>* diary;
@property NSString<Optional>* picUrl;



//参数	类型	说明
//token	string	用户唯一标示
//diaryID	int	日记ID
//diary（可选）	string	日记内容（最多4000个字符）
//picUrl（可选）	string	图片地址

@end
