//
//  TXGreetingCell.m
//  TXChatParent
//
//  Created by gaoju on 12/28/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import "TXGreetingCell.h"
#import "UIImage+Rotate.h"

@interface TXGreetingCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *startBtn;

@end

@implementation TXGreetingCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    
    self.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_imageView];
    
    self.imageView.frame = self.contentView.bounds;
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    UIImage *image = [UIImage mainBundleImage:[NSString stringWithFormat:@"Greeting_0%ld", index]];
    
    self.imageView.image = image;
    
    if (index == 4) {
        
        self.startBtn.hidden = NO;
    }else {
        self.startBtn.hidden = YES;
    }
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        
        _startBtn = [[UIButton alloc] init];
        _startBtn.frame = CGRectMake(50, kScreenHeight - 200, kScreenWidth - 100, 50);
        _startBtn.layer.cornerRadius = 5;
        [_startBtn setTitle:@"开启乐学堂" forState:UIControlStateNormal];
        [_startBtn setBackgroundColor:KColorAppMain];
        
        [_startBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            
            if (self.startBlock) {
                self.startBlock();
            }
        }];
        
        [self.contentView addSubview:_startBtn];
    }
    
    return _startBtn;
}

@end
