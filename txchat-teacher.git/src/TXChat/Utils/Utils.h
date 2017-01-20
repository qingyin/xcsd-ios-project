//
//  Utils.h
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#ifndef TXChatDemo_Utils_h
#define TXChatDemo_Utils_h

//内部测试开关 上传appstore前 必须关掉
#define TEST   @"TEST";

#define TX_CHAT_CLIENT_PLATFORM  @"teacher"  //客户端类型 教师版


//常用声明
#define kFirstLogin                             @"FirstLogin"
#define GardenLeader                            1
#define GardenLeader1                           2
#define kReachabilityStatus                     @"reachabilityStatus"
#define kLocalUserName                          @"localUserName"
#define kLocalPassword                          @"localPassword"
#define kErrorMessage                           @"MESSAGE"
#define kEaseMobUserName                        @"easeMobUserName"
#define KUserNoDisturb                          @"exempt_disturb" //免打扰
#define KDepartNoDisturb                        @"exempt_disturb_" //群的免打扰设置
#define KUserVibration                          @"open_vibration" //震动
#define KUserSound                              @"open_sound" //声音
#define KDisableSendMsg                         @"DisableSendMsg_" //禁言开头
#define KDeviceTokenKey                         @"KEY_DEVICETOKEN" //device token key
#define KMute                                   @"mute" //禁言接口
#define kFeedMute                               @"feed_mute" //亲子圈禁言接口
#define KHOMELIST                               @"home_menu" //home页列表属性
#define KHOMELIST_NAME                          @"home_menu_name"   // home列表名称
#define kIsCanAutoLogin                         @"isCanAutoLogin" //是否可以自动登录
#define kIsHasInitAutoLoginFlag                 @"autoLoginFlag"  //是否已经初始化自动登录标示字段的值(适配2.0.3一下版本)
#define kPlayVideoAndAudioBy2G3G4G              @"playResViaWWAN" //2G,3G,4G播放音频和视频
#define kIsHideGuidePage                        @"isHideGuidePage"//是不是隐藏引导页
#define kLocalRemainingCount                    @"kLocalRemainingCount" // 本地缓存剩余作业的数量
#define kJSHostUrl                              @"JSHostUrl"

#define ISSMALLIPHONE       ([SDiPhoneVersion deviceSize] == iPhone35inch||[SDiPhoneVersion deviceSize] == iPhone4inch)
#define Coefficient 1.8f  //（学堂）首页缩放系数
#define kScale1          (SDiPhoneVersion.deviceSize ==iPhone55inch?(1.2):1)      //缩放系数
#define kScale           (SDiPhoneVersion.deviceSize ==iPhone47inch?(1.17):(SDiPhoneVersion.deviceSize ==iPhone35inch?0.6:(SDiPhoneVersion.deviceSize ==iPhone55inch?1.5:1)))
//#define kScale          (SDiPhoneVersion.deviceSize ==iPhone55inch?(1.4):(SDiPhoneVersion.deviceSize == iPhone47inch?(1.17):(SDiPhoneVersion.deviceSize == iPhone35inch?(0.6):1)))      //缩放系数



#define kStatusBarHeight        20.f    //状态栏高度
#define kNavigationHeight       44.f    //导航栏高度
#define kScreenWidth            [UIScreen mainScreen].bounds.size.width
#define kScreenHeight           [UIScreen mainScreen].bounds.size.height
#define kLineHeight             0.5f
#define kEdgeInsetsLeft         10
#define kTabBarHeight           50.f

#define kChatToolBarHeight       50

#define kImageMaxWidthPixelSize  800
#define kChatMsgImageWidthPixelSize  1080

#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180)
#define RADIANS_TO_DERREES(radians) (radians * 180 / M_PI)

#define kMessageAvatarWidth         42
#define kMessageBubbleTextMargin    5
#define kMessageCellSpace           10
#define kMessageViewMargin          6
#define kMessageSendNameHeight      20
#define kMessageVoiceBubbleMinWidth    80
#define kMessageVoiceBubbleMaxWidth    185
#define kMessageBubbleMinWidth      60
#define kMessageBubbleMinHeight     42

#define kMessageBubbleWidthMargin   22

#define kMessageIncomingLeftMargin  15
#define kMessageIncomingRightMargin 8
#define kMessageOutgoingLeftMargin  8
#define kMessageOutgoingRightMargin 15
#define kMessageBubbleTopMarigin    10
#define kMessageBubbleBottomMargin  10
//#define kMessageIncomingImageLeftMargin     8
//#define kMessageIncomingImageRightMargin    1
//#define kMessageOutgoingImageLeftMargin     1
//#define kMessageOutgoingImageRightMargin    8
//#define kMessageBubbleImageTopMarigin    1
//#define kMessageBubbleImageBottomMargin  1
#define kMessageIncomingImageLeftMargin     13
#define kMessageIncomingImageRightMargin    6
#define kMessageOutgoingImageLeftMargin     6
#define kMessageOutgoingImageRightMargin    13
#define kMessageBubbleImageTopMarigin    6
#define kMessageBubbleImageBottomMargin  6

//cell 位置定义
#define KCellTitleLeft 60.0f   //标题距左边距离
#define KCellTitleTop  15.0f   //标题距顶部距离
#define KCellSubMargin 6.0f    //标题和副标题之间的距离




#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

//判断字符串是不是空字符串
#define KISSTRNULL(a) ((a) == nil || (a).length == 0 )
//字符串处理成@""
#define KCONVERTSTRVALUE(a) (KISSTRNULL(a)?@"":a)
//
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]
//ios8版本
#define __IOS8 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

//颜色
//#define kColorGray3             [UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1]
#define kColorGray4             [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1]
#define kColorGray5             [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1]
#define kColorGray6             [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1]
#define kColorBlue1              [UIColor colorWithRed:48/255.0 green:183/255.0 blue:239/255.0 alpha:1]
#define kColorPinkLine          [UIColor colorWithRed:247/255.0 green:111/255.0 blue:113/255.0 alpha:0.3]


//新定义颜色
#define kColorType              RGBCOLOR(251,141,196)
#define kColorType1             RGBCOLOR(246,129,36)
#define kColorBackground        RGBCOLOR(243,243,243)
#define kColorOrange            RGBCOLOR(255,147,61)
#define kColorBlack             KColorNewTitleTxt              //黑色字体
#define kColorLightBlack        RGBCOLOR(96,96,96)              //浅黑色字体
#define kColorLine              RGBCOLOR(216,216,216)           //分割线颜色

#define kColorClear                 [UIColor clearColor]
#define kColorWhite                 RGBCOLOR(254,254,254)           //白色字体
#define kColorGray                  RGBCOLOR(115,115,115)           //灰色字体
#define kColorGray1                 RGBCOLOR(73, 104, 119)
#define kColorGray2                 RGBCOLOR(158, 158, 158)
#define kColorGray3                 RGBCOLOR(240, 240, 240)
#define kColorLightGray             RGBCOLOR(159,160,160)           //浅灰色字体
#define kColorPink                  RGBCOLOR(253,133,132)           //粉色
#define kColorBlue                  RGBCOLOR(0, 160, 233)
#define kColorItem                  RGBCOLOR(147, 158, 166)         //底部导航颜色
#define kColorSection               RGBCOLOR(230, 230, 230)          //
#define KColorNormalTxt             RGBCOLOR(75, 75, 75)          //
#define KColorTitleTxt              RGBCOLOR(0x44, 0x44, 0x44) //标题颜色
#define KColorSubTitleTxt           RGBCOLOR(0x75, 0x75, 0x75) //子标题颜色
#define kColorNavigationTitle       RGBCOLOR(0x48, 0x48, 0x48)
#define kColorNavigationTitleDisable       RGBACOLOR(0x44, 0x44, 0x44, 0.5)
#define kColorCircleBg              RGBCOLOR(220, 219, 219)
#define kColorStatusBlue            RGBCOLOR(0x35, 0xbe, 0xff)
#define kColorStatusYellow          RGBCOLOR(0xff, 0xa3, 0x2b)
#define kColorStatusPink            RGBCOLOR(0xff, 0x7b, 0xbb)

#define kColorMessageText           RGBCOLOR(46,46,46)
#define kColorSearch                RGBCOLOR(0x82,0x82,0x82)
#define kColorBtn                   RGBCOLOR(0x83,0x83,0x83)
#define kColorStar                  RGBCOLOR(0xff,0xb5,0x56)
#define kColorBorder                RGBCOLOR(0xd0,0xd6,0xd9)
#define kColorBack                  RGBCOLOR(0xf1,0xf1,0xf1)

#define KColorNewTitleTxt           RGBCOLOR(0x33, 0x33, 0x33)
#define KColorNewSubTitleTxt        RGBCOLOR(0x99, 0x99, 0x99)
#define TimeColorTitleTxt        RGBCOLOR(71, 211, 124)
#define CellBackColor                            RGBCOLOR(232,232,232)
#define KColorNewTimeTxt            RGBCOLOR(0xb2, 0xb2, 0xb2)
#define KColorNewLine               RGBCOLOR(0xe5, 0xe5, 0xe5)
#define KColorResourceLine          RGBCOLOR(225, 225, 225)
#define KColorBorderLine            RGBCOLOR(0xe5, 0xe5, 0xe5)
#define KColorSelect                RGBCOLOR(0x41, 0xc3, 0xff)

#define KColorAppMain                RGBCOLOR(138, 143, 255) //app主色调
#define KColorAppMainP              RGBCOLOR(0xf2, 0x80, 0xb9) //app主色调按下效果

//新定义字体
#define kFontMiddle                 [UIFont systemFontOfSize:15]
#define kFontLarge                  [UIFont systemFontOfSize:16]
#define kFontMiddle_b               [UIFont boldSystemFontOfSize:15]
#define kFontSmall                  [UIFont systemFontOfSize:13]

#define kFontNormal                 [UIFont systemFontOfSize:18]
#define kFontNormal_b               [UIFont boldSystemFontOfSize:18]
#define kFontSmall_b                [UIFont boldSystemFontOfSize:13]
#define kFontLarge_b                [UIFont boldSystemFontOfSize:16]
#define kFontSubTitle               [UIFont systemFontOfSize:14]
#define kFontTitle                  [UIFont systemFontOfSize:16]
#define kFontTimeTitle              [UIFont systemFontOfSize:11]

//font
#define kFontSuper              [UIFont systemFontOfSize:20]
#define kFontSuper_b            [UIFont boldSystemFontOfSize:18]
#define kFontLarge_1            [UIFont systemFontOfSize:17]
#define kFontLarge_1_b          [UIFont boldSystemFontOfSize:17]
#define kFontMiddle_1_b          [UIFont boldSystemFontOfSize:15]

#define kFontSmallBold          [UIFont boldSystemFontOfSize:12]
#define kFontTiny               [UIFont systemFontOfSize:13]
#define kFontMini               [UIFont systemFontOfSize:10]
#define kMessageTextFont        [UIFont systemFontOfSize:16]
#define kFontChildSection       [UIFont systemFontOfSize:12]


#define KNavFontSize (ISSMALLIPHONE?kFontMiddle_1_b:kFontSuper_b)
//按钮颜色
#define ColorNavigationTitle       RGBCOLOR(138, 143, 255)
//通知
#define NOTIFY_RCV_NOTICES                      @"NOTIFY_RCV_NOTICES"       //接收到通知
#define NOTIFY_SEND_NOTICES                      @"NOTIFY_SEND_NOTICES"     //通知发送后 本地刷新
#define NOTIFY_RCV_CHECKIN                      @"NOTIFY_RCV_CHECKIN"       //接收到刷卡信息
#define kRefreshUseInfo                         @"refreshUseInfo"           //刷新用户信息
#define kHideMoreView                           @"hideMoreView"             //隐藏亲子圈操作框
#define kFirstInstall                           @"firstInstall"             //是不是第一次安装
#define NOTIFY_UPDATE_MEDICINES                 @"NOTIFY_UPDATE_MEDICINES"  //喂药 更新
#define NOTIFY_UPDATE_MAILS                     @"NOTIFY_UPDATE_MAILS"      //园长信箱 更新
#define NOTIFY_UPDATE_CIRCLE                    @"NOTIFY_UPDATE_CIRCLE"     //刷新亲子圈
#define NOTIFY_RCV_WXYNEWMSG                    @"NOTIFY_RCV_WXYNEWMSG"     //接收到微学院push

#define EaseMobStartLoginNotification           @"reLoginToEaseMobServer" //从后台唤醒时重新登录环信服务器
#define EMMessageImageLoadSuccessNotification   @"emMessageImageLoadSuccess" //聊天图片加载成功
#define ChatListFetchNewWXYPostNotification     @"fetchNewWXYPostNotification" //新的微学园通知
#define ChatListRefreshGardenPostNotification   @"refreshGardenPostNotification" //园公众号通知
#define ReceiveNewCheckinVoiceNotification      @"receiveNewCheckinVoiceNotification" //新的刷卡语音通知
#define TeacherHelpRefreshNewQuestionNotification   @"jsbRefreshNewQuestionNotificaton" //刷新最新的问题通知
#define TeacherHelpRefreshNewAnswerNotification   @"jsbRefreshNewAnswerNotificaton" //刷新最新的回答通知
#define TeacherHelpRefreshAnswerListNotification   @"jsbRefreshAnswerListNotificaton" //刷新回答列表通知
#define TeacherHelpRefreshNewArticleNotification  @"jsbRefreshNewArticleNotificaton"
#define TeacherHelpQuestionReplysChangedNotification   @"jsbQuestionReplyChnagedNotificaton" //问题回答数有变更的通知
//bay gaoju
#define HomePostNotification        @"homePostNotification"
#define HomeWorkPostNotification        @"homeWorkPostNotification"
#define KUPDATEVERSION                          @"updateVersion" //最后一次提示升级的版本

//最大输入字符
#define kMaxInputCharacterCount   200
#define KMaxVerifyCode 6  //校验验证码的最大长度
#define KMinPasswordLen 6 //密码最小长度
#define KMaxPasswordLen 16 //密码最大长度
#define KPasswordFormatError @"密码长度6~16个字符，由数字、大写字母、小写字母组成" //密码格式错误
#define KPasswordPlaceholder @"设置６-16位密码" //密码提示语
#define KPasswordInvitePlaceholder @"设置6-16位登录密码" //密码提示语

#define NOTIFY_UPDATE_MEDIA_LIKEUPDATE          @"NOTIFY_UPDATE_MEDIA_LIKEUPDATE" //多媒体资源被点赞
#define NOTIFY_UPDATE_MEDIA_CommentUPDATE       @"NOTIFY_UPDATE_MEDIA_CommentUPDATE" //多媒体资源评论数更改
#define NOTIFY_MediaNetworkPlayTypeChanged      @"NOTIFY_MediaNetworkPlayTypeChanged" //多媒体资源网络播放选择变更
#define NOTIFY_MediaPlayTypeShouldUpdate        @"NOTIFY_MediaPlayTypeShouldUpdate" //多媒体资源的网络选择应该刷新
#define MediaPlayViewShouldDisabled             @"MediaPlayViewShouldDisabled" //播放界面应该不可用通知

//其他属性
#pragma mark - 友盟分享key

//微信AppId
//#define UMENG_WXAppId  @"wx76e8778053de3318"
//#define UMENG_WXAppSecrect  @"193fe86f5f574a726579cdad55909df0"
#define UMENG_WXAppId  @"wx3812b10c846c96f4"
#define UMENG_WXAppSecrect  @"122e9dafc9dd1684384d9b0bbb27225d"
//QQ的AppId
//#define UMENG_QQAppId  @"1104834058"
//#define UMENG_QQAppKey @"ZsOFbRmstSsZ0uaY"
#define UMENG_QQAppId  @"1105742713"
#define UMENG_QQAppKey @"YNX9K3CBt8oebRXf"

//#define UMENG_APPKEY @"55acaa32e0f55a7def003b61"
#define UMENG_APPKEY @"5721cc78e0f55a26ac002764"
#define MEIQIA_APPKEY @"558bc22a4eae356866000011"


//信鸽推送
#define KXGPUSHID 2200133368
#define KXGPUSHKEY @"IZC88TQU512Q"

//#define KXGCLASSTAG @"class_" //班级标签开始 信鸽 只支持1万个tag 加上班级不够用
#define KXGGARDENTAG @"garden_" //学校标签开始

//bugly 错误日志上报
//#define BUGLY_APP_ID @"900005484"
#define BUGLY_APP_ID @"900027877"

#define BUGTAGS_APP_ID @"8168a9b16424be7eaec9356ac1f44cae"
#import <CocoaLumberjack.h>
//logger日志级别
//static const DDLogLevel ddLogLevel = DDLogLevelVerbose;


//二维码 字段
#define KSignInUrl  @"check_in_with_user_id" //签到标签
#define KUserIdKey   @"user_id" //用户idkey
#define KUserNameKey @"user_name" //孩子名字
#define KUserTypeKey @"user_type" //家长身份
#define KUserCardNumberKey @"user_cardnumber" //卡号

#define KTXCustomerChatter @"10086"

//txpbresource 增加字段

#define KTXPBRESOURCELIKED      @"txpbResourceLiked" //点赞数据
#define KTXPBRESOURCEISLIKED    @"txpbResourceIsLiked" //是否被自己点赞
#define KTXPBRESOURCEVIEWED     @"txpbResourceViewd" //观看次数

#define KURL_H5_SERVER_ADDRESS_DEV @"http://121.40.16.212:8080/gamedata.py" //开发
#define KURL_H5_SERVER_ADDRESS_TEST @"http://121.41.101.14:8080/gamedata.py" //测试
#define KURL_H5_SERVER_ADDRESS_DIS @"http://service.xcsdedu.com/gamedata.py" //线上服

#if DEV_TEST_POD
	#define KURL_H5_HOST @"http://121.41.101.14/html5/" //开发和测试

	#define KSERVERAGREEMENTURL @"http://121.41.101.14:8080/cms/article.do?agreement" //服务协议链接
	#define KURL_FEEDBACK @"http://121.41.101.14:8080/cms/article.do?feedback" //帮助与反馈
#else
	#define KURL_H5_HOST @"http://h5.xcsdedu.com/1.0/"  //正式

	#define KSERVERAGREEMENTURL @"http://service.xcsdedu.com/cms/article.do?agreement" //服务协议链接
	#define KURL_FEEDBACK @"http://service.xcsdedu.com/cms/article.do?feedback" //帮助与反馈
#endif

#define KHuanXin_AppKey_Dev   @"xcsdedu#lexuetangdev"
#define KHuanXin_AppKey_Test  @"xcsdedu#lexuetangdev"
#define KHuanXin_AppKey_Dis   @"xcsdedu#lexuetangdis"
#define kTestFinish           @"kTestFinish"
#define KUpdateToken          @"KUpdateToken"
#define KDataReport           @"KDataReport"

#define kPhotoSelectMaxCount   20  //照片最大选择数

#endif
