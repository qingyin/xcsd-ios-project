//
//  THSpecialistInfoViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/30.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THSpecialistInfoViewController.h"
#import "UIImageView+EMWebCache.h"
#import "THAskQuestionViewController.h"
#import "THSpecialistAnsweredQuestionsViewController.h"
#import "THSpecialistArticlesViewController.h"
#import "NSString+Additions.h"
#import "THNumberButton.h"
#import "NSObject+EXTParams.h"
#import "THAnswerDetailViewController.h"
#import "THGuideArticleDetailViewController.h"
#import <SDiPhoneVersion.h>

static NSInteger const kAnswerButtonTag = 100;
static NSInteger const kArticleButtonTag = 200;
static NSInteger const kLikeNumberButtonTag = 50;

@interface THSpecialistInfoViewController ()
<UIScrollViewDelegate>
{
    BOOL _hasMoreQuestions;
    BOOL _hasMoreArticles;
    NSInteger _infoDescLineNumbers;
    BOOL _isInfoDescExpand;
    CGFloat _topBgHeight;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIView *navigationBarView;

@property (nonatomic,strong) UIImageView *avatarImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *positionLabel;
@property (nonatomic,strong) UILabel *descLabel;

@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UIView *infoView;
@property (nonatomic,strong) UIView *questionView;
@property (nonatomic,strong) UIView *articleView;
@property (nonatomic,strong) CustomButton *backButton;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *infoLabel;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UIButton *introExpandButton;
@property (nonatomic,strong) NSMutableArray *questions;
@property (nonatomic,strong) NSMutableArray *articles;

@end

@implementation THSpecialistInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _topBgHeight = self.view.width_ * 480 / 640;
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveQuestionAnswersUpdateNotification:) name:TeacherHelpRefreshAnswerListNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveArticleUpdateNotification:) name:TeacherHelpRefreshNewArticleNotification object:nil];
    [self setupMainContentView];
    [self setupSpecialistInfoView];
    [self setupInfoNavigationView];
    [self setupWantAskButtonView];
    [self fetchSpecialistInfo];
}
#pragma mark - UI视图创建
//创建主承载视图
- (void)setupMainContentView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.contentView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(self.view).offset(-44);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}
//创建导航视图
- (void)setupInfoNavigationView
{
    //导航视图
    self.navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, kNavigationHeight + kStatusBarHeight)];
    self.navigationBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navigationBarView];
    self.navigationBarView.alpha = 0.f;
    //标题
    self.titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, self.navigationBarView.width_, kNavigationHeight)];
    self.titleLb.backgroundColor = [UIColor clearColor];
    self.titleLb.font = KNavFontSize;
    self.titleLb.textColor = kColorNavigationTitle;
    self.titleLb.textAlignment = NSTextAlignmentCenter;
    self.titleLb.text = _expertInfo.name;
    [self.navigationBarView addSubview:self.titleLb];
    //导航分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationBarView.maxY - 0.5, self.navigationBarView.width_, 0.5)];
    lineView.backgroundColor = RGBCOLOR(0xd8, 0xd8, 0xd8);
    [self.navigationBarView addSubview:lineView];
    //返回按钮
    self.backButton = [[CustomButton alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, 100, kNavigationHeight)];
    self.backButton.showBackArrow = YES;
    self.backButton.tag = TopBarButtonLeft;
    self.backButton.adjustsImageWhenHighlighted = NO;
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.backButton.titleLabel.font = kFontMiddle;
    self.backButton.titleEdgeInsets = UIEdgeInsetsMake(0, kEdgeInsetsLeft - 4, 0, 0);
    self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, kEdgeInsetsLeft, 0, 0);
    self.backButton.exclusiveTouch = YES;
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setTitleColor:kColorBlack forState:UIControlStateNormal];
    [self.backButton setTitleColor:kColorNavigationTitleDisable forState:UIControlStateDisabled];
    [self.backButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
}
//创建个人信息视图
- (void)setupSpecialistInfoView
{
    //背景图
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.image = [UIImage imageNamed:@"zjInfobj.jpg"];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bgImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@(_topBgHeight));
        //设置contentview的底部
        make.bottom.equalTo(self.contentView);
    }];
    //头像头像背景
    CGFloat startY = 80;
    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        startY = 110;
    }else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        startY = 130;
    }
    UIView *avatarBgView = [[UIView alloc] init];
    avatarBgView.backgroundColor = RGBACOLOR(0xff, 0xff, 0xff, 0.3);
    avatarBgView.layer.cornerRadius = 4;
    avatarBgView.layer.masksToBounds = YES;
    [self.bgImageView addSubview:avatarBgView];
    [avatarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@(startY - 2));
        make.width.equalTo(@64);
        make.height.equalTo(@64);
    }];
    //头像
    self.avatarImageView = [[UIImageView alloc] init];
    self.avatarImageView.layer.cornerRadius = 4.f;
    self.avatarImageView.layer.masksToBounds = YES;
    if (_expertInfo) {
        NSString *formatAvatarString = [_expertInfo.avatar getFormatPhotoUrl:120 hight:120];
        [self.avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatAvatarString] placeholderImage:[UIImage imageNamed:@"jsb_specialdefault"]];
    }else{
        self.avatarImageView.image = [UIImage imageNamed:@"jsb_specialdefault"];
    }
    [self.bgImageView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@(startY));
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    //名称
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = kColorWhite;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nameLabel.layer.shadowOffset = CGSizeMake(0, 2);
    self.nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.nameLabel.layer.shadowOpacity = 0.2;
    if (_expertInfo) {
        self.nameLabel.text = _expertInfo.name;
    }
    [self.bgImageView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(avatarBgView.mas_bottom).offset(8);
    }];
    //职位
    self.positionLabel = [[UILabel alloc] init];
    self.positionLabel.backgroundColor = [UIColor clearColor];
    self.positionLabel.textAlignment = NSTextAlignmentCenter;
    self.positionLabel.textColor = kColorWhite;
    self.positionLabel.font = [UIFont systemFontOfSize:12];
    if (_expertInfo) {
        self.positionLabel.text = _expertInfo.title;
    }
    self.positionLabel.layer.shadowOffset = CGSizeMake(0, 2);
    self.positionLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.positionLabel.layer.shadowOpacity = 0.2;
    [self.bgImageView addSubview:self.positionLabel];
    [self.positionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(_nameLabel.mas_bottom).offset(4);
    }];
    //简介
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.backgroundColor = [UIColor clearColor];
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    self.descLabel.textColor = kColorWhite;
    self.descLabel.font = [UIFont systemFontOfSize:14];
    if (_expertInfo) {
        self.descLabel.text = _expertInfo.sign;
    }
    self.descLabel.layer.shadowOffset = CGSizeMake(0, 2);
    self.descLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.descLabel.layer.shadowOpacity = 0.2;
    [self.bgImageView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(_positionLabel.mas_bottom).offset(14);
    }];
}
//创建个人简介视图
- (void)setupPersonalIntrolView
{
    //计算有多少行
    NSString *descString = _expertInfo.pb_description;
    _infoDescLineNumbers = [descString numberOfLinesWithConstrainedToWidth:self.view.width_ - 20 fromFont:[UIFont systemFontOfSize:14] lineSpace:6];
//    NSLog(@"个人简介行数是:%@",@(_infoDescLineNumbers));
    //背景视图
    self.infoView = [[UIView alloc] init];
    self.infoView.backgroundColor = kColorWhite;
    [self.contentView addSubview:self.infoView];
    //简介内容
    UIView *imgView = [[UIView alloc] init];
    imgView.backgroundColor = RGBCOLOR(0xff, 0x93, 0x3d);
    [self.infoView addSubview:imgView];
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = KColorTitleTxt;
    tipLabel.text = @"个人简介";
    [self.infoView addSubview:tipLabel];
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.backgroundColor = [UIColor clearColor];
    self.infoLabel.font = [UIFont systemFontOfSize:14];
    self.infoLabel.textColor = KColorTitleTxt;
    self.infoLabel.numberOfLines = 3;
    self.infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.infoLabel.preferredMaxLayoutWidth = self.view.width_ - 20;
    //设置AttributesString
    UIFont *font = [UIFont systemFontOfSize:14];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 
                                 NSForegroundColorAttributeName:KColorTitleTxt,
                                 NSBackgroundColorAttributeName:[UIColor clearColor],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 };
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:descString attributes:attributes];
    self.infoLabel.attributedText = attString;
    [self.infoView addSubview:self.infoLabel];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@8);
        make.width.equalTo(@2);
        make.bottom.equalTo(tipLabel);
    }];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(5);
        make.top.equalTo(imgView);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.infoView).offset(10);
        make.top.equalTo(tipLabel.mas_bottom).offset(10);
        make.right.equalTo(self.infoView).offset(-10);
    }];
    //查看更多按钮
    if (_infoDescLineNumbers > 3) {
        //大于3行，显示查看更多
        self.introExpandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.introExpandButton.backgroundColor = [UIColor clearColor];
        self.introExpandButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.introExpandButton setTitleColor:RGBCOLOR(0x83, 0x83, 0x83) forState:UIControlStateNormal];
        [self.introExpandButton setTitle:@"查看更多" forState:UIControlStateNormal];
        [self.introExpandButton addTarget:self action:@selector(onIntroDescriptionExpandButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.infoView addSubview:self.introExpandButton];
        [self.introExpandButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_infoLabel.mas_bottom).offset(10);
            make.right.equalTo(@(-10));
            make.height.equalTo(@15);
        }];
        [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(_bgImageView.mas_bottom).offset(5);
//            make.height.equalTo(@109);
            make.bottom.equalTo(_introExpandButton).offset(10);
        }];
    }else{
        [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.top.equalTo(_bgImageView.mas_bottom).offset(5);
//            make.height.equalTo(@109);
            make.bottom.equalTo(_infoLabel).offset(10);
        }];
    }
}
//回答的问题视图
- (void)setupAskedQuestionsView
{
    if ([self.questions count] == 0) {
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.infoView).offset(5);
        }];
        return;
    }
    self.questionView = [[UIView alloc] init];
    self.questionView.backgroundColor = kColorWhite;
    [self.contentView addSubview:self.questionView];
    //简介内容
    UIView *imgView = [[UIView alloc] init];
    imgView.backgroundColor = RGBCOLOR(0xff, 0x93, 0x3d);
    [self.questionView addSubview:imgView];
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = KColorTitleTxt;
    tipLabel.text = @"回答的问题";
    [self.questionView addSubview:tipLabel];
    //问题集
    NSArray *displayQuestions = [self.questions copy];
    UIView *lastView = tipLabel;
    for (int i = 0; i < [displayQuestions count]; i++) {
        TXPBQuestionAnswer *answer = displayQuestions[i];
        //按钮
        UIButton *answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        answerButton.backgroundColor = [UIColor clearColor];
        answerButton.tag = kAnswerButtonTag + i;
        [answerButton addTarget:self action:@selector(onQuestionAnswerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.questionView addSubview:answerButton];
        //标题
        UILabel *questionTitle = [[UILabel alloc] init];
        questionTitle.backgroundColor = [UIColor clearColor];
        questionTitle.font = [UIFont boldSystemFontOfSize:15];
        questionTitle.textColor = KColorTitleTxt;
        questionTitle.text = answer.questionTitle;
        [answerButton addSubview:questionTitle];
        //简介
        UIFont *font = [UIFont systemFontOfSize:14];
        UILabel *questionDesc = [[UILabel alloc] init];
        questionDesc.backgroundColor = [UIColor clearColor];
        questionDesc.font = font;
        questionDesc.textColor = KColorTitleTxt;
        questionDesc.numberOfLines = 2;
        questionDesc.preferredMaxLayoutWidth = self.view.width_ - 28;
        //设置AttributesString
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 6;
        NSDictionary *attributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:KColorTitleTxt,
                                     NSBackgroundColorAttributeName:[UIColor clearColor],
                                     NSParagraphStyleAttributeName:paragraphStyle,
                                     };
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:answer.content attributes:attributes];
        questionDesc.attributedText = attString;
        [answerButton addSubview:questionDesc];
        //赞
        int64_t thankNum = 0;
        NSNumber *extNumber = [answer extParamForKey:@"thankNum"];
        if (extNumber) {
            thankNum = [extNumber longLongValue];
        }else{
            thankNum = answer.thankNum;
        }
        BOOL isLike = NO;
        NSNumber *extLiked = [answer extParamForKey:@"hasThanked"];
        if (extLiked) {
            isLike = [extLiked boolValue];
        }else{
            isLike = answer.hasThanked;
        }
        THNumberButton *likeButton = [[THNumberButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16) normalImage:[UIImage imageNamed:@"jsb-like-a"] highlightedImage:[UIImage imageNamed:@"jsb-like-b"] selectedImage:[UIImage imageNamed:@"jsb-like-c"]];
        likeButton.backgroundColor = [UIColor clearColor];
        likeButton.tag = kLikeNumberButtonTag;
        likeButton.numberString = [NSString stringWithFormat:@"%@",@(thankNum)];
        [likeButton setSelected:isLike];
        [answerButton addSubview:likeButton];
        //设置布局
        [answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.questionView).offset(0);
            if (i == 0) {
                make.top.equalTo(lastView.mas_bottom).offset(2);
            }else{
                make.top.equalTo(lastView.mas_bottom).offset(0);
            }
        }];
        [questionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@18);
            make.right.equalTo(likeButton.mas_left).offset(-5);
            make.top.equalTo(answerButton).offset(14);
        }];
        [questionDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(questionTitle);
            make.right.equalTo(answerButton).offset(-10);
            make.top.equalTo(questionTitle.mas_bottom).offset(10);
        }];
        CGFloat likeWidth = likeButton.adjustWidth;
        [likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(questionTitle);
            make.width.equalTo(@(likeWidth));
            make.height.equalTo(@16);
            make.right.equalTo(answerButton).offset(-10);
        }];
        //分割线
        if (i != [displayQuestions count] - 1) {
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
            [answerButton addSubview:lineView];
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@18);
                make.right.equalTo(@0);
                make.height.equalTo(@kLineHeight);
                make.top.equalTo(questionDesc.mas_bottom).offset(14);
                //设置bottom
                make.bottom.equalTo(answerButton.mas_bottom);
            }];
        }else{
            //设置bottom
            [answerButton mas_updateConstraints:^(MASConstraintMaker *make) {
                //设置bottom
                make.bottom.equalTo(questionDesc.mas_bottom);
            }];
        }
        //设置lastView
        lastView = answerButton;
    }
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@16);
        make.width.equalTo(@2);
        make.bottom.equalTo(tipLabel);
    }];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(5);
        make.top.equalTo(imgView);
    }];
    if (_hasMoreQuestions) {
        //查看更多按钮
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.backgroundColor = [UIColor clearColor];
        moreButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [moreButton setTitleColor:RGBCOLOR(0x83, 0x83, 0x83) forState:UIControlStateNormal];
        [moreButton setTitle:@"查看更多" forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(onMoreQuestionsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.questionView addSubview:moreButton];
        [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView.mas_bottom).offset(12);
            make.right.equalTo(@(-10));
        }];
        //多余3个问题
        [self.questionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.top.equalTo(_infoView.mas_bottom).offset(5);
            make.bottom.equalTo(moreButton).offset(10);
        }];
    }else{
        //少于3个问题
        [self.questionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.top.equalTo(_infoView.mas_bottom).offset(5);
            make.bottom.equalTo(lastView).offset(14);
        }];
    }
    //设置contentview的底部
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.questionView).offset(5);
    }];
}
//创建文章视图
- (void)setupArticlesView
{
    if ([self.articles count] == 0) {
        if ([self.questions count] > 0) {
            //以问题的bottom为底部
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.questionView).offset(5);
            }];
        }else{
            //以简介的bottom为底部
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.infoView).offset(5);
            }];
        }
        return;
    }
    self.articleView = [[UIView alloc] init];
    self.articleView.backgroundColor = kColorWhite;
    [self.contentView addSubview:self.articleView];
    //简介内容
    UIView *imgView = [[UIView alloc] init];
    imgView.backgroundColor = RGBCOLOR(0xff, 0x93, 0x3d);
    [self.articleView addSubview:imgView];
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = KColorTitleTxt;
    tipLabel.text = @"文章";
    [self.articleView addSubview:tipLabel];
    //问题集
    NSArray *displayArticles = [self.articles copy];
    UIView *lastView = tipLabel;
    for (int i = 0; i < [displayArticles count]; i++) {
        TXPBKnowledge *knowledge = displayArticles[i];
        //按钮
        UIButton *articleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        articleButton.backgroundColor = [UIColor clearColor];
        articleButton.tag = kArticleButtonTag + i;
        [articleButton addTarget:self action:@selector(onArticleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.articleView addSubview:articleButton];

        TXPBKnowledegeContentType contentType = knowledge.contentType;
        NSString *thumb = knowledge.coverPicUrl;
        UIImageView *thumbImageView = nil;
        if (contentType == TXPBKnowledegeContentTypeKPic || contentType == TXPBKnowledegeContentTypeKVideo) {
            thumbImageView = [[UIImageView alloc] init];
            thumbImageView.backgroundColor = kColorCircleBg;
            thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
            thumbImageView.clipsToBounds = YES;
            NSString *formatThumbString = [thumb getFormatPhotoUrl:160 hight:120];
            [thumbImageView TX_setImageWithURL:[NSURL URLWithString:formatThumbString] placeholderImage:nil];
            [articleButton addSubview:thumbImageView];
            [thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
                if (i == 0) {
                    make.top.equalTo(articleButton).offset(14);
                }else{
                    make.top.equalTo(articleButton).offset(10);
                }
                make.width.equalTo(@80);
                make.height.equalTo(@60);
            }];
            //是否是视频
            if (contentType == TXPBKnowledegeContentTypeKVideo) {
                //视频半透视图
                UIView *videoBgView = [[UIView alloc] initWithFrame:CGRectZero];
                videoBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
                videoBgView.userInteractionEnabled = NO;
                [thumbImageView addSubview:videoBgView];
                //视频播放视图
                UIImageView *videoPlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
                videoPlayView.backgroundColor = [UIColor clearColor];
                videoPlayView.image = [UIImage imageNamed:@"jsb_video_player"];
                [thumbImageView addSubview:videoPlayView];
                [videoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(thumbImageView);
                }];
                [videoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@30);
                    make.height.equalTo(@30);
                    make.center.equalTo(videoBgView);
                }];

            }
        }
        //标题
        UILabel *articleTitle = [[UILabel alloc] init];
        articleTitle.backgroundColor = [UIColor clearColor];
        articleTitle.font = [UIFont boldSystemFontOfSize:15];
        articleTitle.textColor = KColorTitleTxt;
        articleTitle.text = knowledge.title;
        [articleButton addSubview:articleTitle];
        //简介
        UIFont *font = [UIFont systemFontOfSize:14];
        UILabel *articleDesc = [[UILabel alloc] init];
        articleDesc.backgroundColor = [UIColor clearColor];
        articleDesc.font = font;
        articleDesc.textColor = KColorTitleTxt;
        articleDesc.numberOfLines = 2;
        if (thumbImageView == nil) {
            articleDesc.preferredMaxLayoutWidth = self.view.width_ - 20;
        }else{
            articleDesc.preferredMaxLayoutWidth = self.view.width_ - 110;
        }
        //设置AttributesString
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4;
        NSDictionary *attributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:KColorTitleTxt,
                                     NSBackgroundColorAttributeName:[UIColor clearColor],
                                     NSParagraphStyleAttributeName:paragraphStyle,
                                     };
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:knowledge.pb_description attributes:attributes];
        articleDesc.attributedText = attString;
        [articleButton addSubview:articleDesc];
        //赞
        int64_t thankNum = 0;
        NSNumber *extNumber = [knowledge extParamForKey:@"likedNum"];
        if (extNumber) {
            thankNum = [extNumber longLongValue];
        }else{
            thankNum = knowledge.likedNum;
        }
        BOOL isLike = NO;
        NSNumber *extLiked = [knowledge extParamForKey:@"likedNum"];
        if (extLiked) {
            isLike = [extLiked boolValue];
        }else{
            isLike = knowledge.hasLiked;
        }
        THNumberButton *likeButton = [[THNumberButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16) normalImage:[UIImage imageNamed:@"jsb-like-a"] highlightedImage:[UIImage imageNamed:@"jsb-like-b"] selectedImage:[UIImage imageNamed:@"jsb-like-c"]];
        likeButton.backgroundColor = [UIColor clearColor];
        likeButton.tag = kLikeNumberButtonTag;
        likeButton.numberString = [NSString stringWithFormat:@"%@",@(thankNum)];
        [likeButton setSelected:isLike];
        [articleButton addSubview:likeButton];
        //设置布局
        [articleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.articleView).offset(0);
            if (i == 0) {
                make.top.equalTo(lastView.mas_bottom).offset(2);
            }else{
                make.top.equalTo(lastView.mas_bottom).offset(0);
            }
        }];
        [articleTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            if (thumbImageView == nil) {
                make.left.equalTo(articleButton).offset(10);
            }else{
                make.left.equalTo(thumbImageView.mas_right).offset(10);
            }
            make.right.equalTo(likeButton.mas_left).offset(-5);
            if (i == 0) {
                make.top.equalTo(articleButton).offset(15);
            }else{
                make.top.equalTo(articleButton).offset(11);
            }
        }];
        [articleDesc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(articleTitle);
            make.right.equalTo(articleButton).offset(-10);
            make.top.equalTo(articleTitle.mas_bottom).offset(6);
        }];
        CGFloat likeWidth = likeButton.adjustWidth;
        [likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(articleTitle);
            make.width.equalTo(@(likeWidth));
            make.height.equalTo(@16);
            make.right.equalTo(articleButton).offset(-10);
        }];
        //分割线
        if (i != [displayArticles count] - 1) {
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
            [articleButton addSubview:lineView];
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
                make.right.equalTo(@0);
                make.height.equalTo(@kLineHeight);
                if (thumbImageView == nil) {
                    make.top.equalTo(articleDesc.mas_bottom).offset(15);
                }else{
                    make.top.equalTo(thumbImageView.mas_bottom).offset(9);
                }
                //设置bottom
                make.bottom.equalTo(articleButton.mas_bottom);
            }];
        }else{
            //设置bottom
            if (thumbImageView == nil) {
                [articleButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(articleDesc.mas_bottom);
                }];
            }else{
                [articleButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(thumbImageView.mas_bottom);
                }];
            }
        }
        //设置lastView
        lastView = articleButton;
    }
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.top.equalTo(@16);
        make.width.equalTo(@2);
        make.bottom.equalTo(tipLabel);
    }];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(5);
        make.top.equalTo(imgView);
    }];
    if (_hasMoreArticles) {
        //查看更多按钮
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.backgroundColor = [UIColor clearColor];
        moreButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [moreButton setTitleColor:RGBCOLOR(0x83, 0x83, 0x83) forState:UIControlStateNormal];
        [moreButton setTitle:@"查看更多" forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(onMoreArticlesButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.articleView addSubview:moreButton];
        [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView.mas_bottom).offset(12);
            make.right.equalTo(@(-10));
        }];
        //多余3个文章
        [self.articleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            if ([_questions count] > 0) {
                make.top.equalTo(_questionView.mas_bottom).offset(5);
            }else{
                make.top.equalTo(_infoView.mas_bottom).offset(5);
            }
            make.bottom.equalTo(moreButton).offset(10);
        }];
    }else{
        //少于3个文章
        [self.articleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            if ([_questions count] > 0) {
                make.top.equalTo(_questionView.mas_bottom).offset(5);
            }else{
                make.top.equalTo(_infoView.mas_bottom).offset(5);
            }
            make.bottom.equalTo(lastView).offset(14);
        }];
    }
    //设置contentview的底部
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.articleView).offset(5);
    }];
}
//创建我要回答视图
- (void)setupWantAskButtonView
{
    UIButton *askButton = [UIButton buttonWithType:UIButtonTypeCustom];
    askButton.backgroundColor = [UIColor whiteColor];
    askButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [askButton setImage:[UIImage imageNamed:@"jsb-tw-a"] forState:UIControlStateNormal];
    [askButton setImage:[UIImage imageNamed:@"jsb-tw-b"] forState:UIControlStateHighlighted];
    [askButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [askButton setTitleColor:RGBCOLOR(0x7a, 0x8b, 0x9b) forState:UIControlStateNormal];
    [askButton setTitle:@"我要提问" forState:UIControlStateNormal];
    [askButton addTarget:self action:@selector(onAskQuestionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:askButton];
    UIView *lineView = [UIView new];
    lineView.backgroundColor = RGBCOLOR(219, 219, 219);
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@(kLineHeight));
        make.top.equalTo(askButton);
    }];
    [askButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(@0);
        make.height.equalTo(@44);
    }];
}
- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}
//刷新顶部个人信息
- (void)updateExpertInfoView
{
    if (_expertInfo) {
        NSString *formatAvatarString = [_expertInfo.avatar getFormatPhotoUrl:120 hight:120];
        [self.avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatAvatarString] placeholderImage:[UIImage imageNamed:@"jsb_specialdefault"]];
        self.nameLabel.text = _expertInfo.name;
        self.positionLabel.text = _expertInfo.title;
        self.descLabel.text = _expertInfo.sign;
    }
}
#pragma mark - 通知处理
- (void)onReceiveQuestionAnswersUpdateNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo && [[userInfo allKeys] containsObject:@"answerId"]) {
        int64_t answerId = [userInfo[@"answerId"] longLongValue];
        [self updateQuestionViewWithAnswerId:answerId];
    }
}
- (void)onReceiveArticleUpdateNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo && [[userInfo allKeys] containsObject:@"knowledgeId"]) {
        int64_t knowledgeId = [userInfo[@"knowledgeId"] longLongValue];
        [self updateArticleViewWithKnowledgeId:knowledgeId];
    }
}
//刷新对应的问题界面
- (void)updateQuestionViewWithAnswerId:(int64_t)answerId
{
    __block NSInteger index = -1;
    //查找index
    @synchronized(self.questions) {
        [self.questions enumerateObjectsUsingBlock:^(TXPBQuestionAnswer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.id == answerId) {
                //喜欢该条回答
                index = idx;
                *stop = YES;
            }
        }];
    }
    if (index != -1) {
        //刷新按钮
        TXPBQuestionAnswer *answer = self.questions[index];
        UIButton *answerButton = [self.questionView viewWithTag:kAnswerButtonTag + index];
        THNumberButton *likeButton = [answerButton viewWithTag:kLikeNumberButtonTag];
        if (likeButton) {
            //刷新
            int64_t thankNum = 0;
            NSNumber *extNumber = [answer extParamForKey:@"thankNum"];
            if (extNumber) {
                thankNum = [extNumber longLongValue];
            }else{
                thankNum = answer.thankNum;
            }
            BOOL isLike = NO;
            NSNumber *extLiked = [answer extParamForKey:@"hasThanked"];
            if (extLiked) {
                isLike = [extLiked boolValue];
            }else{
                isLike = answer.hasThanked;
            }
            likeButton.numberString = [NSString stringWithFormat:@"%@",@(thankNum)];
            [likeButton setSelected:isLike];
            //更新frame
            CGFloat likeWidth = likeButton.adjustWidth;
            [likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(likeWidth));
            }];
        }
    }
}
//刷新对应的文章界面
- (void)updateArticleViewWithKnowledgeId:(int64_t)knowledgeId
{
    __block NSInteger index = -1;
    //查找index
    @synchronized(self.articles) {
        [self.articles enumerateObjectsUsingBlock:^(TXPBKnowledge *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.id == knowledgeId) {
                //喜欢该条回答
                index = idx;
                *stop = YES;
            }
        }];
    }
    if (index != -1) {
        //刷新按钮
        TXPBKnowledge *knowledge = self.articles[index];
        UIButton *answerButton = [self.articleView viewWithTag:kArticleButtonTag + index];
        THNumberButton *likeButton = [answerButton viewWithTag:kLikeNumberButtonTag];
        if (likeButton) {
            //刷新
            int64_t likeNum = 0;
            NSNumber *extNumber = [knowledge extParamForKey:@"likedNumer"];
            if (extNumber) {
                likeNum = [extNumber longLongValue];
            }else{
                likeNum = knowledge.likedNum;
            }
            BOOL isLike = NO;
            NSNumber *extLiked = [knowledge extParamForKey:@"hasLike"];
            if (extLiked) {
                isLike = [extLiked boolValue];
            }else{
                isLike = knowledge.hasLiked;
            }
            likeButton.numberString = [NSString stringWithFormat:@"%@",@(likeNum)];
            [likeButton setSelected:isLike];
            //更新frame
            CGFloat likeWidth = likeButton.adjustWidth;
            [likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(likeWidth));
            }];
        }
    }
}
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//提问问题按钮
- (void)onAskQuestionButtonTapped
{
    THAskQuestionViewController *askVc = [[THAskQuestionViewController alloc] init];
    if (_expertInfo.specialities && [_expertInfo.specialities count] > 0) {
        askVc.tag = _expertInfo.specialities[0];
    }
    askVc.backVc = self;
    askVc.forbiddenChangeTag = YES;
    askVc.expertId = _expertInfo.id;
    [self.navigationController pushViewController:askVc animated:YES];

//    THQuestionSelectTagViewController *vc = [[THQuestionSelectTagViewController alloc] init];
//    vc.backVc = self;
//    vc.tagsArray = _expertInfo.specialities;
//    [self.navigationController pushViewController:vc animated:YES];
}
//查看更多个人信息
- (void)onIntroDescriptionExpandButtonTapped:(UIButton *)btn
{
    self.infoLabel.numberOfLines = _isInfoDescExpand ? 3 : 0;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (_isInfoDescExpand) {
            //已经展开
            [btn setTitle:@"查看更多" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"收起" forState:UIControlStateNormal];
        }
        _isInfoDescExpand = !_isInfoDescExpand;
    }];
}
//查看更多回答的问题
- (void)onMoreQuestionsButtonTapped
{
    THSpecialistAnsweredQuestionsViewController *questionVc = [[THSpecialistAnsweredQuestionsViewController alloc] initWithSpecialist:_expertInfo];
    [self.navigationController pushViewController:questionVc animated:YES];
}
//查看更多文章
- (void)onMoreArticlesButtonTapped
{
    THSpecialistArticlesViewController *articlesVc = [[THSpecialistArticlesViewController alloc] init];
    [self.navigationController pushViewController:articlesVc animated:YES];
}
//点击了问题按钮
- (void)onQuestionAnswerButtonTapped:(UIButton *)btn
{
    NSInteger index = btn.tag - kAnswerButtonTag;
    TXPBQuestionAnswer *answer = self.questions[index];
    THAnswerDetailViewController *questionVc = [[THAnswerDetailViewController alloc] init];
    questionVc.questionAnswer = answer;
    [self.navigationController pushViewController:questionVc animated:YES];
}
//点击了文章按钮
- (void)onArticleButtonTapped:(UIButton *)btn
{
    NSInteger index = btn.tag - kArticleButtonTag;
    TXPBKnowledge *knowledge = self.articles[index];
    THGuideArticleDetailViewController *articleVc = [[THGuideArticleDetailViewController alloc] init];
    articleVc.knowledge = knowledge;
    [self.navigationController pushViewController:articleVc animated:YES];
}
#pragma mark - 数据获取+处理
//更新布局
- (void)updatePreviousInfoView
{
    [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@(_topBgHeight));
    }];
}
//获取专家详情信息
- (void)fetchSpecialistInfo
{
    [self.view addSubview:self.indicatorView];
    self.indicatorView.center = self.view.center;
    [self.indicatorView startAnimating];
    [[TXChatClient sharedInstance].txJsbMansger fetchExpertDetailsWithExpertId:_expertInfo ? _expertInfo.id : _expertUserId onCompleted:^(NSError *error, TXPBExpert *expert, NSArray *answers, BOOL hasMoreAnswer, NSArray *knowledge, BOOL hasMoreKnowledge) {
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            self.expertInfo = expert;
            self.questions = [NSMutableArray arrayWithArray:answers];
//            self.articles = [NSMutableArray arrayWithArray:knowledge];
            _hasMoreQuestions = hasMoreAnswer;
//            _hasMoreArticles = hasMoreKnowledge;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicatorView stopAnimating];
                [self.indicatorView removeFromSuperview];
                self.indicatorView = nil;
                [self updatePreviousInfoView];
                [self updateExpertInfoView];
                [self setupPersonalIntrolView];
                [self setupAskedQuestionsView];
//                [self setupArticlesView];
            });
        }
    }];
}
#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        self.navigationBarView.alpha = 0.f;
    }else if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 120) {
        CGFloat alpha = scrollView.contentOffset.y / 120.f;
        self.navigationBarView.alpha = alpha;
    }else{
        self.navigationBarView.alpha = 1.f;
    }
    //顶部header效果
    CGFloat delta = 0.f;
    if (scrollView.contentOffset.y < 0.f) {
        delta = fabs(MIN(0.f, scrollView.contentOffset.y));
    }
    CGRect frame = self.bgImageView.frame;
    frame.origin.y = -delta;
    frame.size.height = _topBgHeight + delta;
    self.bgImageView.frame = frame;

}
@end
