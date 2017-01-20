 

#import "TestSubjectInfo.h"

@implementation TestSubjectInfo

-(BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    TestSubjectInfo *other = (TestSubjectInfo *)object;
    
    BOOL equal = [other.id isEqualToString:self.id];
    return equal;
}

@end
