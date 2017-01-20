//
//  ShareTextField.m
//  TXChatTeacher
//
//  Created by gaoju on 16/11/16.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ShareTextField.h"
#import "UIColor+Hex.h"
#import "ShareSelectIconsView.h"

@interface ShareTextField ()

@property (nonatomic, assign) NSInteger deleteCount;

@end

@implementation ShareTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *placeLbl = [self valueForKey:@"_placeholderLabel"];
        placeLbl.textAlignment = NSTextAlignmentCenter;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
//        self.layer.cornerRadius = 5;
//        self.borderStyle = UITextBorderStyleRoundedRect;
        self.keyboardType = UIKeyboardTypeEmailAddress;
        self.returnKeyType = UIReturnKeySearch;
        
        self.backgroundColor = [UIColor whiteColor];
        self.placeholder = @"搜索";
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
//        self.leftViewMode = UITextFieldViewModeAlways;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"articleShare_search"];
        self.imageView = imageView;
        [self addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.width.height.equalTo(@17);
            make.right.equalTo(self.mas_centerX).offset(-25);
        }];
        
    }
    
    return self;
}


- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    // textSize:placeholder字符串size
    CGSize size = [self.placeholder boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil].size;
    
    CGRect inset;
    if (_isHolderLeft) {
        return bounds;
    }else {
        inset = CGRectMake((bounds.size.width - size.width)/2, bounds.origin.y, size.width, bounds.size.height);
    }
    
    return inset;
}

- (void)drawPlaceholderInRect:(CGRect)rect{
    UIColor *placeholderColor = [UIColor colorWithHexRGB:@"818183"];//设置颜色
    [placeholderColor setFill];
    
    CGRect placeholderRect = CGRectMake(rect.origin.x, (rect.size.height- self.font.pointSize)/2, rect.size.width, rect.size.height);//设置距离
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = self.textAlignment;
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName, [UIFont systemFontOfSize:17], NSFontAttributeName, placeholderColor, NSForegroundColorAttributeName, nil];
    
    [self.placeholder drawInRect:placeholderRect withAttributes:attr];
}

- (void)setHolderLeftAndLeftViewHidden:(BOOL)isSet {
    if (isSet) {
        self.isHolderLeft = YES;
        self.imageView.hidden = YES;
        [self setNeedsDisplay];
        
    }else {
        self.isHolderLeft = NO;
        self.imageView.hidden = NO;
        [self setNeedsDisplay];
    }
}

- (void)deleteBackward {
    
    if (self.text.length == 0) {
        self.deleteCount++;
        self.deleteClick(self.deleteCount);
    }else {
        [super deleteBackward];
    }
}

- (void)revertDeleteCount {
    self.deleteCount = 0;
}

//- (CGRect)leftViewRectForBounds:(CGRect)bounds {
//    
//    if (self.isHolderLeft) {
//        return CGRectMake(<#CGFloat x#>, <#CGFloat y#>, 17, 17);
//    }
//    return CGRectZero;
//}

@end
