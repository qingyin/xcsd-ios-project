//
//  GameMainController.h
//  TXChatParent
//
//  Created by yi.meng on 16/7/4.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BaseViewController.h"



@interface GameMainController : UIViewController


+(BOOL)callNativeUIWithTitle:(NSString *) title andContent:(NSString *)content;

+(void)callNativeHttpPost:(NSString *)url
					token:(NSString *)token
				 bodyData:(NSString *)bodyData
				  hostUrl:(NSString *)hostUrl
				 callback:(NSString *)callback;

+(void)callNativeGameReport:(NSNumber*)gameId
					eventType:(NSNumber*)eventType;

+(void)callNativeFinishHomeworkReport:(NSString *)memberId
							 andScore:(NSString *)scoreJson;

+(void)callNativeGameTestReport:(NSString *)testId;

@property (nonatomic,strong)NSString* param;

@end

static GameMainController* instace;