
#import "CategoryFirstViewController.h"
#import "EduApi.h"
#import "GetCategoryFirstResponse.h"
#import "MyProgressDialog.h"
#import "UserPreference.h"
#import "CategoryFirstCollectionViewCell.h"
#import "CategorySecondViewController.h"

@interface CategoryFirstViewController ()
{
	
	__weak IBOutlet UICollectionView *_collectionView;
	
	MBProgressHUD *HUD;
	
	NSArray *_array;
}

@end

@implementation CategoryFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		
		//        self.hidesBottomBarWhenPushed=NO;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	self.title=@"主题测试";
	
	//    在ViewDidLoad方法中声明Cell的类，在ViewDidLoad方法中添加，此句不声明，将无法加载，程序崩溃
	Class clazz = [CategoryFirstCollectionViewCell class];
	NSString* identifier =  NSStringFromClass(clazz);
	[_collectionView registerClass:clazz forCellWithReuseIdentifier:identifier];
	
	
	//    [self loadData];
	[self setChildInfo:_childInfo];
}

-(void)setChildInfo:(ChildInfo *)childInfo
{
	_childInfo = childInfo;
	
	_array = nil;
	[_collectionView reloadData];
	
	if (_collectionView==nil) {
		return;
	}
	
	[self loadData];
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
	//    [HUD show:YES];
	[EduApi getCategoryFirstWithToken:[UserPreference getToken] schoolAge:self.childInfo.schoolAge.value completion:^BOOL(BOOL success, id response) {
		
		[HUD hide:YES];
		HUD=nil;
		if(!success)
		{
			return NO;
		}
		
		GetCategoryFirstResponse *firstResponse = (GetCategoryFirstResponse*)response;
		_array = firstResponse.result;
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
	
	CategoryFirstCollectionViewCell *cell = (CategoryFirstCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CategoryFirstCollectionViewCell class]) forIndexPath:indexPath];
	
	
	CategoryFirstInfo *info = [_array objectAtIndex:indexPath.row];
	[cell setData:info schoolAge:self.childInfo.schoolAge];
	
	return cell;
}


#pragma mark UICollectionViewDelegateFlowLayout

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	CategoryFirstInfo *info = [_array objectAtIndex:indexPath.row];
	
	CategorySecondViewController *vc = [[CategorySecondViewController alloc]initWithChid:_childInfo categoryFirst:info];
	[self.navigationController pushViewController:vc animated:YES];
}

@end
