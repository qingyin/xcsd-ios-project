//
//  HomeworkAbilityCell.m
//  TXChatParent
//
//  Created by gaoju on 12/27/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import "HomeworkAbilityCell.h"
#import "UIImage+Rotate.h"
#import "LeftInsetLabel.h"
#import "UIColor+Hex.h"

#define KITEM_WIDTH 80
#define KITEM_HEIGHT 94

@interface HomeworkAbilityCell ()

@property (nonatomic, strong) LeftInsetLabel *titleLbl;

@property (nonatomic, strong) UIView *maxView;

@property (nonatomic, strong) UIView *gradeView;

@property (nonatomic, strong) UIView *rankView;

@property (nonatomic, strong) UIView *percentView;

@end

@implementation HomeworkAbilityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupUI];
    }
    
    return self;
}


- (void)setGameScore:(XCSDPBAbilityScoreResponseGameScore *)gameScore {
    _gameScore = gameScore;
    
    _titleLbl.text = gameScore.gameName;
    _titleLbl.textColor = [UIColor colorWithHexRGB:[gameScore.color substringFromIndex:1]];
    
    UILabel *maxLbl = [_maxView viewWithTag:100];
    maxLbl.text = [NSString stringWithFormat:@"%d", gameScore.bestLevel];
    
    UILabel *gradeLbl = [_gradeView viewWithTag:100];
    gradeLbl.text = [NSString stringWithFormat:@"%d", gameScore.score];
    
    UILabel *rankLbl = [_rankView viewWithTag:100];
    rankLbl.text = [NSString stringWithFormat:@"%d", gameScore.classRank];
    
    UILabel *percentLbl = [_percentView viewWithTag:100];
    percentLbl.text = [NSString stringWithFormat:@"%d", (int)(gameScore.percentage * 100)];
}


-(void)setupUI {
    
    _titleLbl = [[LeftInsetLabel alloc] init];
    _titleLbl.layer.borderColor = RGBCOLOR(243, 243, 243).CGColor;
    _titleLbl.layer.borderWidth = 0.5;
    _titleLbl.backgroundColor = RGBCOLOR(247, 247, 247);// RGBCOLOR(247, 247, 247)
    _titleLbl.font = [UIFont systemFontOfSize:15];
    _titleLbl.leftInset = 11;
    [self.contentView addSubview:_titleLbl];
    
    [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self.contentView);
        make.height.equalTo(@30);
    }];
    
    _maxView = [self createItemViewWithIndex:0];
    _gradeView = [self createItemViewWithIndex:1];
    _rankView = [self createItemViewWithIndex:2];
    _percentView = [self createItemViewWithIndex:3];
    
    [self.contentView addSubview:_maxView];
    [self.contentView addSubview:_gradeView];
    [self.contentView addSubview:_rankView];
    [self.contentView addSubview:_percentView];
    
    self.maxView.frame = CGRectMake(73, 30, KITEM_WIDTH, KITEM_HEIGHT);
    self.gradeView.frame = CGRectMake(kScreenWidth - KITEM_WIDTH - 73, 30, KITEM_WIDTH, KITEM_HEIGHT);
    self.rankView.frame = CGRectMake(73, 30 + KITEM_HEIGHT + 9, KITEM_WIDTH, KITEM_HEIGHT);
    self.percentView.frame = CGRectMake(kScreenWidth - KITEM_WIDTH - 73, 30 + KITEM_HEIGHT + 9, KITEM_WIDTH, KITEM_HEIGHT);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.percentView.maxY + 16, kScreenWidth, 0.5)];
    lineView.layer.backgroundColor = RGBCOLOR(243, 243, 243).CGColor;
    [self.contentView addSubview:lineView];
    
}
- (UIView *)createItemViewWithIndex: (NSInteger)index {
    
    UIView *container = [[UIView alloc] init];
    
    UIImage *image;
    NSString *desc;
    
    switch (index) {
        case 0:
            image = [UIImage imageNamed:@"lc_Level_d_01"];
            desc = @"最高关卡";
            break;
        case 1:
            image = [UIImage imageNamed:@"lc_Level_d_02"];
            desc = @"学能积分";
            break;
        case 2:
            image = [UIImage imageNamed:@"lc_Level_d_03"];
            desc = @"班级排名";
            break;
        case 3:
            image = [UIImage imageNamed:@"lc_Level_d_04"];
            desc = @"超过百分比";
            break;
        default:
            break;
    }
    
    UIImageView *iconImage = [[UIImageView alloc] initWithImage:image];
    [iconImage sizeToFit];
    [container addSubview:iconImage];
    
    
    iconImage.frame = CGRectMake((KITEM_WIDTH - image.size.width) / 2, 8, image.size.width, image.size.height);
    
    UILabel *scoreLbl = [[UILabel alloc] init];
    scoreLbl.tag = 100;
    scoreLbl.text = @"0";
    scoreLbl.font = [UIFont systemFontOfSize:19];
    scoreLbl.textAlignment = NSTextAlignmentCenter;
    scoreLbl.textColor = RGBCOLOR(72, 72, 72);
    [container addSubview:scoreLbl];
    
    scoreLbl.frame = CGRectMake(0, iconImage.maxY + 4, KITEM_WIDTH, 17);
    
    UILabel *desLbl = [[UILabel alloc] init];
    desLbl.text = desc;
    desLbl.font = [UIFont systemFontOfSize:14];
    desLbl.textColor = RGBCOLOR(98, 98, 98);
    desLbl.textAlignment = NSTextAlignmentCenter;
    [container addSubview:desLbl];
    
    desLbl.frame = CGRectMake(0, scoreLbl.maxY + 3, KITEM_WIDTH, 14);
    return container;
}

@end
