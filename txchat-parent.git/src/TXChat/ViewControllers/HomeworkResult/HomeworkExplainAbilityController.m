//
//  HomeworkExplainAbilityController.m
//  TXChatParent
//
//  Created by gaoju on 16/8/3.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkExplainAbilityController.h"

@interface HomeworkExplainAbilityController ()

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UILabel *txtLbl;

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation HomeworkExplainAbilityController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    self.titleStr = self.selectIdx == 0 ? @"学能成绩指标解释" : @"五大学习能力";
    
    [self initData];
    
    [self setupUI];
}

- (void)initData{
    
    NSArray *firstArr = @[@"学能等级\n根据PBCCI理论，我们将学习能力提炼为五大能力，他们分别为：注意力、记忆力、反应力、逻辑力、空间思维。我们将每项学习能力的等级分为1-12，等级越高，学习能力越强。同时乐学堂幼儿版还提供了每个年级的学生的平均等级水平，帮助学生和老师对比该学生的学习能力高低。\n\n学能等级根据老师布置的学能作业和家长端测试版块中的学习能力测试中的综合表现得出，例如学生通过了老师布置的序列方阵游戏的第五关，而序列方阵第五关对应的是注意力等级3；而在学能测试中学生通过了注意力等级为4的测试，则最终该学生注意力获得的学能等级为4。\n",
                          @"学能总成绩\n学能总成绩为五大学习能力的等级总分，所以学能总成绩的最高分为60分，乐学堂幼儿版会根据学生的学能总成绩来布置相应的作业，来帮助学生定制化的提高自己的学习能力水平。 \n",
                          @"学能商数\n学生可以在家长端的测试版块做学习能力测试，学习能力测试通过游戏的方式测量学生在五大能力上的水平，从而得出总体的学能商数得分，为了使学生能够取得进步，乐学堂幼儿版的学习能力测试会根据学生目前的学习能力来定制化的发布不同的测试题，以帮助学生逐步的提高自己的学习能力。例如学生目前的注意力等级为3，则测试中会给学生发送注意力等级为4的试题，以判断学生是否能够通过该水平。\n"];
    
    NSArray *secondArr = @[@"注意力\n注意力是心理活动和各种感觉器官对客观事物的关注能力。在学生听课和学习过程中最基础的能力就是注意力。俄罗斯教育家乌申斯基曾精辟地指出：“‘注意’是我们心灵的惟一门户，意识中的一切，必然都要经过它才能进来。”学生上课是否溜号，能够同时加工几件事情，能够瞬间注意到多少数字等都与注意力紧密相关。\n",
                          @"记忆力\n记忆力也就是人脑对外界输入的信息进行编码、存储和提取的过程。是学生学习和生活的基本技能。记忆力分为短时记忆和长时记忆。\n",
                          @"反应力\n反应力是大脑受到体内或体外的刺激引起的相应活动。提高快速反应能力，有助于提高大脑的灵活性和协调性。很多游戏都能够训练孩子的反应能力，例如常玩的手机游戏“别踩白块”等。\n",
                           @"逻辑力\n逻辑能力强的人，在分析问题、看待问题时善于抓住问题的本质。因为他们的脑回路能在较短时间内快速厘清事情的来龙去脉，他们对于各种逻辑关系非常娴熟，既能从A推导到B再到C，也能从C反推回A，这一点是”思路清晰“这点的本质。\n",
                           @"空间思维\n空间思维也是五大学习能力中的高级能力，是指跳出点、线、面的限制，能从上下左右，四面八方去思考问题的思维方式，也就是要“立起来思考”。\n"];
    
    _dataArr = @[
                 @{@"title" : @"",
                   @"text" : firstArr},
                 @{@"title" : @"在学习的各项能力中，以下五种能力是国际认可的最基础的五项：",
                   @"text" : secondArr},
                 ];
}

- (void)setupUI{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.height_, kScreenWidth, kScreenHeight)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    NSDictionary *dict = self.selectIdx == 0 ? _dataArr[0] : _dataArr[1];
    
    NSString *text = dict[@"title"];
    UILabel *label = [self setLabelWithText:text boldText:@""];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_top).offset(17);
        make.left.equalTo(self.view.mas_left).offset(21);
        make.right.equalTo(self.view.mas_right).offset(-21);
    }];
    
    NSArray *texts = dict[@"text"];
    NSMutableArray *labelArr = [NSMutableArray arrayWithCapacity:5];
    
    for (NSInteger i = 0; i < texts.count; i++) {
        
        NSString *content = [texts objectAtIndex:i];
        
        NSString *boldText = [content substringWithRange:NSMakeRange(0, [content rangeOfString:@"\n"].location)];
        UILabel *label2 = [self setLabelWithText:content boldText:boldText];
        [labelArr addObject:label2];
        
        if (i == 0) {
            [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(label.mas_bottom).offset(17);
                make.left.equalTo(self.view.mas_left).offset(21);
                make.right.equalTo(self.view.mas_right).offset(-21);
            }];
        }else{
            
            UILabel *previousLbl = [labelArr objectAtIndex:i - 1];
            [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(previousLbl.mas_bottom).offset(17);
                make.left.equalTo(self.view.mas_left).offset(21);
                make.right.equalTo(self.view.mas_right).offset(-21);
            }];
        }
    }
    
    NSInteger height = kScreenWidth == 320 ? 1400 : 1300;
    
    self.scrollView.contentSize = self.selectIdx == 0  ?  CGSizeMake(0, height - 50) : CGSizeMake(0, height);
}

- (UILabel *)setLabelWithText:(NSString *)text{
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = RGBCOLOR(48, 48, 48);
    label.font = [UIFont systemFontOfSize:15];
    label.text = text;
    label.numberOfLines = 0;
    [label sizeToFit];
    self.txtLbl = label;
    [self.scrollView addSubview:label];
    
    return label;
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
    
    [attr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:19] range:range];
    [attr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    label.attributedText = attr;
    self.txtLbl = label;
    [self.scrollView addSubview:label];
    
    return label;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
