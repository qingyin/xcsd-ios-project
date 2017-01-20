

#import "CommonBaseViewController.h"

#import "UserPreference.h"

#import "Reachability.h"
//#import "BaiduMobStat.h"
#import "AppDelegate.h"

#import "ErrorViewController.h"
#import "EmptyViewController.h"

@interface CommonBaseViewController ()<UIAlertViewDelegate,ErrorViewControllerDelegate>
{
    BOOL isTryToLogin;
    
    CGFloat _viewHeight;
    
    BOOL statusBarHidder;
    
    ErrorViewController *_errorVC;
    EmptyViewController *_emptyVC;
}
@end

@implementation CommonBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //    http://www.cocoachina.com/ask/questions/show/101086
    if (iOS7) {
        super.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    //隐藏返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    //root不显示返回按钮
    if(self.navigationController.viewControllers.count>1)
    {
        [self setBackButton];
    }
    
    //背景
//    self.view.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1];
}

/** navigation bar 左边按钮 */
-(void)setBackButton
{
    [self setBackButtonWithTitle:@"返回"];
}

-(void)setBackButtonWithTitle:(NSString *)title
{
    if (title==nil)
    {
        [self setLeftButtonWithButton:nil];
        return;
    }
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, 49.0, 27.5);
    [backButton setImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    [backButton setTitle:title forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    
    
    [self setLeftButtonWithButton:backButton];
    
}

-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//-(void)setLeftButton:(NSString *)title
//{
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame = CGRectMake(0.0, 0.0, 49.0, 27.5);
//    [backButton setTitle:title forState:UIControlStateNormal];
//    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
//    self.navigationItem.leftBarButtonItem=temporaryBarButtonItem;
//}

-(void)setLeftButtonWithButton:(UIButton *)button
{
    if(button==nil)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItems = nil;
//        self.navigationItem.backBarButtonItem = nil;
        return;
    }
    
    
    [button addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    
//    if (iOS7) {
//        // Add a spacer on when running lower than iOS 7.0
//        
//        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        space.width = -10;
//        
//        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:space, temporaryBarButtonItem,nil];
//        
//    } else {
        // Just set the UIBarButtonItem as you would normally
        self.navigationItem.leftBarButtonItem=temporaryBarButtonItem;
//    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
//    }
}



/** navigation bar 右边按钮 */
-(void)setRightButtonWithTitle:(NSString *)title
{
    if (title==nil) {
        [self setRightButtonWithButton:nil];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, 49.0, 27.5);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  
    
    [self setRightButtonWithButton:button];
}


/** navigation bar 右边按钮 */
-(void)setRightButtonWithImage:(NSString *)image highlightedImage:(NSString*)highlightedImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    if(highlightedImage){
        [button setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    }

    button.frame = CGRectMake(0, 0, 49, 27.5);
//    CGRect frame = button.frame;
//    [button sizeToFit];
//    frame = button.frame;
//    NSLog(@"%@",NSStringFromCGRect(frame));
    
    
    [self setRightButtonWithButton:button];
}

-(void)setRightButtonWithButton:(UIButton *)rightButton
{
    if(rightButton==nil)
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = nil;
        return;
    }
    
    
    [rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    
    if (iOS7) {
        // Add a spacer on when running lower than iOS 7.0
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = -10;
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:space, temporaryBarButtonItem,nil];
        
    } else {
        // Just set the UIBarButtonItem as you would normally
        self.navigationItem.rightBarButtonItem=temporaryBarButtonItem;
    }
}


-(IBAction)rightButtonAction:(id)sender
{
    
}
-(void)addKeyboradNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeKeyboradNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    NSLog(@"%@:viewWillAppear",[NSString stringWithUTF8String:object_getClassName(self)]);
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%@:viewDidAppear",[NSString stringWithUTF8String:object_getClassName(self)]);
    //[[BaiduMobStat defaultStat] pageviewStartWithName:[NSString stringWithUTF8String:object_getClassName(self)]];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self hideKeyboard:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"%@:viewDidDisappear",[NSString stringWithUTF8String:object_getClassName(self)]);
    //[[BaiduMobStat defaultStat] pageviewEndWithName:[NSString stringWithUTF8String:object_getClassName(self)]];
    
}

-(BOOL)isNeedLogin
{
    return NO;
}

//-(void)loadEndWithResponse:(BaseResponse *)result andTag:(NSInteger)tag
//{
//    if ([result isSuccess]){
//        //成功
//        [self loadSuccessWithResponse:result andTag:tag];
//        return;
//    }
//    
//    [self loadErrorWithResponse:result andTag:tag];
//    
//    if ([result isTokenExpired]) {
//        //token过期
//        [self tokenExpired];
//        return;
//    }
//    
//    
//    NSString *msg =  @"连接服务器失败，请稍后重试";
//    if(!result)
//    {
//        if (![[Reachability reachabilityForInternetConnection] isReachable]) {
//            
//            //网络异常
//            msg = @"网络异常，请检查网络";
//            
//        }else{
//            //连接服务器出错
//            
//        }
//        
//    }
//    else{
//        
//        if(result.message){
//            msg = result.message;
//        }else{
//            
//        }
//    }
//    
//    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
//    
//}
//
//-(void)loadErrorWithResponse:(BaseResponse *)result andTag:(NSInteger)tag
//{
//    
//}
//-(void)loadSuccessWithResponse:(BaseResponse *)result andTag:(NSInteger)tag
//{
//    
//}


//-(void)tokenExpired
//{
//    //重新登录
//    [UserPreference setLoginResult:nil];
//    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"登录信息过期，请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
//    return;
//}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //[(AppDelegate*)[UIApplication sharedApplication].delegate launcherOverWithIntroduce:NO];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/** 隐藏键盘 */
-(void)hideKeyboard:(id)sender
{
    [[UIApplication sharedApplication]sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
    UIView *containerView = [self getContainerView];
	CGRect containerFrame = containerView.frame;
    if (_viewHeight<=0) {
        _viewHeight = containerFrame.size.height;
    }
    containerFrame.size.height  = _viewHeight - keyboardBounds.size.height;
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
    
    
    //by mey
	// set views with new info
//	containerView.frame = containerFrame;
    
    
	
	// commit animations
	[UIView commitAnimations];
    
}

-(UIView*)getContainerView
{
    return self.view;
}

-(void) keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
    UIView *containerView = [self getContainerView];
	CGRect containerFrame = containerView.frame;
    containerFrame.size.height = _viewHeight;
    _viewHeight=0;
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // by mey
	// set views with new info
//	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(BOOL)shouldAutorotate
{
    return YES;
}



#pragma mark StatusBar
-(void)showStatusBar
{
    if (iOS7)
    {
        statusBarHidder = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}

-(void)hideStatusBar
{
    if (iOS7)
    {
        statusBarHidder = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
}

//for iOS7
- (BOOL)prefersStatusBarHidden
{
    return statusBarHidder;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark 弹出自己，打开新界面
-(void)popSelfAndPushViewController:(UIViewController*)vc
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array removeLastObject];
    [array addObject:vc];
    [self.navigationController setViewControllers:array animated:YES];
}

-(void)onError
{
    if (_errorVC==nil) {
        _errorVC = [[ErrorViewController alloc]init];
        _errorVC.delegate = self;
    }
    
    if (_errorVC.view.superview) {
        [_errorVC.view removeFromSuperview];
    }
    
    UIView *container = [self getErrorContainer];
    _errorVC.view.frame = container.bounds;
    _errorVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    [container addSubview:_errorVC.view];
}

-(UIView*)getErrorContainer
{
//    if (self.parentViewController)
//    {
//        return self.parentViewController.view;
//    }
    return self.view;
}

-(void)errorViewController:(ErrorViewController *)vc refresh:(id)arg
{
    [self refresh];
}

-(void)refresh
{
    if (_errorVC.view.superview) {
        [_errorVC.view removeFromSuperview];
    }
    
}


-(void)onEmpty:(NSString *)message
{
    if (message==nil) {
        if (_emptyVC.view.superview) {
            [_emptyVC.view removeFromSuperview];
        }
        return;
    }
    
    if (_emptyVC==nil) {
        _emptyVC = [[EmptyViewController alloc]init];
    }
    
    if (_emptyVC.view.superview) {
        [_emptyVC.view removeFromSuperview];
    }
    
    _emptyVC.message = message;
    
    UIView *container = [self getEmptyContainer];
    _emptyVC.view.frame = container.bounds;
    _emptyVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    [container addSubview:_emptyVC.view];
}


-(UIView*)getEmptyContainer
{
    return self.view;
}


@end
