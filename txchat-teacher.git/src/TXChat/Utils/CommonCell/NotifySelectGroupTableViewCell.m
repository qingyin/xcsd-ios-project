//
//  NotifySelectGroupTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NotifySelectGroupTableViewCell.h"

@implementation NotifySelectGroupTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    _checkBtn.selected = NO;
    [_checkBtn setBackgroundColor:[UIColor clearColor]];
    [_checkBtn setImage:[UIImage imageNamed:@"itemUncheck"] forState:UIControlStateNormal];
    [_checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.mas_equalTo(self.contentView).with.offset(-2);
        make.centerY.mas_equalTo(self.contentView);
    }];
    _selectedBock = nil;
    [_groupName setFont:kFontTitle];
    [_groupName setTextColor:KColorTitleTxt];
    [_groupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_groupIcon.mas_right).with.offset(kEdgeInsetsLeft);
        make.height.mas_equalTo(self.contentView);
        make.right.mas_equalTo(_selectedCount.mas_left).with.offset(kEdgeInsetsLeft);
    }];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_seperatorLine setBackgroundColor:kColorLine];
    [_rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(weakSelf.contentView);
        make.size.mas_equalTo(_rightArrow.image.size);
        
    }];
    
    [_selectedCount setFont:kFontSubTitle];
    [_selectedCount setTextColor:KColorSubTitleTxt];
    [_selectedCount setText:@""];
    
    [_selectedCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.contentView);
        make.right.mas_equalTo(_rightArrow.mas_left).with.offset(-kEdgeInsetsLeft);
    }];
    
//    [_checkBtn setTintColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:kColorWhite];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.mas_bottom).with.offset(-kLineHeight);
    }];
    _groupIcon.layer.masksToBounds = YES;
    _groupIcon.layer.cornerRadius = 8.0f/2.0f;
    [_groupIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.mas_equalTo(_checkBtn.mas_right).with.offset(2);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)checkboxClick:(UIButton*)btn
{
    btn.selected=!btn.selected;//每次点击都改变按钮的状态
    
    if(btn.selected){
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setImage:[UIImage imageNamed:@"itemChecked"] forState:UIControlStateNormal];
    }else{
        
        //在此实现打勾时的方法
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setImage:[UIImage imageNamed:@"itemUncheck"] forState:UIControlStateNormal];
    }
    _selectedBock(_departmentId, btn.isSelected);
    

}

//设置选中状态
-(void)setCheckStatus:(BOOL)isSelected
{
    _checkBtn.selected = isSelected;
    if(_checkBtn.selected){
        [_checkBtn setBackgroundColor:[UIColor clearColor]];
        [_checkBtn setImage:[UIImage imageNamed:@"itemChecked"] forState:UIControlStateNormal];
    }else{
        
        //在此实现打勾时的方法
        [_checkBtn setBackgroundColor:[UIColor clearColor]];
        [_checkBtn setImage:[UIImage imageNamed:@"itemUncheck"] forState:UIControlStateNormal];
    }
}
@end
