//
//  HomeworkDescriptionView.m
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkDescriptionView.h"
#import "UILabel+ContentSize.h"
#import "NSDate+TuXing.h"
#import "XCSDGame.pb.h"

#define KSENDER_MARGIN 14.5


@interface HomeworkDescriptionView ()
{
    UILabel *_senderLbl;
    UILabel *_nameLbl;
    UILabel *_descriptionLbl;
    UILabel *_timeLbl;
    UILabel *_listLbl;
    UILabel *_totalScoreLbl;
    CGFloat _height;
    
    UIView *_separteView;
}

@end

@implementation HomeworkDescriptionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.backgroundColor = [UIColor whiteColor];
    
    _senderLbl = [UILabel labelWithFontSize:15 text:@"发件人:"];
    
    _nameLbl = [UILabel labelWithFontSize:15];
    [_nameLbl sizeToFit];
    
    _separteView = [[UIView alloc] init];
    _separteView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_separteView];
    
    _descriptionLbl = [UILabel labelWithFontSize:15];
    _descriptionLbl.numberOfLines = 0;
    [_descriptionLbl sizeToFit];
    
    _timeLbl = [UILabel labelWithFontSize:15];
    [_timeLbl sizeToFit];
    _timeLbl.textAlignment = NSTextAlignmentRight;
    
    _listLbl = [UILabel labelWithFontSize:15 text:@"学能作业列表:"];
    _listLbl.font = [UIFont boldSystemFontOfSize:15];
    [_listLbl sizeToFit];
    
    _totalScoreLbl = [UILabel labelWithFontSize:15];
    _totalScoreLbl.textAlignment = NSTextAlignmentRight;
    [_totalScoreLbl sizeToFit];
    _totalScoreLbl.hidden = YES;
    
//    _descriptionLbl.text = @"      各位家长好，孩子的学习成绩不光和学习知识相关，更重要的是每个孩子自身的学习能力，例如注意力、记忆力等。而这些能力是可以通过科学训练提升的，学能作业会根据学生的学能水平发送相关的训练游戏，来帮助学生通过练习提高学习能力，从而提高学习成绩，让孩子们认真做哦！";
    
    
    _senderLbl.textColor = RGBCOLOR(121, 121, 121);
    _nameLbl.textColor = RGBCOLOR(67, 109, 129);
    _descriptionLbl.textColor = RGBCOLOR(68, 68, 68);
    _timeLbl.textColor = RGBCOLOR(159, 160, 160);
    _listLbl.textColor = RGBCOLOR(83, 83, 83);
    
    [self addSubview:_nameLbl];
    [self addSubview:_descriptionLbl];
    [self addSubview:_timeLbl];
    [self addSubview:_senderLbl];
    [self addSubview:_listLbl];
    [self addSubview:_totalScoreLbl];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize senderLblSize = [UILabel contentSizeForLabelWithText:_senderLbl.text maxWidth:kScreenWidth font:_senderLbl.font];
    _senderLbl.frame = CGRectMake(KSENDER_MARGIN, KSENDER_MARGIN, senderLblSize.width, senderLblSize.height);
    
    _separteView.frame = CGRectMake(0, _senderLbl.maxY + 10, kScreenWidth, 1);
    
    [_nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(_senderLbl.mas_right).offset(10);
        make.top.bottom.equalTo(_senderLbl);
    }];
    [_descriptionLbl mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(_senderLbl.mas_bottom).offset(20);
        make.left.equalTo(_senderLbl.mas_left);
        make.right.equalTo(self.mas_right).offset(-KSENDER_MARGIN);
    }];
    [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_descriptionLbl.mas_bottom).offset(21);
        make.right.equalTo(_descriptionLbl.mas_right).offset(-KSENDER_MARGIN);
    }];
    
    [_listLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_timeLbl.mas_bottom).offset(28);
        make.left.equalTo(_senderLbl.mas_left);
    }];
    [_totalScoreLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_listLbl.mas_top);
        make.right.equalTo(self.mas_right).offset(-KSENDER_MARGIN);
    }];
}

- (void)updateHomework:(XCSDPBHomeworkDetailResponse *) homeworkDetail{
    
    _nameLbl.text = homeworkDetail.senderName;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    _timeLbl.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:homeworkDetail.sendTime / 1000]];
    
    
    NSString *defaultDes = @"      各位家长好，孩子的学习成绩不光和学习知识相关，更重要的是每个孩子自身的学习能力，例如注意力、记忆力等。而这些能力是可以通过科学训练提升的，学能作业会根据学生的学能水平发送相关的训练游戏，来帮助学生通过练习提高学习能力，从而提高学习成绩，让孩子们认真做大哦！";
    
    _descriptionLbl.text = homeworkDetail.hasDescription ? homeworkDetail.description : defaultDes;
    
    if (homeworkDetail.status == XCSDPBHomeworkStatusUnfinished) {  return; }
    
    NSString *leftText = [NSString stringWithFormat:@"本次作业成绩:  %d分",(int)homeworkDetail.totalScore];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:leftText];
    NSRange numRange = [leftText rangeOfString:[NSString stringWithFormat:@"%d", homeworkDetail.totalScore]];
    
    [attr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(253, 162, 32) range:NSMakeRange(numRange.location, leftText.length - numRange.location)];
    _listLbl.attributedText = attr;
    
    _totalScoreLbl.text = [NSString stringWithFormat:@"本次作业满分为:  %d分",(int)homeworkDetail.maxScore];
    _totalScoreLbl.textColor = RGBCOLOR(67, 109, 129);
    _totalScoreLbl.hidden = NO;
    
    [self layoutIfNeeded];
}

- (HomeworkDescriptionView *(^)(XCSDPBHomeworkDetailResponse *))setData{
    
    return ^HomeworkDescriptionView *(XCSDPBHomeworkDetailResponse *homework){
        
        [self updateHomework:homework];
        return self;
    };
}

- (CGFloat (^)())getHeight{
    return ^ CGFloat(){
        [self layoutIfNeeded];
        return _listLbl.maxY + 20;
    };
}

@end
