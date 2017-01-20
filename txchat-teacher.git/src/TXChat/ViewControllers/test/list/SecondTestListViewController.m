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
#import "UIView+Utils.h"
#import "TXApplicationManager.h"
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
    
    [self addNotifi];
    
    [self addEmptyDataImage:NO showMessage:@"暂时没有测试哦~"];
    [self updateEmptyDataImageStatus:_array.count > 0 ? NO : YES];
    
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
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, navHeight, kScreenWidth, kScreenHeight - navHeight);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = KCELL_HEIGHT;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
}

- (UIView *)addTestEntry{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
    UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, kScreenWidth, KTEST_HEIGHT)];
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(8, 2.5, kScreenWidth - 16, 60)];
    [containView addSubview:testView];
    
    testView.backgroundColor = [UIColor whiteColor];
    [testView  setBorderWithWidth:0.5 andCornerRadius:0 andBorderColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1]];
    
    _tableView.tableHeaderView = containView;
    
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

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    //测试返回需要刷新界面
//    [_tableView.header beginRefreshing];
//}

- (void)getLocalData{
    
    NSError *error;
    _array = [[TXApplicationManager sharedInstance].currentUserDbManager.testDao queryTest:[NSString stringWithFormat:@"%lld",LONG_LONG_MAX] count:LONG_LONG_MAX error:error];
    
    if (_array.count > 0) {
        [self updateEmptyDataImageStatus:NO];
    }
    [_tableView reloadData];
}

- (void)setupRefresh{
    
    WEAKSELF
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        STRONGSELF
        [strongSelf refresh];
        
    }];
    
//    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        STRONGSELF
//        [strongSelf getLocalWithMaxId:0];
//    }];
    
//    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
//    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}

- (void)getLocalWithMaxId:(NSInteger *) maxId{
    [_tableView.footer endRefreshing];
}


-(void)refresh
{
        
        NSString *userId = [NSString stringWithFormat:@"%lld", [TXApplicationManager sharedInstance].currentUser.userId];
        
        [EduApi testListWithSchoolAge:@"20" childID:userId viewController:self completion:^BOOL(BOOL success, id response) {
        [_tableView.header endRefreshing];
            
            if (success)
            {
                TestListResponse *myResponse = response;
                _array = myResponse.result;
                
                [_tableView reloadData];
                
                if (_array.count<=0)
                {
                    if ([self.childInfo.schoolAge.value isEqualToString:kSchoolAge6]|| [self.childInfo.schoolAge.value isEqualToString:kSchoolAge7])
                    {
                        
                        //						[self onEmpty:[NSString stringWithFormat:@"%@的小脑袋还不能想太多复杂的事，而且%@的火星语咱也不懂，等%@到了大班，可以表达想法的时候再来测测吧。",self.childInfo.childName,self.childInfo.childName,self.childInfo.childName]];
                        
                        [self updateEmptyDataText:[NSString stringWithFormat:@"%@的小脑袋还不能想太多复杂的事，而且%@的火星语咱也不懂，等%@到了大班，可以表达想法的时候再来测测吧。",self.childInfo.childName,self.childInfo.childName,self.childInfo.childName]];
                    }
                    else
                    {
                        //[self onEmpty:@"暂时没有结果哦～"];
                        [self updateEmptyDataText:@"暂时没有测试哦~"];
                    }
                    
                    [self updateEmptyDataImageStatus:YES];
                }
                else
                {

                    //[self onEmpty:nil];
                    [self updateEmptyDataImageStatus:NO];
                }
                
                [_tableView reloadData];
                [[TXApplicationManager sharedInstance].currentUserDbManager.testDao deleteAllTest];
                for (TestInfo *testInfo in _array) {
                    
                    XCSDTestInfo *xcsdTestInfo = [testInfo changeIntoXCSDTestInfo];
                    
                    NSError *error;
                    [[TXApplicationManager sharedInstance].currentUserDbManager.testDao addTest:xcsdTestInfo error:&
                     error];
                }
                
                return YES;
            }
            
            [self showFailedHudWithTitle:@"服务请求错误"];
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
