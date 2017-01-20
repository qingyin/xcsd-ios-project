//
//  GameTableViewCell.m
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "GameTableViewCell.h"

@implementation GameTableViewCell
{
    UIImageView *_imageView;
}

- (void (^)(id))setData{
    
    //FIXME: 此处还没有设置数据
    return ^(id data){
//        _imageView
    };
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    
    _imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_imageView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

@end
