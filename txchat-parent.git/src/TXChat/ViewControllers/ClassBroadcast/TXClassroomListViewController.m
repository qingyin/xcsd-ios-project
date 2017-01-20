//
//  TXClassroomListViewController.m
//  TXChatTeacher
//
//  Created by Cloud on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXClassroomListViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ClassroomListTableViewCell.h"
#import "BroadcastInfoViewController.h"
#import <MJRefresh.h>
#import "TXProgressHUD.h"


@interface TXClassroomListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_listTableView;
}

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic) NSInteger pages;

@end

@implementation TXClassroomListViewController

- (void)viewDidLoad {
//    self.titleStr = @"云课堂";
    self.pages = 1;
    [super viewDidLoad];
    [self createCustomNavBar];
    [self getDataFromLocal];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStyleGrouped];
    _listTableView.backgroundColor = kColorBack;
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_listTableView];
    [self setupRefresh];
    
    [_listTableView registerClass:[ClassroomListTableViewCell class] forCellReuseIdentifier:@"CellReuseIdentifier"];
    
    [_listTableView.header beginRefreshing];

}

- (void)getDataFromLocal{
    NSArray *tmpArr = [[TXChatClient sharedInstance] getCourses:LONG_LONG_MAX count:LONG_LONG_MAX];
    
    self.listArr = [NSMutableArray arrayWithArray:tmpArr];
}

- (void)getDateFromNetWithPage:(NSInteger)page andIsRefresh:(BOOL)isFooterRefresh
{
    DDLogDebug(@"/fetch_course_lesson_list");
    __weak typeof(self) tmpObj = self;
    [[TXChatClient sharedInstance] fetchCourseList:page onCompleted:^(NSError *error, NSArray *lessons, BOOL hasMore) {
       if (error) {
            [tmpObj showFailedHudWithError:error];
        }else{
            if (lessons!=nil) {
                if (isFooterRefresh) {
                    [tmpObj.listArr addObjectsFromArray:lessons];
                }else{
                    tmpObj.listArr = [NSMutableArray arrayWithArray:lessons];
                }
                self.pages++;
                
                [_listTableView reloadData];
                [_listTableView.footer setHidden:!hasMore];
            }else{
                [self addEmptyDataImage:NO showMessage:@"暂时没有课程哦!"];
                [self updateEmptyDataImageStatus:YES];
            }
        }
        
        [_listTableView.header endRefreshing];
        [_listTableView.footer endRefreshing];
        
    }];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader =[MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    _listTableView.header = gifHeader;
    _listTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _listTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}

/**
 *  下拉刷新
 */
- (void)headerRereshing{
    self.pages = 1;
    [self getDateFromNetWithPage:self.pages andIsRefresh:NO];
}

/**
 *  上拉刷新
 */
- (void)footerRereshing{
    
    NSLog(@"footerRereshing");
    
    [self getDateFromNetWithPage:self.pages andIsRefresh:YES];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.listArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"CellReuseIdentifier" cacheByIndexPath:indexPath configuration:^(ClassroomListTableViewCell *cell) {
        cell.dataDic = self.listArr[indexPath.section];
        if (cell.lineView) {
            cell.lineView.hidden = (indexPath.section + 1 == _listArr.count)?YES:NO;
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellReuseIdentifier";
    ClassroomListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataDic = self.listArr[indexPath.section];
    if (cell.lineView) {
        cell.lineView.hidden = (indexPath.section + 1 == _listArr.count)?YES:NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }else{
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BroadcastInfoViewController *mediaVC = [[BroadcastInfoViewController alloc] init];
    TXPBCourseLesson *lesson = self.listArr[indexPath.section];
    mediaVC.course = lesson.course;
    mediaVC.courseID = lesson.id;
    mediaVC.coverImgUrl = lesson.pic;
    [self.navigationController pushViewController:mediaVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
