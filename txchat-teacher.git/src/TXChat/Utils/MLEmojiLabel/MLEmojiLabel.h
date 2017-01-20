//
//  MLEmojiLabel.h
//  MLEmojiLabel
//
//  Created by molon on 5/19/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "TTTAttributedLabel.h"

typedef void(^MLEmojiLabelBlock)(void);
typedef NS_OPTIONS(NSUInteger, MLEmojiLabelLinkType) {
    MLEmojiLabelLinkTypeURL = 0,
    MLEmojiLabelLinkTypePhoneNumber,
    MLEmojiLabelLinkTypeEmail,
    MLEmojiLabelLinkTypeAt,
    MLEmojiLabelLinkTypePoundSign,
};


@class MLEmojiLabel;
@protocol MLEmojiLabelDelegate <NSObject>

@optional
- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type;
- (void)attributedLabel:(MLEmojiLabel *)emojiLabel
didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;

@end

@interface MLEmojiLabel : TTTAttributedLabel
{
    MLEmojiLabelBlock _block;
}

@property (nonatomic, strong) id author;
@property (nonatomic, strong) id replyUser;
@property (nonatomic, strong) id replyUserName;
@property (nonatomic, strong) id feedComment;
@property (nonatomic, strong) id feed;

@property (nonatomic, assign) BOOL disableEmoji; //禁用表情
@property (nonatomic, assign) BOOL disableThreeCommon; //禁用电话，邮箱，连接三者

@property (nonatomic, assign) BOOL isNeedAtAndPoundSign; //是否需要话题和@功能，默认为不需要

@property (nonatomic, copy) NSString *customEmojiRegex; //自定义表情正则
@property (nonatomic, copy) NSString *customEmojiPlistName; //xxxxx.plist 格式

@property (nonatomic, weak) id<MLEmojiLabelDelegate> emojiDelegate; //点击连接的代理方法

@property (nonatomic, copy) NSString *emojiText; //设置处理文字

- (void)setEmojiDelegate:(id<MLEmojiLabelDelegate>)emojiDelegate withBlock:(MLEmojiLabelBlock)block;

@end
