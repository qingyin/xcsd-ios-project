//
//  HomeWorkTypeViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/31.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//
#import <Masonry.h>
#import <MJRefresh.h>
#import "MJRefreshBackStateFooter.h"
#import "MJRefreshAutoStateFooter.h"
#import "HomeWorkRecordViewController.h"
#import "HomeWorkTypeViewController.h"
#import "HomeWorkTypeTableViewCell.h"
#import "HomeWorkType.h"
#import "SettingHomeWorkViewController.h"
#import "UnifyHomeWorkViewController.h"

#import <extobjc.h>
#import "DropdownView.h"
#import <UIImageView+TXSDImage.h>
#import "UnifyHomeworkController.h"

@interface HomeWorkTypeViewController ()<UITableViewDataSource,UITableViewDelegate>

{
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    UIButton *_selectedBtn;
    NSInteger _selectedIndex;
    UIImageView *_arrowImgView;
    BOOL Status;
    int32_t Count;
    NSError *err;
    TXUser *user ;
}
@property (nonatomic, strong) NSArray *titlesArr;
@property (nonatomic,strong) NSMutableArray *classNames;
@property (nonatomic,strong) NSMutableArray *departmentIds;
@property (nonatomic, strong) DropdownView *dropdownView;



@end
@implementation HomeWorkTypeViewController

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
    Count=1;
    Status=1;
    _selectedIndex = 0;
    [self createCustomNavBar];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width_, self.view.height_-64) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    //[self setupRefresh];
    self.view.backgroundColor = kColorBackground;
    
    UIView *lineView=[[UIView alloc]init];
    lineView.backgroundColor=kColorLine;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customNavigationView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(self.view.width_, .1));
    }];
    user= [[TXChatClient sharedInstance] getCurrentUser:nil];
       // TXUser *Puser=[[TXChatClient sharedInstance] getCurrentUser:nil];
    //bay gaoju
    self.titlesArr = [NSArray array];
    self.departmentIds=[NSMutableArray array];
    self.classNames=[NSMutableArray array];
    //    self.titlesArr=@[Puser.className,@"4785"];
    self.titlesArr = [[TXChatClient sharedInstance] getAllDepartments:nil];
    for (TXDepartment *class in self.titlesArr) {
        if (class.departmentType==TXPBDepartmentTypeClazz) {
            [self.classNames addObject:class.name];
            //NSLog(@"------------%lld",class.departmentId);
            [self.departmentIds addObject:[NSString stringWithFormat:@"%lld",class.departmentId]];
            // NSLog(@"------------%@",self.departmentIds);
        }
    }
    if (self.classNames!=nil&&[self.classNames count]>0) {
        self.titleStr = _classNames[0];
        if (_classNames.count == 1) {
            //只有一个组不显示筛选框
            self.titleStr = _classNames[0];
            self.titleLb.text = self.titleStr;
            return;
        }

    }
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.adjustsImageWhenHighlighted = NO;
        _selectedBtn.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, self.customNavigationView.width_, kNavigationHeight);
        [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavigationView addSubview:_selectedBtn];
        [self.customNavigationView bringSubviewToFront:self.btnLeft];
        [self.customNavigationView bringSubviewToFront:self.btnRight];
        self.titleLb.font = kFontMiddle;
//      self.titleLb.text = _titlesArr[_selectedIndex];
    
        _dropdownView = [[DropdownView alloc] init];
        
        @weakify(self);
        [_dropdownView showInView:self.view andListArr:_classNames andDropdownBlock:^(int index) {
            @strongify(self);
            if(index == -1)
            {
                CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
                _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
                _arrowImgView.centerY = self.titleLb.centerY;
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _arrowImgView.transform = CGAffineTransformMakeRotation(0);
                } completion:nil];
                return;
            }
            else
            {
                _selectedIndex = index;
                self.titleStr = _classNames[_selectedIndex];
                self.titleLb.text = self.titleStr;
                CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
                _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
                _arrowImgView.centerY = self.titleLb.centerY;
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _arrowImgView.transform = CGAffineTransformMakeRotation(0);
                } completion:nil];
                [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
                TXAsyncRun(^{
                    if (self.departmentIds!=nil&&[self.departmentIds count]>0) {
                        int64_t classId=[self.departmentIds[_selectedIndex] integerValue];
                        [[TXChatClient sharedInstance] HomeworkRemainingCountClassId:classId onCompleted:^(NSError *error, BOOL customizedStatus, int32_t unifiedCount) {
                            if (error) {
                                DDLogDebug(@"error:%@", error);
                                [self showFailedHudWithError:error];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //  [_tableView.header endRefreshing];
                                });
                            }else{
                                Status=customizedStatus;
                                Count=unifiedCount;
                                err=error;
                                [self.tableView reloadData];
                            }
                        }];

                    }
                  
                    TXAsyncRunInMain(^{
                        [self.tableView reloadData];
                        [TXProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
             }
}];
        CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
        _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
        _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
        _arrowImgView.centerY = self.titleLb.centerY;
        [self.customNavigationView addSubview:_arrowImgView];
}
#pragma mark - DROPDOWN VIEW
- (void)showDropDownView
{
    [_dropdownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
}
-(void)updateNoDataStatus:(BOOL)isShow
{
    
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}
- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag==TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
    
    if (self.departmentIds!=nil&&[self.departmentIds count]>0) {
        int64_t classId=[self.departmentIds[_selectedIndex] integerValue];
        [[TXChatClient sharedInstance] HomeworkRemainingCountClassId:classId onCompleted:^(NSError *error, BOOL customizedStatus, int32_t unifiedCount) {
            if (error) {
                DDLogDebug(@"error:%@", error);
                [self showFailedHudWithError:error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //  [_tableView.header endRefreshing];
                });
            }else{
                Status=customizedStatus;
                Count=unifiedCount;
                err=error;
                [self.tableView reloadData];
            }
        }];
        
    }
}

//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    //    [self setTitle:MJRefreshAutoFooterIdleText forState:MJRefreshStateIdle];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
   [self performSelector:@selector(test) withObject:nil afterDelay:2];
}


- (void)test{
    [self.tableView reloadData];
    [_tableView.header endRefreshing];
}


- (void)footerRereshing{
    [self performSelector:@selector(test1) withObject:nil afterDelay:2];
}

- (void)test1{
    [_tableView.footer endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"HomeWorkTypeTableViewCell";
    UITableViewCell *cell=nil;
    HomeWorkTypeTableViewCell *homeWorkCell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!homeWorkCell) {
        homeWorkCell=[[[NSBundle mainBundle]loadNibNamed:@"HomeWorkTypeTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
    HomeWorkType *type=[HomeWorkType new];
    homeWorkCell.homeWorkTypeLabel.text=type.homeWorkTypeArray[indexPath.row];
    homeWorkCell.homeWorkBriefLabel.text=type.homeWorkBriefArray[indexPath.row];
    
    if (indexPath.row==0) {
        if (Status==0&&err==nil) {
            homeWorkCell.selectionStyle=UITableViewCellSelectionStyleNone;
            homeWorkCell.accessoryType=UITableViewCellAccessoryNone;
            homeWorkCell.backgroundColor=CellBackColor;
            homeWorkCell.stateLabel.text=@"当天作业已满";
        }else{
             homeWorkCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }else{
        if (Count==0&&err==nil) {
            homeWorkCell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.accessoryType=UITableViewCellAccessoryNone;
            homeWorkCell.backgroundColor=CellBackColor;
            homeWorkCell.stateLabel.text=@"当天作业已满";
        }else{
             homeWorkCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell=homeWorkCell;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80 ;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //消除cell选择痕迹
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
    if (indexPath.row==0&&Status==1) {
        SettingHomeWorkViewController *set=[[SettingHomeWorkViewController alloc]init];
		if (self.departmentIds!=nil&&[self.departmentIds count]>0) {
			int64_t classId=[self.departmentIds[_selectedIndex] integerValue];
			set.classId=classId;
			//  NSLog(@"*****%lld",set.classId);
			[self.navigationController pushViewController:set animated:YES];
		}

    }else if(indexPath.row==1&&Count!=0){
//        UnifyHomeWorkViewController *unify=[[UnifyHomeWorkViewController alloc]init];
        UnifyHomeworkController *unify = [[UnifyHomeworkController alloc] init];
		if (self.departmentIds!=nil&&[self.departmentIds count]>0) {
			NSInteger classId=[self.departmentIds[_selectedIndex] integerValue];
            unify.class_Id = classId;
            unify.remainingCount = Count;
			[self.navigationController pushViewController:unify animated:YES];
		}
    }
}

//点击后，过段时间cell自动取消选中
- (void)deselect
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
