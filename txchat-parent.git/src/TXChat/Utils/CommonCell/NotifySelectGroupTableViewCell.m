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
    // Initialization code
    _checkBtn.selected = NO;
    [_checkBtn setBackgroundColor:[UIColor clearColor]];
    [_checkBtn setImage:[UIImage imageNamed:@"first_selected"] forState:UIControlStateNormal];
    _selectedBock = nil;
//    [_checkBtn setTintColor:[UIColor clearColor]];
    [self.contentView setBackgroundColor:kColorWhite];
//    WEAKSELF
    WEAKSELF
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.mas_bottom).with.offset(-kLineHeight);
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
        [btn setImage:[UIImage imageNamed:@"first_normal"] forState:UIControlStateNormal];
    }else{
        
        //在此实现打勾时的方法
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setImage:[UIImage imageNamed:@"first_selected"] forState:UIControlStateNormal];
    }
    _selectedBock(_groupName.text, btn.isSelected);
    

}


@end
