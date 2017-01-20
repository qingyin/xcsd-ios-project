

#import "TestListViewController.h"

#import "MyProgressDialog.h"

#import "EduApi.h"



#import "TestListTableViewCell.h"

#import "TestDescriptionViewController.h"
#import "TestEvaluationViewController.h"



@interface TestListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
	
	
	__weak IBOutlet UITableView *_tableView;
	
	
	
	
	NSArray *_array;
	
	MBProgressHUD *HUD;
	
}



@end

@implementation TestListViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	if (self.associateTag) {
		self.title = @"相关测试";
		
		[self setRightButtonWithImage:@"home.png" highlightedImage:nil];
	}else{
		self.title=@"主题测试";
	}
	
	
	
	
	
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



-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//测试返回需要刷新界面
	[self refresh];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	
}

-(void)rightButtonAction:(id)sender
{
	//    [self.navigationController popToRootViewControllerAnimated:YES];
	
	[self.tabBarController setSelectedIndex:0];
}

-(void)refresh
{
	if(HUD)
	{
		return;
	}
	
	[super refresh];
	
	HUD = [MyProgressDialog showHUDAddedTo:self.view];
	
	if (self.associateTag)
	{
		//相关测试
		[EduApi relatedTestWithSchoolAge:self.childInfo.schoolAge.value childID:self.childInfo.id associateTag:self.associateTag viewController:self completion:^BOOL(BOOL success, id response) {
			
			//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
			[HUD hide:YES];
			HUD =nil;
			
			if (success) {
				TestListResponse *myResponse = response;
				_array = myResponse.result;
				[_tableView reloadData];
				
				if (_array.count<=0)
				{
					[self onEmpty:@"暂时没有相关的测试哦~先去别的地方看看吧~"];
				}
				else
				{
					[self onEmpty:nil];
				}
			}
			else
			{
				
				if(_array==nil)
				{
					[self onError];
					return YES;
				}
				else
				{
					return NO;
				}
				
			}
			
			return YES;
		}];
	}
	else
	{
		[EduApi testListWithSchoolAge:self.childInfo.schoolAge.value childID:self.childInfo.id viewController:self completion:^BOOL(BOOL success, id response) {
			
			//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
			[HUD hide:YES];
			HUD =nil;
			
			if (success)
			{
				TestListResponse *myResponse = response;
				_array = myResponse.result;
				[_tableView reloadData];
				
				
				if (_array.count<=0)
				{
					if ([self.childInfo.schoolAge.value isEqualToString:kSchoolAge6]|| [self.childInfo.schoolAge.value isEqualToString:kSchoolAge7])
					{
						
						[self onEmpty:[NSString stringWithFormat:@"%@的小脑袋还不能想太多复杂的事，而且%@的火星语咱也不懂，等%@到了大班，可以表达想法的时候再来测测吧。",self.childInfo.childName,self.childInfo.childName,self.childInfo.childName]];
					}
					else
					{
						[self onEmpty:@"暂时没有结果哦～"];
					}
				}
				else
				{
					[self onEmpty:nil];
				}
			}
			else
			{
				if(_array==nil)
				{
					[self onError];
					return YES;
				}
				else
				{
					return NO;
				}
			}
			
			return YES;
		}];
	}
}

-(UIView *)getEmptyContainer
{
	return _tableView;
}

#pragma mark -
#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count = [_array count];
	return count;
	
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = NSStringFromClass(TestListTableViewCell.class);
	
	TestListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		
		
		cell= [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] lastObject];
		
	}
	
	if (indexPath.row<_array.count) {
		TestInfo *info =[_array objectAtIndex:indexPath.row];
		
		[cell setData:info ];
	}
	
	
	return cell;
	
	
}

#pragma mark -
#pragma mark UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TestInfo *info =[_array objectAtIndex:indexPath.row];
	
	if(info.status==kTestStatusFinish){
		//测试结果
		TestEvaluationViewController *vc = [[TestEvaluationViewController alloc]init];
		vc.childInfo = self.childInfo;
		vc.testID = info.id;
		[self.navigationController pushViewController:vc animated:YES];
	}
	else
	{
		TestDescriptionViewController *vc = [[TestDescriptionViewController alloc]init];
		vc.testID = info.id;
		vc.childInfo = self.childInfo;
		[self.navigationController pushViewController:vc animated:YES];
	}
}


@end
