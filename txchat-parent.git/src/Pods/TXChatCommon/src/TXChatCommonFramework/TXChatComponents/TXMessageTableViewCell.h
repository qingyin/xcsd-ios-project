//
//  TXMessageTableViewCell.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXMessageModelData.h"
#import "TXMessageBubbleView.h"

@protocol TXMessageTableViewCellDelegate <NSObject>

//点击头像方法
- (void)onAvatarImageTappedWithMessageData:(id<TXMessageModelData>)data;

@end

@interface TXMessageTableViewCell : UITableViewCell

@property (nonatomic,weak) id<TXMessageTableViewCellDelegate> cellDelegate;
@property (nonatomic,strong) TXMessageBubbleView *bubbleView;
@property (nonatomic,strong) UIImageView *avatarImageView;
@property (nonatomic,strong) UIImageView *maskImageView;
@property (nonatomic,strong) UILabel *senderNameLabel;
@property (nonatomic,strong) UIActivityIndicatorView *sendingIndicatorView;
@property (nonatomic,strong) UIButton *sendFailView;

@property (nonatomic,strong) id<TXMessageModelData> messageData;
@property (nonatomic,assign) CGFloat cellWidth;
@property (nonatomic,assign) BOOL isGroup;
@property (nonatomic,strong) NSIndexPath *indexPath;

//初始化视图
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;
//初始化视图
- (void)setupMessageView;
//更新子视图具体内容
- (void)updateMessageViewWithData:(id<TXMessageModelData>)data;

//头像点击手势
- (void)onAvatarImageViewTapped;

//传递响应链
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
