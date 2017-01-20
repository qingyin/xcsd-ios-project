
#import <Foundation/Foundation.h>

@interface LabelUtils : NSObject

+(CGSize) sizeWithFont: (UIFont *)font WithText: (NSString *) strText width:(CGFloat)width andMinHeight:(CGFloat)minHeight;

+ (CGFloat) heightForLabel: (UILabel *)label WithText: (NSString *) strText andMinHeight:(CGFloat)minHeight;


+ (CGFloat) widthForLabel: (UILabel *)label WithText: (NSString *) strText;

@end
