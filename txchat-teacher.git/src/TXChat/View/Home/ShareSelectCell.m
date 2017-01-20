//
//  ShareSelectCell.m
//  TXChatTeacher
//
//  Created by gaoju on 16/11/15.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ShareSelectCell.h"
#import "TXDepartment+Utils.h"

@interface ShareSelectCell ()

@property (nonatomic, weak) UIButton *selectBtn;

@property (nonatomic, weak) UIImageView *iconImage;

@property (nonatomic, weak) UILabel *nameLbl;

@end

@implementation ShareSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initViews];
    }
    return self;
}

- (void)initViews {
    @weakify(self);
    UIButton *selectBtn = [UIButton new];
//    selectBtn.selected = NO;
    selectBtn.userInteractionEnabled = NO;
    [selectBtn setImage:[UIImage imageNamed:@"itemUncheck"] forState:UIControlStateNormal];
    [selectBtn setImage:[UIImage imageNamed:@"itemChecked"] forState:UIControlStateSelected];
    [self.contentView addSubview:selectBtn];
    self.selectBtn = selectBtn;
    
    [selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.mas_equalTo(self.contentView).with.offset(-2);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    UIImageView *iconImage = [UIImageView new];
    [self.contentView addSubview:iconImage];
    self.iconImage = iconImage;
    
    [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.mas_equalTo(self.selectBtn.mas_right).with.offset(2);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    UILabel *nameLbl = [UILabel new];
    nameLbl.font = [UIFont systemFontOfSize:17];
    [nameLbl sizeToFit];
    [self.contentView addSubview:nameLbl];
    [nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.mas_equalTo(self.iconImage.mas_right).with.offset(kEdgeInsetsLeft);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    self.nameLbl = nameLbl;
}

- (void)setDepartment:(TXDepartment *)department {
    _department = department;
    
    [self.iconImage TX_setImageWithURL:[NSURL URLWithString:[department getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"conversation_default"]];
    self.nameLbl.text = department.name;
}

- (void)setUser:(TXUser *)user {
    _user = user;
    
    [self.iconImage TX_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    self.nameLbl.text = user.nickname;
}

- (void)setCheck:(BOOL)check {
    self.selectBtn.selected = check;
}

- (BOOL)isCheck {
    return self.selectBtn.selected;
}

@end
