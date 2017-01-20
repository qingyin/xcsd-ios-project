//
//  HomeworkAbilityDetailCell.m
//  TXChatParent
//
//  Created by gaoju on 16/7/13.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkAbilityDetailCell.h"
#import "UILabel+ContentSize.h"
#import "UIColor+Hex.h"
#import "UIImage+Rotate.h"

#define kVertical_Margin 10
#define kHorizontal_Margin 20

@interface HomeworkAbilityDetailCell ()

@property (nonatomic, weak) UILabel *gameLevelLbl;

@property (nonatomic, weak) UILabel *bottomLbl;

@property (nonatomic, weak) UILabel *centerLbl;

@property (nonatomic, weak) UIImageView *imageV;

@end

@implementation HomeworkAbilityDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setGameScore:(XCSDPBAbilityScoreResponseGameScore *)gameScore{
    
    NSString *labelText = [NSString stringWithFormat:@"%@:  %d", gameScore.gameName, gameScore.score];
    NSMutableAttributedString *strAtt = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSRange gameStrRange = NSMakeRange(0, [labelText rangeOfString:@":"].location + 1);
    [strAtt addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexRGB:[gameScore.color substringFromIndex:1]] range:gameStrRange];
    self.gameLevelLbl.attributedText = strAtt;
    
    self.centerLbl.text = [NSString stringWithFormat:@"%d", (int)gameScore.bestLevel];
    self.bottomLbl.text = [NSString stringWithFormat:@"超过%d%%的你所在年级的用户", (int)(gameScore.percentage * 100)];
}

- (void)setupUI{
    
    UILabel *gameLevelLbl = [UILabel labelWithFontSize:15];
    UILabel *centerLbl = [UILabel labelWithFontSize:40];
    UILabel *bottomLbl = [UILabel labelWithFontSize:15];
    UIImageView *imageV = [[UIImageView alloc] init];
    UIView *separtorV = [[UIView alloc] init];
    
    centerLbl.font = [UIFont boldSystemFontOfSize:40];
    gameLevelLbl.font = [UIFont boldSystemFontOfSize:15];
    
    separtorV.layer.backgroundColor = [UIColor colorWithHexRGB:@"d8d8d8"].CGColor;
    gameLevelLbl.textColor = [UIColor colorWithHexRGB:@"fd9a37"];
    centerLbl.textColor = [UIColor colorWithHexRGB:@"fe9839"];
    imageV.image = [UIImage mainBundleImage:@"LC_Level_02"];
    bottomLbl.textColor = [UIColor colorWithHexRGB:@"919191"];
    [imageV sizeToFit];
    
    self.gameLevelLbl = gameLevelLbl;
    self.centerLbl = centerLbl;
    self.bottomLbl = bottomLbl;
    self.imageV = imageV;
    
    [self.contentView addSubview:gameLevelLbl];
    [self.contentView addSubview:centerLbl];
    [self.contentView addSubview:bottomLbl];
    [self.contentView addSubview:imageV];
    [self.contentView addSubview:separtorV];
    
    [gameLevelLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(22);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.height.equalTo(@(111));
        make.width.equalTo(@(138));
    }];
    
    [centerLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imageV.mas_centerX);
        make.centerY.equalTo(imageV.mas_centerY).offset(-13);
    }];
    [bottomLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(imageV.mas_bottom).offset(11);
    }];
    
    [separtorV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(19);
        make.right.equalTo(self.contentView.mas_right).offset(-19);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-0.5);
        make.height.equalTo(@(0.5));
    }];
}


@end
