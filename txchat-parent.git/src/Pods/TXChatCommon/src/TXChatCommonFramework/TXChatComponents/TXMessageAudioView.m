//
//  TXMessageAudioView.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXMessageAudioView.h"
#import "CommonUtils.h"

@interface TXMessageAudioView()
{
    UIImageView *_voiceAnimationImageView;
    UILabel *_durationLabel;
    UIView *_unReadView;
}
@property (nonatomic,strong) NSMutableArray *senderImages;
@property (nonatomic,strong) NSMutableArray *receiverImages;
@end

@implementation TXMessageAudioView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAnimationImagesName];
        _voiceAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 10, 18, 18)];
        _voiceAnimationImageView.animationDuration = 1.0;
        [self addSubview:_voiceAnimationImageView];
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 40)];
        _durationLabel.backgroundColor = [UIColor clearColor];
        _durationLabel.font = [UIFont systemFontOfSize:16];
        _durationLabel.textColor = kColorMessageText;
        _durationLabel.text = @"0s";
        [self addSubview:_durationLabel];
        _unReadView = [[UIView alloc] initWithFrame:CGRectMake(81, 9, 6, 6)];
        _unReadView.backgroundColor = RGBCOLOR(0xff, 00, 00);
        _unReadView.layer.cornerRadius = 3.f;
        _unReadView.layer.masksToBounds = YES;
//        _unReadView.image = [UIImage imageNamed:@"unread_background"];
        [self addSubview:_unReadView];
        _unReadView.hidden = YES;
    }
    return self;
}
- (void)setupAnimationImagesName
{
    _senderImages = [NSMutableArray arrayWithCapacity:4];
    _receiverImages = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[@"send" stringByAppendingFormat:@"VoiceNodePlaying%ld", (long)i]];
        if (image)
            [_senderImages addObject:image];
    }
    for (NSInteger i = 0; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[@"receive" stringByAppendingFormat:@"VoiceNodePlaying%ld", (long)i]];
        if (image)
            [_receiverImages addObject:image];
    }
}
- (void)setMessage:(id<TXMessageModelData>)message
{
    _message = message;
    if ([message bubbleMessageType] == TXBubbleMessageTypeIncoming) {
        //别人发送的
        _voiceAnimationImageView.frame = CGRectMake(self.frame.size.width - 28, 12, 18, 18);
        _durationLabel.textAlignment = NSTextAlignmentLeft;
        _durationLabel.frame = CGRectMake(15, 0, 40, 40);
//        _durationLabel.textColor = KColorTitleTxt;
        _voiceAnimationImageView.image = [UIImage imageNamed:@"receiveVoiceNodePlaying3"];
        _voiceAnimationImageView.animationImages = _receiverImages;
        _unReadView.frame = CGRectMake(self.frame.size.width + 5, 2, 6, 6);
        _unReadView.hidden = [_message isVoiceRead];
    }else if ([message bubbleMessageType] == TXBubbleMessageTypeOutgoing) {
        //自己发送的
        _voiceAnimationImageView.frame = CGRectMake(10, 12, 18, 18);
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.frame = CGRectMake(self.frame.size.width - 55, 0, 40, 40);
//        _durationLabel.textColor = [UIColor whiteColor];
        _voiceAnimationImageView.image = [UIImage imageNamed:@"sendVoiceNodePlaying3"];
        _voiceAnimationImageView.animationImages = _senderImages;
        _unReadView.hidden = YES;
    }
    //时间字符串
    if ([message voiceTime] == 0) {
        _durationLabel.text = @"1s";
    }else{
        _durationLabel.text = [NSString stringWithFormat:@"%@s",@([message voiceTime])];
    }
    //是否播放
    if ([_message isVoicePlaying]) {
        [self startAudioAnimation];
    }else{
        [self stopAudioAnimation];
    }
}
-(void)startAudioAnimation
{
    [_voiceAnimationImageView startAnimating];
}

-(void)stopAudioAnimation
{
    [_voiceAnimationImageView stopAnimating];
}

@end
