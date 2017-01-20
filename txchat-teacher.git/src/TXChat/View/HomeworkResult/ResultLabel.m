//
//  ResultLabel.m
//  TXChatParent
//
//  Created by gaoju on 16/7/21.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "ResultLabel.h"

@interface ResultLabel ()

@property (nonatomic, weak) UILabel *topLbl;

@property (nonatomic, weak) UILabel *botLbl;

@end

@implementation ResultLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupWithFrame:frame];
    }
    return self;
}

- (void)setupWithFrame:(CGRect)frame{
    
    UILabel *topLbl = [[UILabel alloc] init];
    UILabel *botLbl = [[UILabel alloc] init];
    
    topLbl.textAlignment = NSTextAlignmentCenter;
    botLbl.textAlignment = NSTextAlignmentCenter;
    
    self.topLbl = topLbl;
    self.botLbl = botLbl;
    
    [self addSubview:topLbl];
    [self addSubview:botLbl];
    
    topLbl.font = [UIFont systemFontOfSize:20];
    botLbl.font = [UIFont systemFontOfSize:10];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _topLbl.frame = CGRectMake(0, 0, width, height / 2);
    _botLbl.frame = CGRectMake(0, height / 2, width, height/ 2);
}

- (void)setTitle:(NSString *)title str:(NSString *)str color:(UIColor *)color{
    
    _topLbl.text = title;
    _botLbl.text = str;
    _topLbl.textColor = self.botLbl.textColor = color;
}

@end
