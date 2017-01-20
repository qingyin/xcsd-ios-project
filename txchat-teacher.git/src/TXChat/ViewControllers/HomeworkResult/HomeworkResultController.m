//
//  HomeworkResultController.m
//  TXChatParent
//
//  Created by gaoju on 16/7/11.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkResultController.h"
#import "UIColor+Hex.h"
#import "UILabel+ContentSize.h"
#import "UIImage+LMExtension.h"
#import "JYRadarChart.h"
#import "XCSDProgressView.h"
#import "UIImage+Rotate.h"
#import "HomeworkAblityDetailController.h"
#import "LineChartsView.h"
#import "TXChatClient.h"
#import "XCSDLearningAbilityManager.h"
#import "SchoolAgeInfo.h"
#import "XCSDLearningAbility.pb.h"
#import "XCSDPopView.h"
#import "KLCPopup.h"
#import "TXChatClient+Deprecated.h"
#import "HomeworkExplainController.h"
#import "UIView+Utils.h"
#import "HomeworkResultCompareController.h"


#define kProgress_Height 25

#define K_selfLevelStr @"HomeworkResultController_selfLevelStr"
#define K_averageLevelStr @"HomeworkResultController_averageLevelStr"
#define K_percentStr @"HomeworkResultController_percentStr"
#define K_scoreStr @"HomeworkResultController_scoreStr"
#define K_nameStr @"HomeworkResultController_nameStr"
#define K_scoreandMaxSocre @"HomeworkResultController_scoreandMaxSocre"
#define k_abilityQuotient @"HomeworkResultController_abilityQuotient"
#define k_maxAbilityQuotient @"HomeworkResultController_maxAbilityQuotient"
#define k_pointsStr @"HomeworkResultController_pointsStr"
#define k_pointsXStr @"HomeworkResultController_pointsXStr"
#define k_totalAbilityLevel @"HomeworkResultController_totalAbilityLevel"

static NSString *memory = @"记忆力";
static NSString *attention = @"注意力";
static NSString *reaction = @"反应力";
static NSString *reasoning = @"逻辑力";
static NSString *spatialThinking = @"空间思维";
static NSString *total = @"学能总成绩";

typedef NS_ENUM(NSUInteger, ViewType) {
    ViewTypeAttention,
    ViewTypeMemory,
    ViewTypeReaction,
    ViewTypeReasoning,
    ViewTypeSpatialThinking,
};

static inline NSString *changetEnumToString(XCSDPBAbility ability){
    switch (ability) {
        case XCSDPBAbilityMemory:
            return memory;
        case XCSDPBAbilityAttention:
            return attention;
        case XCSDPBAbilityReaction:
            return reaction;
        case XCSDPBAbilityReasoning:
            return reasoning;
        case XCSDPBAbilitySpatialThinking:
            return spatialThinking;
    }
}

@interface HomeworkResultController ()<UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollV;

@property (nonatomic, assign) CGFloat currentMaxY;

@property (nonatomic, weak) UILabel *topLbl;

@property (nonatomic, strong) NSArray *botProgressArr;

@property (nonatomic, strong) NSArray *topProgressArr;

@property (nonatomic, strong) NSArray *botProData;

@property (nonatomic, assign) BOOL isLabelAnimated;

@property (nonatomic, assign) BOOL isTopProAnimated;

@property (nonatomic, assign) BOOL isBotProAnimated;

//@property (nonatomic, strong) NSArray *abilityDetailArr;

@property (nonatomic, weak) JYRadarChart *radarView;

@property (nonatomic, weak) LineChartsView *chartsView;


@property (nonatomic, weak) UILabel *avgAbilityLevelLbl;

@property (nonatomic, weak) UILabel *abilityQuotientLbl;
@property (nonatomic, weak) UILabel *maxAbilityQuotientLbl;

@property (nonatomic, weak) UILabel *gradeLbl;

@property (nonatomic, weak) UILabel *imageScoreLbl;

@property (nonatomic, strong) NSMutableDictionary *dict;

@property (nonatomic, assign) NSInteger fetchTime;

@property (nonatomic, assign) CGFloat contentSizeY;

@property (nonatomic, weak) UIButton *compareBtn;

@property (nonatomic, strong) UIButton *startBtn;

@property (nonatomic, strong) XCSDPBAbilityStatResponse * abilityDetails;

@end

@implementation HomeworkResultController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    [self addScrollView];
    
    NSString *explain = @"学能等级是通过日常作业和学能测试的综合表现得出你孩子在各项能力的高低，各个孩子的学习成绩好坏，其实和他的学习能力直接相关，根据大脑学习加工的认知功能，将学习能力分为五大能力，分别是注意力、记忆力、反应力、逻辑力、空间思维。每种能力分别为12个等级，从1到12。\n      五种能力分别对应着不同的训练游戏，我们会根据学生的学能等级水平去适配学生的训练计划，所以赶紧让你的孩子点击去做作业和测试吧。";
    [self addTitleLabelWithLeftTxt:@"学能等级" rightTxt:@"通过作业和学能测试评估" explainText:explain originY:0];
    
    NSArray *emptyArr = @[@0,@0,@0,@0,@0,];
    [self addRandarViewWithDataSource:@[emptyArr, emptyArr] attriArr:@[@"注意力", @"记忆力", @"反应力", @"逻辑力", @"空间思维"]];
    
    [self addLearnGradeView];
    
    [self addProgressViewsWithDataArr:nil];
    
    explain = @"学习通关积分根据孩子做游戏时获得的成绩相关，如果通关的游戏关卡越多，星数越多，这孩子的学能训练积分越高。";
    [self addTitleLabelWithLeftTxt:@"学能通关积分" rightTxt:@"通过游戏大厅通关获得" explainText:explain originY:self.currentMaxY];
    
    [self addProgressViewsTwo];
    
    explain = @"学能商数与孩子的学能测试成绩相关，在测试板块做学习能力测试，就可以测出学生的学习能力，并且通过多次测试展示学生学习能力的变化曲线，孩子可以根据学习能力表现针对性的训练自己相应的能力。";
    [self addTitleLabelWithLeftTxt:@"学能商数" rightTxt:@"通过学能测试获得" explainText:explain originY:self.currentMaxY];
    
    [self addScoreImage];
    
//    [self getLocalData];
    
    [self fetchData];

//    [self addStartTestButton];
}

- (void)getLocalData{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *selfStr = [defaults objectForKey:K_selfLevelStr];
//    NSString *averStr = [defaults objectForKey:K_averageLevelStr];
    NSString *percentStr = [defaults objectForKey:K_percentStr];
    NSString *scoreStr = [defaults objectForKey:K_scoreStr];
    NSString *nameStr = [defaults objectForKey:K_nameStr];
    NSString *pointsStr = [defaults objectForKey:k_pointsStr];
    NSString *pointsXStr = [defaults objectForKey:k_pointsXStr];
    
    if (!selfStr || selfStr.length == 0) {
        return;
    }
    
    NSArray *selfArr = [selfStr componentsSeparatedByString:@","];
//    NSArray *averArr = [averStr componentsSeparatedByString:@","];
    NSArray *averArr = @[@0, @0, @0, @0, @0];
    NSArray *percentArr = [percentStr componentsSeparatedByString:@","];
    NSArray *scoreArr = [scoreStr componentsSeparatedByString:@","];
    NSArray *nameArr = [nameStr componentsSeparatedByString:@","];
    NSArray *pointsArr = [pointsStr componentsSeparatedByString:@","];
    NSArray *pointsXArr = [pointsXStr componentsSeparatedByString:@","];
    NSString *abilityQuotient = [defaults objectForKey:k_abilityQuotient];
    NSString *maxAbilityQuotient = [defaults objectForKey:k_maxAbilityQuotient];
    NSString *totalAbilityLevel = [defaults objectForKey:k_totalAbilityLevel];
    
    _dict = [NSMutableDictionary dictionaryWithDictionary:@{ K_nameStr : nameArr,
                                                             K_selfLevelStr : selfArr,
                                                             K_averageLevelStr : averArr,
                                                             K_scoreStr : scoreArr,
                                                             K_percentStr : percentArr,
                                                             k_pointsXStr : pointsXArr,
                                                             k_pointsStr : pointsArr,
                                                             k_abilityQuotient : abilityQuotient,
                                                             k_maxAbilityQuotient : maxAbilityQuotient,
                                                             k_totalAbilityLevel : totalAbilityLevel,
                                                             }];
    
    [self updateDataWithDict];
    
}

- (void)fetchData{
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    
    NSDate *startTime = [NSDate date];
    
    [[TXChatClient sharedInstance] HomeworkResult:self.childId onCompleted:^(NSError *error, XCSDPBAbilityStatResponse *abilityDetails) {
        
        NSDate *endTime = [NSDate date];
        
        self.fetchTime = endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970;
       
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) {
            [self showFailedHudWithError:error];
            return ;
        }
        
        [self dealNetDataToDict:abilityDetails];
        
        [self updateDataWithDict];
        
        [self savaDataWithDict];
    }];
    
}

#pragma mark- 处理数据
- (void)dealNetDataToDict:(XCSDPBAbilityStatResponse *) abilityDetails{
    
    NSInteger arrCount = abilityDetails.details.count;
    self.abilityDetails = abilityDetails;
    
    NSMutableArray *nameArr = [NSMutableArray arrayWithCapacity:arrCount];
    NSMutableArray *selfLevelArr = [NSMutableArray arrayWithCapacity:arrCount];
//    NSMutableArray *averageLevelArr = [NSMutableArray arrayWithCapacity:arrCount];
    NSArray *averageLevelArr = @[@0, @0, @0, @0, @0];
    NSMutableArray *percentArr = [NSMutableArray arrayWithCapacity:arrCount];
    NSMutableArray *ScoreArr = [NSMutableArray arrayWithCapacity:arrCount];
    
    NSMutableArray *pointXArr = [NSMutableArray arrayWithCapacity:arrCount];
    NSMutableArray *pointsArr = [NSMutableArray arrayWithCapacity:arrCount];
    
    //    NSMutableArray *
    
    for (XCSDPBAbilityDetail *detail in abilityDetails.details) {
        
        [nameArr addObject:changetEnumToString(detail.ability)];
        [selfLevelArr addObject:@(detail.level)];
//        [averageLevelArr addObject:@(detail.avgLevel)];
        [ScoreArr addObject:[NSString stringWithFormat:@"%d/%d",(int)detail.score,(int)detail.maxScore]];
        [percentArr addObject:[NSString stringWithFormat:@"%ld%%",(long)(detail.percentage * 100)]];
    }
    
    for (XCSDPBAbilityStatResponsePoint *point in abilityDetails.abilityChart) {
        [pointXArr addObject:[NSString stringWithFormat:@"%d",(int)point.number]];
        [pointsArr addObject:[NSString stringWithFormat:@"%d",(int)point.score]];
    }
    [percentArr insertObject:[NSString stringWithFormat:@"%ld%%",(long)(abilityDetails.totalAbilityPercentage * 100)] atIndex:0];
    
    _dict = [NSMutableDictionary dictionaryWithDictionary:@{K_nameStr : nameArr,
                                                            K_selfLevelStr : selfLevelArr,
                                                            K_averageLevelStr : averageLevelArr,
                                                            K_scoreStr : ScoreArr,
                                                            K_percentStr : percentArr,
                                                            k_pointsXStr : pointXArr,
                                                            k_pointsStr : pointsArr,
                                                            k_abilityQuotient : [NSString stringWithFormat:@"%d", (int)abilityDetails.abilityQuotient],
                                                            k_maxAbilityQuotient : [NSString stringWithFormat:@"%d", (int)abilityDetails.maxAbilityQuotient],
                                                            k_totalAbilityLevel : [NSString stringWithFormat:@"%d", (int)abilityDetails.totalAbilityLevel],
                                                            }];
    
}

- (void)updateDataWithDict{
    
    NSArray *nameArr = _dict[K_nameStr];
    NSArray *selfLevelArr = _dict[K_selfLevelStr];
    NSArray *averageLevelArr = _dict[K_averageLevelStr];
    NSArray *percentArr = _dict[K_percentStr];
    NSArray *ScoreArr = _dict[K_scoreStr];
    NSArray *pointXArr = _dict[k_pointsXStr];
    NSArray *pointsArr = _dict[k_pointsStr];
    NSString *totalAbilityLevel = _dict[k_totalAbilityLevel];
    NSString *abilityQuotient = _dict[k_abilityQuotient];
    NSString *maxAbilityQuotient = _dict[k_maxAbilityQuotient];
    
    BOOL isFinished = ![totalAbilityLevel isEqualToString:@"0"];
    
    self.avgAbilityLevelLbl.text = isFinished ? [NSString stringWithFormat:@"学能总成绩为:  %@", totalAbilityLevel] : @"还没有做作业和测试!";
    
    if (isFinished) {
        [self addRandarViewWithDataSource:@[selfLevelArr.copy, averageLevelArr.copy] attriArr:nameArr.copy];
    }
    [self startProgressViewAnimation:percentArr progressArr:self.topProgressArr isPercent:YES];
    
    self.botProData = ScoreArr.copy; 
    self.abilityQuotientLbl.text = [NSString stringWithFormat:@"%@",abilityQuotient];
    self.maxAbilityQuotientLbl.text = [NSString stringWithFormat:@"%@",maxAbilityQuotient];
    
    [self addLineChartsWithPointXArr:pointXArr.copy points:pointsArr];
}

- (void)savaDataWithDict{
    
    NSArray *nameArr = _dict[K_nameStr];
    NSArray *selfLevelArr = _dict[K_selfLevelStr];
    NSArray *averageLevelArr = _dict[K_averageLevelStr];
    NSArray *percentArr = _dict[K_percentStr];
    NSArray *ScoreArr = _dict[K_scoreStr];
    NSArray *pointXArr = _dict[k_pointsXStr];
    NSArray *pointsArr = _dict[k_pointsStr];
    NSString *totalAbilityLevel = _dict[k_totalAbilityLevel];
    NSString *abilityQuotient = _dict[k_abilityQuotient];
    NSString *maxAbilityQuotient = _dict[k_maxAbilityQuotient];
    
    NSString *selfLevelStr = [selfLevelArr componentsJoinedByString:@","];
    NSString *averageLevelStr = [averageLevelArr componentsJoinedByString:@","];
    NSString *percentStr = [percentArr componentsJoinedByString:@","];
    NSString *scoreStr = [ScoreArr componentsJoinedByString:@","];
    NSString *nameStr = [nameArr componentsJoinedByString:@","];
    NSString *pointsStr = [pointsArr componentsJoinedByString:@","];
    NSString *pointsXStr = [pointXArr componentsJoinedByString:@","];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:selfLevelStr forKey:K_selfLevelStr];
    [defaults setObject:averageLevelStr forKey:K_averageLevelStr];
    [defaults setObject:percentStr forKey:K_percentStr];
    [defaults setObject:scoreStr forKey:K_scoreStr];
    [defaults setObject:nameStr forKey:K_nameStr];
    [defaults setObject:pointsStr forKey:k_pointsStr];
    [defaults setObject:pointsXStr forKey:k_pointsXStr];
    [defaults setObject:abilityQuotient forKey:k_abilityQuotient];
    [defaults setObject:maxAbilityQuotient forKey:k_maxAbilityQuotient];
    [defaults setObject:totalAbilityLevel forKey:k_totalAbilityLevel];
    
    [defaults synchronize];
}

- (void)addScrollView{
    
    UIScrollView *scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.height_, kScreenWidth, kScreenHeight - self.customNavigationView.height_)];
    self.scrollV = scrollV;
    
    scrollV.delegate = self;
    scrollV.contentSize = CGSizeMake(0, kScreenHeight - self.customNavigationView.height_);

    scrollV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollV];
}

-(void)addTitleLabelWithLeftTxt:(NSString *)leftTxt rightTxt:(NSString *)rightTxt explainText:(NSString *)explainText originY:(CGFloat) originY{
    
    UILabel *leftLbl = [UILabel labelWithFontSize:15 text:leftTxt];
    UILabel *rightLbl = [UILabel labelWithFontSize:12 text:rightTxt];
    leftLbl.textColor = [UIColor colorWithHexRGB:@"919191"];
    rightLbl.textColor = [UIColor colorWithHexRGB:@"919191"];
    
    leftLbl.font = [UIFont boldSystemFontOfSize:15];
    
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.image = [UIImage imageNamed:@"LC_question_white"];
    [imageV sizeToFit];
    
    UIButton *containView = [[UIButton alloc] initWithFrame:CGRectMake(0, originY, kScreenWidth, 30)];
    containView.backgroundColor = [UIColor colorWithHexRGB:@"f7f7f7"];
    
    [containView addSubview:leftLbl];
    [containView addSubview:rightLbl];
    [containView addSubview:imageV];
    [self.scrollV addSubview:containView];
    
    [containView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        XCSDPopView *popView = [[XCSDPopView alloc] init];
        popView.centerX = self.view.centerX;
        popView.centerY = self.view.centerY;
        popView.width_ = kScreenWidth - 2 * 10;
        popView.height_ = kScreenWidth == 320 ? 270 : 240;
        
        [popView setTitle:[NSString stringWithFormat:@"%@是什么?", leftTxt] text:explainText];
        [popView sl_setCornerRadius:5];
        
        KLCPopup *popup = [KLCPopup popupWithContentView:popView showType:KLCPopupShowTypeFadeIn dismissType:KLCPopupDismissTypeFadeOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
        [popup show];
        
    }];
    
    [leftLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containView.mas_left).offset(12);
        make.centerY.equalTo(containView.mas_centerY);
    }];
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containView.mas_right).offset(-12);
        make.centerY.equalTo(leftLbl.mas_centerY);
        make.width.height.equalTo(@23);
    }];
    [rightLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(imageV.mas_left).offset(-5);
        make.centerY.equalTo(containView.mas_centerY);
    }];
    
    self.currentMaxY = originY + 30;
}
- (void)addRandarViewWithDataSource:(NSArray *)dataArr attriArr:(NSArray *)attriArr{
    
    [self.radarView removeFromSuperview];
    self.radarView = nil;
    
    CGFloat charY = 30 + 22;
    JYRadarChart *p = [[JYRadarChart alloc] initWithFrame:CGRectMake(0, charY, kScreenWidth, 320)];
    self.radarView = p;
    
    p.dataSeries = dataArr;
    p.steps = 6;
    p.backgroundColor = [UIColor whiteColor];
    
    p.backgroundFillColor = [UIColor whiteColor];
    p.eachLineColors = @[[UIColor colorWithHexRGB:@"84bef0"], [UIColor colorWithHexRGB:@"82d04d"], [UIColor colorWithHexRGB:@"ffc24b"], [UIColor colorWithHexRGB:@"9a93f3"], [UIColor colorWithHexRGB:@"ff6f84"]];
    p.r = 110;
    p.minValue = 0;
    p.maxValue = 12;
    p.showStepText = YES;
    p.stepTextColor = [UIColor colorWithHexRGB:@"5c5c5c"];
    p.fillArea = YES;
    
    p.showLegend = YES;
    p.colorOpacity = 0.45;
    p.attributes = attriArr;
    
//    p.showLegend = YES;
    [p setTitles:@[@"学生等级", @"平均等级"]];
    [p setColors:@[[UIColor colorWithHexRGB:@"E471C7"],[UIColor colorWithHexRGB:@"5470B4"]]];
    [self.scrollV addSubview:p];
    
    [self.scrollV bringSubviewToFront:self.gradeLbl];
}

- (void)addLearnGradeView{
    
    CGFloat tmpY = 383 - 40;
    
    UILabel *gradeLbl = [[UILabel alloc] init];
    UILabel *persentLbl = [[UILabel alloc] init];
    [self.scrollV addSubview:gradeLbl];
    [self.scrollV addSubview:persentLbl];
    self.gradeLbl = gradeLbl;
    
    gradeLbl.font = [UIFont systemFontOfSize:15];
    persentLbl.font = [UIFont systemFontOfSize:15];
    
    gradeLbl.text = @"学能总成绩为";
    gradeLbl.textColor = [UIColor colorWithHexRGB:@"919191"];
    persentLbl.textColor = [UIColor colorWithHexRGB:@"5c5c5c"];
    persentLbl.text = @"超过了所在年级学生的百分比";
    
    
    UIButton *compareBtn = [[UIButton alloc] init];
    compareBtn.bounds = CGRectMake(0, 0, 163, 26);
    self.compareBtn = compareBtn;
    [compareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    compareBtn.layer.backgroundColor = [UIColor colorWithHexRGB:@"8CD0FF"].CGColor;
    compareBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [compareBtn setTitle:@"对比你的水平" forState:UIControlStateNormal];
    compareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [compareBtn sl_setCornerRadius:13];
    [self.scrollV addSubview:compareBtn];
    
    UIButton *mineBtn = [self createCompareBtn:YES title:@"我的"];
    UILabel *vsLbl = [[UILabel alloc] init];
    vsLbl.text = @"VS";
    vsLbl.textColor = [UIColor colorWithHexRGB:@"919191"];
    vsLbl.font = [UIFont systemFontOfSize:14.4];
    [vsLbl sizeToFit];
    UIButton *othersBtn = [self createCompareBtn:NO title:nil];
    
    mineBtn.hidden = YES;
    vsLbl.hidden = YES;
    othersBtn.hidden = YES;
    
    [othersBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        
        HomeworkResultCompareController *compare = [[HomeworkResultCompareController alloc] init];
        __weak typeof(compare) weakVC = compare;
        compare.onCompleted = ^(NSInteger index) {
            
            mineBtn.hidden = NO;
            vsLbl.hidden = NO;
            othersBtn.hidden = NO;
            compareBtn.hidden = YES;
            
            NSString *title = weakVC.dataArr[index];
            [othersBtn setTitle:title forState:UIControlStateNormal];
            
            NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:5];
            
            [self.abilityDetails.details enumerateObjectsUsingBlock:^(XCSDPBAbilityDetail *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [tmpArr addObject:obj.gradeAvgLevel[index]];
            }];
            
            self.dict[K_averageLevelStr] = tmpArr;
            [self updateDataWithDict];
        };
        
        [self.navigationController pushViewController:compare animated:YES];
    }];
    
    [self.scrollV addSubview:othersBtn];
    [self.scrollV addSubview:mineBtn];
    [self.scrollV addSubview:vsLbl];
    
    [mineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(compareBtn.mas_left);
        make.top.equalTo(compareBtn.mas_top);
        make.width.equalTo(@63);
        make.height.equalTo(@26);
    }];
    
    [vsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mineBtn);
        make.left.equalTo(mineBtn.mas_right).offset(2);
        make.height.equalTo(@26);
    }];
    
    [othersBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vsLbl.mas_right).offset(2);
        make.top.equalTo(mineBtn);
        make.width.equalTo(@73);
        make.height.equalTo(@26);
    }];
    
    
    [compareBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        HomeworkResultCompareController *compare = [[HomeworkResultCompareController alloc] init];
        
        
        __weak typeof(compare) weakVC = compare;
        compare.onCompleted = ^(NSInteger index) {
            
            mineBtn.hidden = NO;
            vsLbl.hidden = NO;
            othersBtn.hidden = NO;
            compareBtn.hidden = YES;
            
            NSString *title = weakVC.dataArr[index];
            [othersBtn setTitle:title forState:UIControlStateNormal];
            
            NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:5];
            
            [self.abilityDetails.details enumerateObjectsUsingBlock:^(XCSDPBAbilityDetail *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [tmpArr addObject:obj.gradeAvgLevel[index]];
            }];
            
            self.dict[K_averageLevelStr] = tmpArr;
            [self updateDataWithDict];
        };
        
        [self.navigationController pushViewController:compare animated:YES];
    }];
    
    [gradeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scrollV.mas_centerX);
        make.top.equalTo(@(tmpY));
    }];
    [compareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gradeLbl.mas_bottom).offset(12);
        make.centerX.equalTo(gradeLbl.mas_centerX);
        make.height.equalTo(@26);
        make.width.equalTo(@163);
    }];
    
    [persentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(compareBtn.mas_bottom).offset(22);
        make.centerX.equalTo(gradeLbl.mas_centerX);
    }];
    self.avgAbilityLevelLbl = gradeLbl;
}

- (UIButton *)createCompareBtn: (BOOL)isMine title: (NSString *)title {
    
    UIButton *btn = [[UIButton alloc] init];
    UIColor *titleColor = isMine? [UIColor colorWithHexRGB:@"919191"] : [UIColor colorWithHexRGB:@"8CD0FF"];
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = titleColor.CGColor;
    btn.bounds = CGRectMake(0, 0, isMine ? 63 : 146, 26);
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.4];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitle:title forState:UIControlStateNormal];
    //    [btn sl_setCornerRadius:13];
    btn.layer.cornerRadius = 13;
    
    
    return btn;
}

- (void)addProgressViewsWithDataArr:(NSArray *)dataArr{
    
    CGFloat tmpY = 435;
    CGFloat tmpHeight = (30 + kProgress_Height * 2 * 6 + 16 * 5 + 44) / 2;
    
    UIView *containV = [[UIView alloc] initWithFrame:CGRectMake(0, tmpY, kScreenWidth, tmpHeight)];
    [self.scrollV addSubview:containV];
    
    XCSDProgressView *totalP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, 15, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *firstP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, totalP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *secondP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, firstP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *thirdP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, secondP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *forthP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, thirdP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *fifthP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, forthP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    
    [containV addSubview:totalP];
    [containV addSubview:firstP];
    [containV addSubview:secondP];
    [containV addSubview:thirdP];
    [containV addSubview:forthP];
    [containV addSubview:fifthP];
    
    totalP.setProgressColor(@"db93f3").setTitle(total);
    firstP.setProgressColor(@"84bef0").setTitle(attention);
    secondP.setProgressColor(@"82d04d").setTitle(memory);
    thirdP.setProgressColor(@"ffc24b").setTitle(reaction);
    forthP.setProgressColor(@"9a93f3").setTitle(reasoning);
    fifthP.setProgressColor(@"ff6f84").setTitle(spatialThinking);
    
    self.currentMaxY = containV.maxY;
    self.topProgressArr = containV.subviews;
}

- (void)addProgressViewsTwo{
    
    CGFloat tmpY = self.currentMaxY;
    CGFloat tmpHeight = (44 + kProgress_Height * 2 * 5 + 16 * 4 + 44) / 2;
    
    UIView *containV = [[UIView alloc] initWithFrame:CGRectMake(0, tmpY, kScreenWidth, tmpHeight)];
    
    [self.scrollV addSubview:containV];
    
    XCSDProgressView *firstP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, 22, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *secondP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, firstP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *thirdP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, secondP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *forthP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, thirdP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    XCSDProgressView *fifthP = [[XCSDProgressView alloc] initWithFrame:CGRectMake(22.5, forthP.maxY + 8, kScreenWidth - 55, kProgress_Height)];
    
    [containV addSubview:firstP];
    [containV addSubview:secondP];
    [containV addSubview:thirdP];
    [containV addSubview:forthP];
    [containV addSubview:fifthP];
    
    int i = 0;
    for (XCSDProgressView *progressV in containV.subviews) {
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressViewTapGesture:)];
        progressV.tag = i;
        [progressV addGestureRecognizer:tap];
        i++;
    }
    
    firstP.setProgressColor(@"84bef0").setTitle(attention).setRightArrow();
    secondP.setProgressColor(@"82d04d").setTitle(memory).setRightArrow();
    thirdP.setProgressColor(@"ffc24b").setTitle(reaction).setRightArrow();
    forthP.setProgressColor(@"9a93f3").setTitle(reasoning).setRightArrow();
    fifthP.setProgressColor(@"ff6f84").setTitle(spatialThinking).setRightArrow();
    
    self.botProgressArr = containV.subviews;
    
    self.currentMaxY = containV.maxY;
}

- (void)progressViewTapGesture:(UITapGestureRecognizer *) tap{
    
    NSInteger tag = tap.view.tag;
    
    HomeworkAblityDetailController *vc = [[HomeworkAblityDetailController alloc] init];
    vc.userId = self.childId;
    
    switch (tag) {
        case ViewTypeAttention:
            vc.titleStr = attention;
            vc.ability = XCSDPBAbilityAttention;
            break;
        case ViewTypeReasoning:
            vc.titleStr = reasoning;
            vc.ability = XCSDPBAbilityReasoning;
            break;
        case ViewTypeMemory:
            vc.titleStr = memory;
            vc.ability = XCSDPBAbilityMemory;
            break;
        case ViewTypeReaction:
            vc.titleStr = reaction;
            vc.ability = XCSDPBAbilityReaction;
            break;
        case ViewTypeSpatialThinking:
            vc.titleStr = spatialThinking;
            vc.ability = XCSDPBAbilitySpatialThinking;
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addScoreImage{
    
    CGFloat imageViewWH = 145.5;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage mainBundleImage:@"LC_Level_01"];
    imageView.frame = CGRectMake(self.view.width_ / 2 - imageViewWH / 2, self.currentMaxY + 22, imageViewWH, imageViewWH);
    [self.scrollV addSubview:imageView];
    
    UILabel *topLbl = [UILabel labelWithFontSize:30];
    UILabel *bottomLbl = [UILabel labelWithFontSize:20];
    [imageView addSubview:topLbl];
    [imageView addSubview:bottomLbl];
    
    self.topLbl = topLbl;
    
    topLbl.textColor = [UIColor colorWithHexRGB:@"484848"];
    bottomLbl.textColor = [UIColor colorWithHexRGB:@"B7B7B7"];
    bottomLbl.text = @"5000";
    
    [topLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageView.mas_centerX);
        make.bottom.equalTo(imageView.mas_centerY);
    }];
    [bottomLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageView.mas_centerX);
        make.top.equalTo(imageView.mas_centerY).offset(10);
    }];
    
    UILabel *scoreLbl = [[UILabel alloc] init];
    [self.scrollV addSubview:scoreLbl];
    
    scoreLbl.textColor = [UIColor colorWithHexRGB:@"B7B7B7"];
    scoreLbl.frame = CGRectMake(0, imageView.maxY, kScreenWidth, 30);
    scoreLbl.textAlignment = NSTextAlignmentCenter;
    scoreLbl.font = [UIFont systemFontOfSize:15];
    scoreLbl.text = @"你的学能商数";
    self.imageScoreLbl = scoreLbl;
    
    self.currentMaxY = scoreLbl.maxY;
    self.abilityQuotientLbl = topLbl;
    self.maxAbilityQuotientLbl = bottomLbl;
}

- (void)changeNumFrom:(NSInteger)originNum to:(NSInteger)newNum animationTime:(NSInteger) time{
    
    [UIView animateWithDuration:time animations:^{
        
        self.topLbl.text = [NSString stringWithFormat:@"%ld",(long)originNum];
    } completion:^(BOOL finished) {
        
        NSInteger speed = (newNum - originNum) / 50;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.02f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (speed > 1) {
                [self changeNumFrom:originNum + speed to:newNum animationTime:time];
            }else if (newNum == originNum){
                
            }else{
                [self changeNumFrom:newNum to:newNum animationTime:time];
            }
        });
    }];
}

- (void)addLineChartsWithPointXArr:(NSArray *)pointXArr points:(NSArray *) points{
    
    [self.chartsView removeFromSuperview];
    
    if (pointXArr.count < 6) {
        pointXArr = @[@"1", @"2", @"3", @"4", @"5", @"6"];
    }
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:6];
    LineChartsView *lineView = [[LineChartsView alloc] initWithFrame:CGRectMake(0, self.currentMaxY, kScreenWidth, kScreenHeight / 2)];
    self.chartsView = lineView;
    
    NSInteger length = 0;
    Boolean isAllZero = true;
    
    for (NSString *numStr in points) {
        NSInteger num = numStr.integerValue;
        
        if (num != 0) {
            isAllZero = false;
            break;
        }
    }
    
    if (points.count == 0 || !points || isAllZero) {
        
        NSInteger tmpNum = 1200 / 6;
        
        for (NSInteger i = 0; i < 6; ++i) {
            [tmpArr addObject:[NSString stringWithFormat:@"%ld", tmpNum * i]];
        }
        
        length = 200;
    }else{
        
        NSString *numMin = points.firstObject;
        NSString *numMax = points.lastObject;
        
        
        for (NSString *numStr in points) {
            
            NSInteger num = numStr.integerValue;
            
            if (numMin.integerValue > num) {
                numMin = numStr;
            }
            
            if (numMax.integerValue < num) {
                numMax = numStr;
            }
        }
        
        NSString *min = numMin.integerValue -50 > 0 ? [NSString stringWithFormat:@"%ld", numMin.integerValue - 50] : @"0";
        NSString *max = [NSString stringWithFormat:@"%ld",(long)(numMax.floatValue * 1.5)];
        
        [tmpArr addObject:min];
        
        length = (max.integerValue - min.integerValue) / 6;
        
        for (NSInteger i = 0; i < 5; ++i) {
            [tmpArr addObject:[NSString stringWithFormat:@"%ld",min.integerValue + (i + 1) * length]];
        }
    }
    
    lineView.length = length;
    [lineView setRowDataSource:pointXArr];
    [lineView setAllPoints:points];
    [lineView setColDataSource:tmpArr.copy];

    [lineView setNeedsDisplay];
    
    [self.scrollV addSubview:lineView];
    
    self.scrollV.contentSize = CGSizeMake(0, lineView.maxY);
    self.contentSizeY = lineView.maxY;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.scrollV.contentSize = CGSizeMake(kScreenWidth, self.contentSizeY);
}

//- (void)addStartTestButton {
//    CGFloat maxY = 1454;
//    UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, maxY, kScreenWidth - 80, 40)];
//    self.startBtn = startBtn;
//    [self.scrollV addSubview:startBtn];
//    
//    [startBtn sl_setCornerRadius:5.f];
//    [startBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
//    [startBtn setBackgroundColor:KColorAppMain];
//    [startBtn setTitle:@"开始学能测试" forState:UIControlStateNormal];
//    
//    [startBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
//        
//        self.isStartTest = YES;
//        StartTestController *testVC = [[StartTestController alloc] init];
//        [self.navigationController pushViewController:testVC animated:YES];
//    }];
//    
//    self.scrollV.contentSize = CGSizeMake(0, startBtn.maxY + 10);
//    self.contentSizeY = startBtn.maxY + 10;
//}


#pragma mark: - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offSetY = scrollView.contentOffset.y + kScreenHeight;
    
    if (offSetY > kScreenHeight + 40 && !self.isBotProAnimated){
        [self startProgressViewAnimation:self.botProData progressArr:self.botProgressArr isPercent:NO];
        self.isBotProAnimated = YES;
        
    }else if (offSetY >= kScreenHeight + 300 && !self.isLabelAnimated) {
        [self changeNumFrom:1 to:self.abilityQuotientLbl.text.integerValue animationTime:4];
        self.isLabelAnimated = YES;
    }
}

- (void)startProgressViewAnimation:(NSArray *) dataArr progressArr:(NSArray *) array isPercent:(BOOL) isPercent{
    
    [array enumerateObjectsUsingBlock:^(__kindof XCSDProgressView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.setProgress(dataArr[idx], isPercent);
    }];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        HomeworkExplainController *vc = [[HomeworkExplainController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    
    self.titleStr = [NSString stringWithFormat:@"%@的成绩", self.childName];
    
//    [self.btnRight setTitle:@"权威解释" forState:UIControlStateNormal];
    
}

@end
