//
//  TXChatClient.m
//  TXChatSDK
//
//  Created by lingiqngwan on 5/17/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXChatClient.h"
#import "TXTrackManager.h"

@implementation TXChatClient {
    NSString *_version;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setupWithVersion:(NSString *)version {
    [[TXHttpClient sharedInstance] setupWithVersion:version];

    _applicationManager = [TXApplicationManager sharedInstance];

    _checkInManager = [[TXCheckInManager alloc] init];
    _commentManager = [[TXCommentManager alloc] init];
    _userManager = [[TXUserManager alloc] init];
    _counterManager = [[TXCounterManager alloc] init];
    _feedManager = [[TXFeedManager alloc] init];
    _feedMedicineTaskManager = [[TXFeedMedicineTaskManager alloc] init];
    _fileManager = [[TXFileManager alloc] init];
    _gardenMailManager = [[TXGardenMailManager alloc] init];
    _noticeManager = [[TXNoticesManager alloc] init];
    _postManager = [[TXPostManager alloc] init];
    _userManager = [[TXUserManager alloc] init];
    _deletedMessageManager = [[TXDeletedMessageManager alloc] init];
    _departmentPhotoManager = [[TXDepartmentPhotoManager alloc] init];
    _trackManager = [[TXTrackManager alloc] init];
    _txJsbMansger=[[TXJsbManager alloc] init];
    _homeWorkManager=[[XCSDHomeWorkManager alloc]init];
    _courseManager = [[TXCourseManager alloc] init];
    _resourceManager = [[TXResourceManager alloc] init];
    _abilityManager = [[XCSDLearningAbilityManager alloc] init];
	_dataReportManager = [[XCSDDataReportManager alloc] init];
    
    [_applicationManager tryReloadAppContextFromFile];
}


@end
