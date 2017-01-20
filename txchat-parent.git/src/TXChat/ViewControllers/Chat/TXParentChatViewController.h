//
//  TXParentChatViewController.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatViewController.h"
#import <EMChatManagerDefs.h>

@interface TXParentChatViewController : TXChatViewController

/**
 *  是否是普通的返回按钮，默认是NO
 */
@property (nonatomic,assign) BOOL isNormalBack;

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;

@end
