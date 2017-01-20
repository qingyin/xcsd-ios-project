//
//  UnifyHomeworkCell.m
//  TXChatTeacher
//
//  Created by gaoju on 16/6/27.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "UnifyHomeworkCell.h"
#import "UILabel+ContentSize.h"
#import "XCSDGame.pb.h"
#import "UIColor+Hex.h"


@interface UnifyHomeworkCell (){
    
    UIView *_containView;
    UIImageView *_iconView;
    UILabel *_nameLbl;
    UILabel *_abilityLbl;
    UILabel *_levelsLbl;
    UIImageView *_arrowView;
}
@end

static inline UIColor *convertGameIDToColor(NSInteger gameID);

@implementation UnifyHomeworkCell

- (UnifyHomeworkCell *(^)(XCSDPBGameListResponseGame *))setGame{
    
    return ^UnifyHomeworkCell *(XCSDPBGameListResponseGame *game){
        
        [_iconView TX_setImageWithURL:[NSURL URLWithString:game.picUrl] placeholderImage:nil];
        _nameLbl.text = game.gameName;
        
        _nameLbl.textColor = [UIColor colorWithHexRGB:game.color];
        _abilityLbl.text = [NSString stringWithFormat:@"%@   共%d关",game.abilityName, (int)game.levelCount];
        _nameLbl.textColor = [UIColor colorWithHexRGB:[game.color substringFromIndex:1]];
        return self;
    };
}

- (UnifyHomeworkCell *(^)(NSString *))setText{
    
    return ^UnifyHomeworkCell *(NSString *text){
//        if ([text hasPrefix:@","]) {
//            NSMutableString *str = [NSMutableString stringWithString:text];
//            text = [str substringFromIndex:1];
//        }
        
        if ([text hasPrefix:@"无"]) {
            _levelsLbl.textColor = RGBCOLOR(183, 183, 183);
        }else{
            _levelsLbl.textColor = RGBCOLOR(249, 180, 75);
        }
        
        _levelsLbl.text = text;
        return self;
    };
}

- (NSString *(^)())getText{
    
    return ^NSString *(){   return _levelsLbl.text;     };
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (UnifyHomeworkCell *(^)())setCustomBackgroundColor{
    
    return ^UnifyHomeworkCell *(){
    
        _containView.backgroundColor = RGBCOLOR(255, 249, 230);
        return self;
    };
}

- (UnifyHomeworkCell *(^)())clearCustomBackgroundColor{
    return ^UnifyHomeworkCell *(){
        
        _containView.backgroundColor = [UIColor whiteColor];
        return self;
    };
}

- (void)setupUI{
    
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    _containView = [[UIView alloc] init];
    _iconView = [[UIImageView alloc] init];
    _nameLbl = [[UILabel alloc] init];
    _abilityLbl = [UILabel labelWithFontSize:15];
    _levelsLbl = [UILabel labelWithFontSize:14];
    _arrowView = [[UIImageView alloc] init];
    
    _abilityLbl.textColor = RGBCOLOR(183, 183, 183);
    _levelsLbl.textColor = RGBCOLOR(183, 183, 183);
    
    _nameLbl.font = [UIFont boldSystemFontOfSize:16];
    _arrowView.image = [UIImage imageNamed:@"hw_arrow_Leftsmall"];
    
    [_iconView sizeToFit];
    [_abilityLbl sizeToFit];
    [_nameLbl sizeToFit];
    [_levelsLbl sizeToFit];
    [_arrowView sizeToFit];
    
    [self.contentView addSubview:_containView];
    [_containView addSubview:_iconView];
    [_containView addSubview:_nameLbl];
    [_containView addSubview:_abilityLbl];
    [_containView addSubview:_levelsLbl];
    [_containView addSubview:_arrowView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(0.75);
        make.bottom.right.equalTo(self.contentView).offset(-0.75);
    }];
    
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.width.height.equalTo(@45);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [_nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconView.mas_right).offset(11);
        make.top.equalTo(_containView.mas_top).offset(10);
    }];
    
    [_abilityLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_containView.mas_bottom).offset(-10);
        make.left.equalTo(_nameLbl.mas_left);
    }];
    [_arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_containView.mas_centerY);
        make.right.equalTo(_containView.mas_right).offset(-16);
    }];
    [_levelsLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_arrowView.mas_right).offset(-25);
        make.centerY.equalTo(_containView.mas_centerY);
    }];
}

static inline UIColor *convertGameIDToColor(NSInteger gameID){
    switch (gameID) {
        case 1:
            return [UIColor colorWithRed:255 / 255.0 green:179 / 255.0 blue:63 / 255.0 alpha:1.0];
        case 2:
            return [UIColor colorWithRed:59 / 255.0 green:212 / 255.0 blue:182 / 255.0 alpha:1.0];
        case 3:
            return [UIColor colorWithRed:240 / 255.0 green:123 / 255.0 blue:106 / 255.0 alpha:1.0];
        case 4:
            return [UIColor colorWithRed:107 / 255.0 green:176 / 255.0 blue:195 / 255.0 alpha:1.0];
        case 5:
            return [UIColor colorWithRed:180 / 255.0 green:133 / 255.0 blue:208 / 255.0 alpha:1.0];
        case 6:
            return [UIColor colorWithRed:18 / 255.0 green:175 / 255.0 blue:99 / 255.0 alpha:1.0];
        case 7:
            return [UIColor colorWithRed:255 / 255.0 green:162 / 255.0 blue:214 / 255.0 alpha:1.0];
        case 8:
            return [UIColor colorWithRed:254 / 255.0 green:220 / 255.0 blue:86 / 255.0 alpha:1.0];
        case 9:
            return [UIColor colorWithRed:101 / 255.0 green:185 / 255.0 blue:9 / 255.0 alpha:1.0];
    }
    return [UIColor colorWithRed:101 / 255.0 green:185 / 255.0 blue:9 / 255.0 alpha:1.0];
}

@end


