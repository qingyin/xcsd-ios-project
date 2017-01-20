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

#import <extobjc.h>
#import "DropdownView.h"
#import <UIImageView+TXSDImage.h>

@interface HomeWorkTypeViewController ()<UITableViewDataSource,UITableViewDelegate>

{
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    UIButton *_selectedBtn;
    NSInteger _selectedIndex;
    UIImageView *_arrowImgView;
}
@property (nonatomic, strong) NSArray *titlesArr;
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
    // Do any additional setup after loading the view.
    self.titleStr = @"一年级五班";
    _selectedIndex = 0;
    [self createCustomNavBar];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, self.view.width_, self.view.height_-64) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self setupRefresh];
    self.view.backgroundColor = kColorBackground;
    
    UIView *lineView=[[UIView alloc]init];
    lineView.backgroundColor=kColorLine;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customNavigationView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(self.view.width_, 1));
    }];
    
        self.titlesArr = [NSArray array];
        self.titlesArr=@[@"三年级二班",@"一年级五班"];
    
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.adjustsImageWhenHighlighted = NO;
        _selectedBtn.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, self.customNavigationView.width_, kNavigationHeight);
        [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavigationView addSubview:_selectedBtn];
        [self.customNavigationView bringSubviewToFront:self.btnLeft];
        [self.customNavigationView bringSubviewToFront:self.btnRight];
        self.titleLb.font = kFontMiddle;
//         self.titleLb.text = _titlesArr[_selectedIndex];
    
        _dropdownView = [[DropdownView alloc] init];
        
        @weakify(self);
        [_dropdownView showInView:self.view andListArr:_titlesArr andDropdownBlock:^(int index) {
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
                self.titleStr = _titlesArr[_selectedIndex];
                self.titleLb.text = self.titleStr;
                CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
                _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
                _arrowImgView.centerY = self.titleLb.centerY;
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _arrowImgView.transform = CGAffineTransformMakeRotation(0);
                } completion:nil];
                [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
                TXAsyncRun(^{
                    
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
    HomeWorkTypeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"HomeWorkTypeTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
    HomeWorkType *type=[HomeWorkType new];

    cell.homeWorkTypeLabel.text=type.homeWorkTypeArray[indexPath.row];
    cell.homeWorkBriefLabel.text=type.homeWorkBriefArray[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80 ;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //消除cell选择痕迹
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
    
    SettingHomeWorkViewController *set=[[SettingHomeWorkViewController alloc]init];
    [self.navigationController pushViewController:set animated:YES];
}

//点击后，过段时间cell自动取消选中
- (void)deselect
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
