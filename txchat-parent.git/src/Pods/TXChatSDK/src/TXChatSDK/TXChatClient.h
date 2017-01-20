//
//  TXChatClient.h
//  TXChatSDK
//
//  Created by lingiqngwan on 5/17/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXEntities.h"
#import "TXApplicationManager.h"
#import "TXCheckInManager.h"
#import "TXCommentManager.h"
#import "TXUserManager.h"
#import "TXCounterManager.h"
#import "TXFeedManager.h"
#import "TXFeedMedicineTaskManager.h"
#import "TXFileManager.h"
#import "TXGardenMailManager.h"
#import "TXNoticesManager.h"
#import "TXPostManager.h"
#import "TXDeletedMessageManager.h"
#import "TXDepartmentPhotoManager.h"
#import "TXTrackManager.h"
#import "TXJsbManager.h"
#import "XCSDHomeWorkManager.h"
#import "TXResourceManager.h"
#import "TXCourseManager.h"
#import "XCSDLearningAbilityManager.h"
#import "XCSDDataReportManager.h"

@interface TXChatClient : NSObject
@property(nonatomic, readonly) TXApplicationManager *applicationManager;
@property(nonatomic, readonly) TXCheckInManager *checkInManager;
@property(nonatomic, readonly) TXCommentManager *commentManager;
@property(nonatomic, readonly) TXUserManager *userManager;
@property(nonatomic, readonly) TXCounterManager *counterManager;
@property(nonatomic, readonly) TXFeedManager *feedManager;
@property(nonatomic, readonly) TXFeedMedicineTaskManager *feedMedicineTaskManager;
@property(nonatomic, readonly) TXFileManager *fileManager;
@property(nonatomic, readonly) TXGardenMailManager *gardenMailManager;
@property(nonatomic, readonly) TXNoticesManager *noticeManager;
@property(nonatomic, readonly) TXPostManager *postManager;
@property(nonatomic, readonly) TXDeletedMessageManager *deletedMessageManager;
@property(nonatomic, readonly) TXDepartmentPhotoManager *departmentPhotoManager;
@property(nonatomic, readonly) TXTrackManager *trackManager;
@property(nonatomic, readonly) TXJsbManager *txJsbMansger;
@property(nonatomic, readonly) XCSDHomeWorkManager *xcsdHomeWorkManager;
@property (nonatomic, readonly) TXResourceManager *resourceManager;
@property (nonatomic, readonly) TXCourseManager *courseManager;
@property (nonatomic, readonly) XCSDLearningAbilityManager *abilityManager;
@property (nonatomic, readonly) XCSDDataReportManager *dataReportManager;


+ (instancetype)sharedInstance;

- (void)setupWithVersion:(NSString *)version;

@end
