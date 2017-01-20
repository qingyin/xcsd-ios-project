//
//  TXReportManager.h
//  TXChatParent
//
//  Created by lyt on 15/12/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BaseViewController;

typedef void(^UpdateLoggsCallBack)(NSError *error, NSString *reportUrl);

@interface TXReportManager : NSObject

//单例
+ (instancetype)shareInstance;
//上传诊断信息
-(BOOL)updateLoggs:(BaseViewController *)showInVC complete:(UpdateLoggsCallBack)complete;

@end
