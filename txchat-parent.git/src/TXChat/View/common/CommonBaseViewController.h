

#import <UIKit/UIKit.h>

#import "BaseResponse.h"

@interface CommonBaseViewController : UIViewController<UITextFieldDelegate>
{

}

/** token过期 */
//-(void)tokenExpired;


//-(void)loadEndWithResponse:(BaseResponse*)result andTag:(NSInteger)tag;
//-(void)loadErrorWithResponse:(BaseResponse *)result andTag:(NSInteger)tag;
//-(void)loadSuccessWithResponse:(BaseResponse *)result andTag:(NSInteger)tag;

/** 需要登录才能使用 */
-(BOOL)isNeedLogin;

-(UIView*)getContainerView;
-(void)showStatusBar;
-(void)hideStatusBar;

-(IBAction)hideKeyboard:(id)sender;


-(void)addKeyboradNotification;
-(void)removeKeyboradNotification;

-(void)setBackButtonWithTitle:(NSString*)title;
-(IBAction)backAction:(id)sender;


-(void)setRightButtonWithTitle:(NSString*)title ;
-(IBAction)rightButtonAction:(id)sender;
-(void)setRightButtonWithImage:(NSString *)image highlightedImage:(NSString*)highlightedImage;

-(void)popSelfAndPushViewController:(UIViewController*)vc;


-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardWillHide:(NSNotification *)note;

-(void)refresh;
-(void)onError;
-(UIView*)getErrorContainer;

-(void)onEmpty:(NSString*)message;
-(UIView*)getEmptyContainer;
@end
