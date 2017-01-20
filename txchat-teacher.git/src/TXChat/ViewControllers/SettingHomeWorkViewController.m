//
//  SettingHomeWorkViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/31.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "SettingHomeWorkViewController.h"
#import <Masonry.h>
#import <MJRefresh.h>
#import "MJRefreshBackStateFooter.h"
#import "MJRefreshAutoStateFooter.h"
#import "SettingHomeWorkTableViewCell.h"
#import "HomeWorkListViewController.h"

#import <extobjc.h>
#import "DropdownView.h"
#import <UIImageView+TXSDImage.h>

@interface SettingHomeWorkViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    
    UIButton *_selectedBtn;
    NSInteger _selectedIndex;
    UIImageView *_arrowImgView;
    UILabel *_selectedLabel;
}

@property (nonatomic, strong) NSArray *titlesArr;
@property (nonatomic, strong) DropdownView *dropdownView;
@property (nonatomic) BOOL titleLabelWidth;

@end

@implementation SettingHomeWorkViewController

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
    self.titleStr = @"布置作业";
    _titleLabelWidth=NO;
    [self createCustomNavBar];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65+83, self.view.width_, self.view.height_-158) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    // _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    _selectedIndex = 0;
    self.titlesArr = [NSArray array];
    self.titlesArr=@[@"全部学生",@"普通学生",@"特别关注学生"];
    
    _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedBtn.adjustsImageWhenHighlighted = NO;
    _selectedBtn.frame = CGRectMake(0, self.customNavigationView.maxY, self.customNavigationView.width_, kNavigationHeight);
    [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_selectedBtn];
   
//    [self.customNavigationView bringSubviewToFront:self.btnLeft];
//    [self.customNavigationView bringSubviewToFront:self.btnRight];
//    self.titleLb.font = kFontMiddle;
    //         self.titleLb.text = _titlesArr[_selectedIndex];
    _selectedLabel=[[UILabel alloc]initLineWithFrame:CGRectMake(15, self.customNavigationView.maxY, 100, 30)];
    _selectedLabel.frame = CGRectMake(0, self.customNavigationView.maxY,_titleLabelWidth ? 100 : self.customNavigationView.width_, 40);

    _selectedLabel.font=kFontMiddle;
    _selectedLabel.textAlignment = NSTextAlignmentCenter;
    _selectedLabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_selectedLabel];
    _selectedLabel.text=@"全部学生";
    
    UILabel *briefLabel=[[UILabel alloc]initClearColorWithFrame:CGRectMake(15, _selectedLabel.maxY-10, self.customNavigationView.width_-30, 60)];
    briefLabel.numberOfLines=2;
    briefLabel.font=kFontMiddle;
    [briefLabel setTextColor:KColorNewSubTitleTxt];
    [self.view addSubview:briefLabel];
    briefLabel.text=@"老师们好，系统根据每个学生的学能水平专门定制了作业，每天定制的作业不能超过10个。";
    
    _dropdownView = [[DropdownView alloc] init];
    
    @weakify(self);
    [_dropdownView showInView:self.view andListArr:_titlesArr andDropdownBlock:^(int index) {
        @strongify(self);
        if(index == -1)
        {
            CGSize size = [_selectedLabel sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(_selectedLabel.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = _selectedLabel.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
            return;
        }
        else
        {
            _selectedIndex = index;
            _selectedLabel.text = _titlesArr[_selectedIndex];
           // self.titleLb.text = self.titleStr;
            CGSize size = [_selectedLabel sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(_selectedLabel.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = _selectedLabel.centerY;
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
    CGSize size = [_selectedLabel sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
    _arrowImgView.frame = CGRectMake(_selectedLabel.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = _selectedLabel.centerY;
    [self.customNavigationView addSubview:_arrowImgView];
}
#pragma mark - DROPDOWN VIEW
- (void)showDropDownView
{
    [_dropdownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [_selectedLabel sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(_selectedLabel.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = _selectedLabel.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
}

-(void)updateNoDataStatus:(BOOL)isShow
{
    
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnRight setTitle:@"发送" forState:UIControlStateNormal];
}
- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag==TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (sender.tag == TopBarButtonRight) {
        
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
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
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"SettingHomeWorkTableViewCell";
    SettingHomeWorkTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"SettingHomeWorkTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
   // cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //消除cell选择痕迹
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
    
}
//点击后，过段时间cell自动取消选中
- (void)deselect
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end

