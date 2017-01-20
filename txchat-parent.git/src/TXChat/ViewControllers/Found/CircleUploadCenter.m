//
//  CircleUploadCenter.m
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleUploadCenter.h"
#import "TXContactManager.h"
#import "TXSystemManager.h"

@implementation CircleUploadCenter

//单例
+ (instancetype)shareInstance
{
    static CircleUploadCenter *_instance = nil;
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
        self.uploadArr = [NSMutableArray array];
    }
    return self;
}

//是否禁言
- (BOOL)isForbiddenAddFeed
{
    //暂时屏蔽亲子圈禁言功能
//    return NO;
    if (![TXSystemManager sharedManager].isParentApp) {
        //教师端不禁言
        return NO;
    }
    NSDictionary *userProfile = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (!userProfile) {
        return NO;
    }
    NSNumber *muteNumber = [userProfile objectForKey:kFeedMute];
    if (muteNumber) {
        return [muteNumber boolValue];
    }
    return NO;
//    NSArray *groups = [[TXContactManager shareInstance] getAllGroupId];
//    for (NSString *groupId in groups) {
//        BOOL isForbidden = [[TXContactManager shareInstance] getGagStatusByGroupId:groupId];
//        if (isForbidden) {
//            return YES;
//        }
//    }
//    return NO;
}
//刷新亲子圈上传图片
- (void)refreshAttaches:(NSString *)serverFileKey andFile:(NSString *)serverFile{
    __block BOOL uploadComplete = YES;
    [_uploadArr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        NSMutableArray *arr = dic[@"attaches"];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSUUID class]]) {
                NSUUID *uuid = obj;
                if ([uuid.UUIDString isEqualToString:serverFileKey]) {
                    [arr replaceObjectAtIndex:idx withObject:serverFile];
                }else{
                    uploadComplete  = NO;
                }
            }
        }];
    }];
    
    if (uploadComplete && _uploadArr.count) {
        NSDictionary *dic = _uploadArr[0];
        [[CircleUploadCenter shareInstance] sendFeed:dic[@"content"] attaches:dic[@"attaches"] departmentIds:dic[@"departmentIds"]];
    }
}

//发布亲子圈
- (void)sendFeed:(NSString *)content attaches:(NSMutableArray *)attaches departmentIds:(NSArray *)departmentIds{
    
    [_uploadArr addObject:@{@"content":content,@"attaches":attaches,@"departmentIds":departmentIds}];
    __block BOOL isTmp = NO;
    [attaches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSUUID class]]) {
            isTmp = YES;
            *stop = YES;
        }
    }];
    
    if (isTmp) {
        return;
    }
    
    _isUploading = YES;
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    NSError *error = nil;
    NSArray *arr = [[TXChatClient sharedInstance] getAllDepartments:&error];
    NSMutableArray *departmentIds1 = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(TXDepartment *department, NSUInteger idx, BOOL *stop) {
        [departmentIds1 addObject:@(department.departmentId)];
    }];
    [[TXChatClient sharedInstance].feedManager sendFeed:content attaches:attaches departmentIds:departmentIds1 syncToDepartmentPhoto:NO onCompleted:^(NSError *error) {
        tmpObject.isUploading = NO;
        if (error) {
        }else{
            if (tmpObject.uploadArr.count) {
                [tmpObject.uploadArr removeObjectAtIndex:0];
            }
        }
    }];
}

@end
