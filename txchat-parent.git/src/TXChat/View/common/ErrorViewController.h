

#import <UIKit/UIKit.h>

@protocol ErrorViewControllerDelegate;

@interface ErrorViewController : UIViewController

@property id<ErrorViewControllerDelegate> delegate;

@end

@protocol ErrorViewControllerDelegate <NSObject>

@required
-(void)errorViewController:(ErrorViewController*)vc refresh:(id)arg;

@end