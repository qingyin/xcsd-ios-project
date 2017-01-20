//
//  TXMediaToolBar.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/12.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXMediaToolBar.h"
#import "TXBudgeButton.h"
#import "NSObject+EXTParams.h"
#import "TXPBResource+Utils.h"

@interface TXMediaToolBar()
{
    UIView *_topLine;
    UIButton *_writeCommentBtn;
    TXBudgeButton *_commentButton;
    TXBudgeButton *_likeButton;
    TXBudgeButton *_shareButton;
    BOOL _hasClickLike;
}

@end

@implementation TXMediaToolBar

#pragma mark - 视图创建
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupMediaToolBar];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResourceCommentCountChanged:) name:NOTIFY_UPDATE_MEDIA_CommentUPDATE object:nil];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
                      resouce:(TXPBResource *)resource
{
    self = [super initWithFrame:frame];
    if (self) {
        _resource = resource;
        self.backgroundColor = [UIColor whiteColor];
        [self setupMediaToolBar];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResourceCommentCountChanged:) name:NOTIFY_UPDATE_MEDIA_CommentUPDATE object:nil];
    }
    return self;
}
//创建工具栏视图
- (void)setupMediaToolBar
{
    //添加分割线
    _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width_, kLineHeight)];
    _topLine.backgroundColor = RGBCOLOR(0xe1, 0xe1, 0xe1);
    [self addSubview:_topLine];
    //添加分享按钮
    //    _shareButton = [[TXBudgeButton alloc] initWithFrame:CGRectMake(self.width_ - 42, 0, 42, self.height_) normalName:@"media_shareSocial" selectedName:nil budge:0];
    //    [_shareButton addTarget:self action:@selector(onShareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    //    [self addSubview:_shareButton];
    //添加赞按钮
    NSInteger likeBudge = _resource ? (NSInteger)[_resource getLikedNumber] : 0;
    _liked = _resource ? [_resource isLiked] : NO;
    _likeButton = [[TXBudgeButton alloc] initWithFrame:CGRectMake(self.width_ - 52, 0, 42, self.height_) normalName:@"media_like" selectedName:@"media_like_selected" budge:likeBudge];
    [_likeButton addTarget:self action:@selector(onLikeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_likeButton];
    [_likeButton setSelected:_liked];
    //添加评论按钮
    NSInteger commentCount;
    NSNumber *extNumber = [_resource extParamForKey:@"commentCount"];
    if (extNumber) {
        commentCount = [extNumber integerValue];
    }else{
        commentCount = _resource.commentCount;
    }
    _commentButton = [[TXBudgeButton alloc] initWithFrame:CGRectMake(_likeButton.minX - 45, 0, 42, self.height_) normalName:@"media_comment" selectedName:nil budge:commentCount];
    [_commentButton addTarget:self action:@selector(onCommentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_commentButton];
    //添加写评论按钮
    _writeCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _writeCommentBtn.frame = CGRectMake(10, (self.height_ - 31) / 2, _commentButton.minX - 20, 31);
    _writeCommentBtn.layer.borderWidth = 0.5f;
    _writeCommentBtn.layer.borderColor = RGBCOLOR(83, 83, 83).CGColor;
    _writeCommentBtn.layer.cornerRadius = 4.f;
    _writeCommentBtn.layer.masksToBounds = YES;
    [_writeCommentBtn addTarget:self action:@selector(onWriteCommentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_writeCommentBtn];
    UILabel *writeCommentTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, _writeCommentBtn.width_ - 10, _writeCommentBtn.height_)];
    writeCommentTitle.textColor = [UIColor clearColor];
    writeCommentTitle.userInteractionEnabled = NO;
    writeCommentTitle.textColor = RGBCOLOR(83, 83, 83);
    writeCommentTitle.font = [UIFont systemFontOfSize:15];
    writeCommentTitle.text = @"写评论...";
    [_writeCommentBtn addSubview:writeCommentTitle];
}
#pragma mark - public
- (void)setResource:(TXPBResource *)resource
{
    if (_resource == resource) {
        return;
    }
    _resource = resource;
    _hasClickLike = NO;
    //赞
    int64_t likeBudge = _resource ? [_resource getLikedNumber] : 0;
    _liked = _resource ? [_resource isLiked] : NO;
    //    NSNumber *extNumber = [_resource extParamForKey:KTXPBRESOURCEISLIKED];
    //    if (extNumber) {
    //        _liked = [extNumber boolValue];
    //        likeBudge += 1;
    //    }else{
    //        _liked = _resource ? _resource.liked : NO;
    //    }
    _likeButton.budge = (NSInteger)likeBudge;
    [_likeButton setSelected:_liked];
    //评论
    NSInteger commentCount;
    NSNumber *extNumber = [_resource extParamForKey:@"commentCount"];
    if (extNumber) {
        commentCount = [extNumber integerValue];
    }else{
        commentCount = _resource.commentCount;
    }
    _commentButton.budge = commentCount;
}
- (void)setLiked:(BOOL)liked
{
    if (!_liked && liked) {
        NSInteger budge = _likeButton.budge;
        [_likeButton setSelected:YES];
        _likeButton.budge = budge + 1;
        //添加ext属性
        [_resource setTXExtParams:@(YES) forKey:KTXPBRESOURCEISLIKED];
        [_resource addLikedNumber:1];
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_MEDIA_LIKEUPDATE object:@(_resource.id)];
    }
    _liked = liked;
    _hasClickLike = NO;
}
//更新竖屏布局
- (void)updateLayoutToPortrait
{
    _topLine.frame = CGRectMake(0, 0, self.width_, kLineHeight);
    _likeButton.frame = CGRectMake(self.width_ - 52, 0, 42, self.width_);
    _commentButton.frame = CGRectMake(_likeButton.minX - 45, 0, 42, self.width_);
    _writeCommentBtn.frame = CGRectMake(10, (self.height_ - 31) / 2, _commentButton.minX - 20, 31);
}
//更新横屏布局
- (void)updateLayoutToLandscape
{
    _topLine.frame = CGRectMake(0, 0, self.height_, kLineHeight);
    _likeButton.frame = CGRectMake(self.height_ - 52, 0, 42, self.height_);
    _commentButton.frame = CGRectMake(_likeButton.minX - 45, 0, 42, self.height_);
    _writeCommentBtn.frame = CGRectMake(10, (self.width_ - 31) / 2, _commentButton.minX - 20, 31);
    
}
#pragma mark - 通知接收
- (void)onResourceCommentCountChanged:(NSNotification *)notification
{
    NSInteger commentCount;
    NSNumber *extNumber = [_resource extParamForKey:@"commentCount"];
    if (extNumber) {
        commentCount = [extNumber integerValue];
    }else{
        commentCount = _resource.commentCount;
    }
    _commentButton.budge = commentCount;
}
#pragma mark - 按钮点击相应
//分享
- (void)onShareButtonTapped
{
    if (_clickBlock) {
        _clickBlock(TXMediaToolType_Share);
    }
}
//赞
- (void)onLikeButtonTapped
{
    if (!_liked && !_hasClickLike) {
        _hasClickLike = YES;
        //传递给外部
        if (_clickBlock) {
            _clickBlock(TXMediaToolType_Like);
        }
    }
}
//评论
- (void)onCommentButtonTapped
{
    if (_clickBlock) {
        _clickBlock(TXMediaToolType_Comment);
    }
}
//写评论
- (void)onWriteCommentButtonTapped
{
    if (_clickBlock) {
        _clickBlock(TXMediaToolType_WriteComment);
    }
}
@end
