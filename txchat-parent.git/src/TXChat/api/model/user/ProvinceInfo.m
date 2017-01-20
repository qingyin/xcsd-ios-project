

#import "ProvinceInfo.h"



@implementation ProvinceInfo


-(BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    ProvinceInfo *other = (ProvinceInfo *)object;
    
    BOOL equal = (other.id ==self.id);
    return equal;
}

@end
