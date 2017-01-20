

#import "BaseRequest.h"

@interface AddDiaryRequest : BaseRequest

//    参数	类型	说明
//    token	string	用户唯一标示
//    childID	int	孩子ID
//    diary	string	日记内容（最多4000个字符）
//    picUrl（可选）	string	图片
//    childTaskID（可选）	int	任务ID

@property NSString* childID;
@property NSString* diary;
@property NSString<Optional>* picUrl;
@property NSString<Optional>* taskID;

@end
