

#import "BaseRequest.h"

@interface AddChildRequest : BaseRequest

//@property NSString* token;

@property NSString* name;

@property NSString* schoolAge;

//孩子性别 1(male) ,2(female)
@property NSString* gender;

//血型1(A), 2 (B),3(O),(4)AB,(5)other
@property NSString<Optional>* blood;

@property NSString<Optional>* relation;

@property NSString<Optional>* picture;

@property NSDate* birthday;

/** 修改信息时使用 */
@property NSString<Optional>* id;


@property NSString* schoolName;
@property NSString* realName;
@end
