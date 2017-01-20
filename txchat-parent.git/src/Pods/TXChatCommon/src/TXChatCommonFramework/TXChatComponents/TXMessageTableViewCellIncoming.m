//
//  TXMessageTableViewCellIncoming.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXMessageTableViewCellIncoming.h"
#import "TXMessageBubbleView.h"
#import "UIImageView+EMWebCache.h"
#import "CommonUtils.h"
#import "UIImageView+TXSDImage.h"


@implementation TXMessageTableViewCellIncoming

- (void)setupMessageView
{
    [super setupMessageView];
    //头像
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMessageCellSpace, kMessageViewMargin, kMessageAvatarWidth, kMessageAvatarWidth)];
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
    //添加发送者名字
    self.senderNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMessageAvatarWidth +  kMessageCellSpace + kMessageCellSpace + 2, kMessageViewMargin, self.cellWidth - (kMessageAvatarWidth + kMessageViewMargin + kMessageCellSpace) * 2, kMessageSendNameHeight)];
    self.senderNameLabel.backgroundColor = [UIColor clearColor];
    self.senderNameLabel.font = [UIFont systemFontOfSize:13];
    self.senderNameLabel.textColor = RGBCOLOR(0x44, 0x68, 0x7a);
    [self.contentView addSubview:self.senderNameLabel];
    //消息视图
    self.bubbleView = [[TXMessageBubbleView alloc] initWithFrame:CGRectMake(kMessageAvatarWidth + kMessageViewMargin + kMessageCellSpace, 0, self.cellWidth - 120, 60) type:TXBubbleMessageTypeIncoming];
    self.bubbleView.clipsToBounds = NO;
    [self.contentView addSubview:self.bubbleView];
}
//更新子视图具体内容
- (void)updateMessageViewWithData:(id<TXMessageModelData>)data
{
    [super updateMessageViewWithData:data];
    //消息本体
    self.bubbleView.message = data;
    //头像
    [self.avatarImageView TX_setImageWithURL:[NSURL URLWithString:[data avatarUrlString]] placeholderImage:data.isService ? [UIImage imageNamed:@"xx_customService"] : [data avatarImage]];
    
    //    更新群聊时的位置
    if (self.isGroup) {
        CGRect bubbleFrame = self.bubbleView.frame;
        bubbleFrame.origin.y += kMessageSendNameHeight;
        self.bubbleView.frame = bubbleFrame;
        //设置发送者的名称
        self.senderNameLabel.text = [data senderName];
    }
    
    //调整frame
    if ([data messageMediaType] == TXBubbleMessageMediaTypeText) {
        
        if ([data isShare]) {
            
            CGFloat max_width = [UIScreen mainScreen].bounds.size.width - kMessageBubbleWidthMargin - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) * 2 - kMessageTextWidthMargin;
            
            //            CGFloat max_height = max_width * 40 / (kScreenWidth - 30);
//            CGFloat max_height = 120;
            
            self.bubbleView.frame = CGRectMake(kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace, kMessageViewMargin, max_width, [data rowHeight]);
            return;
        }
        //文本消息
        CGSize textSize = [data textSize];
        textSize.width += kMessageBubbleWidthMargin;
        if (textSize.width <= kMessageBubbleMinWidth) {
            textSize.width = kMessageBubbleMinWidth;
        }
        if (textSize.height < kMessageAvatarWidth) {
            self.bubbleView.frame = CGRectMake(kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace, kMessageViewMargin, textSize.width, kMessageAvatarWidth);
        }else{
            self.bubbleView.frame = CGRectMake(kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace, kMessageViewMargin, textSize.width, textSize.height);
        }
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypePhoto) {
        //图片消息
        CGSize thumbImageSize = [data thumbnailImageSize];
        self.bubbleView.frame = CGRectMake(kMessageAvatarWidth + kMessageAvatarAndBubbleMargin  + kMessageCellSpace, kMessageViewMargin, thumbImageSize.width, thumbImageSize.height);
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypeVoice) {
        //语音消息
        self.bubbleView.frame = CGRectMake(kMessageAvatarWidth + kMessageAvatarAndBubbleMargin  + kMessageCellSpace, kMessageViewMargin, [data voiceBubbleLength], kMessageAvatarWidth);
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypeEmotion) {
        //表情消息
        self.bubbleView.frame = CGRectMake(60, 0, self.cellWidth - 120, [data rowHeight]);
    }else if ([data messageMediaType] == TXBubbleMessageMediaTypeVideo) {
        //视频
        CGSize thumbImageSize = [data videoThumbSize];
        self.bubbleView.frame = CGRectMake(kMessageAvatarWidth + kMessageAvatarAndBubbleMargin  + kMessageCellSpace + 5, kMessageViewMargin, thumbImageSize.width, thumbImageSize.height);
    }
}

@end
