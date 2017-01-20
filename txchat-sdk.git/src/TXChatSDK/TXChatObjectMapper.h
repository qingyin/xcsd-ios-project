//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TXPBChat.pb.h"
#import "TXEntities.h"


@interface TXChatObjectMapper : NSObject

+ (void)mapTXPBUser:(TXPBUser *)txpbUser toTXUser:(TXUser *)txUser;

+ (void)mapTXPBNotice:(TXPBNotice *)txpbNotice toTXNotice:(TXNotice *)txNotice;

+ (void)mapTXPBDepartment:(TXPBDepartment *)txpbDepartment toTXDepartment:(TXDepartment *)txDepartment;

+ (void)mapTXPBCheckIn:(TXPBCheckin *)txpbCheckIn toTXCheckin:(TXCheckIn *)txCheckIn;

+ (void)mapTXPBFeedMedicineTask:(TXPBFeedMedicineTask *)txpbFeedMedicineTask toTXFeedMedicineTask:(TXFeedMedicineTask *)txFeedMedicineTask;

+ (void)mapTXPBTXGardenMail:(TXPBGardenMail *)txpbGardenMail toTXGardenMail:(TXGardenMail *)txGardenMail;

+ (void)mapTXPBFeed:(TXPBFeed *)txpbFeed toTXFeed:(TXFeed *)txFeed;

+ (void)mapTXPBComment:(TXPBComment *)txpbComment toTXComment:(TXComment *)txComment;

+ (void)mapTXPBPost:(TXPBPost *)txpbPost groupId:(int64_t)groupId toTXPost:(TXPost *)txPost;

@end