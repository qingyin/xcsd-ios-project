//
//  TXBudgeButton.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/12.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXBudgeButton.h"

@interface TXBudgeButton()

@property (nonatomic,strong) UIImageView *btnImageView;
@property (nonatomic,strong) UILabel *budgeLabel;
@property (nonatomic,strong) UIImage *normalImage;
@property (nonatomic,strong) UIImage *selectedImage;

@end

@implementation TXBudgeButton

- (instancetype)initWithFrame:(CGRect)frame
                   normalName:(NSString *)normalName
                 selectedName:(NSString *)selectedName
                        budge:(NSInteger)budge
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        UIImage *image = normalName ? [UIImage imageNamed:normalName] : nil;
        self.normalImage = image;
        UIImage *selectedImage = selectedName ? [UIImage imageNamed:selectedName] : nil;
        self.selectedImage = selectedImage;
        //添加底图
        _btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - image.size.width) / 2, (frame.size.height - image.size.height) / 2, image.size.width, image.size.height)];
        _btnImageView.image = _normalImage ?: nil;
        [self addSubview:_btnImageView];
        //添加角标视图
        _budgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_btnImageView.maxX - 11, _btnImageView.minY - 5, 16, 16)];
        _budgeLabel.backgroundColor = RGBCOLOR(0xef, 0x38, 0x38);
        _budgeLabel.layer.cornerRadius = 8;
        _budgeLabel.layer.masksToBounds = YES;
        _budgeLabel.textColor = [UIColor whiteColor];
        _budgeLabel.textAlignment = NSTextAlignmentCenter;
        _budgeLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:_budgeLabel];
        self.budge = budge;
    }
    return self;
}
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _btnImageView.image = self.selectedImage ?: self.normalImage;
    }else{
        _btnImageView.image = self.normalImage;
    }
}
- (void)setBudge:(NSInteger)budge
{
    _budge = budge;
    //更新视图
    if (_budge >= 100) {
        _budgeLabel.text = @"99+";
    }else{
        _budgeLabel.text = [NSString stringWithFormat:@"%@",@(_budge)];
    }
    //设置是否隐藏
    if (_budge <= 0) {
        _budgeLabel.hidden = YES;
    }else{
        _budgeLabel.hidden = NO;
    }
    //更改frame
    CGFloat width = 16;
    CGFloat startX = _btnImageView.maxX - 11;
    if (_budge >= 100) {
        width = 28;
        startX -= 5;
    }else if (_budge >= 10) {
        width = 21;
        startX -= 2;
    }
    _budgeLabel.frame = CGRectMake(startX, _btnImageView.minY - 5, width, 16);
}
@end
