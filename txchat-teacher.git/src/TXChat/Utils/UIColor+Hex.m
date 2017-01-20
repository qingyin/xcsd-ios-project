

#import "UIColor+Hex.h"

@implementation UIColor(Hex)

+(UIColor *)colorWithHexRGB:(NSString *)inColorString
{
    return [self colorFromHexRGB:inColorString default:[UIColor clearColor]];
}
+ (UIColor *) colorFromHexRGB:(NSString *) inColorString default:(UIColor *)defaultColor
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (inColorString.length>0)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
   
        redByte = (unsigned char) (colorCode >> 16);
        greenByte = (unsigned char) (colorCode >> 8);
        blueByte = (unsigned char) (colorCode); // masks off high bits
        result = [UIColor
                  colorWithRed: (float)redByte / 0xff
                  green: (float)greenByte/ 0xff
                  blue: (float)blueByte / 0xff
                  alpha:1.0];
        return result;
    }
   
    return defaultColor;
}

@end
