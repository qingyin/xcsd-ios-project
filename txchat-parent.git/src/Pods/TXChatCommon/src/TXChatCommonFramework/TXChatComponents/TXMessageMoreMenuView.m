//
//  TXMessageMoreMenuView.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXMessageMoreMenuView.h"
#import "CommonUtils.h"

static NSInteger const kMoreButtoBaseTag = 100;
static NSString *const kMoreMenuImageName = @"menuImage";
static NSString *const kMoreMenuTitle = @"menuTitle";
static NSString *const kMoreMenuType = @"menuType";
static CGFloat const kMoreButtonWidth = 64;
static CGFloat const kMoreButtonHeight = 64;
static CGFloat const kMoreButtonSpace = 10;
static CGFloat const kMoreButtonMargin = 20;
static CGFloat const kMoreLabelHeight = 25;

@interface TXMessageMoreMenuView()
{
    UIScrollView *_menuScrollView;
}
@property (nonatomic,strong) NSArray *menuList;
@end

@implementation TXMessageMoreMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMoreMenuData];
        [self setupMoreMenuView];
    }
    return self;
}
//暂时只添加照片和拍照，待修改为从外部传入list定制化界面
- (void)setupMoreMenuData
{
    NSDictionary *picDict = @{kMoreMenuImageName: @"chat_pic",kMoreMenuTitle: @"图片",kMoreMenuType:@(TXMessageMoreMenuTypePhoto)};
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSDictionary *takePicDict = @{kMoreMenuImageName: @"chat_takePhoto",kMoreMenuTitle: @"拍照",kMoreMenuType:@(TXMessageMoreMenuTypeTakePicture)};
//        NSDictionary *takeVideoDict = @{kMoreMenuImageName: @"chat_video",kMoreMenuTitle: @"视频",kMoreMenuType:@(TXMessageMoreMenuTypeTakeVideo)};
//        _menuList = @[picDict,takePicDict,takeVideoDict];
        _menuList = @[picDict,takePicDict];
    }else{
        _menuList = @[picDict];
    }
}
- (void)setupMoreMenuView
{
    _menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _menuScrollView.pagingEnabled = YES;
    _menuScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_menuScrollView];
    //test:添加按钮,暂时只添加照片和拍照按钮，待修改为从外部传入的array来定制化界面
    for (NSInteger i = 0; i < [_menuList count]; i++) {
        CGRect menuFrame = CGRectMake(kMoreButtonMargin + (kMoreButtonWidth + kMoreButtonSpace) * (i % 4), kMoreButtonMargin + (kMoreButtonHeight + kMoreButtonSpace) * (i / 4), kMoreButtonWidth, kMoreButtonHeight);
        NSDictionary *menuDict = _menuList[i];
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = menuFrame;
        [menuButton setImage:[UIImage imageNamed:menuDict[kMoreMenuImageName]] forState:UIControlStateNormal];
        [menuButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_press",menuDict[kMoreMenuImageName]]] forState:UIControlStateHighlighted];
        menuButton.tag = [(NSNumber *)menuDict[kMoreMenuType] integerValue] + kMoreButtoBaseTag;
        [menuButton addTarget:self action:@selector(onMoreMenuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_menuScrollView addSubview:menuButton];
        //添加标题
        CGRect titleRect = CGRectMake(kMoreButtonMargin + (kMoreButtonWidth + kMoreButtonSpace) * (i % 4), kMoreButtonMargin + kMoreButtonHeight + (kMoreButtonHeight + kMoreButtonSpace) * (i / 4), kMoreButtonWidth, kMoreLabelHeight);
        UILabel *menuNameLabel = [[UILabel alloc] initWithFrame:titleRect];
        menuNameLabel.backgroundColor = [UIColor clearColor];
        menuNameLabel.font = [UIFont systemFontOfSize:15];
        menuNameLabel.textColor = RGBCOLOR(0x48, 0x48, 0x48);
        menuNameLabel.textAlignment = NSTextAlignmentCenter;
        menuNameLabel.text = menuDict[kMoreMenuTitle];
        [_menuScrollView addSubview:menuNameLabel];
    }
    [_menuScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
}
- (void)onMoreMenuButtonTapped:(UIButton *)btn
{
    NSInteger tag = btn.tag - kMoreButtoBaseTag;
    if (_delegate && [_delegate respondsToSelector:@selector(clickMoreMenuButtonWithType:)]) {
        [_delegate clickMoreMenuButtonWithType:tag];
    }
}
@end
