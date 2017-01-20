

#import "ErrorViewController.h"
#import "UIView+UIViewUtils.h"
@interface ErrorViewController ()
{
    __weak IBOutlet UIView *_refreshButton;
}
-(IBAction)refreshAction:(id)sender;
@end

@implementation ErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [_refreshButton setBorderWithWidth:0 andCornerRadius:CGRectGetHeight(_refreshButton.frame)/2 andBorderColor:[UIColor clearColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshAction:(id)sender
{
    [self.view removeFromSuperview];
    
    [self.delegate errorViewController:self refresh:nil];
}


@end
