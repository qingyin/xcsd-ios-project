//
//  TXNoticeManage.m
//  TXChat
//
//  Created by lyt on 15-6-15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXSendNoticeManager.h"
#import <TXChatClient.h>
#import "NoticeSelectedModel.h"
#import "UploadImageStatus.h"
#import "TXSystemManager.h"

@implementation TXSendNotice



@end


@interface TXSendNoticeManager()
{
    NSMutableArray *_noticeList;
    dispatch_queue_t _noticeQ;
}

@end



@implementation TXSendNoticeManager

//单例
+ (instancetype)shareInstance
{
    static TXSendNoticeManager *_instance = nil;
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
        _noticeList = [NSMutableArray arrayWithCapacity:5];
        _noticeQ = dispatch_queue_create("tx.gcd.NoticeQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


//-(BOOL)addNoticeSender:(TXSendNotice *)notice
//{
//    @synchronized(_noticeList)
//    {
//        [_noticeList addObject:notice];
//    }
//    if([_noticeList count] == 1)
//    {
//        dispatch_async(_noticeQ, ^{
//            
//            
//            
//        });
//        
//    }
//    
//    return YES;
//}

-(BOOL)addNoticeSender:(TXSendNotice *)notice  completeBlock:(SendNoticeRequestBLock)completeBlcok
{
    //添加附件
    NSMutableArray *photoArray = [NSMutableArray arrayWithCapacity:1];
    
    for(UploadImageStatus *photoIndex in notice.attachList)
    {
        TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
        txpbAttachBuilder.attachType = TXPBAttachTypePic;
        txpbAttachBuilder.fileurl = photoIndex.serverFileKey;
        TXPBAttach *txpbAttach = [txpbAttachBuilder build];
        [photoArray addObject:txpbAttach];
        [[TXSystemManager sharedManager] saveImageToCache:photoIndex.uploadImage forURLString:[photoIndex.serverFileUrl getFormatPhotoUrl]];
    }
    //添加发送人
    NSMutableArray *departmentsArray = [NSMutableArray arrayWithCapacity:1];
    for(NoticeSelectedModel *departmentIndex in notice.toUsers)
    {     
        //发送到整个部门
        TXPBNoticeDepartmentBuilder *txpbNoticeDepartmentBuilder = [TXPBNoticeDepartment builder];
        txpbNoticeDepartmentBuilder.departmentId = departmentIndex.departmentId;
        BOOL isAllSelected = [self isAllSelected:departmentIndex];
        if(isAllSelected)
        {
            txpbNoticeDepartmentBuilder.all = TRUE;
        }
        else
        {
            for(TXUser *user in departmentIndex.selectedUsers)
            {
                [txpbNoticeDepartmentBuilder addMemberUserIds:user.userId];
            }
        }
        [departmentsArray addObject:[txpbNoticeDepartmentBuilder build]];
    }
    
    //发送
    [[TXChatClient sharedInstance]  sendNotice:notice.content
                                      attaches:photoArray
                                 toDepartments:departmentsArray
                                   onCompleted:^(NSError *error, int64_t noticeId) {
                                       NSLog(@"ERROR=%@", error);
                                       NSLog(@"%qi", noticeId);
                                       if(completeBlcok)
                                       {
                                           completeBlcok(error, noticeId);
                                       }
                                   }];
    return YES;
}

-(BOOL)isAllSelected:(NoticeSelectedModel *)department
{
    TXPBUserType userType = TXPBUserTypeChild;
    if(department.departmentType != TXPBDepartmentTypeClazz)
    {
        userType = TXPBUserTypeTeacher;
    }
    
    NSArray *allUsers = [[TXChatClient sharedInstance] getDepartmentMembers:department.departmentId userType:userType error:nil];
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
    return [department.selectedUsers count] == [myMutableArray count];
}



-(void)fireNetwork
{
    if([_noticeList count] > 0)
    {
        TXSendNotice *notice = [_noticeList objectAtIndex:0];
        if(notice)
        {
//            [[TXChatClient sharedInstance] sendNotice:notice.content attaches:notice.attaches toDepartments:notice.toUsers onCompleted:^(NSError *error, TXNotice *txNotice) {
//                if(error)
//                {
//                    
//                }
//                else
//                {
//                    
//                    
//                    
//                }
//            }];
            
//            [[TXChatClient sharedInstance] sendNotice:notice.content attaches:notice.attaches toDepartments:notice.toUsers onCompleted:^(NSError *error, int64_t noticeId) {
//                DLog(@"error:%@", error);
//            }];
        }
    }
}



@end
