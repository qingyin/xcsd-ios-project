//
//  ShareSelectIconsView.m
//  TXChatTeacher
//
//  Created by yarn on 2016/11/29.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ShareSelectIconsView.h"
#import "TXDepartment+Utils.h"


@interface ShareSelectIconsView ()

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *selectArr;

//@property (nonatomic, assign) NSInteger count;

@end

@implementation ShareSelectIconsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initViews];
        
        _selectArr = [NSMutableArray arrayWithCapacity:1];
    }
    
    return self;
}

- (void)initViews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView = scrollView;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self addSubview:scrollView];
}

- (void)addSelectPerson:(id) person {
    
    [_selectArr addObject:person];
    
    NSInteger count = self.selectArr.count;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(kLeftMargin + (count - 1) * (kIconWH + kMargin), 7.5, kIconWH, kIconWH);
    [self.scrollView addSubview:imageView];
    
    if ([person isKindOfClass:[TXUser class]]) {
        
        [imageView TX_setImageWithURL:[NSURL URLWithString:((TXUser *)person).avatarUrl] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    }else {
        
        [imageView TX_setImageWithURL:[NSURL URLWithString:[((TXDepartment *)person) getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"conversation_default"]];
    }
    
    if (count <= kIconsCount) {
        self.scrollView.frame = CGRectMake(0, 0, kLeftMargin + (kIconWH + 8) * count, 50);
//        self.scrollView.contentSize = CGSizeMake(count * kIconWH, 0);
    }else {
        self.scrollView.frame = CGRectMake(0, 0, kLeftMargin + (kIconWH + 8) * 6, 50);
        self.scrollView.contentSize = CGSizeMake(kLeftMargin + (kIconWH + 8) * count, 0);
        self.scrollView.contentOffset = CGPointMake(kLeftMargin + (count - kIconsCount) * (kIconWH + 8), 0);
    }
    
//    _count++;o
}

- (void)deleteSelectPerson:(id) person {
    
    NSInteger index = [_selectArr indexOfObject:person];
    [_selectArr removeObject:person];
    
    UIView *deleteView = [_scrollView.subviews objectAtIndex:index];
    [deleteView removeFromSuperview];
    
    for (NSInteger i = index; i < self.scrollView.subviews.count; ++i) {
        
        UIView *view = _scrollView.subviews[i];
        view.minX -= kIconWH + 8;
    }
    
    if (self.selectArr.count <= kIconsCount) { //kLeftMargin + (kIconWH + 8) * _selectArr.count + 8
        self.scrollView.frame = CGRectMake(0, 0, kLeftMargin + (kIconWH + 8) * _selectArr.count, 50);
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }else if (self.selectArr.count == 0) {
        self.scrollView.frame = CGRectMake(0, 0, 0, 0);
    }else {
        self.scrollView.contentSize = CGSizeMake(kLeftMargin + (kIconWH + 8) * _selectArr.count + 8, 0);
        self.scrollView.contentOffset = CGPointMake((self.selectArr.count - kIconsCount) * (8 + kIconWH), 0);
    }
    
//    _count--;
}

- (void)updateSelectIcons {
    
    NSInteger count = self.selectArr.count;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(count * kIconWH, 0, kIconWH, kIconWH);
    [self.scrollView addSubview:imageView];
    
    for (NSInteger i = 0; i < self.selectArr.count; ++i) {
        
        id select = self.selectArr[i];
        
        if ([select isKindOfClass:[TXUser class]]) {
            
            [imageView TX_setImageWithURL:[NSURL URLWithString:((TXUser *)select).avatarUrl] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        }else {
            
            [imageView TX_setImageWithURL:[NSURL URLWithString:[((TXDepartment *)select) getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"conversation_default"]];
        }
    }
    
    self.scrollView.frame = CGRectMake(0, 0, count * kIconWH, kIconWH);
    self.scrollView.contentSize = CGSizeMake(count * kIconWH, 0);
}

- (void)deleteHalfAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        UIView *view = self.scrollView.subviews.lastObject;
        view.alpha = 0.5;
    }];
}

- (id)deleteLastPerson {
    id person = self.selectArr.lastObject;
    [self deleteSelectPerson:person];
    
    return person;
}

- (void)revertHalfAnimation {
    
    [UIView animateWithDuration:0.25 animations:^{
        UIView *view = self.scrollView.subviews.lastObject;
        view.alpha = 1.0;
    }];
}


@end
