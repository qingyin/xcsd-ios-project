

#import "TestSubjectViewController.h"

//#import "UIView+UIViewUtils.h"
#import "EduApi.h"
#import "UserPreference.h"
#import "AnswerInfo.h"
#import "MyProgressDialog.h"
//#import "LabelUtils.h"
#import "UILabel+ContentSize.h"
#import "TestEvaluationViewController.h"
#import "XCSDDataProto.pb.h"

@interface TestSubjectViewController ()
{
	
	
	__weak IBOutlet UIScrollView *_scrollView;
	
	__weak IBOutlet UIView *_contentView;
	
	__weak IBOutlet UILabel *_subjectLabel;
	__weak IBOutlet UIView *_optionContainer;
	
	__weak IBOutlet UIButton *_previousButton;
	__weak IBOutlet UIButton *_nextButton;
	
	MBProgressHUD *HUD;
	
	NSInteger _index;
	
	NSMutableDictionary *_answerDic;
}
@end

@implementation TestSubjectViewController

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
	
	//边框
	[_contentView setBorderWithWidth:0.5 andCornerRadius:12 andBorderColor:[UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:1]];
	
	self.title = @"测试";//_testInfo.name;
    self.titleStr = @"测试";
	
	_answerDic = [[NSMutableDictionary alloc]init];
	
	[self showTest];
	
	[self createCustomNavBar];
	
    [self setupSubviewFrame];
    
    //_contentView.frame = CGRectMake(_contentView.frame.origin.x, height, _contentView.frame.size.width, kScreenHeight-height);
    
}

- (void)setupSubviewFrame{
    
    CGFloat height = self.customNavigationView.height_;
    CGRect frame = _contentView.frame;
    frame.origin.y = height + 15 + THEAMTEST_TO_TOPBAR_SPACE;
    frame.size.height = frame.size.height - 10;
    _contentView.frame = frame;
    
    _optionContainer.width_ = _scrollView.width_;
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

-(void)showTest
{
	
	
	TestSubjectInfo *subjectInfo = [_testInfo.subjects objectAtIndex:_index];
	
	_subjectLabel.text =[NSString stringWithFormat:@"%ld.%@",(long)subjectInfo.num,subjectInfo.subject ];
	
	
//	CGFloat height = [LabelUtils heightForLabel:_subjectLabel WithText:_subjectLabel.text andMinHeight:20];
    CGFloat height = [UILabel heightForLabelWithText:_subjectLabel.text maxWidth:_subjectLabel.width_ font:[UIFont systemFontOfSize:17]];
	CGRect frame = _subjectLabel.frame;
	frame.size.height = height;
	_subjectLabel.frame = frame;
	
	
	//选项
	for (UIView *view in _optionContainer.subviews) {
		[view removeFromSuperview];
	}
	
	
	NSNumber *selectedOption = [_answerDic objectForKey:subjectInfo.id];
	
	CGFloat y = 0;
	height = 30;
//	CGFloat width = CGRectGetWidth(_optionContainer.frame);
    CGFloat width = kScreenWidth - 20 * 2;
	NSInteger tag=100;
	for (TestOptionInfo *option in subjectInfo.options) {
		UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		button.titleLabel.font = [UIFont systemFontOfSize:15];
		
		NSString *text = option.optionName;
		[button setTitle:text forState:UIControlStateNormal];
		
		button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		//        button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
		button.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
		
//		[button setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 10)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
		[button setImage:[UIImage imageNamed:@"test_radio_button.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"test_radio_button_selected.png"] forState:UIControlStateHighlighted];
		[button setImage:[UIImage imageNamed:@"test_radio_button_selected.png"] forState:UIControlStateSelected];
		
//		[button setBackgroundImage:[UIImage imageNamed:@"test_radio_bg.png"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"test_radio_bg_selected.png"] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[UIImage imageNamed:@"test_radio_bg_selected.png"] forState:UIControlStateSelected];		
		
		button.titleLabel.numberOfLines=0;
		button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//		CGSize size = [LabelUtils sizeWithFont:button.titleLabel.font WithText:text width:(width - 60)  andMinHeight:height];
//        CGSize size = [LabelUtils sizeWithFont:button.titleLabel.font WithText:text width:width - 60 andMinHeight:height];
        CGSize size = [UILabel contentSizeForLabelWithText:text maxWidth:width - 60 font: button.titleLabel.font];
		
		[button addTarget:self action:@selector(optionItemClickAction:) forControlEvents:UIControlEventTouchUpInside];
		button.frame = CGRectMake(0, y, width, size.height + 8);
		button.tag = tag;
		[_optionContainer addSubview:button];
		y = CGRectGetMaxY(button.frame)+10;
		tag++;
		
		
		//上次选择
		if (selectedOption) {
			if ([selectedOption integerValue]==button.tag) {
				button.selected=YES;
			}
		}
	}
	
	frame = _optionContainer.frame;
	frame.origin.y = CGRectGetMaxY(_subjectLabel.frame)+20;
	frame.size.height=y;
	_optionContainer.frame = frame;
	
	//    frame = _contentView.frame;
	//    frame.size.height = CGRectGetMaxY(_optionContainer.frame)+20;
	//    _contentView.frame = frame;
	
	_scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_optionContainer.frame)+20);
	
	//按钮
	if (_index>0) {
		//        _previousButton.hidden = NO;
		_previousButton.enabled=YES;
		[_previousButton setBackgroundColor:[UIColor colorWithRed:32/255.0 green:159/255.0 blue:212/255.0 alpha:1]];
	}else{
		//        _previousButton.hidden = YES;
		_previousButton.enabled=NO;
		[_previousButton setBackgroundColor:[UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1]];
	}
	
	if (_index==_testInfo.subjects.count-1) {
		//最后一题，显示提交按钮
		[_nextButton setTitle:@"提交" forState:UIControlStateNormal];
	}
	else
	{
		[_nextButton setTitle:@"下一题" forState:UIControlStateNormal];
	}
}

#pragma mark 点击选项
-(IBAction)optionItemClickAction:(id)sender
{
	//取消延迟消息
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextAction:) object:nil];
	
	TestSubjectInfo *subjectInfo = [_testInfo.subjects objectAtIndex:_index];
	NSNumber *selectedOption = [_answerDic objectForKey:subjectInfo.id];
	if (selectedOption) {
		UIButton *button = (UIButton*)[_optionContainer viewWithTag:[selectedOption integerValue]];
		button.selected=NO;
	}
	[(UIButton*)sender setSelected:YES];
	[_answerDic setObject:[NSNumber numberWithInteger:[(UIButton*)sender tag]] forKey:subjectInfo.id];
	
	if (_index<(_testInfo.subjects.count-1)) {
		
		//延迟一下
		[self performSelector:@selector(nextAction:) withObject:nil afterDelay:0.5];
		//        [self showTest];
	}else{
		
	}
}

#pragma mark 上一题
-(void)previousAction:(id)sender
{
	//取消延迟消息
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextAction:) object:nil];
	
	
	_index--;
	[self showTest];
}

#pragma mark 下一题
-(void)nextAction:(id)sender
{
	TestSubjectInfo *subjectInfo = [_testInfo.subjects objectAtIndex:_index];
	NSNumber *selectedOption = [_answerDic objectForKey:subjectInfo.id];
	if (selectedOption==nil) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请选择答案" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
		[alert show];
		return;
	}
	
	//取消延迟消息
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextAction:) object:nil];
	
	
	if (_index<(_testInfo.subjects.count-1)) {
		//下一题
		_index++;
		[self showTest];
	}else{
		//提交
		[self submitAction:nil];
	}
	
	
}

#pragma mark 提交
- (IBAction)submitAction:(id)sender {
	
	
	
	
	NSMutableArray *answers = [[NSMutableArray alloc]init];
	for (TestSubjectInfo* info in _testInfo.subjects) {
		AnswerInfo *answerInfo = [[AnswerInfo alloc]init];
		answerInfo.subjectID = info.id;
		
		NSNumber *value =  [_answerDic objectForKey:info.id];
		TestOptionInfo *optionInfo = [info.options objectAtIndex:([value integerValue]-100)];
		answerInfo.option = optionInfo.id;
		
		[answers addObject:answerInfo];
	}
	
	if (HUD) {
		return;
	}
	HUD = [MyProgressDialog showHUDAddedTo:self.view];
	
    NSString *userId = [NSString stringWithFormat:@"%lld", [TXApplicationManager sharedInstance].currentUser.userId];
	[EduApi addAnswersWithToken:[UserPreference getToken] testID:_testInfo.id childID:userId answers:answers completion:^BOOL(BOOL success, id response) {
		
		[HUD hide:YES];
		HUD=nil;
		if(!success)
		{
            [TXProgressHUD hideHUDForView:self.view animated:NO];
            [self showFailedHudWithError:((BaseResponse *)response).error];
            
			return NO;
		}
		
        [self reportEvent:XCSDPBEventTypeCompletedTest bid:self.testInfo.id];
        
		//跳转到测试结果
		TestEvaluationViewController *vc = [[TestEvaluationViewController alloc]init];
		vc.testInfo = self.testInfo;
	
		
		NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
		[array removeLastObject];
		[array addObject:vc];
		[self.navigationController setViewControllers:array animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTestFinish object:nil];
		
		return YES;
	}];
	
	
	
	
}


@end
