
#import "CategorySecondViewController.h"
#import "EduApi.h"
#import "GetCategorySecondResponse.h"
#import "MyProgressDialog.h"
#import "UserPreference.h"
#import "CategorySecondCollectionViewCell.h"
#import "TestDescriptionViewController.h"
#import "TestEvaluationViewController.h"

@interface CategorySecondViewController ()
{
	ChildInfo *_childInfo;
	CategoryFirstInfo *_categoryFirstInfo;
	
	__weak IBOutlet UICollectionView *_collectionView;
	
	MBProgressHUD *HUD;
	
	NSArray *_array;
}

@end

@implementation CategorySecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

-(id)initWithChid:(ChildInfo *)child categoryFirst:(CategoryFirstInfo *)categoryFirst
{
	self = [super init];
	if (self) {
		_childInfo = child;
		_categoryFirstInfo = categoryFirst;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	self.title= _categoryFirstInfo.name;
	
	//    在ViewDidLoad方法中声明Cell的类，在ViewDidLoad方法中添加，此句不声明，将无法加载，程序崩溃
	Class clazz = [CategorySecondCollectionViewCell class];
	NSString* identifier =  NSStringFromClass(clazz);
	[_collectionView registerClass:clazz forCellWithReuseIdentifier:identifier];
	
	
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self loadData];
}

-(void)loadData
{
	if (HUD) {
		return;
	}
	
	HUD = [MyProgressDialog showHUDAddedTo:self.view];
	//    [HUD show:YES];
	[EduApi getCategorySecondWithToken:[UserPreference getToken] categoryFirstId:_categoryFirstInfo.id childID:_childInfo.id completion:^BOOL(BOOL success, id response) {
		[HUD hide:YES];
		HUD =nil;
		
		if(!success)
		{
			return NO;
		}
		
		GetCategorySecondResponse *secondResponse = (GetCategorySecondResponse*)response;
		_array = secondResponse.result;
		[_collectionView reloadData];
		return YES;
	}];
	
	
}



#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [_array count];
	
}

-  (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	CategorySecondCollectionViewCell *cell = (CategorySecondCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CategorySecondCollectionViewCell class]) forIndexPath:indexPath];
	
	
	CategorySecondInfo *info = [_array objectAtIndex:indexPath.row];
	[cell setData:info schoolAge:_childInfo.schoolAge];
	
	return cell;
}


#pragma mark UICollectionViewDelegateFlowLayout

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	CategorySecondInfo *info = [_array objectAtIndex:indexPath.row];
	
	if (info.status==1) {
		//已完成
		TestEvaluationViewController *vc=  [[TestEvaluationViewController alloc]init];
		vc.childInfo = _childInfo;
		//        vc.testInfo = info;
		
		[self.navigationController pushViewController:vc animated:YES];
	}else{
		TestDescriptionViewController *vc=  [[TestDescriptionViewController alloc]init];
		vc.childInfo = _childInfo;
		//        vc.categorySecondInfo = info;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

@end
