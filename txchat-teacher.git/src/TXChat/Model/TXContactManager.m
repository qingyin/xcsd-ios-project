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
#import "NoticeSelectedModel.h"
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
                        [[TXChatClient sharedInstance] fetchDepartmentMembers:index.departmentId clearLocalData:NO onCompleted:^(NSError *error) {
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
    __weak __typeof(&*self) weakSelf=self;  //by sck
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


//发通知时默认的选中组
-(NSArray *)defaultDepartForSendNotice
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSArray *departments = [[TXChatClient sharedInstance] getAllDepartments:nil];
    if(departments == nil || currentUser == nil)
    {
        return nil;
    }
    NSMutableArray *selectedDeparts = [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *departIndex in departments)
    {
        if([currentUser isKindergartenLeader])
        {
            if(departIndex.departmentType == TXPBDepartmentTypeGarden)
            {
                [selectedDeparts addObject:departIndex];
            }
        
        }
        else
        {

            if(departIndex.departmentType == TXPBDepartmentTypeClazz)
            {
                [selectedDeparts addObject:departIndex];
            }
        }
    }
    NSMutableArray *defaultGroups = [NSMutableArray arrayWithCapacity:5];
    for(TXDepartment *departIndex in selectedDeparts)
    {
        TXPBUserType userType = TXPBUserTypeChild;
        if(departIndex.departmentType == TXPBDepartmentTypeGarden)
        {
            userType = TXPBUserTypeTeacher;
        }
        NSArray *allUsers = [self getAllUserExceptSelf:departIndex.departmentId userType:userType];
        NoticeSelectedModel *selectedDepart = [[NoticeSelectedModel alloc] init];
        selectedDepart.departmentId = departIndex.departmentId;
        selectedDepart.allDepartmentUsersCount = [allUsers count];
        selectedDepart.selectedUsers = allUsers;
        selectedDepart.departmentType = departIndex.departmentType;
        selectedDepart.departmentName = departIndex.name;
        [defaultGroups addObject:selectedDepart];
    }
    return [NSArray arrayWithArray:defaultGroups];
}


-(NSArray *)getAllUserExceptSelf:(int64_t)departmentId userType:(TXPBUserType)userType
{
    NSArray *allUsers = [[TXChatClient sharedInstance] getDepartmentMembers:departmentId userType:userType error:nil];
    NSMutableArray *myMutableArray = [NSMutableArray arrayWithArray:allUsers];
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    //过滤掉自己
    if(userType == TXPBUserTypeTeacher && currentUser != nil)
    {
        [myMutableArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TXUser *user = (TXUser *)obj;
            if(user.userId == currentUser.userId)
            {
                [myMutableArray removeObject:user];
                *stop = YES;
            }
        }];
    }
    return [NSArray arrayWithArray:myMutableArray];
}

//获取教师通讯录的所有人员
-(NSArray *)getTeachersList
{
    NSArray *departments = [[TXChatClient sharedInstance] getAllDepartments:nil];
    if(departments == nil )
    {
        return nil;
    }
    NSMutableArray *selectedDeparts = [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *departIndex in departments)
    {
        //if(departIndex.departmentType == TXPBDepartmentTypeGarden)
        //modify by sck
        if(departIndex.departmentType == TXPBDepartmentTypeSchool)
        {
            [selectedDeparts addObject:departIndex];
        }
    }

    NSMutableArray *myMutableArray = [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *departIndex in selectedDeparts)
    {
        NSArray *allUsers =[[TXChatClient sharedInstance] getDepartmentMembers:departIndex.departmentId userType:TXPBUserTypeTeacher error:nil] ;
        [myMutableArray addObjectsFromArray:allUsers];
    }
    return [NSArray arrayWithArray:myMutableArray];
}

//获取教师通讯录的所有人员
-(NSDictionary *)getTeachersListAndFirstLetter
{
    NSArray *departments = [[TXChatClient sharedInstance] getAllDepartments:nil];
    if(departments == nil )
    {
        return nil;
    }
    NSMutableArray *selectedDeparts = [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *departIndex in departments)
    {
        if(departIndex.departmentType == TXPBDepartmentTypeGarden)
        {
            [selectedDeparts addObject:departIndex];
        }
    }
    
    NSMutableArray *myMutableArray = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *firstArr = [NSMutableArray array];
    for(TXDepartment *departIndex in selectedDeparts)
    {
        NSArray *allUsers =[[TXChatClient sharedInstance] getDepartmentMembers:departIndex.departmentId userType:TXPBUserTypeTeacher error:nil];
        NSArray *array1 = [allUsers sortedArrayUsingComparator:cmptr2];
        NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:array1];
        while (tmpArr.count) {
            TXUser *user = tmpArr[0];
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@ ",@"nicknameFirstLetter",[user.nicknameFirstLetter substringWithRange:NSMakeRange(0, 1)]];
            NSArray *arr = [tmpArr filteredArrayUsingPredicate:pre];
            [firstArr addObject:arr];
            [tmpArr removeObjectsInArray:arr];
        }
        [myMutableArray addObjectsFromArray:array1];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:myMutableArray,@"list",firstArr,@"first", nil];
}

#pragma mark - 刷新UI
NSComparator cmptr2 = ^(TXUser *feed1, TXUser *feed2){
    return [feed1.nicknameFirstLetter compare:feed2.nicknameFirstLetter];
//    if (feed1.nicknameFirstLetter > feed2.nicknameFirstLetter) {
//        return (NSComparisonResult)NSOrderedDescending;
//    }
//    
//    if (feed1.nicknameFirstLetter < feed2.nicknameFirstLetter) {
//        return (NSComparisonResult)NSOrderedAscending;
//    }
//    return (NSComparisonResult)NSOrderedSame;
};


//获取家长分组列表;
-(NSArray *)getParentsGroupList
{
    NSArray *departments = [[TXChatClient sharedInstance] getAllDepartments:nil];
    if(departments == nil )
    {
        return nil;
    }
    NSMutableArray *selectedDeparts = [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *departIndex in departments)
    {
        if(departIndex.departmentType == TXPBDepartmentTypeClazz)
        {
            [selectedDeparts addObject:departIndex];
        }
    }
    
    NSMutableArray *myMutableArray = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *allMutableArray = [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *departIndex in selectedDeparts)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:departIndex.name, @"name", [NSArray arrayWithObjects:@(departIndex.departmentId), nil] ,@"type",nil];
        [myMutableArray addObject:dic];
        [allMutableArray addObject:@(departIndex.departmentId)];
    }
    if([allMutableArray count] >0)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"通讯录全部", @"name", [NSArray arrayWithArray:allMutableArray] ,@"type",nil];
        [myMutableArray insertObject:dic atIndex:0];
    }
    return [NSArray arrayWithArray:myMutableArray];
}

//获取 家长列表
-(NSArray *)getParentListByArray:(NSArray *)departmentIds
{
    if(departmentIds == nil || [departmentIds count] == 0)
    {
        return nil;
    }
    NSMutableArray *allParents = [NSMutableArray arrayWithCapacity:1];
    for(NSNumber *departmentId in departmentIds)
    {
        NSArray *parents = [self getParentListByDepartmentId:[departmentId longLongValue]];
        if(parents != nil && [parents count] > 0)
        {
            [allParents addObjectsFromArray:parents];
        }
    }
    return [NSArray arrayWithArray:allParents];
}


-(NSArray *)getParentListByDepartmentId:(int64_t)departmentId
{

    NSMutableArray *parentsList = [NSMutableArray arrayWithCapacity:1];
    NSArray *allUsers = [[TXChatClient sharedInstance] getDepartmentMembers:departmentId userType:0  error:nil];
    for(TXUser *user in allUsers)
    {
        if(!user || user.userType != TXPBUserTypeChild)
        {
            continue;
        }
        
        NSMutableArray *parentArray = [NSMutableArray arrayWithCapacity:3];
        [parentArray addObject:user];
        for(TXUser *parent in allUsers)
        {
            if(!parent || parent.userType != TXPBUserTypeParent)
            {
                continue;
            }
            if(parent.childUserId == user.userId)
            {
                [parentArray addObject:parent];
            }
        }
        if([parentArray count] > 1)
        {
            [parentsList addObject:parentArray];
        }
        parentArray = nil;
    }
    
    return [NSArray arrayWithArray:parentsList];
}
//判断用户本地是否存在
-(BOOL)isUserExist:(int64_t)userId
{
    TXUser *user = [[TXChatClient sharedInstance] getUserByUserId:userId error:nil];
    return user != nil;
}



@end
