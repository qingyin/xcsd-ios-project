//
//  TXUserDbManager.h
//  TXChatSDK
//
//  Created by lingiqngwan on 6/7/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntities.h"
#import "TXCheckInDao.h"
#import "TXSettingDao.h"
#import "TXCommentDao.h"
#import "TXDeletedMessageDao.h"
#import "TXDepartmentDao.h"
#import "TXFeedDao.h"
#import "TXFeedMedicineTaskDao.h"
#import "TXGardenMailDao.h"
#import "TXPostDao.h"
#import "TXUserDao.h"
#import "TXNoticeDao.h"
#import "TXDepartmentDao.h"
#import "TXDepartmentPhotoDao.h"
#import "TXQrCheckInItemDao.h"

@class TXQrCheckInItem;
@class TXQrCheckInItemDao;

@interface TXUserDbManager : NSObject
@property(nonatomic, readonly) TXCheckInDao *checkInDao;
@property(nonatomic, readonly) TXSettingDao *settingDao;
@property(nonatomic, readonly) TXCommentDao *commentDao;
@property(nonatomic, readonly) TXDeletedMessageDao *deletedMessageDao;
@property(nonatomic, readonly) TXFeedDao *feedDao;
@property(nonatomic, readonly) TXFeedMedicineTaskDao *feedMedicineTaskDao;
@property(nonatomic, readonly) TXGardenMailDao *gardenMailDao;
@property(nonatomic, readonly) TXPostDao *postDao;
@property(nonatomic, readonly) TXUserDao *userDao;
@property(nonatomic, readonly) TXNoticeDao *noticeDao;
@property(nonatomic, readonly) TXDepartmentDao *departmentDao;
@property(nonatomic, readonly) TXDepartmentPhotoDao *departmentPhotoDao;
@property(nonatomic, readonly) TXQrCheckInItemDao *qrCheckInItemDao;


- (instancetype)initWithUsername:(NSString *)username error:(NSError **)outError;

@end
