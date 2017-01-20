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
    UILabel *_totalScoreLbl;    // 得分
    UILabel *_maxScoreLbl;      // 总分
//    UILabel *_descriptionLbl;
//    UILabel *_timeLbl;
//    UILabel *_listLbl;
//    CGFloat _height;
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
    
    self.backgroundColor = [UIColor grayColor];
    
    _totalScoreLbl = [UILabel labelWithFontSize:15];
    _maxScoreLbl = [UILabel labelWithFontSize:15];
    _totalScoreLbl.textAlignment = NSTextAlignmentRight;
    
    _maxScoreLbl.textColor = [UIColor colorWithRed:183/ 255.0 green:183/ 255.0 blue:183/ 255.0 alpha:1];
    _totalScoreLbl.textColor = [UIColor colorWithRed:67 / 255.0 green:109/ 255.0 blue:129/ 255.0 alpha:1];
    
    [self addSubview:_maxScoreLbl];
    [self addSubview:_totalScoreLbl];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
//    CGFloat tmpHeight = 50;
    _maxScoreLbl.frame = CGRectMake(0, 0, self.width_ / 2, self.height_);
    
//    CGSize scoreSize = [UILabel contentSizeForLabelWithText:_scoreLbl.text maxWidth:kScreenWidth font:_scoreLbl.font];
    _totalScoreLbl.frame = CGRectMake(self.width_ / 2, 0, self.width_ / 2, self.height_);
}

- (void)updateHomework:(XCSDPBHomeworkDetailResponse *) homeworkDetail{
    
    _maxScoreLbl.text = [NSString stringWithFormat:@"本次作业成绩: %d分",(int)homeworkDetail.totalScore];
    _totalScoreLbl.text = [NSString stringWithFormat:@"作业满分为%d分",homeworkDetail.maxScore];
    [self layoutIfNeeded];
}

- (HomeworkDescriptionView *(^)(XCSDPBHomeworkDetailResponse *))setData{
    
    return ^HomeworkDescriptionView *(XCSDPBHomeworkDetailResponse *homework){
        
        [self updateHomework:homework];
        return self;
    };
}

//- (CGFloat (^)())getHeight{
//    return ^ CGFloat(){
//        [self layoutIfNeeded];
//        
//        CGFloat margin = 20;
//        
//    };
//}

@end
