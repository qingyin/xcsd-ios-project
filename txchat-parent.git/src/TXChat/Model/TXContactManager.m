//
//  TXContactManager.m
//  TXChat
//
//  Created by lyt on 15-6-19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXContactManager.h"
#import <TXChatClient.h>
#import <TXUser.h>
#import <TXDepartment.h>
#import "TXDepartment+Utils.h"
#import "TXUser+Utils.h"


@implementation TXContactManager

//单例
+ (instancetype)shareInstance
{
    static TXContactManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [[TXEaseMobHelper sharedHelper] addEaseMobRefreshObserver:self selector:@selector(refreshContactDataSource:) type:TXEaseMobRefreshCMDMessageType];
    }
    return self;
}

-(NSDictionary *)getUserByUserID:(int64_t)objId isGroup:(BOOL)isGroup complete:(GetUserComplted)complete
{
    NSDictionary *dic = nil;
    NSError *error = nil;
    if(isGroup)
    {
        TXDepartment *depart = [[TXChatClient sharedInstance] getDepartmentByGroupId:[NSString stringWithFormat:@"%lld", objId] error:&error];
        dic = [NSDictionary dictionaryWithObjectsAndKeys:depart.name, @"name", [depart getFormatAvatarUrl:50.0f hight:50.0f], @"headerImg",nil];
    }
    else
    {
        TXUser *user = [[TXChatClient sharedInstance] getUserByUserId:objId error:&error];
        if(user)
        {
            dic = [NSDictionary dictionaryWithObjectsAndKeys:KCONVERTSTRVALUE(user.nickname), @"name", KCONVERTSTRVALUE([user getFormatAvatarUrl:50.0f hight:50.0f]), @"headerImg",nil];
        }
        else
        {
            [[TXChatClient sharedInstance] fetchUserByUserId:objId onCompleted:^(NSError *error, TXUser *txUser) {
                DLog(@"error");
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:KCONVERTSTRVALUE(txUser.nickname), @"name", KCONVERTSTRVALUE([txUser getFormatAvatarUrl:50.0f hight:50.0f]), @"headerImg",nil];
                if(complete)
                {
                    complete(dic, error);
                }
            }];
        }
        
    }

    return dic;

}
//请求不存在的用户信息
-(void)checkUserExist:(int64_t)userId
{
    if([[TXChatClient sharedInstance] getUserByUserId:userId error:nil]  == nil)
    {
        [[TXChatClient sharedInstance] fetchUserByUserId:userId onCompleted:^(NSError *error, TXUser *txUser) {
            DDLogDebug(@"error");
        }];
    }
}

//判断 环信的id是不是群id
-(BOOL)isGroupId:(NSString *)easeMobId
{
    if(easeMobId == nil)
    {
        return NO;
    }
    BOOL ret = NO;
    int64_t departId = [easeMobId longLongValue];
    NSArray *departList = [[TXChatClient sharedInstance] getAllDepartments:nil];
    for(TXDepartment *departIndex in departList)
    {
        if(departIndex.departmentId == departId)
        {
            ret = YES;
            break;
        }
    }
    return ret;
}
//根据group获取 免打扰状态
-(BOOL)getGroupNoDisturbStatus:(NSString *)groupId
{
    BOOL ret = NO;
    TXDepartment *depart = [[TXChatClient sharedInstance] getDepartmentByGroupId:groupId error:nil];
    if(depart == nil)
    {
        return ret;
    }
    NSString *departmentKey = [NSString stringWithFormat:@"%@%lld", KDepartNoDisturb, depart.departmentId];
    NSError *err = nil;
    NSDictionary *userProfile = [[TXChatClient sharedInstance] getCurrentUserProfiles:&err];
    if([userProfile objectForKey:departmentKey])
    {
        ret = [[userProfile objectForKey:departmentKey] boolValue];
    }
    return ret;
}

//获取用户所有的groupid
-(NSArray *)getAllGroupId
{
    NSMutableArray *groupIds = [NSMutableArray arrayWithCapacity:1];
    NSArray *departList = [[TXChatClient sharedInstance] getAllDepartments:nil];
    for(TXDepartment *departIndex in departList)
    {
        if(departIndex.groupId != nil)
        {
            [groupIds addObject:departIndex.groupId];
        }
    }
    return [NSArray arrayWithArray:groupIds];
}
//刷新联系人信息
- (void)refreshContactDataSource:(NSNumber *)cmdType
{
    
    if(cmdType.integerValue == TXCMDMessageType_UnBindUser || cmdType.integerValue == TXCMDMessageType_ProfileChange )
    {
        //获取联系人
        [[TXChatClient sharedInstance] fetchDepartments:^(NSError *error) {
            DDLogDebug(@"fetchDepartments:");
            if(!error)
            {
                //从网络获取成功，通知列表更新群
                [[TXEaseMobHelper sharedHelper] notifyObserverRefreshChatList];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *departs = [[TXChatClient sharedInstance] getAllDepartments:nil];
                    for(TXDepartment *index in departs)
                    {
                        [[TXChatClient sharedInstance] fetchDepartmentMembers:index.departmentId clearLocalData:NO  onCompleted:^(NSError *error) {
                            DDLogDebug(@"error:%@", error);
                        }];
                    }
                });
            }
        }];
    }
    else if(cmdType.integerValue == TXCMDMessageType_GagUser)
    {
        //更新 用户设置信息
        [[TXChatClient sharedInstance] fetchUserProfiles:^(NSError *error, NSDictionary *userProfiles) {
            DDLogDebug(@"请求profile的error:%@", error);
        }];
    }
}

//通知所有的群 个人信息变更
-(void)notifyAllGroupsUserInfoUpdate:(TXCMDMessageType)type
{
    WEAKSELF
    TXAsyncRun(^{
        
        [[TXEaseMobHelper sharedHelper] sendCMDMessageWithType:type];
        [weakSelf refreshContactDataSource:@(type)];
    });
}
//获取群的禁言状态
-(BOOL)getGagStatusByGroupId:(NSString *)groupId
{
    NSDictionary *userProfile = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if(groupId == nil || [groupId length] == 0 ||userProfile == nil)
    {
        return FALSE;
    }
    NSString  *muteGroupids = [userProfile objectForKey:KMute];
    NSArray *muteGroupidsArray = [muteGroupids componentsSeparatedByString:@","];
    return  [muteGroupidsArray containsObject:groupId];
}



//判断用户本地是否存在
-(BOOL)isUserExist:(int64_t)userId
{
    TXUser *user = [[TXChatClient sharedInstance] getUserByUserId:userId error:nil];
    return user != nil;
}



@end
