 

#import "UIView+UIViewUtils.h"

@implementation UIView (UIViewUtils)

-(void)setBorderWithWidth:(CGFloat)borderWidth andCornerRadius:(CGFloat)cornerRadius andBorderColor:(UIColor*)borderColor
{

    // 按钮边框宽度
    self.layer.borderWidth = borderWidth;
    
    // 设置圆角
    self.layer.cornerRadius = cornerRadius;
    
    // 设置边框颜色
    self.layer.borderColor = [borderColor CGColor];

    self.layer.masksToBounds=YES;
}

- (UIViewController *)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
