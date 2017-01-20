 

#import "BaseJSONModel.h"

@protocol CategoryFirstInfo
@end

@interface CategoryFirstInfo : BaseJSONModel

// animalPic = "http://resource.bobzhou.cn/pic/24/2444cbc35693efd693955599c8f17f8a.PNG";
//color = 5;
//colorValue = a1e4ff;
//id = 22;
//name = "\U56db\U5e74\U7ea7\U8eab\U5fc3\U5065\U5eb7";
//schoolAge = 5;
//type = 4;

@property NSString* animalPic;
@property NSString* colorValue;

//1绿色，2深蓝色，3黄色，4红色，5蓝色,6紫色，7橙色
//@property NSInteger color;
@property NSString* id;
@property NSString* name;
@property NSString* schoolAge;

//任务类型,1自我发展,猫. 2社会交往,狗. 3智力开发,海豚. 4身心健康,兔子. 5习惯养成,猴子. 6品格塑造,羊. 7责任意识,虎. 8思维训练,蛇.
//@property NSInteger type;
@end
