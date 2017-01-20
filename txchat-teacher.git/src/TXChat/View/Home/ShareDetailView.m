//
//  ShareDetailView.m
//  TXChatTeacher
//
//  Created by gaoju on 16/11/15.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ShareDetailView.h"
#import "UIColor+Hex.h"
#import "TXDepartment.h"
#import "TXDepartment+Utils.h"
#import "TXChatSendHelper.h"
#import "UIView+Utils.h"

#define KLeftMargin 21
#define KViewWidth 291
#define KIconCount 6
#define KIconWH 35

@interface ShareDetailView ()

@property (nonatomic, weak) UITextField *msgTF;

@end

@implementation ShareDetailView


- (void)setSelectArr:(NSArray<NSArray *> *)selectArr {
    _selectArr = selectArr;
    
    [self initViews];
}
- (void)initViews {
    @weakify(self);
    self.backgroundColor = [UIColor colorWithHexRGB:@"F1F1F1"];
    self.layer.borderColor = [UIColor colorWithHexRGB:@"E5E5E5"].CGColor;
    self.layer.borderWidth = 0.5;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(21, 23, KViewWidth - 42, 34)];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor colorWithHexRGB:@"313131"];
    label.text = @"发送给:";
    [label sizeToFit];
    label.backgroundColor = [UIColor colorWithHexRGB:@"F1F1F1"];
    [self addSubview:label];
    
    UIView *iconsView = [self createIconsView];
    [self addSubview:iconsView];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexRGB:@"E5E5E5"];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconsView.mas_bottom).offset(14);
        make.width.equalTo(@(KViewWidth - 42));
        make.left.equalTo(self.mas_left).offset(21);
        make.height.equalTo(@0.5);
    }];
    
    UILabel *textLbl = [[UILabel alloc] init];
//    CGRectMake(21, line.maxY + 13, ., .
    textLbl.font = [UIFont systemFontOfSize:14];
    textLbl.text = [NSString stringWithFormat:@"[链接]%@", self.articleTitle];
    textLbl.textColor = [UIColor colorWithHexRGB:@"B0B0B0"];
    textLbl.numberOfLines = 0;
    [textLbl sizeToFit];
    [self addSubview:textLbl];
    
    [textLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_bottom).offset(13);
        make.left.equalTo(self).offset(25);
        make.width.equalTo(@(KViewWidth - 50));
    }];
    
//    CGSize textSize = [self.articleTitle boundingRectWithSize:CGSizeMake(textLbl.width_, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
//    textLbl.frame = CGRectMake(25, line.maxY + 13, KViewWidth - 50, textSize.height);
//    [self addSubview:textLbl];
    
    UITextField *msgTF = [[UITextField alloc] init];
    self.msgTF = msgTF;
    msgTF.font = [UIFont systemFontOfSize:14];
//    WithFrame:CGRectMake(21, textLbl.maxY + 19, KViewWidth - 21, 37)
    msgTF.placeholder = @"给朋友留言";
    msgTF.backgroundColor = [UIColor whiteColor];
    [self addSubview:msgTF];
    
    msgTF.layer.borderWidth = 0.5;
    msgTF.layer.borderColor = [UIColor colorWithHexRGB:@"E5E5E5"].CGColor;
    msgTF.borderStyle = UITextBorderStyleRoundedRect;
    msgTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, msgTF.height_)];
    
    [msgTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textLbl.mas_bottom).offset(19);
        make.left.equalTo(self.mas_left).offset(21);
        make.width.equalTo(@(KViewWidth - 42));
        make.height.equalTo(@37);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorWithHexRGB:@"E5E5E5"];
    [self addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(msgTF.mas_bottom).offset(14);
        make.width.left.equalTo(self);
        make.height.equalTo(@1);
    }];
    
    
    UIButton *cancle = [[UIButton alloc] init];
    UIButton *confirm = [[UIButton alloc] init];
    
    [cancle setTitle:@"取消" forState:UIControlStateNormal];
    [cancle setTitleColor:[UIColor colorWithHexRGB:@"313131"] forState:UIControlStateNormal];
    
    [confirm setTitle:@"发送" forState:UIControlStateNormal];
    [confirm setTitleColor:KColorAppMain forState:UIControlStateNormal];
    
    [confirm handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        self.confirmBlock(msgTF.text);
    }];
    
    [cancle handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        self.cancleBlock();
    }];
    
    [self addSubview:cancle];
    [self addSubview:confirm];
    
    cancle.backgroundColor = [UIColor colorWithHexRGB:@"F1F1F1"];
    confirm.backgroundColor = [UIColor colorWithHexRGB:@"F1F1F1"];
    
    [cancle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.width.equalTo(@(KViewWidth / 2 - 0.25));
        make.height.equalTo(@43);
    }];
    
    [confirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancle.mas_top);
        make.left.equalTo(cancle.mas_right).offset(0.25);
        make.width.equalTo(@(KViewWidth / 2 - 0.25));
        make.height.equalTo(@43);
    }];
    
    UIView *colLine = [[UIView alloc] init];
    colLine.backgroundColor = [UIColor colorWithHexRGB:@"E5E5E5"];
    [self addSubview:colLine];
    
    [colLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancle.mas_top);
        make.left.equalTo(cancle.mas_right);
        make.width.equalTo(@0.5);
        make.height.equalTo(cancle.mas_height);
    }];
}

- (UIView *)createIconsView {
    
    UIView *container = [[UIView alloc] init];
    
    for (NSInteger i = 0; i < self.selectArr.firstObject.count + self.selectArr.lastObject.count; ++i) {
        
        UIImageView *imageV = [[UIImageView alloc] init];
        CGFloat x = 21 + (35 + 7) * (i % 6);
        CGFloat y = 14 + (35 + 6) * (i / 6);
        
        if (i < self.selectArr.firstObject.count) {
            
            TXDepartment *department = self.selectArr.firstObject[i];
            
            [imageV TX_setImageWithURL:[NSURL URLWithString:[department getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"conversation_default"]];
            
            
        }else {
            if (self.selectArr.lastObject.count > 0) {
                TXUser *user = self.selectArr.lastObject[i - self.selectArr.firstObject.count];
                
                [imageV TX_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            }
        }
        imageV.frame = CGRectMake(x, y, KIconWH, KIconWH);
        [container addSubview:imageV];
    }
    
    if (self.selectArr.firstObject.count + self.selectArr.lastObject.count > 6) {
        container.frame = CGRectMake(0, 40, KViewWidth, 83);
    }else {
        container.frame = CGRectMake(0, 40, KViewWidth, 46);
    }
    
    
    return container;
}

- (void)endEditing {
    [self.msgTF endEditing:YES];
}

@end
