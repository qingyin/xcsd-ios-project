//
//  HomeworkExplainDetailController.m
//  TXChatParent
//
//  Created by gaoju on 16/7/13.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkExplainDetailController.h"
#import "UILabel+ContentSize.h"

@interface HomeworkExplainDetailController ()

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UILabel *txtLbl;

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation HomeworkExplainDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    [self initData];
    
    [self setupUI];
}

- (void)setupUI{
    
    NSInteger topMargin = 21;
    NSInteger leftRightMargin = 21;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.height_, kScreenWidth, kScreenHeight)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    UILabel *label = [self setLabelWithText:self.dataArr[self.selectedIdx] boldText:@""];
    
    CGFloat height = [UILabel heightForLabelWithText:self.dataArr[self.selectedIdx] maxWidth:kScreenWidth - 2 * 21 font:[UIFont systemFontOfSize:17]];
    label.frame = CGRectMake(leftRightMargin, topMargin, kScreenWidth - leftRightMargin * 2, height);
    [scrollView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(21);
        make.left.equalTo(self.view).offset(21);
        make.right.equalTo(self.view).offset(-21);
    }];
    
    if (self.selectedIdx == 4 && kScreenWidth == 320) {
        self.scrollView.contentSize = CGSizeMake(0, 682);
    }else if (self.selectedIdx == 2 && kScreenWidth == 320){
        self.scrollView.contentSize = CGSizeMake(0, 658);
    }
}

- (void)initData{
    
    self.dataArr = @[@"",
                     @"乐学堂致力于通过游戏训练的方式提升孩子的学习能力，学习能力是指人们在正式学习环境下使用到的各项认知能力。即当一个孩子的学习能力提高了，相应的他的学习成绩也会有显著提高。学习能力存在显著的关键发展期，在幼儿园和小学阶段，学习能力的提升速度最快，美国哈弗大学研究表明，后天的体系化训练，能够帮助孩子提高学习能力，并且随着学习能力的提高，孩子的学习方法也会相应得到改善。",
                     @"该项目依托中国儿童积极行为塑造模型（Positive Behavior Cultivation for China Infants）简称PBCCI，从小学生认知发展核心任务为切入点，将认知能力提升训练以手机游戏的形式延伸至学生课后生活，实现知识和能力的螺旋式提升。\n\nPBCCI依托美国PBS（Positive Behavior Support）积极行为支持理论，以心理学为基础，结合生理学、社会学、应用行为分析等科学，从中国教育文化特征、家庭特征、儿童智能发展及身体发育特征及需求出发，形成的具有中国特色的“中国儿童积极行为塑造模型”。旨在从能力和意愿两方面对儿童的积极行为进行塑造。",
                     @"",
                     @"PBCCI（Positive Behavior Cultivation for China Infants）——中国儿童积极行为塑造模型，是由携成尚德教育创始人王辉带领其研究团队，联合中国科学院心理研究所重点实验室郑希耕教授、苏州大学教育学院刘雅颖教授共同研发形成的。\n\n王辉：中科院心理研究所硕士，北京携成尚德教育创始人。中国PBCCI模型创建者；“减法教育”创始人；北京教委特聘“游戏化教学”项目负责人；土星教育研究院特聘心理学专家；国内青少年网络成瘾治疗（北京军区总院）发起人。",
                     ];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UILabel *)setLabelWithText:(NSString *)text boldText:(NSString *) boldText{
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = RGBCOLOR(48, 48, 48);
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = [text rangeOfString:boldText];
    
    [attr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:range];
    [attr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    label.attributedText = attr;
    self.txtLbl = label;
    [self.scrollView addSubview:label];
    
    return label;
}

@end
