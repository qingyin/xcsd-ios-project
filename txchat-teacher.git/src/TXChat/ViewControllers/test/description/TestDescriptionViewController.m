

#import "TestDescriptionViewController.h"
//#import "UIView+UIViewUtils.h"
#import "EduApi.h"
#import "UserPreference.h"
#import "GetTestsResponse.h"
#import "MyProgressDialog.h"
//#import "LabelUtils.h"
#import "UILabel+ContentSize.h"
#import "TestSubjectViewController.h"
#import "UIView+Utils.h"

@interface TestDescriptionViewController ()
{
    
    
    __weak IBOutlet UIScrollView *_scrollView;
    
    __weak IBOutlet UIView *_contentView;
    __weak IBOutlet UILabel *_descriptionLabel;
    __weak IBOutlet UIView *_numView;
    __weak IBOutlet UILabel *_numLabel;
    
    __weak IBOutlet UIButton *_startButton;
    MBProgressHUD *HUD;
//    TestInfo *_testInfo;
}
@end

@implementation TestDescriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (IBAction)startAction:(id)sender {
    TestSubjectViewController *vc = [[TestSubjectViewController alloc]init];
    vc.testInfo = _testInfo;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array removeLastObject];
    [array addObject:vc];
    [self.navigationController setViewControllers:array animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title=@"测试说明";
    self.titleStr = @"测试说明";
    
    [_contentView setBorderWithWidth:0.5 andCornerRadius:12 andBorderColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1]];
    
    _contentView.hidden=YES;
    
    [self loadData];
    
    [self createCustomNavBar];
    
    CGFloat height = self.customNavigationView.height_;
    //    _scrollView.frame = CGRectMake(0, height, _scrollView.frame.size.width, kScreenHeight-height);
    CGRect frame = _contentView.frame;
    frame.origin.y = height + THEAMTEST_TO_TOPBAR_SPACE;
    frame.size.height = frame.size.height - 10;
    _contentView.frame = frame;
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    if (HUD) {
        return;
    }
    HUD = [MyProgressDialog showHUDAddedTo:self.view];
    
    NSString *userId = [NSString stringWithFormat:@"%lld", [TXApplicationManager sharedInstance].currentUser.userId];
    //    [HUD show:YES];
    [EduApi getTestsWithToken:[UserPreference getToken] testID:self.testID childID:userId completion:^BOOL(BOOL success, id response) {
        
        [HUD hide:YES];
        HUD =nil;
        
        if(!success)
        {
            [TXProgressHUD hideHUDForView:self.view animated:NO];
            [self showFailedHudWithError:((BaseResponse *)response).error];
            
            return NO;
        }
        
        [self getTestsSuccess:response];
        
        return YES;
    }];
    
    
}


-(void)getTestsSuccess:(GetTestsResponse *)result
{
    GetTestsResponse *response = (GetTestsResponse*)result;
    _testInfo = response.result;
    
    _startButton.hidden=NO;
    _contentView.hidden=NO;
    
    
    _descriptionLabel.text = _testInfo.description;
    
    //	CGFloat height = [LabelUtils heightForLabel:_descriptionLabel WithText:_descriptionLabel.text andMinHeight:20];
    CGFloat height = [UILabel heightForLabelWithText:_descriptionLabel.text maxWidth:_descriptionLabel.width_ font:[UIFont systemFontOfSize:17]];
    CGRect frame = _descriptionLabel.frame;
    frame.size.height = height;
    _descriptionLabel.frame = frame;
    
    frame = _numView.frame;
    frame.origin.y = CGRectGetMaxY(_descriptionLabel.frame);
    _numView.frame = frame;
    _numLabel.text = [NSString stringWithFormat:@"本测试总共%ld道题目",_testInfo.subjects.count];
    
    
    frame = _contentView.frame;
    frame.size.height = CGRectGetMaxY(_numView.frame)+24;
    _contentView.frame = frame;
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_contentView.frame)+20);
}

@end
