

#import "JSONValueTransformer+CustomTransformer.h"

@implementation JSONValueTransformer (CustomTransformer)

- (NSDate *)NSDateFromNSNumber:(NSNumber*)string {
    
    
    NSTimeInterval interval = [string longLongValue]/1000;
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:interval];
    return date;
}

- (NSDate *)NSDateFromNSString:(NSString*)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:string];
}

- (NSString *)JSONObjectFromNSDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

@end
