//
//  ClassroomListTableViewCell.m
//  TXChatTeacher
//
//  Created by Cloud on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ClassroomListTableViewCell.h"

@interface ClassroomListTableViewCell ()
{
    UIImageView *_imgView;
    UILabel *_titleLb;
    UILabel *_authorLb;
    UILabel *_timeLb;
    UIImageView *_iconImage;
}

@end

@implementation ClassroomListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorWhite;
        self.contentView.backgroundColor = kColorWhite;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(0);
            make.top.left.bottom.equalTo(self);
//            make.left.mas_equalTo(0);
            make.width.mas_equalTo(self);
//            make.bottom.mas_equalTo(0);
        }];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgView.backgroundColor = kColorWhite;
        _imgView.clipsToBounds = YES;
        _imgView.layer.masksToBounds = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.contentView);
            make.height.mas_equalTo(150);
        }];
        
//        UIImageView *imageV = [[UIImageView alloc]init];
//        [self.contentView addSubview:imageV];
//        imageV.image = [UIImage imageNamed:@"tips_95"];
//        
//        [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(12);
//            make.left.mas_equalTo(9);
//        }];
        
        _iconImage = [[UIImageView alloc]init];
        [self.contentView addSubview:_iconImage];
        _iconImage.layer.masksToBounds = YES;
        _iconImage.layer.cornerRadius = 4;
        
        [_iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_imgView.mas_bottom).with.offset(15);
            make.left.mas_equalTo(10);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(30);
        }];
        
        
        
        _titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _titleLb.textColor = KColorTitleTxt;
        [_titleLb setFont:[UIFont boldSystemFontOfSize:13]];
        _titleLb.textAlignment = NSTextAlignmentLeft;
//        _titleLb.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLb.preferredMaxLayoutWidth = kScreenWidth - 62;
        [self.contentView addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_iconImage.mas_right).with.offset(12);
            make.right.mas_equalTo(-10);
            make.top.mas_equalTo(_imgView.mas_bottom).with.offset(13);
        }];
        
        _authorLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _authorLb.font = kFontTimeTitle;
        _authorLb.textColor = KColorNewSubTitleTxt;
        _authorLb.textAlignment = NSTextAlignmentLeft;
        _authorLb.preferredMaxLayoutWidth = kScreenWidth - 62;
        [self.contentView addSubview:_authorLb];
        [_authorLb mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(_titleLb.mas_left).with.offset(0);
            make.left.equalTo(_titleLb.mas_left);
            make.top.mas_equalTo(_titleLb.mas_bottom).with.offset(5);
        }];
        
        _timeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _timeLb.font = kFontMini;
        _timeLb.textColor = KColorNewSubTitleTxt;
        _timeLb.textAlignment = NSTextAlignmentLeft;
        _timeLb.preferredMaxLayoutWidth = kScreenWidth - 62;
        [self.contentView addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_authorLb.mas_centerY).with.offset(0);
            make.right.mas_equalTo(-10);
        }];
        
        _lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
        [self.contentView addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(kLineHeight);
        }];
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_timeLb.mas_bottom).offset(15);
        }];
    }
    return self;
}

- (void)setDataDic:(TXPBCourseLesson *)dataDic{
    _dataDic = dataDic;
    
    //标题
    NSString *titleStr = dataDic.title;
    _titleLb.text = titleStr;
//    [_titleLb sizeToFit];
//    [_titleLb mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(_titleLb.height_);
//    }];
    //封面
    [_imgView TX_setImageWithURL:[NSURL URLWithString:[dataDic.pic getFormatPhotoUrl:kScreenWidth hight:150]] placeholderImage:nil];
    //主讲人
    NSString *authorStr = [NSString stringWithFormat:@"主讲人：%@",dataDic.course.teacherName];
    _authorLb.text = authorStr;
//    [_authorLb sizeToFit];
//    [_authorLb mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(_authorLb.height_);
//    }];
    [_iconImage TX_setImageWithURL:[NSURL URLWithString:[dataDic.course.teacherAvatar getFormatPhotoUrl:30 hight:30]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    
    //时间
    NSString *timeStr;
    if (dataDic.duration < 60) {
        timeStr = @"时长：1分钟";
    }else{
        timeStr = [NSString stringWithFormat:@"时长：%d分钟",dataDic.duration/60];
    }
    _timeLb.text = timeStr;
//    [_timeLb sizeToFit];
//    [_timeLb mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(_timeLb.height_);
//    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
