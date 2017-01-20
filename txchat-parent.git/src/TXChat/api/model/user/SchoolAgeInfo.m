

#import "SchoolAgeInfo.h"

@implementation SchoolAgeInfo

-(BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SchoolAgeInfo *other = (SchoolAgeInfo *)object;
    
    BOOL equal = [other.value isEqualToString:self.value];
    return equal;
}
@end
