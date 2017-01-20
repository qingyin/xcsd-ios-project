//
//  NotifyFromView.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NotifyFromView.h"



@implementation NotifyFromView

//@property(nonatomic, strong)IBOutlet UILabel *titleLabel;
//@property(nonatomic, strong)IBOutlet UILabel *fromLabel;
//@property(nonatomic, strong)IBOutlet UIImageView *rightArrow;


-(void)awakeFromNib
{
    [super awakeFromNib];
    _delegate = nil;
    [_titleLabel setFont:kFontTitle];
    [_titleLabel setTextColor:KColorSubTitleTxt];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(@(0));
        make.left.mas_equalTo(@(kEdgeInsetsLeft));
    }];
    
    [_fromLabel setFont:kFontTitle];
    [_fromLabel setTextColor:kColorGray1];
    [_fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(@(0));
        make.left.mas_equalTo(_titleLabel.mas_right).with.offset(kEdgeInsetsLeft);
    }];
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(weakSelf);
        make.size.mas_equalTo(_rightArrow.image.size);
        
    }];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.mas_bottom).with.offset(-kLineHeight);
    }];
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//-(void)FromViewTapEvent:(UITapGestureRecognizer*)recognizer
//{
//    
//    //    NSInteger section = recognizer.view.tag - KHEADERVIEWBASETAG;
//    //    DLog(@"section:%ld", (long)section);
////    [self showFromDetailVC];
//    
//}

-(IBAction)btnPressed:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(UserTouchUpInView)])
    {
        [_delegate UserTouchUpInView];
    }

}

@end
