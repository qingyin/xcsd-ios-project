//
//  HomeworkDetailCell.m
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkDetailCell.h"
#import "UILabel+ContentSize.h"
#import <Masonry.h>
#import "UIImageView+TXSDImage.h"
#import "UIColor+Hex.h"

@interface HomeworkDetailCell ()
{
    UIImageView *_iconView;
    UILabel *_nameLbl;
    UILabel *_abilityLbl;
    
    HomeworkStarsView *_starsView;
}

@end

static inline UIColor *convertToColor(NSInteger gameID);


@implementation HomeworkDetailCell

- (HomeworkDetailCell * (^)(XCSDPBGameLevel *))setData{
    return ^(XCSDPBGameLevel *data){
        
        _iconView.image = [UIImage imageNamed:@"01_haveTodo"];
        _nameLbl.text = data.gameName;
        [_iconView TX_setImageWithURL:[NSURL URLWithString:data.picUrl] placeholderImage:nil];
        _abilityLbl.text = [NSString stringWithFormat:@"%@ 第%d关",data.abilityName, (int)data.level];
        _starsView.numOfStars = data.stars;
        _nameLbl.textColor = [UIColor colorWithHexRGB:[data.color substringFromIndex:1]];
//        _nameLbl.textColor = convertToColor((NSInteger)data.gameId);
        
        [self layoutIfNeeded];
        return self;
    };
}

- (HomeworkDetailCell *(^)(BOOL))showStarsView{
    
    return ^HomeworkDetailCell *(BOOL showStarsView){
        
        _starsView.hidden = !showStarsView;
        
        return self;
    };
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _iconView = [[UIImageView alloc] init];
    _nameLbl = [[UILabel alloc] init];
    _abilityLbl = [UILabel labelWithFontSize:15];
    _starsView = [[HomeworkStarsView alloc] init];
    
    _abilityLbl.textColor = RGBCOLOR(183, 183, 183);
    _nameLbl.font = [UIFont boldSystemFontOfSize:16];
    
    [_iconView sizeToFit];
    [_abilityLbl sizeToFit];
    [_nameLbl sizeToFit];
    
    [self.contentView addSubview:_iconView];
    [self.contentView addSubview:_nameLbl];
    [self.contentView addSubview:_abilityLbl];
    [self.contentView addSubview:_starsView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.width.height.equalTo(@45);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [_nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconView.mas_right).offset(10);
        make.top.equalTo(_iconView.mas_top);
    }];
    
    [_abilityLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLbl.mas_bottom).offset(10);
        make.left.equalTo(_nameLbl.mas_left);
    }];
    
    [_starsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconView.mas_top);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(_iconView.mas_bottom);
        make.width.equalTo(@(100));
    }];
}
//static inline UIColor *convertToColor(NSInteger gameID){
//    switch (gameID) {
//        case 1:
//            return [UIColor colorWithRed:255 / 255.0 green:179 / 255.0 blue:63 / 255.0 alpha:1.0];
//        case 2:
//            return [UIColor colorWithRed:59 / 255.0 green:212 / 255.0 blue:182 / 255.0 alpha:1.0];
//        case 3:
//            return [UIColor colorWithRed:240 / 255.0 green:123 / 255.0 blue:106 / 255.0 alpha:1.0];
//        case 4:
//            return [UIColor colorWithRed:107 / 255.0 green:176 / 255.0 blue:195 / 255.0 alpha:1.0];
//        case 5:
//            return [UIColor colorWithRed:180 / 255.0 green:133 / 255.0 blue:208 / 255.0 alpha:1.0];
//        case 6:
//            return [UIColor colorWithRed:18 / 255.0 green:175 / 255.0 blue:99 / 255.0 alpha:1.0];
//        case 7:
//            return [UIColor colorWithRed:255 / 255.0 green:162 / 255.0 blue:214 / 255.0 alpha:1.0];
//        case 8:
//            return [UIColor colorWithRed:254 / 255.0 green:220 / 255.0 blue:86 / 255.0 alpha:1.0];
//        case 9:
//            return [UIColor colorWithRed:101 / 255.0 green:185 / 255.0 blue:9 / 255.0 alpha:1.0];
//    }
//    return [UIColor colorWithRed:101 / 255.0 green:185 / 255.0 blue:9 / 255.0 alpha:1.0];
//}

//- (void)drawRect:(CGRect)rect{
//    
//     CGFloat x = _iconView.centerX;
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGFloat lengths[] = {5, 2};
//    CGContextSetLineDash(ctx, 0, lengths, 2);
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathMoveToPoint(path, NULL, x, 0);
//    CGPathAddLineToPoint(path, NULL, x, _iconView.frame.origin.y);
//    
//    CGContextAddPath(ctx, path);
//    
//    CGMutablePathRef path2 = CGPathCreateMutable();
//    CGPathMoveToPoint(path2, NULL, x, _iconView.maxY);
//    CGPathAddLineToPoint(path2, NULL, x, self.contentView.height_);
//    CGContextAddPath(ctx, path2);
//    
//    CGContextStrokePath(ctx);
//    
//    CGPathRelease(path);
//    CGPathRelease(path2);
//}

@end


@interface HomeworkStarsView (){
    
    UIButton *_firstStar;
    UIButton *_secondStar;
    UIButton *_thirdStar;
    
    UILabel *_unfinishLbl;
}

@end

@implementation HomeworkStarsView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
//        [self drawLine];
    }
    return self;
}

- (void)setupUI{
    
    _firstStar = [[UIButton alloc] init];
    _secondStar = [[UIButton alloc] init];
    _thirdStar = [[UIButton alloc] init];
    
    [_firstStar setImage:[UIImage imageNamed:@"game_star_small_02"] forState:UIControlStateSelected];
    [_firstStar setImage:[UIImage imageNamed:@"game_star_small_01"] forState:UIControlStateNormal];
    [_secondStar setImage:[UIImage imageNamed:@"game_star_small_02"] forState:UIControlStateSelected];
    [_secondStar setImage:[UIImage imageNamed:@"game_star_small_01"] forState:UIControlStateNormal];
    [_thirdStar setImage:[UIImage imageNamed:@"game_star_small_02"] forState:UIControlStateSelected];
    [_thirdStar setImage:[UIImage imageNamed:@"game_star_small_01"] forState:UIControlStateNormal];
    
    _unfinishLbl = [UILabel labelWithFontSize:15 text:@"未通关"];
    _unfinishLbl.textColor = RGBCOLOR(253, 162, 32);
    
    [self addSubview:_firstStar];
    [self addSubview:_secondStar];
    [self addSubview:_thirdStar];
    [self addSubview:_unfinishLbl];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_thirdStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right);
        make.width.equalTo(@16);
        make.height.equalTo(@16);
    }];
    [_secondStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_thirdStar.mas_left).offset(-14);
        make.top.equalTo(_thirdStar.mas_top);
        make.width.equalTo(@16);
        make.height.equalTo(@16);
    }];
    
    [_firstStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_secondStar.mas_top);
        make.right.equalTo(_secondStar.mas_left).offset(-14);
        make.width.equalTo(@16);
        make.height.equalTo(@16);
    }];
    
    
    [_unfinishLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_thirdStar.mas_top);
        make.right.equalTo(_thirdStar.mas_right);
    }];
}

- (void)setNumOfStars:(NSInteger)numOfStars{
    _numOfStars = numOfStars;
    
    if (numOfStars > 3) {return;}
    
    switch (numOfStars) {
        case 0:
            _firstStar.hidden = YES;
            _secondStar.hidden = YES;
            _thirdStar.hidden = YES;
            _unfinishLbl.hidden = NO;
            break;
        case 1:
            _firstStar.selected = YES;
            _secondStar.selected = NO;
            _thirdStar.selected = NO;
            _unfinishLbl.hidden = YES;
            break;
        case 2:
            _firstStar.selected = YES;
            _secondStar.selected = YES;
            _thirdStar.selected = NO;
            _unfinishLbl.hidden = YES;
            break;
        case 3:
            _firstStar.selected = YES;
            _secondStar.selected = YES;
            _thirdStar.selected = YES;
            _unfinishLbl.hidden = YES;
            break;
    }
}
@end



