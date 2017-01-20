//
//  CommonUtils.h
//  TXChatCommonFramework
//
//  Created by 陈爱彬 on 15/12/17.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#ifndef CommonUtils_h
#define CommonUtils_h

#define IOS7_OR_LATER       ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] != NSOrderedAscending)
#define IOS9_OR_LATER       ([[[UIDevice currentDevice] systemVersion] compare:@"9" options:NSNumericSearch] != NSOrderedAscending)
#define IOS8AFTER           ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)
#define IOS8_OR_AFTER           ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)

#define kScreenWidth            [UIScreen mainScreen].bounds.size.width
#define kScreenHeight           [UIScreen mainScreen].bounds.size.height
#define kLineHeight             0.5f
#define kEdgeInsetsLeft         10
#define kTabBarHeight           50.f

#define kChatToolBarHeight       50

#define kImageMaxWidthPixelSize  800
#define kChatMsgImageWidthPixelSize  1080

#define kMessageAvatarWidth         42
#define kMessageBubbleTextMargin    5
#define kMessageCellSpace           10
#define kMessageViewMargin          6
#define kMessageSendNameHeight      20
#define kMessageVoiceBubbleMinWidth    80
#define kMessageVoiceBubbleMaxWidth    185
#define kMessageBubbleMinWidth      60
#define kMessageBubbleMinHeight     42
#define kMessageAvatarAndBubbleMargin          3
#define kMessageTextWidthMargin     15

#define kMessageBubbleWidthMargin   22

#define kMessageIncomingLeftMargin  15
#define kMessageIncomingRightMargin 8
#define kMessageOutgoingLeftMargin  8
#define kMessageOutgoingRightMargin 15
#define kMessageBubbleTopMarigin    10
#define kMessageBubbleBottomMargin  10
#define kMessageIncomingImageLeftMargin     13
#define kMessageIncomingImageRightMargin    6
#define kMessageOutgoingImageLeftMargin     6
#define kMessageOutgoingImageRightMargin    13
#define kMessageBubbleImageTopMarigin    6
#define kMessageBubbleImageBottomMargin  6

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

#define KChatColorTitleTxt              RGBCOLOR(0x44, 0x44, 0x44) //标题颜色
#define kColorMessageText           RGBCOLOR(46,46,46)
#define KColorNewTitleTxt           RGBCOLOR(0x33, 0x33, 0x33)
#define KColorNewSubTitleTxt        RGBCOLOR(0x99, 0x99, 0x99)
#define KColorNewTimeTxt            RGBCOLOR(0xb2, 0xb2, 0xb2)
#define KColorNewLine               RGBCOLOR(0xe5, 0xe5, 0xe5)


#define kMessageTextFont                   [UIFont systemFontOfSize:16]
#define kMessageFontTitle                  [UIFont systemFontOfSize:16]
#define kMessageFontSubTitle               [UIFont systemFontOfSize:14]
#define kMessageFontTimeTitle              [UIFont systemFontOfSize:11]

//最大输入字符
#define kMaxInputCharacterCount   200

#define EMMessageImageLoadSuccessNotification   @"emMessageImageLoadSuccess" //聊天图片加载成功
#define EMMessageVoiceHasPlayedNotification   @"emMessageVoicePlayed"

#define AudioPlayShouldPauseNotification  @"AudioPlayShouldPauseNotification" //语音录制将要开始录制
#define AudioPlayShouldResumeNotification     @"AudioPlayShouldResumeNotification"  //语音录制将要结束

#endif /* CommonUtils_h */
