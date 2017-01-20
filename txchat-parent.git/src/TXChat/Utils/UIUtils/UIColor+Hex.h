

#import <Foundation/Foundation.h>

@interface UIColor (Hex)

+ (UIColor *) colorFromHexRGB:(NSString *) inColorString default:(UIColor*)defaultColor;

+ (UIColor *) colorWithHexRGB:(NSString *) inColorString;

@end
