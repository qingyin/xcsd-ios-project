//
//  StartTestController.m
//  TXChatParent
//
//  Created by gaoju on 16/7/19.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "StartTestController.h"
#import "UIView+Utils.h"
#import "GameManager.h"
#import "XCSDTestManager.h"
#import "UIImage+Rotate.h"

@interface StartTestController ()

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UIImageView *imgView;

@property (nonatomic, weak) UILabel *textLbl;

@property (nonatomic, weak) UIButton *startBtn;

@property (nonatomic, strong) NSString *gameList;

@property (nonatomic, assign) BOOL isFirstTest;

@property (nonatomic, assign) SInt64 testId;

@end

@implementation StartTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createCustomNavBar];
    
    self.titleStr = @"学习能力测试";
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self fetchData];
}

- (void)fetchData{
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    
    @weakify(self);
    [XCSDTestManager fetchTest:[self getCurrentChildInfo] onCompleted:^(NSError *error, XCSDPBGameTestResponse *response) {
        @strongify(self);
        
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *gameList = [NSString string];
        
        for (NSInteger i = 0; i < response.gameLevel.count; ++i) {
            
            XCSDPBGameLevel *level = response.gameLevel[i];
            gameList = [gameList stringByAppendingFormat:@"%lld#%d$%d_", level.gameId, level.level, level.abilityId];
            
            NSString *trueOrFalse = level.hasGuide ? @"true" : @"false";
            gameList = [gameList stringByAppendingString:[NSString stringWithFormat:@"%@;", trueOrFalse]];
        }
        
        self.gameList = gameList;
        self.isFirstTest = response.isFirstTest;
        self.testId = response.testId;
    }];
}

- (void)setupUI{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.height_, kScreenWidth, kScreenHeight - self.customNavigationView.height_)];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    CGFloat imgViewX = (kScreenWidth - 300) / 2;
    CGFloat imgViewY = self.customNavigationView.height_ + 40;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, 300, 196)];
    self.imgView = imgView;
    //    imgView.image = [UIImage imageNamed:@"lc_pic"];
    imgView.image = [UIImage mainBundleImage:@"lc_pic"];
    [self.scrollView addSubview:imgView];
    
    UILabel *textLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, imgView.maxY + 40, kScreenWidth - 20, 10)];
    
    self.textLbl = textLbl;
    textLbl.numberOfLines = 0;
    textLbl.font = [UIFont systemFontOfSize:15];
    textLbl.textColor = RGBCOLOR(72, 72, 72);
    textLbl.text = @"        学能测试是测量你的学习能力商数.通过学能测试你可以了解自己在各个能力上的等级以及变化 你也可以和班级其他用户比较,做出最好的训练计划";
    [textLbl sizeToFit];
    [self.scrollView addSubview:textLbl];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(40, textLbl.maxY + 40, kScreenWidth - 80, 40)];
    //    btn.frame = CGRectMake(40, kScreenHeight - startBtnH - 8, startBtnW, startBtnH);
    [btn sl_setCornerRadius:5.f];
    [btn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [btn setBackgroundColor:KColorAppMain];
    [btn setTitle:@"开始测试" forState:UIControlStateNormal];
    self.startBtn = btn;
    [self.scrollView addSubview:btn];

    @weakify(self);
    [_startBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        
        if (!self.gameList || self.gameList.length == 0) {
            [self showFailedHudWithTitle:@"测试列表为空"];
            return ;
        }
        UIViewController *gameManager = [[GameManager getInstance] createGameTestViewController:self.gameList isFirstTest:self.isFirstTest testId:self.testId];
        
        NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [viewcontrollers removeLastObject];
        [viewcontrollers addObject:gameManager];
            
        [self.navigationController setViewControllers:viewcontrollers];
    }];
}

-(NSInteger)getCurrentChildInfo
{
    TXUser * user = [[TXChatClient sharedInstance]getCurrentUser:nil];
    TXPBChild *child;
    
    if ([user.childUserIdAndRelationsList count] == 0) {
        //         todo
    }
    else
    {
        child= (TXPBChild*)user.childUserIdAndRelationsList[0];
    }
    
    return child.userId;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, self.startBtn.maxY + 10);
}

@end
