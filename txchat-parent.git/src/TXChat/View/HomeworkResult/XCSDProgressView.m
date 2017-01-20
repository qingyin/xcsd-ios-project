//
//  XCSDProgressView.m
//  TXChatParent
//
//  Created by gaoju on 16/7/12.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "XCSDProgressView.h"
#import "UIColor+Hex.h"
#import "UIImage+Rotate.h"

@interface XCSDProgressView ()

@property (nonatomic, weak) UIView *leftV;

@property (nonatomic, weak) UIView *rightV;

@property (nonatomic, weak) UILabel *leftLbl;

@property (nonatomic, weak) UILabel *rightLbl;

@property (nonatomic, weak) UIImageView *rightImageV;

@property (nonatomic, assign) float progress;

@property (nonatomic, strong) MASConstraint *constraint;

@end

@implementation XCSDProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addProgressV];
    }
    return self;
}

- (void)addProgressV{
    
    CGFloat leftLblW = 100;
    CGFloat rightLblW = 50;
    
    UIView *leftV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height_)];
    UIView *rightV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width_, self.height_)];
    rightV.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *leftLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, leftLblW, self.height_)];
    UILabel *rightLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.width_ - 10 - rightLblW, 0, rightLblW, self.height_)];
    
    leftLbl.font = [UIFont systemFontOfSize:12];
    rightLbl.font = [UIFont systemFontOfSize:12];
    
    UIImageView *rightArrow = [[UIImageView alloc] initWithImage:[UIImage mainBundleImage:@"lc_rightArrow_normal"]];
    rightArrow.frame = CGRectMake(self.width_ - 50, 0, 50, self.height_);
    rightArrow.layer.backgroundColor = [UIColor colorWithHexRGB:@"838383"].CGColor;
    rightArrow.contentMode = UIViewContentModeScaleAspectFit;
    rightArrow.hidden = YES;
    
    leftLbl.textColor = rightLbl.textColor = [UIColor whiteColor];
    
    self.leftV = leftV;
    self.rightV = rightV;
    [leftLbl sizeToFit];
    [rightLbl sizeToFit];
    [rightArrow sizeToFit];
    self.leftLbl = leftLbl;
    self.rightLbl = rightLbl;
    self.rightImageV = rightArrow;
    
//    leftV.backgroundColor = [UIColor blackColor];
    rightV.layer.backgroundColor = [UIColor colorWithHexRGB:@"c8c8c8"].CGColor;
    
    [self addSubview:rightV];
    [self addSubview:leftV];
    [self addSubview:leftLbl];
    [self addSubview:rightLbl];
    [self addSubview:rightArrow];
    
    [self setView:rightArrow corners:UIRectCornerTopRight | UIRectCornerBottomRight];
    [self setView:self corners:UIRectCornerAllCorners];
    
    [self.leftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        self.constraint = make.width.equalTo(@(0));
        make.top.equalTo(self.mas_top);
        make.height.equalTo(self.mas_height);
    }];
    
    [self.rightV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@((1) * self.width_));
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.equalTo(self.mas_height);
    }];
    
    [self.leftLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(16);
        make.top.equalTo(self.mas_top);
        make.centerY.equalTo(self.mas_centerY);
    }];
    [self.rightLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-16);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.rightImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightV.mas_right);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@30);
        make.height.equalTo(self.mas_height);
    }];
}

- (void)setView:(UIView *)view corners:(UIRectCorner) rectCorner{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(view.height_, view.height_)];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

- (XCSDProgressView *(^)())setRightArrow{
    
    return ^ XCSDProgressView *(){
        
        self.rightImageV.hidden = NO;
        
        [self.rightLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.rightImageV.mas_left).offset(-6);
            make.top.bottom.equalTo(self);
        }];
        return self;
    };
}

- (XCSDProgressView *(^)(NSString *, BOOL))setProgress{
    
    return ^ XCSDProgressView *(NSString *str, BOOL ispercent){
        
//        NSString *progressStr = ispercent ? [str substringToIndex:str.length - 1] : str;
        CGFloat width = self.width_;
        
        if (ispercent) {
            self.progress = [str substringToIndex:str.length - 1].floatValue / 100;
        }else{
            width = self.width_ - 50;
            
            NSArray *strArr = [str componentsSeparatedByString:@"/"];
            NSString *first = strArr[0];
            NSString *second = strArr[1];
            
            self.progress = first.floatValue / second.floatValue;
        }
        
        self.rightLbl.text = str;
        
        [self.leftV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(width * self.progress));
        }];
        
        [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.leftV.frame = CGRectMake(0, 0, self.progress * width, self.height_);
            self.rightV.frame = CGRectMake(0, 0, width, self.height_);
        } completion:nil];
        return self;
    };
}

- (XCSDProgressView *(^)(NSString *))setProgressColor{
    
    return ^ XCSDProgressView *(NSString *color){
        
        self.leftV.layer.backgroundColor = [UIColor colorWithHexRGB:color].CGColor;
        return self;
    };
}

- (XCSDProgressView *(^)(NSString *))setTitle{
    return ^ XCSDProgressView *(NSString *title){
        self.leftLbl.text = title;
        return self;
    };
}

@end
