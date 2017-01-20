//
//  TXMessageInputView.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXMessageInputView.h"
#import "NSString+MessageInputView.h"
#import "TXMessageEmotionView.h"
#import "TXVoiceRecordHUD.h"
#import "UIScrollView+XHkeyboardControl.h"
#import "TXVoiceRecordHelper.h"
#import "CommonUtils.h"

@interface TXMessageInputView()
<UITextViewDelegate,
TXMessageMoreMenuDelegate,
TXMessageEmotionViewDelegate>

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong, readwrite) TXMessageTextView *inputTextView;

@property (nonatomic, assign) TXMessageInputViewType textViewInputViewType;

@property (nonatomic, strong, readwrite) UIButton *voiceChangeButton;
@property (nonatomic, strong, readwrite) UIButton *voiceKeyboardButton;

@property (nonatomic, strong, readwrite) UIButton *multiMediaSendButton;

@property (nonatomic, strong, readwrite) UIButton *faceMenuButton;
@property (nonatomic, strong, readwrite) UIButton *faceKeyboardButton;
@property (nonatomic, strong) UIButton *faceSendButton;

@property (nonatomic, strong, readwrite) UIButton *holdDownButton;

@property (nonatomic, strong, readwrite) UIView *bottomLineView;
/**
 *  是否取消錄音
 */
@property (nonatomic, assign, readwrite) BOOL isCancelled;

/**
 *  是否正在錄音
 */
@property (nonatomic, assign, readwrite) BOOL isRecording;

/**
 *  在切换语音和文本消息的时候，需要保存原本已经输入的文本，这样达到一个好的UE
 */
@property (nonatomic, copy) NSString *inputedText;

@property (nonatomic, strong) TXMessageEmotionView *emotionView;    //表情视图
@property (nonatomic, strong) TXMessageMoreMenuView *moreMenuView;   //更多视图
@property (nonatomic, strong) TXVoiceRecordHUD *voiceRecordHUD;
@property (nonatomic, strong) UIView *voiceContentBgView;
//管理录音工具对象
@property (nonatomic, strong) TXVoiceRecordHelper *voiceRecordHelper;
//判断是不是超出了录音最大时长
@property (nonatomic) BOOL isMaxTimeStop;
//键盘高度
@property (nonatomic, assign) CGFloat keyboardViewHeight;
//记录旧的textView contentSize Heigth
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
//toolheight
@property (nonatomic, assign) CGFloat toolHeight;

@end

@implementation TXMessageInputView

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (index) {
        case 0:
        case 3:
        {
            //语音
            if (self.voiceKeyboardButton.isHidden) {
                self.voiceKeyboardButton.hidden = NO;
                self.voiceChangeButton.hidden = YES;
            }else{
                self.voiceChangeButton.hidden = NO;
                self.voiceKeyboardButton.hidden = YES;
            }

            self.faceMenuButton.hidden = NO;
            self.faceKeyboardButton.hidden = YES;

            if (self.voiceChangeButton.isHidden) {
                self.inputedText = self.inputTextView.text;
                self.inputTextView.text = @"";
                [self.inputTextView resignFirstResponder];
            } else {
                self.inputTextView.text = self.inputedText;
//                self.inputedText = nil;
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.alpha = self.voiceChangeButton.isHidden;
                self.inputTextView.alpha = !self.voiceChangeButton.isHidden;
            } completion:^(BOOL finished) {
                
            }];
            
            if (self.voiceChangeButton.isHidden) {
                if (self.textViewInputViewType == TXMessageInputViewTypeText)
                    return;
                // 在这之前，textViewInputViewType已经不是XHTextViewTextInputType
                [self layoutOtherMenuViewHiden:YES];
            }
            
            break;
        }
        case 1:
        case 4:
        {
            //表情
            if (self.faceKeyboardButton.isHidden) {
                self.faceKeyboardButton.hidden = NO;
                self.faceMenuButton.hidden = YES;
            }else{
                self.faceMenuButton.hidden = NO;
                self.faceKeyboardButton.hidden = YES;
            }
            self.voiceChangeButton.hidden = NO;
            self.voiceKeyboardButton.hidden = YES;
            
            if (self.faceMenuButton.isHidden) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = !self.faceMenuButton.isHidden;
//                    self.borderView.alpha = !sender.selected;
                    self.inputTextView.alpha = self.faceMenuButton.isHidden;
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = self.faceMenuButton.isHidden;
//                    self.borderView.alpha = sender.selected;
                    self.inputTextView.alpha = !self.faceMenuButton.isHidden;
                } completion:^(BOOL finished) {
                    
                }];
            }
            //将内容重新赋值回来
            self.inputTextView.text = self.inputedText;
            if (self.faceMenuButton.isHidden) {
                self.textViewInputViewType = TXMessageInputViewTypeEmotion;
                [self layoutOtherMenuViewHiden:NO];
            } else {
                [self.inputTextView becomeFirstResponder];
            }
            break;
        }
        case 2: {
//            self.faceMenuButton.selected = NO;
            self.voiceChangeButton.hidden = NO;
            self.voiceKeyboardButton.hidden = YES;
            self.faceMenuButton.hidden = NO;
            self.faceKeyboardButton.hidden = YES;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.alpha = NO;
                self.inputTextView.alpha = YES;
            } completion:^(BOOL finished) {
                //将内容重新赋值回来
                self.inputTextView.text = self.inputedText;
            }];
            self.textViewInputViewType = TXMessageInputViewTypeMenu;
            [self layoutOtherMenuViewHiden:NO];
            break;
        }
            break;
        default:
            break;
    }
}

- (void)holdDownButtonTouchDown {
    
    self.isCancelled = NO;
    self.isRecording = NO;
    //判断是否已授权麦克风
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkIsMicrophoneAvailable)]) {
        BOOL isAvailable = [self.delegate checkIsMicrophoneAvailable];
        if (!isAvailable) {
            return;
        }
    }
    //判断是否允许发送语音
    if (self.delegate && [self.delegate respondsToSelector:@selector(canStartRecordVoiceAction)]) {
        BOOL canStart = [self.delegate canStartRecordVoiceAction];
        if (!canStart) {
            return;
        }
    }
//    WEAKSELF
    // by mey
    __weak __typeof(&*self) weakSelf=self;
    [self prepareRecordWithCompletion:^BOOL{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //判斷回調回來的時候, 使用者是不是已經早就鬆開手了
        if (strongSelf && !strongSelf.isCancelled) {
            strongSelf.isRecording = YES;
            [strongSelf didStartRecordingVoiceAction];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (void)holdDownButtonTouchUpOutside {
    
    //如果已經開始錄音了, 才需要做取消的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        [self cancelRecord];
    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownButtonTouchUpInside {
    
    //如果已經開始錄音了, 才需要做結束的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        if (self.isMaxTimeStop == NO) {
            [self finishRecorded];
        } else {
            self.isMaxTimeStop = NO;
        }

    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragOutside {
    
    //如果已經開始錄音了, 才需要做拖曳出去的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        [self resumeRecord];

    } else {
        self.isCancelled = YES;
    }
}

- (void)holdDownDragInside {
    
    //如果已經開始錄音了, 才需要做拖曳回來的動作, 否則只要切換 isCancelled, 不讓錄音開始.
    if (self.isRecording) {
        [self pauseRecord];
    } else {
        self.isCancelled = YES;
    }
}

#pragma mark - layout subViews UI

- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30.f, 30.f);
    if (image)
        [button setBackgroundImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupMessageInputViewBar {
    
    self.backgroundColor = RGBCOLOR(254, 255, 255);

    // 需要显示按钮的总宽度，包括间隔在内
    CGFloat allButtonWidth = 0.0;
    
    // 水平间隔
    CGFloat horizontalPadding = 10;
    
    // 垂直间隔
    CGFloat verticalPadding = 10.f;
    
    // 输入框
    CGFloat textViewLeftMargin = 10.0;
    
    // 每个按钮统一使用的frame变量
    CGRect buttonFrame;
    
    //分割线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kLineHeight)];
    topLineView.backgroundColor = RGBCOLOR(0xc9, 0xca, 0xca);
    [self addSubview:topLineView];
    
    // 语音按钮
    if (_isVoiceSupport) {
        _voiceChangeButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_voice"] HLImage:[UIImage imageNamed:@"chat_voice_press"]];
        [_voiceChangeButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _voiceChangeButton.tag = 0;
//        [_voiceChangeButton setImage:[UIImage imageNamed:@"chat_keyboard"] forState:UIControlStateSelected];
        buttonFrame = _voiceChangeButton.frame;
        buttonFrame.origin = CGPointMake(horizontalPadding, verticalPadding);
        _voiceChangeButton.frame = buttonFrame;
        [self addSubview:_voiceChangeButton];
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding;
        textViewLeftMargin += CGRectGetMaxX(buttonFrame);
        
        _voiceKeyboardButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_keyboard"] HLImage:[UIImage imageNamed:@"chat_keyboard_press"]];
        [_voiceKeyboardButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _voiceKeyboardButton.tag = 3;
        _voiceKeyboardButton.frame = _voiceChangeButton.frame;
        [self addSubview:_voiceKeyboardButton];
        _voiceKeyboardButton.hidden = YES;

    }
    
    // 多媒体消息按钮
    if (_isMultiMediaSupport) {
        _multiMediaSendButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_more"] HLImage:[UIImage imageNamed:@"chat_more_press"]];
        _multiMediaSendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_multiMediaSendButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _multiMediaSendButton.tag = 2;
        buttonFrame = _multiMediaSendButton.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
        _multiMediaSendButton.frame = buttonFrame;
        [self addSubview:_multiMediaSendButton];
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding;
    }
    
    // 允许发送表情
    _faceMenuButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_face"] HLImage:[UIImage imageNamed:@"chat_face_press"]];
    _faceMenuButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    [_faceMenuButton setImage:[UIImage imageNamed:@"chat_keyboard"] forState:UIControlStateSelected];
    [_faceMenuButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _faceMenuButton.tag = 1;
    buttonFrame = _faceMenuButton.frame;
    buttonFrame.origin = CGPointMake(CGRectGetWidth(self.frame) - (_isMultiMediaSupport ? CGRectGetWidth(self.multiMediaSendButton.frame) + horizontalPadding : 0) - CGRectGetWidth(buttonFrame) - horizontalPadding, verticalPadding);
    allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2;
    _faceMenuButton.frame = buttonFrame;
    [self addSubview:_faceMenuButton];
    _faceKeyboardButton = [self createButtonWithImage:[UIImage imageNamed:@"chat_keyboard"] HLImage:[UIImage imageNamed:@"chat_keyboard_press"]];
    _faceKeyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_faceKeyboardButton addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _faceKeyboardButton.tag = 4;
    _faceKeyboardButton.frame = _faceMenuButton.frame;
    [self addSubview:_faceKeyboardButton];
    _faceKeyboardButton.hidden = YES;

    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : textViewLeftMargin) - horizontalPadding;
    CGFloat height = [TXMessageInputView textViewLineHeight];
    
//    _borderView = [[UIView alloc] initWithFrame:CGRectMake(textViewLeftMargin, verticalPadding, width, height)];
//    _borderView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
//    _borderView.layer.borderWidth = 0.65f;
//    _borderView.layer.cornerRadius = 6.0f;
//    _borderView.layer.cornerRadius = height / 2;
//    _borderView.layer.masksToBounds = YES;
//    [self addSubview:_borderView];
    // 初始化输入框
    TXMessageTextView *textView = [[TXMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 修改returnkeytype
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
    textView.placeHolder = @"";
    textView.delegate = self;
    
    [self addSubview:textView];
    _inputTextView = textView;
    
    _inputTextView.frame = CGRectMake(textViewLeftMargin, (kChatToolBarHeight - height) / 2, width, height);
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = RGBCOLOR(132, 133, 134).CGColor;
    _inputTextView.layer.borderWidth = 0.5f;
    _inputTextView.layer.cornerRadius = 3.0f;
    _inputTextView.layer.masksToBounds = YES;
    
    //按钮录音的按钮
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    UIImage *holdDownNormalImage = [[UIImage imageNamed:@"chat_voice_hold"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    UIEdgeInsets hlEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    UIImage *holdDownHLImage = [[UIImage imageNamed:@"chat_voice_hold_highlighted"] resizableImageWithCapInsets:hlEdgeInsets resizingMode:UIImageResizingModeStretch];
    self.holdDownButton = [self createButtonWithImage:holdDownNormalImage HLImage:holdDownHLImage];
    [self.holdDownButton setTitleColor:KChatColorTitleTxt forState:UIControlStateNormal];
    [self.holdDownButton setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.holdDownButton setTitle:@"放开发送"  forState:UIControlStateHighlighted];
//    buttonFrame = CGRectMake(textViewLeftMargin - 5, 3, width+10, self.frame.size.height - 6);
    self.holdDownButton.frame = _inputTextView.frame;
    self.holdDownButton.alpha = 0.f;
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.holdDownButton addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.holdDownButton addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.holdDownButton addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    [self addSubview:self.holdDownButton];
    //分割线
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - kLineHeight, CGRectGetWidth(self.frame), kLineHeight)];
    self.bottomLineView.backgroundColor = RGBCOLOR(0xc9, 0xca, 0xca);
    [self addSubview:self.bottomLineView];
    //初始化表情试图和更多选项
    self.emotionView.alpha = 0.f;
    self.moreMenuView.alpha = 0.f;
    //工具栏高度
    self.toolHeight = CGRectGetHeight(self.frame);
    //设置变量值
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = [self getTextViewContentH:self.inputTextView];
}
//表情视图
- (TXMessageEmotionView *)emotionView
{
    if (!_emotionView) {
        _emotionView = [[TXMessageEmotionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), self.keyboardViewHeight)];
        _emotionView.backgroundColor = RGBCOLOR(245, 246, 248);
        _emotionView.alpha = 0.f;
        _emotionView.delegate = self;
        [self addSubview:_emotionView];
    }
    [self bringSubviewToFront:_emotionView];
    return _emotionView;
}
//更多menu视图
- (TXMessageMoreMenuView *)moreMenuView
{
    if (!_moreMenuView) {
        _moreMenuView = [[TXMessageMoreMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), self.keyboardViewHeight)];
        _moreMenuView.backgroundColor = RGBCOLOR(246, 246, 248);
        _moreMenuView.alpha = 0.f;
        _moreMenuView.delegate = self;
        [self addSubview:_moreMenuView];
    }
    [self bringSubviewToFront:_moreMenuView];
    return _moreMenuView;
}
//语音HUD视图
- (TXVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[TXVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    }
    return _voiceRecordHUD;
}
//语音背景视图
- (UIView *)voiceContentBgView
{
    if (!_voiceContentBgView) {
        _voiceContentBgView = [[UIView alloc] init];
        _voiceContentBgView.backgroundColor = [UIColor clearColor];
        _voiceContentBgView.frame = _contentViewController.view.bounds;
    }
    return _voiceContentBgView;
}
#pragma mark - helper
- (TXVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        
//        WEAKSELF
        // by mey
        __weak __typeof(&*self) weakSelf=self;
        _voiceRecordHelper = [[TXVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
//            DLog(@"已经达到最大限制时间了，进入下一步的提示");
            
            // Unselect and unhilight the hold down button, and set isMaxTimeStop to YES.
            UIButton *holdDown = weakSelf.holdDownButton;
            holdDown.selected = NO;
            holdDown.highlighted = NO;
            weakSelf.isMaxTimeStop = YES;
            
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
    }
    return _voiceRecordHelper;
}
- (void)setAssociatedScrollView:(UIScrollView *)associatedScrollView
{
    _associatedScrollView = associatedScrollView;
    if (_associatedScrollView) {
        // 设置键盘通知或者手势控制键盘消失
        [_associatedScrollView setupPanGestureControlKeyboardHide:YES];
    }else{
        [_associatedScrollView disSetupPanGestureControlKeyboardHide:YES];
    }
    //添加键盘动画通知
    // 控制输入工具条的位置块
//    WEAKSELF
    // by mey
    __weak __typeof(&*self) weakSelf=self;
//    void (^AnimationForMessageInputViewAtPoint)(CGPoint point) = ^(CGPoint point) {
//        CGRect inputViewFrame = weakSelf.frame;
//        CGPoint keyboardOrigin = [weakSelf.contentViewController.view convertPoint:point fromView:nil];
//        inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
//        weakSelf.frame = inputViewFrame;
//    };
    
//    _associatedScrollView.keyboardDidScrollToPoint = ^(CGPoint point) {
//        if (weakSelf.textViewInputViewType == TXMessageInputViewTypeText)
//            AnimationForMessageInputViewAtPoint(point);
//    };
    
//    _associatedScrollView.keyboardWillSnapBackToPoint = ^(CGPoint point) {
//        if (weakSelf.textViewInputViewType == TXMessageInputViewTypeText)
//            AnimationForMessageInputViewAtPoint(point);
//    };
    
    _associatedScrollView.keyboardWillBeDismissed = ^() {
        CGRect inputViewFrame = weakSelf.frame;
        inputViewFrame.size.height = weakSelf.toolHeight;
        inputViewFrame.origin.y = weakSelf.shouldShowInputViewWhenFinished ? weakSelf.contentViewController.view.bounds.size.height - inputViewFrame.size.height : weakSelf.contentViewController.view.bounds.size.height;
        weakSelf.frame = inputViewFrame;
    };
    // block回调键盘通知
    _associatedScrollView.keyboardWillChange = ^(CGRect keyboardRect, UIViewAnimationOptions options, double duration, BOOL showKeyborad) {
        if (weakSelf.textViewInputViewType == TXMessageInputViewTypeText) {
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:options
                             animations:^{
                                 CGFloat keyboardY = [weakSelf.contentViewController.view convertRect:keyboardRect fromView:nil].origin.y;
                                 
                                 CGRect inputViewFrame = weakSelf.frame;
                                 inputViewFrame.size.height = weakSelf.toolHeight;
                                 CGFloat inputViewFrameY = showKeyborad ? keyboardY - inputViewFrame.size.height : keyboardY;
//                                 inputViewFrameY = keyboardY - inputViewFrame.size.height;
                                 
                                 // for ipad modal form presentations
                                 CGFloat messageViewFrameBottom = weakSelf.shouldShowInputViewWhenFinished ? weakSelf.contentViewController.view.frame.size.height - inputViewFrame.size.height : weakSelf.contentViewController.view.frame.size.height;
                                 if (inputViewFrameY > messageViewFrameBottom)
                                     inputViewFrameY = messageViewFrameBottom;
                                 
                                 weakSelf.frame = CGRectMake(inputViewFrame.origin.x,
                                                                          inputViewFrameY,
                                                                          inputViewFrame.size.width,
                                                                          inputViewFrame.size.height);
                                 
                                 if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onBottomInsetsChanged:isShowKeyboard:)]) {
                                     [weakSelf.delegate onBottomInsetsChanged:weakSelf.contentViewController.view.frame.size.height - weakSelf.frame.origin.y isShowKeyboard:showKeyborad];
                                 }
                             }
                             completion:nil];
        }
    };
    
    _associatedScrollView.keyboardDidChange = ^(BOOL didShowed) {
        if ([weakSelf.inputTextView isFirstResponder]) {
            if (didShowed) {
                if (weakSelf.textViewInputViewType == TXMessageInputViewTypeText) {
                    weakSelf.moreMenuView.alpha = 0.0;
                    weakSelf.emotionView.alpha = 0.0;
                }
            }
        }
    };
    
    _associatedScrollView.keyboardDidHide = ^() {
        [weakSelf.inputTextView resignFirstResponder];
    };
    
    // 设置手势滑动，默认添加一个bar的高度值
    _associatedScrollView.messageInputBarHeight = CGRectGetHeight(self.bounds);
}
#pragma mark - Life cycle

- (void)setup {
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.clipsToBounds = YES;
    //初始化键盘高度值
    self.keyboardViewHeight = 216;
    _shouldShowInputViewWhenFinished = YES;
    _shouldLimitInputCharacterCount = YES;
    _maxInputCharacterCount = kMaxInputCharacterCount;
}
//开始创建视图
- (void)setupView
{
    [self setupMessageInputViewBar];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [_associatedScrollView disSetupPanGestureControlKeyboardHide:YES];
    self.inputedText = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceMenuButton = nil;
    _holdDownButton = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        // KVO 检查contentSize
        [self.inputTextView addObserver:self
                                          forKeyPath:@"contentSize"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
        [self.inputTextView setEditable:YES];
    }else{
        [_associatedScrollView disSetupPanGestureControlKeyboardHide:YES];
        // remove KVO
        [self.inputTextView removeObserver:self forKeyPath:@"contentSize"];
        [self.inputTextView setEditable:NO];
    }
}
#pragma mark - Key-value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}
#pragma mark - Layout Message Input View Helper Method

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = [TXMessageInputView maxHeight];
    
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - _previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.frame;
                             self.frame = CGRectMake(0.0f,
                                                     inputViewFrame.origin.y - changeInHeight,
                                                     inputViewFrame.size.width,
                                                     inputViewFrame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             if (_delegate && [_delegate respondsToSelector:@selector(onBottomInsetsChanged:isShowKeyboard:)]) {
                                 [_delegate onBottomInsetsChanged:_associatedScrollView.contentInset.bottom + changeInHeight isShowKeyboard:YES];
                             }

                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

#pragma mark - Message input view
- (void)associatedScrollViewWillBeginDragging
{
    if (self.textViewInputViewType != TXMessageInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
//    [self layoutOtherMenuViewHiden:YES];

}
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;
    
    NSUInteger numLines = MAX([self.inputTextView numberOfLinesOfText],
                              [self.inputTextView.text numberOfLines]);
    
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                          prevFrame.origin.y,
                                          prevFrame.size.width,
                                          prevFrame.size.height + changeInHeight);
    
    
    self.inputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f,
                                                       (numLines >= 6 ? 4.0f : 0.0f),
                                                       0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.inputTextView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.inputTextView.contentSize.height - self.inputTextView.bounds.size.height);
        [self.inputTextView setContentOffset:bottomOffset animated:YES];
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length - 2, 1)];
    }
    self.toolHeight = prevFrame.origin.y * 2 + prevFrame.size.height + changeInHeight;
    self.bottomLineView.frame = CGRectMake(0, self.toolHeight - kLineHeight, CGRectGetWidth(self.frame), kLineHeight);
    self.emotionView.frame = CGRectMake(0, self.toolHeight, CGRectGetWidth(self.bounds), self.keyboardViewHeight);
    self.moreMenuView.frame = CGRectMake(0, self.toolHeight, CGRectGetWidth(self.bounds), self.keyboardViewHeight);
//    CGRect borderRect = self.borderView.frame;
//    borderRect.size.height += changeInHeight;
//    self.borderView.frame = borderRect;
}

+ (CGFloat)textViewLineHeight {
    return 34.f; // for fontSize 16.0f
}

+ (CGFloat)maxLines {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}

+ (CGFloat)maxHeight {
    return ([TXMessageInputView maxLines] + 1.0f) * [TXMessageInputView textViewLineHeight];
}

#pragma mark - UITextView Helper Method
- (CGFloat)getTextViewContentH:(UITextView *)textView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}
#pragma mark - Text view delegate
//将要开始允许编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
//    self.faceMenuButton.selected = NO;
    self.faceMenuButton.hidden = NO;
    self.faceKeyboardButton.hidden = YES;
//    self.voiceChangeButton.selected = NO;
    self.voiceChangeButton.hidden = NO;
    self.voiceKeyboardButton.hidden = YES;
    self.textViewInputViewType = TXMessageInputViewTypeText;

    return YES;
}
//开始编辑
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = [self getTextViewContentH:textView];

}
//结束编辑
- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}
//文字更改了
- (void)textViewDidChange:(UITextView *)textView
{
    if (_shouldLimitInputCharacterCount && textView.markedTextRange == nil && textView.text.length > _maxInputCharacterCount) {
        textView.text = [textView.text substringToIndex:_maxInputCharacterCount];
    }
    self.inputedText = textView.text;
}
//是否允许添加新字符
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:textView.text];
            self.inputedText = @"";
        }
        return NO;
    }
    NSInteger existedLength = textView.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = text.length;
    if (_shouldLimitInputCharacterCount && text && [text length] && existedLength - selectedLength + replaceLength > _maxInputCharacterCount) {
//        NSLog(@"字符数超过：%@",@(_maxInputCharacterCount));
        return NO;
    }
//    NSLog(@"当前字符数:%@",@([textView.text length]));
    return YES;
}
#pragma mark - Other Menu View Frame Helper Mehtod

- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    [self.inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.frame;
        inputViewFrame.size.height = self.toolHeight;
        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
//            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(_contentViewController.view.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            inputViewFrame.origin.y = (hide ? (_shouldShowInputViewWhenFinished ? CGRectGetHeight(_contentViewController.view.bounds) - CGRectGetHeight(inputViewFrame) : CGRectGetHeight(_contentViewController.view.bounds)) : (CGRectGetHeight(_contentViewController.view.bounds) - CGRectGetHeight(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            inputViewFrame.size.height = hide ? self.toolHeight : CGRectGetHeight(otherMenuViewFrame) + CGRectGetHeight(inputViewFrame);
            self.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.emotionView.frame;
//            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(_contentViewController.view.frame) : (CGRectGetHeight(_contentViewController.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.frame) : self.toolHeight);
            self.emotionView.alpha = !hide;
            self.emotionView.frame = otherMenuViewFrame;
        };
        
        void (^ShareMenuViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.moreMenuView.frame;
//            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(_contentViewController.view.frame) : (CGRectGetHeight(_contentViewController.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.frame) : self.toolHeight);
            self.moreMenuView.alpha = !hide;
            self.moreMenuView.frame = otherMenuViewFrame;
        };
        
        if (hide) {
            switch (self.textViewInputViewType) {
                case TXMessageInputViewTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case TXMessageInputViewTypeMenu: {
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (self.textViewInputViewType) {
                case TXMessageInputViewTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    ShareMenuViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case TXMessageInputViewTypeMenu: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);

        if (_delegate && [_delegate respondsToSelector:@selector(onBottomInsetsChanged:isShowKeyboard:)]) {
            [_delegate onBottomInsetsChanged:self.contentViewController.view.frame.size.height
             - self.frame.origin.y isShowKeyboard:YES];
        }
    } completion:^(BOOL finished) {
        if (hide) {
            self.textViewInputViewType = TXMessageInputViewTypeNormal;
        }
    }];
}
//结束编辑响应
- (void)endEdit
{
    [self.inputTextView endEditing:YES];
    if (self.textViewInputViewType != TXMessageInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
}
#pragma mark - TXMessageMoreMenuDelegate
- (void)clickMoreMenuButtonWithType:(TXMessageMoreMenuType)type
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickMoreMenuButtonWithType:)]) {
        [_delegate clickMoreMenuButtonWithType:type];
    }
}
#pragma mark - TXMessageEmotionViewDelegate
- (void)sendEmotion
{
    if (_delegate && [_delegate respondsToSelector:@selector(sendEmotionText:)]) {
        NSString *chatText = self.inputTextView.text;
        [_delegate sendEmotionText:chatText];
        self.inputedText = @"";
    }
}
- (void)selectedEmotion:(NSString *)str isDeleted:(BOOL)isDeleted
{
    //设置文字
    NSString *chatText = self.inputTextView.text;
    
    if (!isDeleted && str.length > 0) {
        //添加表情
        if (_shouldLimitInputCharacterCount && [self.inputTextView.text length] >= _maxInputCharacterCount) {
            self.inputedText = self.inputTextView.text;
//            NSLog(@"emotion:字符数超过：%@",@(_maxInputCharacterCount));
            return;
        }
//        NSLog(@"emotion:当前字符数:%@",@([self.inputTextView.text length]));
        if (IOS7_OR_LATER) {
            NSRange currentRange = self.inputTextView.selectedRange;
            self.inputTextView.text = [chatText stringByReplacingCharactersInRange:currentRange withString:str];
        }else{
            self.inputTextView.text = [chatText stringByAppendingString:str];
        }
    }
    else {
        //删除表情
        if (chatText.length >= 2)
        {
            NSRange currentRange = self.inputTextView.selectedRange;
            NSString *subStr = [chatText substringFromIndex:currentRange.location - 2];
            if ([self.emotionView stringIsFace:subStr]) {
                self.inputTextView.text = [chatText stringByReplacingCharactersInRange:NSMakeRange(currentRange.location - 2, 2) withString:@""];
                return;
            }
        }
        //删除普通文字
        if (chatText.length > 0) {
            NSRange currentRange = self.inputTextView.selectedRange;
            self.inputTextView.text = [chatText stringByReplacingCharactersInRange:NSMakeRange(currentRange.location - 1, 1) withString:@""];
        }
    }
    self.inputedText = self.inputTextView.text;
}
#pragma mark - Voice Recording Helper Method
- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    recorderPath = [recorderPath stringByAppendingFormat:@"%d%d",(int)time,x];
    
    return recorderPath;
}
- (void)prepareRecordWithCompletion:(TXPrepareRecorderCompletion)completion {
    [self.voiceRecordHelper prepareRecordingWithPath:[self getRecorderPath] prepareRecorderCompletion:completion];
}

- (void)startRecord {
    [self.contentViewController.view addSubview:self.voiceContentBgView];
    [self.voiceRecordHUD startRecordingHUDAtView:_contentViewController.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:^{
    }];
}

- (void)finishRecorded {
//    WEAKSELF
    // by mey
    __weak __typeof(&*self) weakSelf=self;
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
        [weakSelf.voiceContentBgView removeFromSuperview];
        weakSelf.voiceContentBgView = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(finishVoiceRecordWithFile:displayName:duration:)]) {
            [weakSelf.delegate finishVoiceRecordWithFile:weakSelf.voiceRecordHelper.recordPath displayName:@"audio" duration:[weakSelf.voiceRecordHelper.recordDuration integerValue]];
        }
    }];
}

- (void)pauseRecord {
    [self.voiceRecordHUD pauseRecord];
}

- (void)resumeRecord {
    [self.voiceRecordHUD resaueRecord];
}

- (void)cancelRecord {
//    WEAKSELF
    // by mey
    __weak __typeof(&*self) weakSelf=self;
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
        [weakSelf.voiceContentBgView removeFromSuperview];
        weakSelf.voiceContentBgView = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}

- (void)didStartRecordingVoiceAction {
    [self startRecord];
}

@end
