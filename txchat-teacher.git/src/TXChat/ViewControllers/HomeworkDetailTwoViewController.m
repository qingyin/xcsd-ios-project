//
//  HomeworkDetailTwoViewController.m
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkDetailTwoViewController.h"
//#import "HomeworkDescriptionView.h"
#import "HomeworkDetailCell.h"
#import "XCSDHomeWorkManager.h"

#define K_LABEL_HEIGHT 30
#define K_MARGIN 10


@interface HomeworkDetailTwoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_gameList;
    UITableView *_tableView;
    XCSDHomeWork *_homework;
    UILabel *_leftLbl;
    UILabel *_rightLbl;
}

@property (nonatomic, assign) SInt64 childId;
@end
@implementation HomeworkDetailTwoViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    [self setupUI];
    
    [self fetchHomeworkDetail];
}

//- (void)updateDataWith:(XCSDHomeWork *)homework{
//    
//    _startBtn.hidden = homework.status == XCSDPBHomeworkStatusFinished;
//    _tableView.height_ += homework.status == XCSDPBHomeworkStatusFinished ? 59 : 0;
//    
//    [[TXChatClient sharedInstance].homeWorkManager fetchHomeworkDetail:homework.memberId onCompleted:^(NSError *error, XCSDPBHomeworkDetailResponse *response) {
//        
//        if (error) { return ;}
//        
//        _homework = homework;
//        _homeworkDescriptionView.setData(response);
//        _gameList = response.gameLevels;
//        [_tableView reloadData];
//    }];
//}
//
//- (HomeworkDetailTwoViewController *(^)(XCSDHomeWork *))setHomework{
//    return ^HomeworkDetailTwoViewController *(XCSDHomeWork *homework){
//        
//        [self updateDataWith:homework];
//        return self;
//    };
//}

- (void)fetchHomeworkDetail{
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    
    [[TXChatClient sharedInstance].homeWorkManager fetchHomeworkDetail:self.memberId onCompleted:^(NSError *error, XCSDPBHomeworkDetailResponse *response) {
        
        [TXProgressHUD hideHUDForView:self.view animated:NO];
        
        _gameList = response.gameLevels;
        _childId = response.childUserId;
        [_tableView reloadData];
        
        NSString *leftText = [NSString stringWithFormat:@"本次作业成绩: %d分",response.totalScore];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:leftText];
        NSRange numRange = [leftText rangeOfString:[NSString stringWithFormat:@"%d", response.totalScore]];
        
        [attr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(253, 162, 32) range:NSMakeRange(numRange.location, leftText.length - numRange.location)];
        _leftLbl.attributedText = attr;
        
//        _leftLbl.text = [NSString stringWithFormat:@"本次作业成绩: %d分",response.totalScore];
        _rightLbl.text = [NSString stringWithFormat:@"作业满分为: %d分",response.maxScore];
    }];
}

- (void)setupUI{
    self.titleStr = @"学能作业";
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat labelY = self.customNavigationView.height_ + K_MARGIN;
    
    
    
    
    _leftLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth / 2 - 15, K_LABEL_HEIGHT)];
    _rightLbl = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2, 0, kScreenWidth / 2 - 15, K_LABEL_HEIGHT)];
    
    
    _leftLbl.textColor = RGBCOLOR(83, 83, 83);
    _rightLbl.textColor = RGBCOLOR(67, 109, 129);
    
    _leftLbl.font = [UIFont boldSystemFontOfSize:15];
    _rightLbl.font = [UIFont systemFontOfSize:15];
    
    _leftLbl.textAlignment = NSTextAlignmentLeft;
    _rightLbl.textAlignment = NSTextAlignmentRight;
    _leftLbl.backgroundColor = RGBCOLOR(243, 243, 243);
    _rightLbl.backgroundColor = RGBCOLOR(243, 243, 243);
    
    UIView *containView = [[UIView alloc] initWithFrame:CGRectMake(0, labelY, kScreenWidth, K_LABEL_HEIGHT)];
    containView.backgroundColor = RGBCOLOR(243, 243, 243);
    [self.view addSubview:containView];
    
    [containView addSubview:_leftLbl];
    [containView addSubview:_rightLbl];
    
    [self addTableView];
}

- (void)addTableView{
    
    CGFloat tableViewY = self.customNavigationView.height_ + K_MARGIN + K_LABEL_HEIGHT;
    
    _tableView = [[UITableView  alloc] initWithFrame:CGRectMake(0, tableViewY, kScreenWidth, kScreenHeight - _leftLbl.maxY) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.bounces = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.allowsSelection = NO;
    _tableView.rowHeight = 60;
    
    [self.view addSubview:_tableView];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)drawLine{
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer setFrame:_tableView.frame];
    
    [layer setStrokeColor:[UIColor grayColor].CGColor];
    
    [layer setLineWidth:1.0f];
    [layer setLineJoin:kCALineJoinRound];
    
    [layer setLineDashPattern:@[@(10),@(3)]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 65, 50);
    CGPathAddLineToPoint(path, NULL, 65, _tableView.height_);
    
    [layer setPath:path];
    CGPathRelease(path);
    [_tableView.layer addSublayer:layer];
}

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
    cell.setData(gameLevel).showStarsView(YES);
    return cell;
}

#pragma mark: UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}

@end
