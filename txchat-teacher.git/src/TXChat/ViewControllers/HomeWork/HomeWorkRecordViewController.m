//
//  HomeWorkRecordViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/29.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkListViewController.h"
#import <Masonry.h>
#import <MJRefresh.h>
#import "MJRefreshBackStateFooter.h"
#import "MJRefreshAutoStateFooter.h"
#import "HomeWorkRecordTableViewCell.h"
#import "HomeWorkRecordViewController.h"
#import "HomeWorkListViewController.h"
#import "RecordDetailsViewController.h"
#import "HomeworkDetailTwoViewController.h"

@interface HomeWorkRecordViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    XCSDHomeworkMember *Member;
    int32_t page;
    int32_t pageCount ;

}
@property (nonatomic,strong) NSMutableArray *homeWorkMembers;
@end


@implementation HomeWorkRecordViewController


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
        _homeWorkMembers=[NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"学能作业成绩";
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
    pageCount = 20;
    page=1;
    
//    UIView *lineView=[[UIView alloc]init];
//    lineView.backgroundColor=kColorLine;
//    [self.view addSubview:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.customNavigationView.mas_bottom);
//        make.size.mas_equalTo(CGSizeMake(self.view.width_, .5));
//    }];
    
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
    [_tableView.header beginRefreshing];
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
        [self fatchNewMemberssRereshing];
    });

}
-(void)fatchNewMemberssRereshing{
     [[TXChatClient sharedInstance] HomeworkMemberList:YES HomeworkId:self.hkId onCompleted:^(NSError *error, NSArray *members, BOOL hasMore, BOOL lastOneHasChanged) {
        if (error) {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
            [self updateEmptyDataImageStatus:[_homeWorkMembers count] > 0?NO:YES];
        }else{
            [self updateMemberssAfterHeaderRefresh:members];
            [_tableView.footer setHidden:!hasMore];

            }
    }];
}
- (void)updateMemberssAfterHeaderRefresh:(NSArray *)members
{
    @synchronized(_homeWorkMembers) {
        [_homeWorkMembers removeAllObjects];
        if (members!=nil &&[members count]>0) {
            
            NSMutableArray *attentionList = [NSMutableArray arrayWithCapacity:5];
            NSMutableArray *commomList = [NSMutableArray arrayWithCapacity:5];
            
            for (XCSDHomeworkMember *member in members) {
                if (member.specialAttention) {
                    [attentionList addObject:member];
                }else{
                    [commomList addObject:member];
                }
            }
            
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:attentionList];
            [tmpArr addObjectsFromArray:commomList];
            
            _homeWorkMembers=tmpArr;
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
    [_tableView.footer endRefreshing];
//    int64_t beginMemberId=0;
//    if (_homeWorkMembers!=nil &&[_homeWorkMembers count]) {
//        XCSDHomeworkMember *beginMember=_homeWorkMembers.lastObject;
//        beginMemberId=beginMember.memberId;
//    }
//    
//    [[TXChatClient sharedInstance] HomeworkMemberList:YES HomeworkId:self.hkId onCompleted:^(NSError *error, NSArray *members, BOOL hasMore, BOOL lastOneHasChanged) {
//
//        if (error) {
//            DDLogDebug(@"error:%@", error);
//            [self showFailedHudWithError:error];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [_tableView.footer endRefreshing];
//            });
//            [self updateEmptyDataImageStatus:[_homeWorkMembers count] > 0?NO:YES];
//        }else{
//            
//            [self updateMemberssAfterHeaderRefresh:members];
//    
//            [_tableView.footer setHidden:!hasMore];
//        }
//            }];
    
  }
-(void)updateMemberssAfterFooterRefresh:(NSArray *)members{
    @synchronized(_homeWorkMembers) {
        if (members!=nil&&[members count]>0) {
            [_homeWorkMembers addObjectsFromArray:members];
        }
    }
    [self updateViewConstraints];
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
}

#pragma mark -tableView 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _homeWorkMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"HomeWorkRecordTableViewCell";
    UITableViewCell *cell=nil;
    HomeWorkRecordTableViewCell *memberCell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!memberCell) {
        memberCell=[[[NSBundle mainBundle]loadNibNamed:@"HomeWorkRecordTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    memberCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row>=[_homeWorkMembers count]) {
        return memberCell;
    }
    Member=[_homeWorkMembers objectAtIndex:indexPath.row];
    [memberCell.avatarImage TX_setImageWithURL:[NSURL URLWithString:Member.avatar] placeholderImage:[UIImage imageNamed:@"attendance_defaultHeader"]];
    [memberCell.childNameLabel setText:Member.name];
    [memberCell.scoreLabel setText:[NSString stringWithFormat:@"%d分",Member.score]];
    if (Member.specialAttention==1) {
        memberCell.markImage.image=[UIImage imageNamed:@"hw_keysymbol_s"];
    }
    if (Member.status==0) {
        memberCell.selectionStyle=UITableViewCellSelectionStyleNone;
        memberCell.accessoryType=UITableViewCellAccessoryNone;
        memberCell.staticStringLabel.text=@"作业未提交";
        memberCell.staticStringLabel.font=[UIFont systemFontOfSize:16];
        memberCell.staticStringLabel.textColor=[UIColor colorWithRed:255/255.0 green:150/255.0 blue:37/255.0 alpha:1];
        memberCell.scoreLabel.text=@"";
    }
    cell=memberCell;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //消除cell选择痕迹
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
    XCSDHomeworkMember *member=[_homeWorkMembers objectAtIndex:indexPath.row];
    if (member.status==1) {
        HomeworkDetailTwoViewController *record = [[HomeworkDetailTwoViewController alloc] init];
        record.memberId = member.memberId;
//    RecordDetailsViewController *record=[[RecordDetailsViewController alloc]init];

//    record.member_Id=[NSString stringWithFormat:@"%lld",member.memberId];
    
        [self.navigationController pushViewController:record animated:YES];
    }
}
//点击后，过段时间cell自动取消选中
- (void)deselect
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}
@end

