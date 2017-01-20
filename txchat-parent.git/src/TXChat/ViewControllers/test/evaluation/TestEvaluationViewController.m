

#import "TestEvaluationViewController.h"
#import "UIView+UIViewUtils.h"
#import "LabelUtils.h"
#import "EduApi.h"
#import "GetEvaluationResponse.h"
#import "UserPreference.h"

#import "MyProgressDialog.h"
#import "LabelUtils.h"
#import "TestDescriptionViewController.h"
#import "UnderLineLabel.h"
//#import "ArticleViewController.h"

//#import "TaskRelatedViewController.h"
//#import "ArticleRelatedViewController.h"

#import "AuthorityViewController.h"

//#import "RankViewController.h"
//#import "ShareView.h"
//#import "UIImageView+WebCache.h"

@interface TestEvaluationViewController ()
{
	
	__weak IBOutlet UIScrollView *_scrollView;
	
	__weak IBOutlet UIView *_contentView;
	
	__weak IBOutlet UILabel *_label;
	__weak IBOutlet UIView *_buttonContainer;
	
	
	__weak IBOutlet UIButton *_taskButton;
	__weak IBOutlet UIButton *_articleButton;
	MBProgressHUD *HUD;
	EvaluationInfo *_evaluationInfo;
	__weak IBOutlet UIButton *_shareButton;
	__weak IBOutlet UIButton *_shareTestButton;
	
	
	__weak IBOutlet UIView *_rankDescView;
	__weak IBOutlet UILabel *_rankDescLabel;
	__weak IBOutlet UILabel *_rankLabel;
	__weak IBOutlet UILabel *_childNameLabel;
	__weak IBOutlet UIImageView *_childImageView;
}
- (IBAction)shareAction:(id)sender;
-(IBAction)shareTestAction:(id)sender;

- (IBAction)taskAction:(id)sender;
- (IBAction)relatedArticleAction:(id)sender;

@end

@implementation TestEvaluationViewController

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
	// Do any additional setup after loading the view from its nib.
    
    [self createCustomNavBar];
	
	_contentView.hidden=YES;
	
	[_contentView setBorderWithWidth:0.5 andCornerRadius:12 andBorderColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1]];
	
	self.titleStr = @"测试结果";
	
	if (self.childInfo.childType!=kChildTypeWritable)
	{
		//无权限
		_taskButton.enabled=NO;
		[_taskButton setBackgroundColor:[UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1]];
		
		_shareButton.enabled=NO;
		_shareTestButton.enabled = NO;
	}
	else
	{
		//[self setRightButtonWithTitle:@"重测"];
        
        [self.btnRight setTitle:@"重测" forState:UIControlStateNormal];
        [self.btnRight setTitleColor:ColorNavigationTitle forState:UIControlStateNormal];
        [self.btnRight setTitleColor:kColorNavigationTitleDisable forState:UIControlStateDisabled];
	}
    
    
    _shareButton.hidden = YES;
    _shareTestButton.hidden = YES;
	
	//    [_taskButton setTitle:[NSString stringWithFormat:@"让我们开始%@的提升任务吧",_childInfo.childName] forState:UIControlStateNormal];
	
	
	[_rankDescView setBorderWithWidth:0 andCornerRadius:CGRectGetHeight(_rankDescView.frame)/2 andBorderColor:[UIColor clearColor ]];
	
	[_childImageView setBorderWithWidth:1 andCornerRadius:CGRectGetWidth(_childImageView.frame)/2 andBorderColor:[UIColor whiteColor]];
	
	
	if (self.testInfo) {
		[self getEvalutaion];
	}else{
		[self getTestInfo];
	}
	
    
    CGFloat height = self.customNavigationView.height_;
//    _scrollView.frame = CGRectMake(0, height, _scrollView.frame.size.width, kScreenHeight-100);
	CGRect frame = _contentView.frame;
	frame.origin.y = height + THEAMTEST_TO_TOPBAR_SPACE;
	frame.size.height = frame.size.height - 20;
	_contentView.frame = frame;
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (sender.tag == TopBarButtonRight) {
		[self rightButtonAction:sender];
	}
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)rightButtonAction:(id)sender
{
	//重测
	TestDescriptionViewController *vc=  [[TestDescriptionViewController alloc]init ];
	
	vc.childInfo = _childInfo;
	//  vc.categorySecondInfo = self.categorySecondInfo;
	if(self.testInfo){
		vc.testID = self.testInfo.id;
	}else{
		vc.testID = self.testID;
	}
	
	NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
	[array removeLastObject];
	[array addObject:vc];
	[self.navigationController setViewControllers:array animated:YES];
}



-(void)getTestInfo
{
	if (HUD)
	{
		return;
	}
	HUD = [MyProgressDialog showHUDAddedTo:self.view];
	[EduApi getTestsWithToken:[UserPreference getToken] testID:self.testID childID:_childInfo.id completion:^BOOL(BOOL success, id response)
	 {
		 [HUD hide:YES];
		 HUD =nil;
		 
		 if(!success)
		 {
             [TXProgressHUD hideHUDForView:self.view animated:NO];
             [self showFailedHudWithError:((BaseResponse *)response).error];
             
             return NO;
		 }
         GetTestsResponse *myResponse = response;
         self.testInfo = myResponse.result;
         
         [self getEvalutaion];
		 
		 return YES;
	 }];
	
	
}


-(void)getEvalutaion
{
	if (HUD) {
		return;
	}
	HUD = [MyProgressDialog showHUDAddedTo:self.view];
	
	[EduApi getEvaluationWithToken:[UserPreference getToken]  testID:self.testInfo.id childID:_childInfo.id completion:^BOOL(BOOL success, id response) {
		
		[HUD removeFromSuperview];
		HUD=nil;
		
		if(!success)
		{
            [TXProgressHUD hideHUDForView:self.view animated:NO];
            [self showFailedHudWithError:((BaseResponse *)response).error];
			return NO;
		}
		
		[self getEvaluationSuccess:response];
		
		return YES;
	}];
	
	
}


-(void)getEvaluationSuccess:(BaseResponse *)result
{
	GetEvaluationResponse *response = (GetEvaluationResponse*)result;
	_evaluationInfo = response.result;
	
	//宝宝信息
	[_childImageView sd_setImageWithURL:[NSURL URLWithString:self.childInfo.picture] placeholderImage:[UIImage imageNamed:@"head_default.png"]];
	_childNameLabel.text = self.childInfo.childName;
	_rankLabel.text = [NSString stringWithFormat:@"%ld",_evaluationInfo.testSerialNumber];
	_rankDescLabel.text = [NSString stringWithFormat:@"%@是第%ld名参加此测试的孩子喔～",self.childInfo.childName,_evaluationInfo.testSerialNumber];
	
	_articleButton.hidden = YES;
	_taskButton.hidden = YES;
	_contentView.hidden=NO;
	_label.text = _evaluationInfo.description;
	
	CGFloat height = [LabelUtils heightForLabel:_label WithText:_label.text andMinHeight:20];
	CGRect frame = _label.frame;
	frame.size.height = height;
	_label.frame = frame;
	
	frame = _buttonContainer.frame;
	frame.origin.y = CGRectGetMaxY(_label.frame)+0;//10;
	_buttonContainer.frame = frame;
	
	frame = _contentView.frame;
	frame.size.height = CGRectGetMaxY(_buttonContainer.frame);
	_contentView.frame = frame;
	
	
	//看看相关文章怎么说
	CGFloat y = CGRectGetMaxY(_contentView.frame);
	//    if(_evaluationInfo.socialArticle||_evaluationInfo.authority)
	//    {
	//
	//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_contentView.frame), y+10, CGRectGetWidth(_contentView.frame), 30)];
	//        label.textColor=[UIColor blackColor];
	//        label.text=@"看看相关文章怎么说？";
	//        [label setFont:[UIFont boldSystemFontOfSize:15]];
	//        [_scrollView addSubview:label];
	//
	//        y = CGRectGetMaxY(label.frame);
	//
	//
	//        if (_evaluationInfo.socialArticle)
	//        {
	//
	//            UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"article.png"]];
	//            frame = imageView.frame;
	//            frame.origin.x = CGRectGetMinX(_contentView.frame)+3;
	//            frame.origin.y = y+10;
	//            imageView.frame = frame;
	//            [_scrollView addSubview:imageView];
	//
	//            CGFloat x = CGRectGetMaxX(imageView.frame)+8;
	//            CGFloat width = CGRectGetWidth(_contentView.frame)-x;
	//            UnderLineLabel *underLineLabel = [[UnderLineLabel alloc]initWithFrame:CGRectMake(x, y+6, width, 30)];
	//            underLineLabel.font = [UIFont systemFontOfSize:15];
	//            underLineLabel.textColor = [UIColor colorWithRed:32/255.0 green:159/255.0 blue:212/255.0 alpha:1];
	//
	//            underLineLabel.text = _evaluationInfo.socialArticle.title;
	//            [underLineLabel addTarget:self action:@selector(articleAction:)];
	//
	//            [_scrollView addSubview:underLineLabel];
	//
	//            y = CGRectGetMaxY(underLineLabel.frame);
	//
	//        }
	//
	//
	//        if (_evaluationInfo.authority) {
	//
	//            UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"article.png"]];
	//            frame = imageView.frame;
	//            frame.origin.x = CGRectGetMinX(_contentView.frame)+3;
	//            frame.origin.y = y+10;
	//            imageView.frame = frame;
	//            [_scrollView addSubview:imageView];
	//
	//            CGFloat x = CGRectGetMaxX(imageView.frame)+8;
	//            CGFloat width = CGRectGetWidth(_contentView.frame)-x;
	//            UnderLineLabel *underLineLabel = [[UnderLineLabel alloc]initWithFrame:CGRectMake(x, y+6, width, 30)];
	//            underLineLabel.font = [UIFont systemFontOfSize:15];
	//            underLineLabel.textColor = [UIColor colorWithRed:32/255.0 green:159/255.0 blue:212/255.0 alpha:1];
	//
	//            underLineLabel.text = _evaluationInfo.authority.title;
	//            [underLineLabel addTarget:self action:@selector(authorityAction:)];
	//
	//            [_scrollView addSubview:underLineLabel];
	//
	//            y = CGRectGetMaxY(underLineLabel.frame);
	//
	//        }
	//
	//    }
	
	
	_scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), y+20);
}

#pragma mark 文章
//-(IBAction)articleAction:(id)sender
//{
//    ArticleViewController *vc = [[ArticleViewController alloc]initWithAriticle:_evaluationInfo.socialArticle];
//    [self.navigationController pushViewController:vc animated:YES];
//}

#pragma mark 文献
-(IBAction)authorityAction:(id)sender
{
	AuthorityViewController *vc = [[AuthorityViewController alloc]init];
	vc.authorityInfo = _evaluationInfo.authority;
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 相关游戏
-(void)taskAction:(id)sender
{
//	TaskRelatedViewController *vc = [[TaskRelatedViewController alloc]init];
//	vc.childInfo = _childInfo;
//	vc.associateTag = self.testInfo.associateTag;
//	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 相关文章
- (IBAction)relatedArticleAction:(id)sender
{
//	ArticleRelatedViewController *vc = [[ArticleRelatedViewController alloc]init];
//	vc.childInfo = _childInfo;
//	vc.associateTag = self.testInfo.associateTag;
//	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 分享
- (IBAction)shareAction:(id)sender
{
//	ShareView *shareView = [[ShareView alloc]initWithView:self.view];
//	shareView.viewController = self;
//	shareView.evaluationInfo = _evaluationInfo;
//	shareView.testInfo = self.testInfo;
//	shareView.childInfo = self.childInfo;
//	//    shareView.title = @"家长汇，宝宝成长助手";
//	//    shareView.content = _evaluationInfo.description;
//	[shareView show];
}

- (IBAction)shareTestAction:(id)sender {
//	ShareView *shareView = [[ShareView alloc]initWithView:self.view];
//	shareView.viewController = self;
//	shareView.testInfo = self.testInfo;
//	shareView.childInfo = self.childInfo;
//	[shareView show];
}
@end
