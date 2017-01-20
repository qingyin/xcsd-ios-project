//
//  TXMessageInputView.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXMessageTextView.h"
#import "TXMessageMoreMenuView.h"

typedef NS_ENUM(NSInteger, TXMessageInputViewType) {
    TXMessageInputViewTypeNormal = 0,
    TXMessageInputViewTypeText,
    TXMessageInputViewTypeEmotion,
    TXMessageInputViewTypeMenu,
};

@protocol XHMessageInputViewDelegate <NSObject>

@optional

/**
 *  输入框刚好开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(TXMessageTextView *)messageInputTextView;

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(TXMessageTextView *)messageInputTextView;

/**
 *  在发送文本和语音之间发送改变时，会触发这个回调函数
 *
 *  @param changed 是否改为发送语音状态
 */
- (void)didChangeSendVoiceAction:(BOOL)changed;

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param text 目标文本消息
 */
- (void)didSendTextAction:(NSString *)text;

/**
 *  点击+号按钮Action
 */
- (void)didSelectedMultipleMediaAction;

/**
 *  按下錄音按鈕 "準備" 錄音
 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion;

//判断是否允许访问麦克风
- (BOOL)checkIsMicrophoneAvailable;

//是否允许录音操作
- (BOOL)canStartRecordVoiceAction;
/**
 *  开始录音
 */
- (void)didStartRecordingVoiceAction;
/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction;
/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction;
/**
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction;
/**
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction;

/**
 *  发送第三方表情
 *
 *  @param facePath 目标表情的本地路径
 */
- (void)didSendFaceAction:(BOOL)sendFace;

//底部insets改变
- (void)onBottomInsetsChanged:(CGFloat)bottom
               isShowKeyboard:(BOOL)isShow;

//结束语音录制
- (void)finishVoiceRecordWithFile:(NSString *)filePath
                      displayName:(NSString *)displayName
                         duration:(NSInteger)duration;

//点击更多media的按钮
- (void)clickMoreMenuButtonWithType:(TXMessageMoreMenuType)type;

//发送表情
- (void)sendEmotionText:(NSString *)text;

@end

@interface TXMessageInputView : UIView

@property (nonatomic, weak) id <XHMessageInputViewDelegate> delegate;

//是否支持语音
@property (nonatomic) BOOL isVoiceSupport;

//更多菜单是否支持
@property (nonatomic) BOOL isMultiMediaSupport;

/**
 *  用于输入文本消息的输入框
 */
@property (nonatomic, strong, readonly) TXMessageTextView *inputTextView;

/**
 *  切换文本和语音的按钮
 */
@property (nonatomic, strong, readonly) UIButton *voiceChangeButton;
@property (nonatomic, strong, readonly) UIButton *voiceKeyboardButton;

/**
 *  +号按钮
 */
@property (nonatomic, strong, readonly) UIButton *multiMediaSendButton;

/**
 *  第三方表情按钮
 */
@property (nonatomic, strong, readonly) UIButton *faceMenuButton;
@property (nonatomic, strong, readonly) UIButton *faceKeyboardButton;

/**
 *  语音录制按钮
 */
@property (nonatomic, strong, readonly) UIButton *holdDownButton;

/**
 *  关联的scrollView
 */
@property (nonatomic, weak) UIScrollView *associatedScrollView;

//承载viewcontroller
@property (nonatomic, weak) UIViewController *contentViewController;

//输入完成后是否还需要展示输入框,默认为YES
@property (nonatomic) BOOL shouldShowInputViewWhenFinished;

//是否应该限制文本输入长度,默认为YES且限制的长度为200
@property (nonatomic) BOOL shouldLimitInputCharacterCount;

//限制文本输入的长度，默认为200
@property (nonatomic) NSInteger maxInputCharacterCount;

#pragma mark - Message input view

/**
 *  动态改变高度
 *
 *  @param changeInHeight 目标变化的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  获取输入框内容字体行高
 *
 *  @return 返回行高
 */
+ (CGFloat)textViewLineHeight;

/**
 *  获取最大行数
 *
 *  @return 返回最大行数
 */
+ (CGFloat)maxLines;

/**
 *  获取根据最大行数和每行高度计算出来的最大显示高度
 *
 *  @return 返回最大显示高度
 */
+ (CGFloat)maxHeight;

//关联的scrollview将要开始拖动
- (void)associatedScrollViewWillBeginDragging;

//结束响应
- (void)endEdit;

//开始创建视图
- (void)setupView;

@end
