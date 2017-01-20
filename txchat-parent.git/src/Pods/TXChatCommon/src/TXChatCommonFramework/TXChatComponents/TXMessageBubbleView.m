//
//  TXMessageBubbleView.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXMessageBubbleView.h"
#import "TXMessageAudioView.h"
#import "UIResponder+Router.h"
#import "NIAttributedLabel.h"
#import "NSMutableAttributedString+NimbusKitAttributedLabel.h"
#import "CommonUtils.h"
#import <YYText.h>
#import "TXMessageTextParser.h"
#import "UIImageView+TXSDImage.h"
#import <Foundation/Foundation.h>

static NSString *const kRouterEventImageBubbleTapEventName = @"kRouterEventImageBubbleTapEventName";
static NSString *const kRouterEventAudioBubbleTapEventName = @"kRouterEventAudioBubbleTapEventName";
static NSString *const kRouterEventTextBubbleDoubleTapEventName = @"kRouterEventTextBubbleDoubleTapEventName";
static NSString *const kRouterEventTextBubbleClickLinkURLEventName = @"kRouterEventTextBubbleClickLinkURLEventName";
static NSString *const kRouterEventVideoBubbleTapEventName = @"kRouterEventVideoBubbleTapEventName";
static NSString *const kRouterEventShareTapEventName = @"kRouterEventShareTapEventName";


@interface TXMessageBubbleView()
<NIAttributedLabelDelegate>

@property (nonatomic,strong) UIImageView *bubbleImageView;
//@property (nonatomic,strong) NIAttributedLabel *displayTextLabel;
@property (nonatomic,strong) YYLabel *displayTextLabel;
@property (nonatomic,strong) UIImageView *messageImageView;
@property (nonatomic,strong) TXMessageAudioView *audioView;
@property (nonatomic,strong) UIView *videoPlayBgView;
@property (nonatomic,strong) UIImageView *videoPlayImageView;
@property (nonatomic,strong) UIImageView *imageMaskView;

@property (nonatomic, weak) UIImageView *shareImageView;
@property (nonatomic, weak) UILabel *shareLbl;
@property (nonatomic, weak) UIView *shareView;


@property (nonatomic, assign) TXBubbleMessageType type;

@end

@implementation TXMessageBubbleView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame
                         type:(TXBubbleMessageType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _type = type;
        //背景图
        _bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
//        _bubbleImageView.backgroundColor = [UIColor blueColor];
        if (type == TXBubbleMessageTypeIncoming) {
            //接收bubble
            UIImage *image = [UIImage imageNamed:@"chatBubble_receiving"];
            UIEdgeInsets bubbleImageEdgeInsets = UIEdgeInsetsMake(28, 26, 55, 18);
            image = [image resizableImageWithCapInsets:bubbleImageEdgeInsets resizingMode:UIImageResizingModeStretch];
            _bubbleImageView.image = image;
        }else{
            //发送bubble
            UIImage *image = [UIImage imageNamed:@"chatBubble_sending"];
            UIEdgeInsets bubbleImageEdgeInsets = UIEdgeInsetsMake(28, 18, 55, 26);

            image = [image resizableImageWithCapInsets:bubbleImageEdgeInsets resizingMode:UIImageResizingModeStretch];
            _bubbleImageView.image = image;
        }
        [self addSubview:_bubbleImageView];
        //文本视图
//        _displayTextLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
//        _displayTextLabel.numberOfLines = 0;
//        _displayTextLabel.textColor = kColorMessageText;
//        _displayTextLabel.linkColor = kColorMessageText;
//        _displayTextLabel.font = kMessageTextFont;
//        _displayTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        _displayTextLabel.backgroundColor = [UIColor clearColor];
//        _displayTextLabel.verticalTextAlignment = NIVerticalTextAlignmentMiddle;
//        _displayTextLabel.autoDetectLinks = YES;
//        _displayTextLabel.delegate = self;
//        _displayTextLabel.linksHaveUnderlines = YES;
//        _displayTextLabel.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
//        [self addSubview:_displayTextLabel];
        
        _displayTextLabel = [YYLabel new];
        _displayTextLabel.backgroundColor = [UIColor clearColor];
        _displayTextLabel.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _displayTextLabel.font = kMessageTextFont;
        _displayTextLabel.textColor = kColorMessageText;
        _displayTextLabel.textAlignment = NSTextAlignmentLeft;
        _displayTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _displayTextLabel.numberOfLines = 0;
//        //设置行高矫正
//        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
//        modifier.fixedLineHeight = 16;
//        _displayTextLabel.linePositionModifier = modifier;
        //设置parser
        TXMessageTextParser *parser = [TXMessageTextParser new];
        parser.highlightColor = kColorMessageText;
        _displayTextLabel.textParser = parser;
        __weak __typeof(&*self) weakSelf=self;  //by sck
        _displayTextLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            NSString *clickUrlString = [[text string] substringWithRange:range];
            if (clickUrlString && [clickUrlString length]) {
                //向外跳转
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf routerEventWithName:kRouterEventTextBubbleClickLinkURLEventName userInfo:@{@"url":clickUrlString}];
                }
            }
        };
        [self addSubview:_displayTextLabel];
        //图片消息
        _messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _messageImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_messageImageView];
        //图片mask
        _imageMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        if (type == TXBubbleMessageTypeIncoming) {
            //接收bubble
            UIImage *image = [UIImage imageNamed:@"msgImageMask_incoming"];
            UIEdgeInsets bubbleImageEdgeInsets = UIEdgeInsetsMake(28, 26, 55, 18);
            image = [image resizableImageWithCapInsets:bubbleImageEdgeInsets resizingMode:UIImageResizingModeStretch];
            _imageMaskView.image = image;
        }else{
            //发送bubble
            UIImage *image = [UIImage imageNamed:@"msgImageMask_outgoing"];
            UIEdgeInsets bubbleImageEdgeInsets = UIEdgeInsetsMake(28, 18, 55, 26);
            
            image = [image resizableImageWithCapInsets:bubbleImageEdgeInsets resizingMode:UIImageResizingModeStretch];
            _imageMaskView.image = image;
        }
        [_messageImageView addSubview:_imageMaskView];
        //语音视图
        _audioView = [[TXMessageAudioView alloc] initWithFrame:CGRectMake(0, 0, kMessageVoiceBubbleMinWidth, kMessageAvatarWidth)];
        _audioView.backgroundColor = [UIColor clearColor];
        _audioView.clipsToBounds = NO;
        [self addSubview:_audioView];
        //视频半透视图
        _videoPlayBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _videoPlayBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        [_messageImageView addSubview:_videoPlayBgView];
        _videoPlayBgView.hidden = YES;
        //视频播放视图
        _videoPlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
        _videoPlayImageView.backgroundColor = [UIColor clearColor];
        _videoPlayImageView.image = [UIImage imageNamed:@"chat_video_play"];
        [_messageImageView addSubview:_videoPlayImageView];
        _videoPlayImageView.hidden = YES;
        //添加双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBubbleViewDoubleTapped)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        //添加单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBubbleViewSingleTapped)];
        singleTap.numberOfTapsRequired = 1;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:singleTap];
    }
    return self;
}
- (void)setMessage:(id<TXMessageModelData>)message
{
    if (message == nil) {
        return;
    }
    _message = message;
    //暂时用普通颜色代替来区分
    if ([_message bubbleMessageType] == TXBubbleMessageTypeOutgoing) {
        //本人发送的消息
        //隐藏或显示视图
        [self updateBubbleViewVisibleStateWithMediaType:[_message messageMediaType]];
        //展示对应消息内容
        if ([_message messageMediaType] == TXBubbleMessageMediaTypeText) {
            
            if ([message isShare]) {
                
                self.displayTextLabel.hidden = YES;
                self.shareView.hidden = NO;
//                self.shareLbl.hidden = NO;
//                self.shareImageView.hidden = NO;
                
                if (!self.shareView) {
                    [self createShareViewWithMsg:message];
                }else {
                    [self updateShareSubviewsFrameWithMsg:message];
                }
                
                return;
            }
            
            self.shareView.hidden = YES;
            self.displayTextLabel.hidden = NO;
            
            //文本消息
            CGSize textSize = [message textSize];
            textSize.width += kMessageBubbleWidthMargin;
            if (textSize.width <= kMessageBubbleMinWidth) {
                textSize.width = kMessageBubbleMinWidth;
            }
            _bubbleImageView.frame = CGRectMake(0, 0, textSize.width, textSize.height);
            _displayTextLabel.frame = CGRectMake(kMessageOutgoingLeftMargin + (textSize.width - kMessageBubbleWidthMargin - [message textSize].width) / 2, 0, [message textSize].width, textSize.height);
            NSString *msgText = @"";
            if (message && [message text] && [[message text] length]) {
                msgText = [message text];
            }
//            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:msgText];
////            [text performSelector:@selector(nimbuskit_setTextColor:) withObject:KColorTitleTxt];
//            [text performSelector:@selector(nimbuskit_setFont:) withObject:kMessageTextFont];
//            [text nimbuskit_setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByCharWrapping lineHeight:19.1];
//            _displayTextLabel.attributedText = text;
            
//            _displayTextLabel.textLayout = [_message textLayout];
//            _displayTextLabel.frame.size = [[_message textLayout] textBoundingSize];
//
//            CGSize size = [self.textLayout textBoundingSize];
//            size.height += (kMessageBubbleTopMarigin + kMessageBubbleBottomMargin);
//            if (size.height < kMessageBubbleMinHeight) {
//                self.textSize = CGSizeMake(size.width, kMessageBubbleMinHeight);
//            }else{
//                self.textSize = size;
//            }
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:msgText];
            text.yy_font = kMessageTextFont;
            text.yy_lineSpacing = 3;
            _displayTextLabel.attributedText = text;
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypePhoto) {
            //图片消息
            _bubbleImageView.frame = CGRectMake(0, 0, [_message thumbnailImageSize].width, [_message thumbnailImageSize].height);
            _messageImageView.frame = CGRectMake(0, 0, [_message thumbnailImageSize].width, [_message thumbnailImageSize].height);
            _imageMaskView.frame = CGRectMake(0, 0, [_message thumbnailImageSize].width, [_message thumbnailImageSize].height);
            _messageImageView.image = [UIImage imageWithContentsOfFile:[_message thumbnailImageLocalPath]];
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeVoice) {
            //语音消息
            _bubbleImageView.frame = CGRectMake(0, 0, [_message voiceBubbleLength], kMessageAvatarWidth);
            _audioView.frame = CGRectMake(0, 0, [_message voiceBubbleLength], kMessageAvatarWidth);
            _audioView.message = message;
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeEmotion) {
            //表情消息
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeVideo) {
            //视频
            _bubbleImageView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _messageImageView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _imageMaskView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _messageImageView.image = [UIImage imageWithContentsOfFile:[_message videoLocalThumbnailImageURL]];
            _videoPlayBgView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _videoPlayImageView.center = CGPointMake([_message videoThumbSize].width / 2, [_message videoThumbSize].height / 2);
        }
    }else if ([_message bubbleMessageType] == TXBubbleMessageTypeIncoming) {
        //别人发的消息
        //隐藏或显示视图
        [self updateBubbleViewVisibleStateWithMediaType:[_message messageMediaType]];
        //展示对应消息内容
        if ([_message messageMediaType] == TXBubbleMessageMediaTypeText) {
            
            
            if ([message isShare]) {
                
                self.displayTextLabel.hidden = YES;
                self.shareView.hidden = NO;
//                self.shareLbl.hidden = NO;
//                self.shareImageView.hidden = NO;
                
                if (!self.shareView) {
                    [self createShareViewWithMsg:message];
                }else {
                    [self updateShareSubviewsFrameWithMsg:message];
                }
                
//                self.shareLbl.text = [message shareTitle];
//                [self.shareImageView TX_setImageWithURL:[message shareImageUrl] placeholderImage:nil];
//                
//                CGFloat max_width = [UIScreen mainScreen].bounds.size.width - kMessageBubbleWidthMargin - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) * 2 - kMessageTextWidthMargin - 4.5;
//                
//                
//                CGFloat max_height = [message rowHeight] - 14;
//                
//                NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName,nil];
//                CGSize textSize = [[message shareTitle] boundingRectWithSize:CGSizeMake(max_width - 16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
//                //
//                //                self.bubbleView.frame = CGRectMake(kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace, kMessageViewMargin, max_width, max_height);
//                
//                self.shareLbl.frame = CGRectMake(12.5, 7, textSize.width, textSize.height);
//                CGFloat imageHeight = max_height - textSize.height - 15 - 7 - 30;
//                self.shareImageView.frame = CGRectMake(12.5, textSize.height + 8 + 7, max_width - 20, imageHeight);
//                
//                CGFloat imageViewMaxY = textSize.height + 8 + 7 + imageHeight;
//                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(4, imageViewMaxY + 7, max_width - 4, 0.5)];
//                lineView.backgroundColor = RGBCOLOR(210, 210, 210);
//                [self.shareView addSubview:lineView];
//                
//                UILabel *readLbl = [[UILabel alloc] initWithFrame:CGRectMake(12.5, textSize.height + 29 + imageHeight, max_width - 16, 15)];
//                readLbl.text = @"阅读全文";
//                readLbl.textColor = RGBCOLOR(0, 0, 0);
//                readLbl.font = [UIFont systemFontOfSize:12];
//                [self.shareView addSubview:readLbl];
//                
//                UIImage *image = [UIImage imageNamed:@"articleShare_arrow"];
//                UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(max_width - 9 - 7 - image.size.width, textSize.height + 30.5 + imageHeight, image.size.width, image.size.height)];
//                imageV.image = image;
//                [self.shareView addSubview:imageV];
//
//                
//                self.bubbleImageView.frame = CGRectMake(0, 0, max_width, max_height);
//                self.shareView.frame = CGRectMake(0, 0, max_width, max_height);
                
                return;
            }
            
//            self.shareLbl.hidden = YES;
            self.shareView.hidden = YES;
//            self.shareImageView.hidden = YES;
            self.displayTextLabel.hidden = NO;
            //文本消息
            CGSize textSize = [message textSize];
            textSize.width += kMessageBubbleWidthMargin;
            if (textSize.width <= kMessageBubbleMinWidth) {
                textSize.width = kMessageBubbleMinWidth;
            }
            _bubbleImageView.frame = CGRectMake(0, 0, textSize.width, textSize.height);
            _displayTextLabel.frame = CGRectMake(kMessageIncomingLeftMargin + (textSize.width - kMessageBubbleWidthMargin - [message textSize].width) / 2, 0, [message textSize].width, textSize.height);
//            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[message text]];
////            [text performSelector:@selector(nimbuskit_setTextColor:) withObject:KColorTitleTxt];
//            [text performSelector:@selector(nimbuskit_setFont:) withObject:kMessageTextFont];
//            [text nimbuskit_setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByCharWrapping lineHeight:19.1];
//            _displayTextLabel.attributedText = text;
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[message text]];
            text.yy_font = kMessageTextFont;
            text.yy_lineSpacing = 3;
            _displayTextLabel.attributedText = text;
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypePhoto) {
            //图片消息
            _bubbleImageView.frame = CGRectMake(0, 0, [_message thumbnailImageSize].width, [_message thumbnailImageSize].height);
            _messageImageView.frame = CGRectMake(0, 0, [_message thumbnailImageSize].width, [_message thumbnailImageSize].height);
            _imageMaskView.frame = CGRectMake(0, 0, [_message thumbnailImageSize].width, [_message thumbnailImageSize].height);
            _messageImageView.image = [UIImage imageWithContentsOfFile:[_message thumbnailImageLocalPath]];
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeVoice) {
            //语音消息
            _bubbleImageView.frame = CGRectMake(0, 0, [_message voiceBubbleLength], kMessageAvatarWidth);
            _audioView.frame = CGRectMake(0, 0, [_message voiceBubbleLength], kMessageAvatarWidth);
            _audioView.message = message;
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeEmotion) {
            //表情消息
        }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeVideo) {
            //视频
            _bubbleImageView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _messageImageView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _imageMaskView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _messageImageView.image = [UIImage imageWithContentsOfFile:[_message videoLocalThumbnailImageURL]];
            _videoPlayBgView.frame = CGRectMake(0, 0, [_message videoThumbSize].width, [_message videoThumbSize].height);
            _videoPlayImageView.center = CGPointMake([_message videoThumbSize].width / 2, [_message videoThumbSize].height / 2);
        }

    }
}

- (void)createShareViewWithMsg:(id<TXMessageModelData>)message {
    
    UIView *shareView = [[UIView alloc] init];
    [self addSubview:shareView];
    self.shareView = shareView;
    
    BOOL isOut = [message bubbleMessageType] == TXBubbleMessageTypeOutgoing;
    
//    self.shareLbl.text = [message shareTitle];
//    [self.shareImageView TX_setImageWithURL:[message shareImageUrl] placeholderImage:nil];
    
//    CGFloat max_width = [UIScreen mainScreen].bounds.size.width - kMessageBubbleWidthMargin - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) * 2 - kMessageTextWidthMargin - 4.5;
//    
//    
//    CGFloat max_height;
//    if (isOut) {
//        max_height = [message rowHeight] - 14 + 20;
//    }else {
//        max_height = [message rowHeight] - 14;
//    }
    
//    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName,nil];
//    CGSize textSize = [[message shareTitle] boundingRectWithSize:CGSizeMake(max_width - 16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
//    
//    CGFloat imageHeight = max_height - textSize.height - 15 - 7 - 30;
    
    
    
    UIView *lineView = [[UIView alloc] init];
    lineView.tag = 100;
    lineView.backgroundColor = RGBCOLOR(210, 210, 210);
    [self.shareView addSubview:lineView];
    
    UILabel *readLbl = [[UILabel alloc] init];
    readLbl.tag = 101;
    readLbl.text = @"阅读全文";
    readLbl.textColor = RGBCOLOR(0, 0, 0);
    readLbl.font = [UIFont systemFontOfSize:12];
    [self.shareView addSubview:readLbl];
    
    UIImage *image = [UIImage imageNamed:@"articleShare_arrow"];
    UIImageView *imageV = [[UIImageView alloc] init];
    imageV.tag = 102;
    imageV.image = image;
    [self.shareView addSubview:imageV];
    
    [self updateShareSubviewsFrameWithMsg:message];
    
    if (isOut) {
        self.bubbleImageView.image = [UIImage imageNamed:@"lt_right"];
    }
}

- (void)updateShareSubviewsFrameWithMsg:(id<TXMessageModelData>)message {
    
    BOOL isOut = [message bubbleMessageType] == TXBubbleMessageTypeOutgoing;
    
    self.shareLbl.text = [message shareTitle];
    [self.shareImageView TX_setImageWithURL:[message shareImageUrl] placeholderImage:nil];
    
    CGFloat max_width = [UIScreen mainScreen].bounds.size.width - kMessageBubbleWidthMargin - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) * 2 - kMessageTextWidthMargin - 4.5;
    
    
    CGFloat max_height;
    if (isOut) {
        max_height = [message rowHeight] - 14 + 20;
    }else {
        max_height = [message rowHeight] - 14;
    }
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName,nil];
    CGSize textSize = [[message shareTitle] boundingRectWithSize:CGSizeMake(max_width - 16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    CGFloat imageHeight = max_height - textSize.height - 15 - 7 - 30;
    CGFloat imageViewMaxY = textSize.height + 8 + 7 + imageHeight;

    
    UIView *lineV = [self.shareView viewWithTag:100];
    UILabel *readLbl = [self.shareView viewWithTag:101];
    UIImageView *imageV = [self.shareView viewWithTag:102];
    UIImage *image = [UIImage imageNamed:@"articleShare_arrow"];
    
    if (isOut) {
        
        self.shareLbl.frame = CGRectMake(8, 7, textSize.width, textSize.height);
        self.shareImageView.frame = CGRectMake(8, textSize.height + 8 + 7, max_width - 20, imageHeight);
        lineV.frame = CGRectMake(0, imageViewMaxY + 7, max_width - 4, 0.5);
        readLbl.frame = CGRectMake(8, textSize.height + 29 + imageHeight, max_width - 16, 15);
        imageV.frame = CGRectMake(max_width - 9 - 7 - image.size.width, textSize.height + 30.5 + imageHeight, image.size.width, image.size.height);
    }else {
        
        self.shareLbl.frame = CGRectMake(12.5, 7, textSize.width, textSize.height);
        self.shareImageView.frame = CGRectMake(12.5, textSize.height + 8 + 7, max_width - 20, imageHeight);
        lineV.frame = CGRectMake(4, imageViewMaxY + 7, max_width - 4, 0.5);
        readLbl.frame = CGRectMake(12.5, textSize.height + 29 + imageHeight, max_width - 16, 15);
        imageV.frame = CGRectMake(max_width - 9 - 7 - image.size.width, textSize.height + 30.5 + imageHeight, image.size.width, image.size.height);
    }
    
    self.bubbleImageView.frame = CGRectMake(0, 0, max_width, max_height);
    self.shareView.frame = CGRectMake(0, 0, max_width - 9, max_height);
}
//根据状态显示对应的视图
- (void)updateBubbleViewVisibleStateWithMediaType:(TXBubbleMessageMediaType)type
{
    switch (type) {
        case TXBubbleMessageMediaTypeText: {
            _displayTextLabel.hidden = NO;
            _messageImageView.hidden = YES;
            _audioView.hidden = YES;
            break;
        }
        case TXBubbleMessageMediaTypePhoto: {
            _displayTextLabel.hidden = YES;
            _messageImageView.hidden = NO;
            _audioView.hidden = YES;
            _videoPlayBgView.hidden = YES;
            _videoPlayImageView.hidden = YES;
            break;
        }
        case TXBubbleMessageMediaTypeVoice: {
            _displayTextLabel.hidden = YES;
            _messageImageView.hidden = YES;
            _audioView.hidden = NO;
            break;
        }
        case TXBubbleMessageMediaTypeEmotion: {
            _displayTextLabel.hidden = YES;
            _messageImageView.hidden = YES;
            _audioView.hidden = YES;
            break;
        }
        case TXBubbleMessageMediaTypeVideo: {
            _displayTextLabel.hidden = YES;
            _messageImageView.hidden = NO;
            _audioView.hidden = YES;
            _videoPlayBgView.hidden = NO;
            _videoPlayImageView.hidden = NO;
        }
            break;
        default: {
            _displayTextLabel.hidden = YES;
            _messageImageView.hidden = YES;
            _audioView.hidden = YES;
            break;
        }
    }
}
//单击bubble视图
- (void)onBubbleViewSingleTapped
{
//    NSLog(@"单击了bubble视图");
    if ([_message messageMediaType] == TXBubbleMessageMediaTypePhoto) {
        //图片消息
        [self routerEventWithName:kRouterEventImageBubbleTapEventName userInfo:@{@"message":_message}];
    }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeVoice) {
        //语音消息
        [self routerEventWithName:kRouterEventAudioBubbleTapEventName userInfo:@{@"message":_message}];
    }else if ([_message messageMediaType] == TXBubbleMessageMediaTypeVideo) {
        //视频消息
        [self routerEventWithName:kRouterEventVideoBubbleTapEventName userInfo:@{@"message":_message}];
    }else if ([self.message messageMediaType] == TXBubbleMessageMediaTypeText && [self.message isShare]) {
        // 点击内部分享
        [self routerEventWithName:kRouterEventShareTapEventName userInfo:@{@"shareUrl" : [self.message shareUrl], @"shareTitle" : [self.message shareTitle], @"shareImageUrl" : [self.message shareImageUrl]}];
    }
}
//双击bubble视图
- (void)onBubbleViewDoubleTapped
{
//    NSLog(@"双击了bubble视图");
    if ([_message messageMediaType] == TXBubbleMessageMediaTypeText) {
        //文本消息
        
        if ([self.message isShare]) {
            return;
        }
        
        [self routerEventWithName:kRouterEventTextBubbleDoubleTapEventName userInfo:@{@"message":_message}];
    }
}
#pragma mark - NIAttributedLabelDelegate methods
- (BOOL)attributedLabel:(NIAttributedLabel *)attributedLabel shouldPresentActionSheet:(UIActionSheet *)actionSheet withTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    return NO;
}
- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
//    NSLog(@"url:%@",result.URL);
    NSString *clickUrlString = result.URL.absoluteString;
    if (clickUrlString && [clickUrlString length]) {
        //向外跳转
        [self routerEventWithName:kRouterEventTextBubbleClickLinkURLEventName userInfo:@{@"url":clickUrlString}];
    }
}


- (UIImageView *)shareImageView {
    if (!_shareImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        _shareImageView = imageView;
        _shareImageView.contentMode = UIViewContentModeScaleAspectFill;
        _shareImageView.clipsToBounds = YES;
        _shareImageView.layer.cornerRadius = 5;
        [self.shareView addSubview:_shareImageView];
    }
    return _shareImageView;
}

- (UILabel *)shareLbl {
    if (!_shareLbl) {
        UILabel *label = [[UILabel alloc] init];
        _shareLbl = label;
        _shareLbl.numberOfLines = 0;
        [_shareLbl sizeToFit];
        _shareLbl.font = [UIFont systemFontOfSize:16];
        [self.shareView addSubview:_shareLbl];
    }
    return _shareLbl;
}
@end
