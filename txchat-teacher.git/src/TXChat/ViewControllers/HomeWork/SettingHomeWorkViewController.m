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
#import "HomeWorkDetailsViewController.h"

#import <extobjc.h>
#import "DropdownView.h"
#import <UIImageView+TXSDImage.h>
#import "HomeworkDetailTwoViewController.h"
#import "HomeworkDetailController.h"
#import "XCSDDataProto.pb.h"

@interface SettingHomeWorkViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    
    UIButton *_selectedBtn;
    NSInteger _selectedIndex;
    UIImageView *_arrowImgView;
    UILabel *_selectedLabel;
    XCSDHomeWorkGenerate *userHomeWork;
}
//定制作业 选择学生的范围
typedef enum StudentScope {
    ALL = 1,
    NORMAL = 2,
    SPECIAL = 3,
}Scope;

@property (nonatomic, strong) NSArray *titlesArr;
@property  (nonatomic,strong) NSArray *keyArr;
@property (nonatomic, strong) DropdownView *dropdownView;
@property (nonatomic) BOOL titleLabelWidth;
@property (nonatomic,strong) NSMutableArray *homeWorkList;
@property (nonatomic,strong) NSMutableArray *attentionList;
@property (nonatomic,strong) NSMutableArray *commonList;
@property (nonatomic,strong) NSMutableArray *allHomeWorkList;


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
-(instancetype)init{
    self=[super init];
    if (self) {
        _homeWorkList=[NSMutableArray arrayWithCapacity:5];
       _allHomeWorkList=[NSMutableArray arrayWithCapacity:5];
        _attentionList=[NSMutableArray arrayWithCapacity:5];
        _commonList=[NSMutableArray arrayWithCapacity:5];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"布置定制作业";
    _titleLabelWidth=NO;
    [self createCustomNavBar];

   //bay gaoju 去除提示图片
//    [self addEmptyDataImage:[UIImage imageNamed:@"noedit_default_icon"] showMessage:@"没有学能作业信息"];    
//    [self updateEmptyDataImageStatus:NO];
    
    _selectedIndex = 0;
    self.titlesArr = [NSArray array];
    self.keyArr=[NSArray array];
    //self.titlesArr=@[@"全部学生",@"普通学生",@"特别关注学生"];
    NSDictionary *dic = @{@"1":@"全部学生",@"3":@"特别关注学生",@"2":@"普通学生"};
    self.titlesArr=[dic allValues];
    self.keyArr=[dic allKeys]; 
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
    briefLabel.numberOfLines=0;
    briefLabel.font=kFontMiddle;
    [briefLabel setTextColor:KColorNewSubTitleTxt];
    [self.view addSubview:briefLabel];
//    briefLabel.text=@"老师们好，系统根据每个学生的学能水平专门定制了作业，每天定制的作业不能超过10个。";
    briefLabel.text = @"系统根据每个学生的学能水平专门定制了作业，每天定制的作业不能超过10个，带标志的学生是特殊关注学生，为学能总成绩排名后20%的学生。";
    [briefLabel sizeToFit];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, briefLabel.maxY, self.view.width_, self.view.height_-158) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    //[self addHomeWorksData];
    
    self.view.backgroundColor = kColorBackground;
    
    UIView *lineView=[[UIView alloc]init];
    
    lineView.backgroundColor=kColorLine;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customNavigationView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(self.view.width_, .1));
    }];
    
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
               //[self addHomeWorksData];
                if (_selectedIndex==0) {
                    _homeWorkList=_allHomeWorkList;
                }else if (_selectedIndex==1){
                    _homeWorkList=_attentionList;
                }else{
                    _homeWorkList=_commonList;
                }
                TXAsyncRunInMain(^{
                    if (_homeWorkList.count<=0||_homeWorkList==nil) {
                        [self.btnRight setTitleColor:kColorGray forState:UIControlStateNormal];
                        [self.btnRight endEditing:NO];
                        [self.btnRight setUserInteractionEnabled:NO];
                        [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
                    }else{
                        [self.btnRight setTitleColor:KColorAppMain forState:UIControlStateNormal];
                        [self.btnRight endEditing:YES];
                        [self.btnRight setUserInteractionEnabled:YES];
                        [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
                    }
      
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
        
        int dex=[[self.keyArr objectAtIndex:_selectedIndex] intValue];
        if ([_homeWorkList count]>0 &&_homeWorkList!=nil) {
            [[TXChatClient sharedInstance] SendHomework:YES ClassId:self.classId StudentScope:dex onCompleted:^(NSError *error) {
                if (error) {
                    DDLogDebug(@"error:%@", error);
                    [self showFailedHudWithError:error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // [_tableView.header endRefreshing];
                    });
                    [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
                    return ;
                }
                
                [self reportEvent:XCSDPBEventTypeCustomizedHomework bid:[NSString stringWithFormat:@"%lld",self.classId]];
                [self showSuccessHudWithTitle:@"发送成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:HomeWorkPostNotification object:nil];
            }];
            //bay gaoju
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
           
          }
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
    [self addAllHomeWorkList];
//    [self addHomeWorksData];
    [_tableView reloadData];
}
-(void)addAllHomeWorkList{
    [_attentionList removeAllObjects];
    [_commonList removeAllObjects];
    //TXUser *Puser=[[TXChatClient sharedInstance] getCurrentUser:nil];
    [[TXChatClient sharedInstance] GenerateHomeworkListClassId:self.classId onCompleted:^(NSError *error, NSArray *homeWork, BOOL lastOneHasChanged) {
        if (error) {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
            //[self addEmptyDataImage:[UIImage imageNamed:@"noedit_default_icon"] showMessage:@"没有学能作业信息"];
            //[self updateEmptyDataImageStatus:[UIImage imageNamed:@"noedit_default_icon"]];

        }else{
            
            @synchronized(_homeWorkList) {
//                NSMutableArray *tmpList=[NSMutableArray arrayWithCapacity:1];
//                for (NSMutableArray *homeWorkItem in homeWork) {
//                    [tmpList addObject:homeWorkItem];
//                }
//                [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
//                _homeWorkList=tmpList;
//                [_tableView reloadData];
                
                NSMutableArray *tmpList=[NSMutableArray arrayWithCapacity:1];
                for (NSMutableArray *homeWorkItem in homeWork) {
                    [tmpList addObject:homeWorkItem];
                }
                //                 _allHomeWorkList=tmpList;
                for (XCSDHomeWorkGenerate *hw in tmpList) {
                    if (hw.specialAttention==1) {
                        [_attentionList addObject:hw];
                    }if (hw.specialAttention==0){
                        [_commonList addObject:hw];
                    }
                }
                
                _allHomeWorkList = [NSMutableArray arrayWithArray:_attentionList];
                [_allHomeWorkList addObjectsFromArray:_commonList];
                _homeWorkList = _allHomeWorkList.copy;
                
                [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
                [_tableView reloadData];
            }
        }
    }];
}
-(void)addHomeWorksData{
     [_attentionList removeAllObjects];
//    [_attentionList removeAllObjects];
      [_commonList removeAllObjects];
  
//    TXUser *Puser=[[TXChatClient sharedInstance] getCurrentUser:nil];
      //NSLog(@"________%lld",self.classId);
    [[TXChatClient sharedInstance] GenerateHomeworkListClassId:self.classId onCompleted:^(NSError *error, NSArray *homeWork, BOOL lastOneHasChanged) {
        if (error) {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
            //[self addEmptyDataImage:[UIImage imageNamed:@"noedit_default_icon"] showMessage:@"没有学能作业信息"];
            //[self updateEmptyDataImageStatus:[UIImage imageNamed:@"noedit_default_icon"]];

        }else{
            
            @synchronized(_homeWorkList) {
                NSMutableArray *tmpList=[NSMutableArray arrayWithCapacity:1];
                for (NSMutableArray *homeWorkItem in homeWork) {
                    [tmpList addObject:homeWorkItem];
                }
//                 _allHomeWorkList=tmpList;
                for (XCSDHomeWorkGenerate *hw in tmpList) {
                    if (hw.specialAttention==1) {
                        [_attentionList addObject:hw];
                    }if (hw.specialAttention==0){
                        [_commonList addObject:hw];
                    }
                }
                
                _allHomeWorkList = [NSMutableArray arrayWithArray:_attentionList];
                [_allHomeWorkList addObjectsFromArray:_commonList];
                
                [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
                [_tableView reloadData];
            }
        }
      
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _homeWorkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"SettingHomeWorkTableViewCell";
    UITableViewCell *cell=nil;
    SettingHomeWorkTableViewCell *homeWorkCell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!homeWorkCell) {
        homeWorkCell=[[[NSBundle mainBundle]loadNibNamed:@"SettingHomeWorkTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    homeWorkCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row>=[_homeWorkList count]) {
        return homeWorkCell;
    }
      userHomeWork=[_homeWorkList objectAtIndex:indexPath.row];
    [homeWorkCell.avatarImage TX_setImageWithURL:[NSURL URLWithString:userHomeWork.avatar] placeholderImage:[UIImage imageNamed:@"attendance_defaultHeader"]];
    [homeWorkCell.childNameLabel setText:userHomeWork.name];
    [homeWorkCell.levelLabel setText:[ NSString stringWithFormat:@"%d关",userHomeWork.generateCount]];
    if (userHomeWork.specialAttention==1) {
        homeWorkCell.markImage.image=[UIImage imageNamed:@"hw_keysymbol_s"];
    }
    if (userHomeWork.remainMaxCount==0) {
        homeWorkCell.selectionStyle=UITableViewCellSelectionStyleNone;
        homeWorkCell.accessoryType=UITableViewCellAccessoryNone;
        homeWorkCell.backgroundColor=CellBackColor;
        homeWorkCell.state.numberOfLines=0;
        homeWorkCell.state.text=@"该学生今天的作业已满";
        homeWorkCell.state.font=[UIFont systemFontOfSize:16];
        homeWorkCell.state.textColor=[UIColor colorWithRed:255/255.0 green:150/255.0 blue:37/255.0 alpha:1];
        homeWorkCell.levelLabel.text=@"";
        homeWorkCell.staticStringLabel.text=@"";
    }

    cell=homeWorkCell;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //消除cell选择痕迹
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
 
    XCSDHomeWorkGenerate *generate=[_homeWorkList objectAtIndex:indexPath.row];
    if (generate.remainMaxCount!=0) {
        
//    HomeWorkDetailsViewController *details=[[HomeWorkDetailsViewController alloc]init];
//    details.childUser_Id=[NSString stringWithFormat:@"%lld",generate.childUserId];
//    details.class_Id = self.classId;
//    [self.navigationController pushViewController:details animated:YES];
        
        HomeworkDetailController *detail = [[HomeworkDetailController alloc] init];
        
        detail.setData(generate.childUserId, self.classId);
        
        [self.navigationController pushViewController:detail animated:YES];
    }
}
//点击后，过段时间cell自动取消选中
- (void)deselect
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end

