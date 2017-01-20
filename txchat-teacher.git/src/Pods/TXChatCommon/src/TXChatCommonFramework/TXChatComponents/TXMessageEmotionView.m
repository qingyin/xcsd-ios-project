//
//  TXMessageEmotionView.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXMessageEmotionView.h"
#import "Emoji.h"
#import "CommonUtils.h"

@interface TXMessageEmotionView()
<UIScrollViewDelegate>
{
    UIScrollView *_emotionScrollView;
    UIView *_bottomToolView;
    UIPageControl *_pageControl;
    NSInteger _pageCount;
}
@property (nonatomic,strong) NSArray *faces;

@end

@implementation TXMessageEmotionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _faces = [Emoji allEmoji];
        [self setupEmotionScrollView];
    }
    return self;
}
//设置滚动视图
- (void)setupEmotionScrollView
{
    CGFloat kToolViewHeight = 40;
    CGFloat kPageControlHeight = 30;
    _emotionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - kToolViewHeight)];
    _emotionScrollView.pagingEnabled = YES;
    _emotionScrollView.showsHorizontalScrollIndicator = NO;
    _emotionScrollView.delegate = self;
    [self addSubview:_emotionScrollView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(100, CGRectGetHeight(self.frame)  - kPageControlHeight  - kToolViewHeight - 5, CGRectGetWidth(self.frame) - 200, kPageControlHeight)];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.pageIndicatorTintColor = RGBCOLOR(0xbb, 0xbb, 0xbb);
    _pageControl.currentPageIndicatorTintColor = RGBCOLOR(0x8b, 0x8b, 0x8b);
    [self addSubview:_pageControl];
    //添加表情内容
    int maxRow = 3;
    int maxCol = 7;
    CGFloat itemWidth = self.frame.size.width / maxCol;
    CGFloat itemHeight = (self.frame.size.height  - kPageControlHeight - kToolViewHeight) / maxRow;
    _pageCount = ceilf([_faces count] / (float)(maxRow * maxCol - 1));
    for (NSInteger page = 0; page < _pageCount; page++) {
        for (NSInteger row = 0; row < maxRow; row++) {
            for (NSInteger col = 0; col < maxCol; col++) {
                NSInteger index = page * (maxRow * maxCol) + row * maxCol + col;
                if (index >= [_faces count] + _pageCount) {
                    break;
                }
                if (index == (page + 1) * (maxRow *maxCol) - 1 || index == [_faces count] + page) {
                    //最后一行的最后一个或者是最后一页的最后一个
                    //添加发送删除按钮
                    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [deleteButton setBackgroundColor:[UIColor clearColor]];
                    [deleteButton setFrame:CGRectMake(page * CGRectGetWidth(_emotionScrollView.frame) + col * itemWidth, row * itemHeight, itemWidth, itemHeight)];
                    [deleteButton setImage:[UIImage imageNamed:@"chat_face_delete"] forState:UIControlStateNormal];
                    [deleteButton setImage:[UIImage imageNamed:@"chat_face_delete_press"] forState:UIControlStateHighlighted];
                    [deleteButton addTarget:self action:@selector(onDeleteEmotionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
                    [_emotionScrollView addSubview:deleteButton];
                }else{
                    NSInteger faceIndex = index - page;
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    [button setBackgroundColor:[UIColor clearColor]];
                    [button setFrame:CGRectMake(page * CGRectGetWidth(_emotionScrollView.frame) + col * itemWidth, row * itemHeight, itemWidth, itemHeight)];
                    [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
                    [button setTitle: [_faces objectAtIndex:faceIndex] forState:UIControlStateNormal];
                    button.tag = faceIndex;
                    [button addTarget:self action:@selector(onEmotionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                    [_emotionScrollView addSubview:button];
                }
            }
        }
    }
    _pageControl.numberOfPages = _pageCount;
    _pageControl.currentPage = 0;
    [_emotionScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * _pageCount, CGRectGetHeight(_emotionScrollView.frame))];
    //添加底部栏
    _bottomToolView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_emotionScrollView.frame), self.frame.size.width, kToolViewHeight)];
    _bottomToolView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomToolView];
    //添加发送按钮
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setFrame:CGRectMake(CGRectGetWidth(_bottomToolView.frame) - 80, 0, 80, kToolViewHeight)];
    [sendButton addTarget:self action:@selector(onSendEmotionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setBackgroundColor:RGBCOLOR(0x00, 0x7a, 0xff)];
    [_bottomToolView addSubview:sendButton];

}
//表情按钮被点击
- (void)onEmotionButtonTapped:(UIButton *)btn
{
    NSString *str = [_faces objectAtIndex:btn.tag];
    if (_delegate && [_delegate respondsToSelector:@selector(selectedEmotion:isDeleted:)]) {
        [_delegate selectedEmotion:str isDeleted:NO];
    }
}
//删除表情
- (void)onDeleteEmotionButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectedEmotion:isDeleted:)]) {
        [_delegate selectedEmotion:nil isDeleted:YES];
    }
}
//发送表情
- (void)onSendEmotionButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(sendEmotion)]) {
        [_delegate sendEmotion];
    }
}
#pragma mark - public
- (BOOL)stringIsFace:(NSString *)string
{
    if ([_faces containsObject:string]) {
        return YES;
    }
    
    return NO;
}
#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > _pageCount - 1) index = _pageCount - 1;
    _pageControl.currentPage = index;
}
@end
