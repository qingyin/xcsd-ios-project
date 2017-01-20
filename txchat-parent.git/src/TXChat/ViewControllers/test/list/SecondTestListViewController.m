//
//  SecondTestListViewController.m
//  TXChatParent
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "SecondTestListViewController.h"
#import <MJRefresh.h>

#import "EduApi.h"
#import "TestListTableViewCell.h"
#import "TestDescriptionViewController.h"
#import "TestEvaluationViewController.h"
#import "StartTestController.h"
#import "UIView+UIViewUtils.h"
#import "UIImage+Rotate.h"

#define KTEST_HEIGHT 65
#define KCELL_HEIGHT 65

@interface SecondTestListViewController ()
<UIWebViewDelegate,UITableViewDelegate, UITableViewDataSource>
{
//	__weak IBOutlet UITableView *_tableView;
    UITableView *_tableView;
	NSArray *_array;
}
@end

@implementation SecondTestListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self createCustomNavBar];
    
    [self getLocalData];
    
    [self setupTableView];
    
    [self setupRefresh];
    
    [self getChildInfo];
    
    [self addNotifi];
    [_tableView.header beginRefreshing];
}

- (void)addNotifi{
    
    NSNotificationCenter *notif = [NSNotificationCenter defaultCenter];
    
    [notif addObserver:self selector:@selector(receiveNotif:) name:kTestFinish object:nil];
}

- (void)receiveNotif:(NSNotification *)notif{
    
    [_tableView.header beginRefreshing];
}

- (void)setupTableView{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
//    UIView *testEntry = [self addTestEntry];
//    testEntry.frame = CGRectMake(0, navHeight, kScreenWidth, KTEST_HEIGHT);
//    [self.view addSubview:testEntry];
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, navHeight, kScreenWidth, kScreenHeight - navHeight);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = KCELL_HEIGHT;
    [self.view addSubview:_tableView];
    _tableView.tableHeaderView = [self addTestEntry];
    _tableView.tableFooterView = [[UIView alloc] init];
}

- (UIView *)addTestEntry{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
    UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, kScreenWidth, KTEST_HEIGHT)];
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(8, 2.5, kScreenWidth - 16, 60)];
    [containView addSubview:testView];
    
    testView.backgroundColor = [UIColor whiteColor];
    [testView  setBorderWithWidth:0.5 andCornerRadius:0 andBorderColor:RGBCOLOR(211, 211, 211)];
    
    UIImageView *image = [[UIImageView alloc] init];
    image.image = [UIImage mainBundleImage:@"lc_icon_learning"];
    [testView addSubview:image];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"学习能力测试";
    [testView addSubview:label];
    
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(testView.mas_left).offset(6);
        make.centerY.equalTo(testView.mas_centerY);
        make.height.width.equalTo(@(48));
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(image.mas_top);
        make.left.equalTo(image.mas_right).offset(10);
        make.height.equalTo(image.mas_height);
        make.right.equalTo(testView.mas_right).offset(-6);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jump2Test)];
    [testView addGestureRecognizer:tap];
    
    return containView;
}

- (void)jump2Test{
    
    StartTestController *startVC = [[StartTestController alloc] init];
    [self.navigationController pushViewController:startVC animated:YES];
}

- (void)getChildInfo{
    
    [[TXChatClient sharedInstance] fetchChild:^(NSError *error, TXUser *childUser) {
        if (error) {
            return ;
        }
        self.childInfo.childName = childUser.nickname;
    }];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count = [_array count];
	return count;
}

- (void)getLocalData{
    
    NSError *error;
    _array = [[TXApplicationManager sharedInstance].currentUserDbManager.testDao queryTest:[NSString stringWithFormat:@"%lld",LONG_LONG_MAX] count:LONG_LONG_MAX error:error];
}

- (void)setupRefresh{
    
    WEAKSELF
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        STRONGSELF
        [strongSelf refresh];
        
    }];
    
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        STRONGSELF
        [strongSelf getLocalWithMaxId:0];
    }];
    
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}

- (void)getLocalWithMaxId:(NSInteger *) maxId{
    [_tableView.footer endRefreshing];
}


-(void)refresh
{
    [EduApi testListWithSchoolAge:self.childInfo.schoolAge.value childID:self.childInfo.id viewController:self completion:^BOOL(BOOL success, id response) {
        [_tableView.header endRefreshing];
        
        if (success)
        {
            TestListResponse *myResponse = response;
            _array = myResponse.result;
            
            [_tableView reloadData];
            //[self onEmpty:nil];
            
            [[TXApplicationManager sharedInstance].currentUserDbManager.testDao deleteAllTest];
            
            for (TestInfo *testInfo in _array) {
                
                XCSDTestInfo *xcsdTestInfo = [testInfo changeIntoXCSDTestInfo];
                
                NSError *error;
                [[TXApplicationManager sharedInstance].currentUserDbManager.testDao addTest:xcsdTestInfo error:&
                 error];
            }
        }
        else
        {
            [self showFailedHudWithError:((BaseResponse *)response).error];
        }
        return YES;
    }];
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
        vc.testInfo = info;
		vc.testID = info.id;
		vc.childInfo = self.childInfo;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
