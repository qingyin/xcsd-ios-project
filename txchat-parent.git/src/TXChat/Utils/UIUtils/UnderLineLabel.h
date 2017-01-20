
#import <UIKit/UIKit.h>



@interface UnderLineLabel : UILabel

{
    
    UIControl *_actionView;
    
   
    
}

- (void)addTarget:(id)target action:(SEL)action;

@end
 