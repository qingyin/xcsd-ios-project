

#import "EmptyViewController.h"

#import "LabelUtils.h"

@interface EmptyViewController ()
{
    __weak IBOutlet UILabel *label;
}

@end

@implementation EmptyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    
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


-(void)setMessage:(NSString *)message
{
    _message = message;
 
    label.text = message;
    
    CGFloat height = [LabelUtils heightForLabel:label WithText:message andMinHeight:0];
    CGRect frame = label.frame;
    frame.size.height = height;
    label.frame = frame;
}

@end
