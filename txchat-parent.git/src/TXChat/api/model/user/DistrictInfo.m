

#import "DistrictInfo.h"

@implementation DistrictInfo
-(BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    DistrictInfo *other = (DistrictInfo *)object;
    
    BOOL equal = (other.id == self.id);
    return equal;
}

@end
