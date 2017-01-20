

#import "BaseNavigationViewController.h"

@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //给navigationBar设置背景图片
    UIImage *navbarBg = [UIImage imageNamed:@"task_header_bg.png" ];
    [self.navigationBar setBackgroundImage:navbarBg forBarMetrics:UIBarMetricsDefault];
    
    
    //标题颜色
    NSDictionary *attributes =[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIColor whiteColor], UITextAttributeTextColor,
                               nil];
    [self.navigationBar setTitleTextAttributes:attributes];
    self.navigationBar.translucent = NO;//解决遮住内容
}

-(void)setTitle:(NSString *)title
{
    self.navigationItem.title = title;
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}



@end
