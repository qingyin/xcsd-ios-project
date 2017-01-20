//
//  TXContactManager.h
//  TXChat
//
//  Created by lyt on 15-6-19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEaseMobHelper.h"

typedef void(^GetUserComplted)(NSDictionary *userInfo, NSError *error);


@interface TXContactManager : NSObject
//单例
+ (instancetype)shareInstance;
//根据 id 返回 头像(@"headerImg") 和姓名(@"name")
-(NSDictionary *)getUserByUserID:(int64_t)objId isGroup:(BOOL)isGroup complete:(GetUserComplted)complete;
//判断 环信的id是不是群id
-(BOOL)isGroupId:(NSString *)easeMobId;

//根据group获取 免打扰状态
-(BOOL)getGroupNoDisturbStatus:(NSString *)groupId;

//获取用户所有的groupid
-(NSArray *)getAllGroupId;

//通知所有的群 个人信息变更
-(void)notifyAllGroupsUserInfoUpdate:(TXCMDMessageType)type;

//获取群的禁言状态
-(BOOL)getGagStatusByGroupId:(NSString *)groupId;

//请求不存在的用户信息
-(void)checkUserExist:(int64_t)userId;

//发通知时默认的选中组
-(NSArray *)defaultDepartForSendNotice;

//判断用户本地是否存在
-(BOOL)isUserExist:(int64_t)userId;


//获取教师通讯录的所有人员
-(NSArray *)getTeachersList;
- (NSDictionary *)getTeachersListAndFirstLetter;

//获取家长分组列表;
-(NSArray *)getParentsGroupList;

//获取 家长列表
-(NSArray *)getParentListByArray:(NSArray *)departmentIds;


@end
