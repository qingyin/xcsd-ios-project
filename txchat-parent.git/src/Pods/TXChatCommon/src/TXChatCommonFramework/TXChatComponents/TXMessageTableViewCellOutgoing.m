//
//  TXMessageTableViewCellOutgoing.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXMessageTableViewCellOutgoing.h"
#import "TXMessageBubbleView.h"
#import "UIImageView+EMWebCache.h"
#import "CommonUtils.h"
#import "UIImageView+TXSDImage.h"

static NSString *const kRouterEventRetryButtonTapEventName = @"kRouterEventRetryButtonTapEventName";

@implementation TXMessageTableViewCellOutgoing

- (void)setupMessageView
{
    [super setupMessageView];
    //头像
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.cellWidth - kMessageAvatarWidth - kMessageCellSpace, kMessageViewMargin, kMessageAvatarWidth, kMessageAvatarWidth)];
    self.avatarImageView.backgroundColor = [UIColor clearColor];
    self.avatarImageView.userInteractionEnabled = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 4;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.avatarImageView];
    //添加点击手势
    UITapGestureRecognizer *avatarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarImageViewTapped)];
    [self.avatarImageView addGestureRecognizer:avatarTapGesture];
    //消息视图
    self.bubbleView = [[TXMessageBubbleView alloc] initWithFrame:CGRectMake(self.cellWidth - 180, 0, self.cellWidth - 120, 60) type:TXBubbleMessageTypeOutgoing];
    self.bubbleView.clipsToBounds = NO;
    [self.contentView addSubview:self.bubbleView];
    //发送中视图
    self.sendingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:self.sendingIndicatorView];
    [self.sendingIndicatorView startAnimating];
    self.sendingIndicatorView.hidden = YES;
    //发送失败视图
    self.sendFailView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendFailView.frame = CGRectMake(0, 0, 22, 22);
    [self.sendFailView setImage:[UIImage imageNamed:@"chat_sendFail"] forState:UIControlStateNormal];
    [self.sendFailView addTarget:self action:@selector(onSendFailViewTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.sendFailView];
    self.sendFailView.hidden = YES;
}
//更新子视图具体内容
- (void)updateMessageViewWithData:(id<TXMessageModelData>)data
{
    [super updateMessageViewWithData:data];
    //消息本体
    self.bubbleView.message = data;
    //头像
    [self.avatarImageView TX_setImageWithURL:[NSURL URLWithString:[data avatarUrlString]] placeholderImage:[data avatarImage]];
    //调整frame
    if ([data messageMediaType] == TXBubbleMessageMediaTypeText) {
        
        
        if ([data isShare]) {
            
            CGFloat max_width = [UIScreen mainScreen].bounds.size.width - kMessageBubbleWidthMargin - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) * 2 - kMessageTextWidthMargin;
            
            //            CGFloat max_height = max_width * 40 / (kScreenWidth - 30);
//            CGFloat max_height = 120;
            
            self.bubbleView.frame = CGRectMake(self.cellWidth - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) - max_width, kMessageViewMargin, max_width, [data rowHeight]);
            return;
        }
        
        //文本消息
        CGSize textSize = [data textSize];
        textSize.width += kMessageBubbleWidthMargin;
        if (textSize.width <= kMessageBubbleMinWidth) {
            textSize.width = kMessageBubbleMinWidth;
        }
        if (textSize.height < kMessageAvatarWidth) {
            self.bubbleView.frame = CGRectMake(self.cellWidth - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) - textSize.width, kMessageViewMargin, textSize.width, kMessageAvatarWidth);
        }else{
            self.bubbleView.frame = CGRectMake(self.cellWidth - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) - textSize.width, kMessageViewMargin, textSize.width, textSize.height);
        }
        //设置发送中的视图
        self.sendingIndicatorView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
        //设置发送失败的视图
        self.sendFailView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypePhoto) {
        //图片消息
        CGSize thumbImageSize = [data thumbnailImageSize];
        self.bubbleView.frame = CGRectMake(self.cellWidth - kMessageAvatarWidth - kMessageAvatarAndBubbleMargin - kMessageCellSpace - thumbImageSize.width, kMessageViewMargin, thumbImageSize.width, thumbImageSize.height);
        //设置发送中的视图
        self.sendingIndicatorView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
        //设置发送失败的视图
        self.sendFailView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypeVoice) {
        //语音消息
        self.bubbleView.frame = CGRectMake(self.cellWidth - kMessageAvatarWidth - kMessageAvatarAndBubbleMargin - kMessageCellSpace - [data voiceBubbleLength], kMessageViewMargin, [data voiceBubbleLength], kMessageAvatarWidth);
        //设置发送中的视图
        self.sendingIndicatorView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 60, self.bubbleView.center.y);
        //设置发送失败的视图
        self.sendFailView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 60, self.bubbleView.center.y);
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypeEmotion) {
        //表情消息
        self.bubbleView.frame = CGRectMake(60, 0, self.cellWidth - 120, [data rowHeight]);
        //设置发送中的视图
        self.sendingIndicatorView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
        //设置发送失败的视图
        self.sendFailView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypeVideo) {
        //视频
        CGSize thumbImageSize = [data videoThumbSize];
        self.bubbleView.frame = CGRectMake(self.cellWidth - kMessageAvatarWidth - kMessageAvatarAndBubbleMargin - kMessageCellSpace - thumbImageSize.width - 5, kMessageViewMargin, thumbImageSize.width, thumbImageSize.height);
        //设置发送中的视图
        self.sendingIndicatorView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
        //设置发送失败的视图
        self.sendFailView.center = CGPointMake(CGRectGetMinX(self.bubbleView.frame) - 20, self.bubbleView.center.y);
    }
}
//点击了重试按钮
- (void)onSendFailViewTapped
{
    [super routerEventWithName:kRouterEventRetryButtonTapEventName userInfo:@{@"message":self.messageData,@"indexPath": self.indexPath}];
}
@end
