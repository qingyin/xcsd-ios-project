//
//  TXPublicUtils.m
//  TXChatParent
//
//  Created by lyt on 16/1/26.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXPublicUtils.h"

@implementation TXPublicUtils
+(NSString *)fortmatInt64ToTenThousandStr:(int64_t)number
{
    if(number <= 9999)
    {
        return [NSString stringWithFormat:@"%@", @(number)];
    }
    CGFloat tmp = number/10000.0f;
    NSNumber *formatNumber = [NSNumber numberWithDouble:[NSString stringWithFormat:@"%.1f", tmp].doubleValue] ;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    [formatter setGroupingSeparator:@""];///使用空去分割group
    return [NSString stringWithFormat:@"%@万", [formatter stringFromNumber:formatNumber]];
}
@end
