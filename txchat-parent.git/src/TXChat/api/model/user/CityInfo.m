 
#import "CityInfo.h"

@implementation CityInfo

-(BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CityInfo *other = (CityInfo *)object;
    
    BOOL equal = (other.id == self.id);
    return equal;
}


@end
