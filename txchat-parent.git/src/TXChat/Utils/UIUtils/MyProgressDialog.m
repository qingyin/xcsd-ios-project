 

#import "MyProgressDialog.h"

@implementation MyProgressDialog

+(MBProgressHUD*)showHUDAddedTo:(UIView *)view
{
    //初始化进度框，置于当前的View当中
    MBProgressHUD* HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //    [view addSubview:HUD];
    HUD.removeFromSuperViewOnHide = YES;
    
    //如果设置此属性则当前的view置于后台
//    HUD.dimBackground = YES;
    
    //设置对话框文字
//    HUD.labelText = @"请稍等";

    
//    CGFloat imageWidth = 41.5;
//    CGFloat imageHeight = 41.5;
//    CGRect frame =CGRectMake(0, 0, imageWidth, imageHeight);
//    UIView *customView = [[UIView alloc]initWithFrame:frame];
//    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loading.png"]];
//    bgImageView.frame = frame;
//    [customView addSubview:bgImageView];
//    UIImageView *progressImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loading01.png"]];
//    progressImageView.frame =frame;
//    [customView addSubview:progressImageView];
//    
//    //动画
//    CABasicAnimation* rotationAnimation;
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
//    rotationAnimation.duration = 2;
//    rotationAnimation.cumulative = YES;
//    rotationAnimation.repeatCount = 1000;
//    [progressImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
//    
//    
//    HUD.customView = customView;
//    
//    
//    // Set custom view mode
//    HUD.mode = MBProgressHUDModeCustomView;
    

    
    return HUD;
}







@end
