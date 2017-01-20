//
//  HomeworkDetailTwoViewController.m
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkDetailTwoViewController.h"
#import "HomeworkDescriptionView.h"
#import "HomeworkDetailCell.h"
#import "XCSDHomeWorkManager.h"
#import "GameManager.h"

#define kStartBtnViewH 57

@interface HomeworkDetailTwoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    HomeworkDescriptionView *_homeworkDescriptionView;
    UIButton *_startBtn;
    NSArray *_gameList;
    UITableView *_tableView;
    XCSDHomeWork *_homework;
}

@property (nonatomic, assign) SInt64 childId;
@end
@implementation HomeworkDetailTwoViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    [self setupUI];
}

- (void)updateDataWith:(XCSDHomeWork *)homework{
    
    _homework = homework;
    _startBtn.hidden = homework.status == XCSDPBHomeworkStatusFinished;
    _tableView.height_ += homework.status == XCSDPBHomeworkStatusFinished ? _startBtn.height_ + 16 : 0;
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    
    [[TXChatClient sharedInstance].xcsdHomeWorkManager fetchHomeworkDetail:(NSInteger)homework.memberId onCompleted:^(NSError *error, XCSDPBHomeworkDetailResponse *response) {
        
        [TXProgressHUD hideHUDForView:self.view animated:NO];
        
        if (error) { return ;}
        _homeworkDescriptionView.setData(response);
        _gameList = response.gameLevels;
        _childId = response.childUserId;
        [_tableView reloadData];
    }];
}

- (HomeworkDetailTwoViewController *(^)(XCSDHomeWork *))setHomework{
    return ^HomeworkDetailTwoViewController *(XCSDHomeWork *homework){
        
        [self updateDataWith:homework];
        return self;
    };
}

- (void)setupUI{
    self.titleStr = @"学能作业";
    
    _homeworkDescriptionView = [[HomeworkDescriptionView alloc] init];
    
    [self addStartBtn];
    
    [self addTableView];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addStartBtn{
    
    CGFloat startBtnH = 40;
    CGFloat startBtnW = kScreenWidth - 40 * 2;
    
    _startBtn = [[UIButton alloc] init];
    _startBtn.frame = CGRectMake(40, kScreenHeight - startBtnH - 8, startBtnW, startBtnH);
    [_startBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_startBtn setBackgroundColor:KColorAppMain];
    [_startBtn setTitle:@"开始作业" forState:UIControlStateNormal];
    [_startBtn sl_setCornerRadius:5.f];
    [self.view addSubview:_startBtn];
    
    @weakify(self);
    [_startBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        self.didStartHomework(YES);
        
        if (_gameList.count == 0) {
            [self showFailedHudWithTitle:@"数据错误"];
            return ;
        }
        
        //gameList:"1_2;3_4"--->1->gameId;2->level;
        NSString *gameList = [NSString string];
        for (NSInteger i = 0; i < _gameList.count; ++i) {
            
            XCSDPBGameLevel *level = _gameList[i];
            
           gameList = [gameList stringByAppendingFormat:@"%lld#%d$1_", level.gameId, level.level];
            
            NSString *trueOrFalse = level.hasGuide ? @"true" : @"false";
            
            gameList = [gameList stringByAppendingString:[NSString stringWithFormat:@"%@;", trueOrFalse]];
        }
        
        UIViewController *gameManager = [[GameManager getInstance] createGameHomeWorkViewController:gameList.copy memberId:_homework.memberId childUserId:self.childId];
        
        
        //[self.navigationController pushViewController:gameManager animated:YES];
		
		NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
		[array removeLastObject];
		[array addObject:gameManager];
		[self.navigationController setViewControllers:array animated:YES];
    }];
    
    _startBtn.hidden = _homework.status == XCSDPBHomeworkStatusFinished;
}

- (void)addTableView{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
    _tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, navHeight, kScreenWidth, kScreenHeight - navHeight - kStartBtnViewH) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    _tableView.rowHeight = 75;
    _tableView.backgroundColor = [UIColor whiteColor];
    //    _tableView.estimatedRowHeight = 60;
    //    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.view addSubview:_tableView];
    
    _tableView.height_ += _homework.status == XCSDPBHomeworkStatusFinished ? kStartBtnViewH : 0;
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//- (void)drawLine{
//
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    [layer setFrame:_tableView.frame];
//
//    [layer setStrokeColor:[UIColor grayColor].CGColor];
//
//    [layer setLineWidth:1.0f];
//    [layer setLineJoin:kCALineJoinRound];
//
//    [layer setLineDashPattern:@[@(10),@(3)]];
//
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathMoveToPoint(path, NULL, 65, 50);
//    CGPathAddLineToPoint(path, NULL, 65, _tableView.height_);
//
//    [layer setPath:path];
//    CGPathRelease(path);
//    [_tableView.layer addSublayer:layer];
//}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _gameList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"homeworkDatil";
    
    HomeworkDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[HomeworkDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    XCSDPBGameLevel *gameLevel = _gameList[indexPath.row];
    cell.setData(gameLevel,_homework);
    return cell;
}

#pragma mark: UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return _homeworkDescriptionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return _homeworkDescriptionView.getHeight();
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}


@end
