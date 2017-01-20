//
//  HomeWorkListViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkListViewController.h"
#import <Masonry.h>
#import <MJRefresh.h>
#import "NSDate+TuXing.h"
#import "MJRefreshBackStateFooter.h"
#import "MJRefreshAutoStateFooter.h"
#import "HomeWorkListTableViewCell.h"
#import "HomeWorkTypeViewController.h"
#import "HomeWorkRecordViewController.h"

@interface HomeWorkListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    XCSDClassHomework *homeWork;
}
@property (nonatomic,strong) NSMutableArray *homeWorkList;
@end


@implementation HomeWorkListViewController

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
    // Do any additional setup after loading the view.
    
    [self createCustomNavBar];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width_, self.view.height_-64) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self setupRefresh];
    [_tableView.header beginRefreshing];
    
    self.view.backgroundColor = kColorBackground;
    [self addEmptyDataImage:[UIImage imageNamed:@"noedit_default_icon"] showMessage:@"没有学能作业信息"];
    [self updateEmptyDataImageStatus:[UIImage imageNamed:@"noedit_default_icon"]];
    
    UIView *lineView=[[UIView alloc]init];
    lineView.backgroundColor=kColorLine;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customNavigationView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(self.view.width_, .1));
    }];
   

}

-(void)updateNoDataStatus:(BOOL)isShow
{
    
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnRight setTitle:@"布置" forState:UIControlStateNormal];
     }
- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag==TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (sender.tag == TopBarButtonRight) {
        HomeWorkTypeViewController *type=[[HomeWorkTypeViewController alloc]init];
        [self.navigationController pushViewController:type animated:YES];
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
    //bay gaoju
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeWork) name:HomeWorkPostNotification object:nil];
}
-(void)refreshHomeWork{
    [self headerRereshing];
    [_tableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fatchNewHomeWorksRereshing];
    });
}
-(void)fatchNewHomeWorksRereshing{
    [[TXChatClient sharedInstance] HomeworkSentList:YES sentHomeWorksHasMaxId:LLONG_MAX onCompleted:^(NSError *error, NSArray *Homeworks, BOOL hasMore, BOOL lastOneHasChanged) {
        if (error) {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
            [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
        }else{
            
            [self updateMemberssAfterHeaderRefresh:Homeworks];
            [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
            //[_tableView.footer setHidden:!hasMore];
        }
    }];
}
- (void)updateMemberssAfterHeaderRefresh:(NSArray *)homeWorks{
    @synchronized(_homeWorkList) {
        [_homeWorkList removeAllObjects];
        if (homeWorks!=nil &&[homeWorks count]>0) {
            _homeWorkList=[NSMutableArray arrayWithArray:homeWorks];
        }
    }
    [_tableView.header endRefreshing];
    [self updateViewConstraints];
    [_tableView reloadData];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView scrollsToTop];
    });

}
- (void)footerRereshing{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self LoadLastPages];
    });
}
-(void)LoadLastPages{
    int64_t beginHomeWorkId = 0;
    if(_homeWorkList != nil && [_homeWorkList count] > 0)
    {
        XCSDClassHomework *beginHomeWork = _homeWorkList.lastObject;
        beginHomeWorkId =beginHomeWork.homeworkId;
    }
    [[TXChatClient sharedInstance] HomeworkSentList:YES sentHomeWorksHasMaxId:beginHomeWorkId onCompleted:^(NSError *error, NSArray *Homeworks, BOOL hasMore, BOOL lastOneHasChanged) {
        if (error) {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
            [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
        }else{
            [self updateHomeWorksAfterFooterRefresh:Homeworks];
            [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
            [_tableView.footer setHidden:!hasMore];
        }
    }];
}
-(void)updateHomeWorksAfterFooterRefresh:(NSArray *)homeWorks{
    @synchronized(_homeWorkList) {
        if (homeWorks!=nil &&[homeWorks count]>0) {
            [_homeWorkList addObjectsFromArray:homeWorks];
        }
    }
    [self updateViewConstraints];
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
}

#pragma mark - tableView 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _homeWorkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"HomeWorkListTableViewCell";
    UITableViewCell *cell=nil;
    HomeWorkListTableViewCell *homeWorkCell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!homeWorkCell) {
        homeWorkCell=[[[NSBundle mainBundle]loadNibNamed:@"HomeWorkListTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    homeWork=[_homeWorkList objectAtIndex:indexPath.row];
    homeWorkCell.selectionStyle=UITableViewCellSelectionStyleNone;
    [homeWorkCell.classLabel setText:homeWork.className];
   if (homeWork.type==1) {
        homeWorkCell.avatarImage.image=[UIImage imageNamed:@"hw_alone"];
         homeWorkCell.homeWorkTypeLabel.text=@"系统定制作业";
   } else{
       homeWorkCell.avatarImage.image=[UIImage imageNamed:@"hw_unify"];
       homeWorkCell.homeWorkTypeLabel.text=@"教师自主作业";
    }
    homeWorkCell.classLabel.text=homeWork.className;
    [homeWorkCell.timeLabel setText:[NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(homeWork.sendTime/1000)]]];
    homeWorkCell.numberLabel.text=[NSString stringWithFormat:@"%d/%d",homeWork.finishedCount,homeWork.totalCount];
    cell=homeWorkCell;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //消除cell选择痕迹
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
    
    HomeWorkRecordViewController *record=[[HomeWorkRecordViewController alloc]init];
   XCSDClassHomework  *hw=[_homeWorkList objectAtIndex:indexPath.row];
    record.hkId=hw.homeworkId;
    [self.navigationController pushViewController:record animated:YES];
}
//点击后，过段时间cell自动取消选中
- (void)deselect
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
@end

