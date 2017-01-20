//
//  ShareJumpView.m
//  TXChatTeacher
//
//  Created by gaoju on 16/11/17.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ShareJumpSelectView.h"
#import "UIColor+Hex.h"
#import "UIView+Utils.h"


@implementation ShareJumpSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initViews];
    }
    
    return self;
}

- (instancetype)initWithArticleBlock:(SelectBlock)articleBlock msgBlock:(SelectBlock)msgBlock {
    if (self  = [super init]) {
        self.articleBlock = articleBlock;
        self.msgBlock = msgBlock;
    }
    return self;
}

- (void)initViews {
    
    self.backgroundColor = [UIColor colorWithHexRGB:@"F1F1F1"];
    
    [self sl_setCornerRadius:5];
    
    UILabel *title = [[UILabel alloc] init];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"已发送";
    title.font = [UIFont systemFontOfSize:16];
    [self addSubview:title];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@46);
    }];
    
    UIView *oneLine = [[UIView alloc] init];
    oneLine.backgroundColor = [UIColor colorWithHexRGB:@"E5E5E5"];
    [self addSubview:oneLine];
    
    [oneLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@0.5);
    }];
    
    UIButton *article = [[UIButton alloc] init];
    [article setTitle:@"继续阅读文章" forState:UIControlStateNormal];
    [article setTitleColor: KColorAppMain forState:UIControlStateNormal];
    [self addSubview:article];
    @weakify(self);
    [article handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        
        self.articleBlock();
    }];
    
    [article mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(oneLine.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@46);
    }];
    
    UIView *twoLine = [[UIView alloc] init];
    twoLine.backgroundColor = [UIColor colorWithHexRGB:@"E5E5E5"];
    [self addSubview:twoLine];
    
    [twoLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(article.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@0.5);
    }];
    
    UIButton *msgBtn = [[UIButton alloc] init];
    [msgBtn setTitle:@"进入消息界面" forState:UIControlStateNormal];
    [msgBtn setTitleColor:KColorAppMain forState:UIControlStateNormal];
    [self addSubview:msgBtn];
    
    [msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoLine.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@46);
    }];
    
    [msgBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        self.msgBlock();
    }];
}

@end
