//
//  HomeworkExplainCell.m
//  TXChatParent
//
//  Created by gaoju on 16/7/13.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkExplainCell.h"
#import "UIColor+Hex.h"
#import "UIImage+Rotate.h"

@interface HomeworkExplainCell ()

@property (nonatomic, weak) UIImageView *iconImageV;

@property (nonatomic, weak) UILabel *titleLbl;

@end

@implementation HomeworkExplainCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        [self setupUI];
    }
    return self;
}

- (void)setDict:(NSDictionary *)dict{
    
    _dict = dict;
    
    _iconImageV.image = [UIImage mainBundleImage:dict[@"icon"]];
    _titleLbl.text = dict[@"title"];
}

- (void)setupUI{
    
    UIImageView *iconImageV = [[UIImageView alloc] init];
    UILabel *titleLbl = [[UILabel alloc] init];
    UIImageView *arrowImageV = [[UIImageView alloc] init];
    UIView *separtorV = [[UIView alloc] init];
    
    [iconImageV sizeToFit];
    [titleLbl sizeToFit];
    [arrowImageV sizeToFit];
    
    self.iconImageV = iconImageV;
    self.titleLbl = titleLbl;
    
    titleLbl.font = [UIFont systemFontOfSize:15];
    titleLbl.textColor = [UIColor colorWithHexRGB:@"484848"];
    arrowImageV.image = [UIImage imageNamed:@"_newmessage"];
    separtorV.layer.backgroundColor = [UIColor colorWithHexRGB:@"d8d8d8"].CGColor;
    
    [self.contentView addSubview:iconImageV];
    [self.contentView addSubview:titleLbl];
    [self.contentView addSubview:arrowImageV];
    [self.contentView addSubview:separtorV];
    
    [iconImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(iconImageV.mas_right).offset(12.5);
    }];
    [arrowImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    
    [separtorV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(2);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-0.5);
        make.height.equalTo(@0.5);
    }];
}


@end
