//
// Created by lingqingwan on 6/9/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack.h>

#define TX_CHAT_SERVER_ENDPOINT                         @"http://api.tx2010.com:80/http_invoke"

//#define TX_CHAT_SERVER_ENDPOINT                         @"http://123.57.43.111:8080/http_invoke"
//#ifndef TX_SYNC_HTTP_REQUEST
//#define TX_SYNC_HTTP_REQUEST
//#endif

#define TX_SETTING_POST_IS_READ                         @"__post_is_read_"

#define TX_CLIENT_NS_ERROR_DOMAIN                       @"com.tuxing.ios.sdk"

#define TX_NOTIFICATION_ERROR                           @"tx.notification.error"
#define TX_NOTIFICATION_COUNTER_REFRESHED               @"tx.notification.counter.refreshed"
#define TX_NOTIFICATION_CURRENT_USER_CHANGED            @"tx.notification.current.user.changed"
#define TX_NOTIFICATION_QR_CHECK_IN_COUNT_CHANGED       @"tx.notification.qr_check_in.changed"
#define TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_SUCCEED      @"tx.notification.qr_check_in.upload.succeed"
#define TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_FAILED       @"tx.notification.qr_check_in.upload.failed"
#define TX_NOTIFICATION_WEI_DOU_AWARDED                 @"tx.notification.wei_dou.awarded"
#define TX_NOTIFICATION_WEI_DOU_AWARDED_BY_CHECK_IN     @"tx.notification.wei_dou.awarded.by.check"

#define TX_STATUS_OK                                    200
#define TX_STATUS_UNAUTHORIZED                          403
#define TX_STATUS_LOCAL_USER_EXPIRED                    -403
#define TX_STATUS_PB_PARSE_ERROR                        900
#define TX_STATUS_KICK_OFF                              1001
#define TX_STATUS_TIMEOUT                               8000
#define TX_STATUS_UN_KNOW_ERROR                         1000
#define TX_STATUS_DB_INIT_FAILED                        -200

#define TX_STATUS_UNAUTHORIZED_DESC                     @"未登录"
#define TX_STATUS_TIMEOUT_DESC                          @"请求超时，请重试"
#define TX_STATUS_LOCAL_USER_EXPIRED_DESC               @"本地登录态已经失效"

#pragma mark 计数器
#define TX_COUNT_ACTIVITY                               @"activity"         //活动
#define TX_COUNT_ANNOUNCEMENT                           @"announcement"     //公告
#define TX_COUNT_CHECK_IN                               @"checkIn"          //刷卡
#define TX_COUNT_FEED                                   @"feed"             //亲子圈
#define TX_COUNT_FEED_COMMENT                           @"comment"
#define TX_COUNT_MAIL                                   @"mail"             //园长信箱
#define TX_COUNT_MEDICINE                               @"medicine"         //喂药
#define TX_COUNT_NOTICE                                 @"notice"           //通知
#define TX_COUNT_LEARN_GARDEN                           @"learn_garden"     //微学院
#define TX_COUNT_GARDEN_OFFICIAL_ACCOUNT                @"public_info"      //园公众号
#define TX_COUNT_REST                                   @"rest"             //请假的小红点
#define TX_COUNT_APPROVE                                @"approve"          //审批的小红点
#define TX_COUNT_JSB                                    @"communion"        //教师帮动态小红点

#define TX_LAST_FETCHED_ON_DEPARTMENT                   @"lastFetchedOn.department"
#define TX_LAST_FETCHED_ON_DEPARTMENT_MEMBER            @"lastFetchedOn.departmentMember"

#define TX_PROFILE_KEY_OPTION_CONTACTS                  @"addressList" //通讯录
#define TX_PROFILE_KEY_OPTION_VOICE_BROADCAST           @"voiceBroadcast" //语音播报
#define TX_PROFILE_KEY_OPTION_ANNOUNCEMENT              @"announcement"
#define TX_PROFILE_KEY_OPTION_ACTIVITY                  @"activity"
#define TX_PROFILE_KEY_OPTION_RECIPES                   @"recipes"
#define TX_PROFILE_KEY_OPTION_MEDICINE                  @"medicine"
#define TX_PROFILE_KEY_OPTION_CHECK_IN                  @"checkIn"
#define TX_PROFILE_KEY_OPTION_ATTENDANCE                @"attendance" //考勤
#define TX_PROFILE_KEY_OPTION_NOTICE                    @"notice"
#define TX_PROFILE_KEY_OPTION_MAIL                      @"mail"
#define TX_PROFILE_KEY_OPTION_INSURANCE                 @"insurance"
#define TX_PROFILE_KEY_GARDEN_IMAGE                     @"garden_image"
#define TX_PROFILE_KEY_SPLASH_IMAGE                     @"splash_image" //启动页
#define TX_PROFILE_KEY_HOME_BANNERS                     @"home_banners" //家园滚动图片,json 格式 [{imgUrl:"",url:"",desc:""},{imgUrl:"",url:"",desc:""}]
#define TX_PROFILE_KEY_GRADE                            @"grade" //等级
#define TX_PROFILE_KEY_GRADE_NAME                       @"grade_name" //等级名称
#define TX_PROFILE_KEY_RANKING_NAME                     @"ranking_name" //达人姓名
#define TX_PROFILE_KEY_LEARN_GARDEN_CLICKED             @"learn_garden_clicked"
#define TX_PROFILE_KEY_GARDEN_OFFICIAL_ACCOUNT_CLICKED  @"public_info_clicked"
#define TX_PROFILE_KEY_CURRENT_USERNAME                 @"_current.userame"
#define TX_PROFILE_KEY_CURRENT_TOKEN                    @"_current.token"

#define TX_APP_CONTEXT_FILE_NAME                        @"appContext.plist"
#define TX_QINIU_DOMAIN                                 @"http://s.tx2010.com"


#define TIMESTAMP_OF_NOW [[NSDate date] timeIntervalSince1970]*1000

#define TX_ERROR_MAKE(errorCode, errorMessage)                                      \
    [NSError errorWithDomain:TX_CLIENT_NS_ERROR_DOMAIN                              \
                        code:errorCode                                              \
                    userInfo:@{ @"FILE" : @(__FILE__),                              \
                                @"LINE" : @(__LINE__),                              \
                                @"MESSAGE" : errorMessage }]

#define TX_ERROR_MAKE_WITH_URL(errorCode, errorMessage, url)                        \
    [NSError errorWithDomain:TX_CLIENT_NS_ERROR_DOMAIN                              \
                        code:errorCode                                              \
                    userInfo:@{ @"FILE" : @(__FILE__),                              \
                                @"LINE" : @(__LINE__),                              \
                                @"URL"  : url,                                      \
                                @"MESSAGE" : errorMessage }]

#define TX_COUNTER_PREV_PREFIX                @"prev-"

#define TX_RUN_ON_MAIN(_code)                                   \
if ( [NSThread isMainThread]) {                                 \
    _code;                                                      \
}else{                                                          \
    dispatch_async(dispatch_get_main_queue(), ^{                \
        _code;                                                  \
    });                                                         \
}                                                               \


#define TX_PARSE_PB_OBJECT(targetClassName, targetObject)                                                              \
    @try {                                                                                                             \
        targetObject = [targetClassName parseFromData:response.body];                                                  \
    } @catch (NSException *e) {                                                                                        \
        innerError = TX_ERROR_MAKE(TX_STATUS_PB_PARSE_ERROR, e.name);                                                  \
        goto completed;                                                                                                \
    }                                                                                                                  \

#define TX_POST_NOTIFICATION_IF_ERROR(error)                                                                           \
    if (error) {                                                                                                       \
        dispatch_async(dispatch_get_main_queue(), ^{                                                                   \
            [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_ERROR object:error];            \
        });                                                                                                            \
    }                                                                                                                  \

#define TX_GO_TO_COMPLETED_IF_ERROR(error)                                                                             \
    if (error) {                                                                                                       \
        innerError = error;                                                                                            \
        goto completed;                                                                                                \
    }

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;