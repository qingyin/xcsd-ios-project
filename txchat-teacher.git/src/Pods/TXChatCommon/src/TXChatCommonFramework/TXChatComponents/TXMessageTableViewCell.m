//
//  TXMessageTableViewCell.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXMessageTableViewCell.h"
#import "UILabel+ContentSize.h"
#import "UIResponder+Router.h"
#import "CommonUtils.h"

static CGFloat const kTimeFontSize = 12;
static CGFloat const kTipFontSize = 15;

@interface TXMessageTableViewCell()

@property (nonatomic,strong) UILabel *timeLabel;

@end

@implementation TXMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellWidth = width;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //初始化视图
        [self setupMessageView];
    }
    return self;
}
#pragma mark - UI视图
//初始化视图
- (void)setupMessageView
{
    //创建时间字符串
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 8, _cellWidth - 260, 16)];
    _timeLabel.backgroundColor = [UIColor colorWithRed:179/255.f green:179/255.f blue:186/255.f alpha:1.f];
    _timeLabel.layer.cornerRadius = 4.f;
    _timeLabel.layer.masksToBounds = YES;
    _timeLabel.font = [UIFont systemFontOfSize:kTimeFontSize];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_timeLabel];
}
#pragma mark - 设置数据
- (void)setMessageData:(id<TXMessageModelData>)messageData
{
    _messageData = messageData;
    //设置消息文本
    if ([_messageData isTimeMessage]) {
        //时间字符串消息
        _timeLabel.text = [_messageData time];
        [_timeLabel setFont:[UIFont systemFontOfSize:kTimeFontSize]];
        CGFloat width = [UILabel widthForLabelWithText:[_messageData time] maxHeight:_cellWidth - 20 font:[UIFont systemFontOfSize:kTimeFontSize]];
        _timeLabel.frame = CGRectMake((_cellWidth - width - 10) / 2, 8, width + 10, 16);
        //显示设置
        _timeLabel.hidden = NO;
        _bubbleView.hidden = YES;
        _avatarImageView.hidden = YES;
        _maskImageView.hidden = YES;
        _sendFailView.hidden = YES;
        [_sendingIndicatorView stopAnimating];
        _sendingIndicatorView.hidden = YES;
    }else if ([_messageData isTipMessage]) {
        //tip字符串消息
        _timeLabel.text = [_messageData tipMessage];
        [_timeLabel setFont:[UIFont systemFontOfSize:kTipFontSize]];
        CGFloat width = [UILabel widthForLabelWithText:[_messageData tipMessage] maxHeight:_cellWidth - 20 font:[UIFont systemFontOfSize:kTipFontSize]];
        _timeLabel.frame = CGRectMake((_cellWidth - width - 20) / 2, 10, width + 20, 40);
        //显示设置
        _timeLabel.hidden = NO;
        _bubbleView.hidden = YES;
        _avatarImageView.hidden = YES;
        _maskImageView.hidden = YES;
        _sendFailView.hidden = YES;
        [_sendingIndicatorView stopAnimating];
        _sendingIndicatorView.hidden = YES;
    }else{
        [self updateMessageViewWithData:_messageData];
    }
}
//更新具体消息视图
- (void)updateMessageViewWithData:(id<TXMessageModelData>)data
{
    _timeLabel.hidden = YES;
    _bubbleView.hidden = NO;
    _avatarImageView.hidden = NO;
    _maskImageView.hidden = NO;
    _senderNameLabel.hidden = !_isGroup;
    MessageDeliveryState status = [data status];
    switch (status) {
        case eMessageDeliveryState_Delivering: {
            _sendingIndicatorView.hidden = NO;
            [_sendingIndicatorView startAnimating];
            _sendFailView.hidden = YES;
            break;
        }
        case eMessageDeliveryState_Delivered: {
            _sendingIndicatorView.hidden = YES;
            [_sendingIndicatorView stopAnimating];
            _sendFailView.hidden = YES;
            break;
        }
        case eMessageDeliveryState_Pending:
        case eMessageDeliveryState_Failure: {
            [_sendingIndicatorView stopAnimating];
            _sendingIndicatorView.hidden = YES;
            _sendFailView.hidden = NO;
            break;
        }
        default: {
            break;
        }
    }
}
#pragma mark - 消息响应链传递
//需实现该方法并返回YES，不然长按时无法弹出菜单选项
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [super routerEventWithName:eventName userInfo:userInfo];
}
#pragma mark - 点击手势
//头像点击手势
- (void)onAvatarImageViewTapped
{
    NSLog(@"点击了头像");
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(onAvatarImageTappedWithMessageData:)]) {
        [_cellDelegate onAvatarImageTappedWithMessageData:_messageData];
    }
}
@end
