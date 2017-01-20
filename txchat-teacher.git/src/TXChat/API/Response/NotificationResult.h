

#import "BaseJSONModel.h"

#define kNotificationResultTypeOffline @"100"

@protocol NotificationResult
@end

@interface NotificationResult : BaseJSONModel
@property NSString *message;
@property NSString *type;

//{
    //        "message":
    //        "您的账号于2014年12月16日11时44分在一台iOS设备登陆，您被迫下线。如果不是您本人的操作，那么您的密码可能已经泄露，建议请立即更换密码。",
    //        "type":
    //        100
    //    }


@end
