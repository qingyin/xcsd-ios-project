 

#import "BaseJSONModel.h"

@interface BaseRequest : BaseJSONModel

@property NSString *source;

@property NSString<Optional>* token;

@property NSString* deviceID;

@end
