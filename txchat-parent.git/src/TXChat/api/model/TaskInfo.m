

#import "TaskInfo.h"



@implementation TaskInfo

@synthesize description=_description;

-(NSString*)description
{
    return _description;
}
-(void)setDescription:(NSString *)description
{
    _description = description;
}
@end
