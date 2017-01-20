//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXChatObjectMapper.h"


@implementation TXChatObjectMapper {
}

+ (void)mapTXPBUser:(TXPBUser *)txpbUser toTXUser:(TXUser *)txUser {
    txUser.userId = txpbUser.userId;
    txUser.username = txpbUser.userName;
    txUser.avatarUrl = txpbUser.avatar;
    txUser.userType = txpbUser.userType;
    txUser.mobilePhoneNumber = txpbUser.mobile;
    txUser.childUserId = txpbUser.childUserId;
    txUser.userType = txpbUser.userType;
    txUser.nickname = txpbUser.nickname;
    txUser.nicknameFirstLetter = txpbUser.firstLetter;
    txUser.sign = txpbUser.sign;
    txUser.sex = txpbUser.sexType;
    txUser.birthday = txpbUser.birthday;
    txUser.className = txpbUser.className;
    txUser.gardenName = txpbUser.gardenName;
    txUser.classId = txpbUser.classId;
    txUser.gardenId = txpbUser.gardenId;
    txUser.location = txpbUser.address;
    txUser.positionId = txpbUser.positionId;
    txUser.positionName = txpbUser.positionName;
    txUser.realName = txpbUser.realname;
    txUser.parentType = txpbUser.parentType;
    txUser.realName = txpbUser.realname;
    txUser.guarder = txpbUser.guarder;
    txUser.activated = txpbUser.activated;
}

+ (void)mapTXPBNotice:(TXPBNotice *)txpbNotice toTXNotice:(TXNotice *)txNotice {
    txNotice.content = txpbNotice.content;
    txNotice.fromUserId = txpbNotice.sendUserId;
    txNotice.noticeId = txpbNotice.id;
    txNotice.sentOn = txpbNotice.sendTime;
    txNotice.attaches = [[NSMutableArray alloc] init];
    for (uint i = 0; i < txpbNotice.attaches.count; ++i) {
        TXPBAttach *txpbAttach = txpbNotice.attaches[i];
        [txNotice.attaches addObject:txpbAttach.fileurl];
    }
    txNotice.isRead = txpbNotice.isRead;
    txNotice.createdOn = txpbNotice.sendTime;
    txNotice.senderAvatar = txpbNotice.senderAvatar;
    txNotice.senderName = txpbNotice.senderName;
}

+ (void)mapTXPBDepartment:(TXPBDepartment *)txpbDepartment toTXDepartment:(TXDepartment *)txDepartment {
    txDepartment.departmentId = txpbDepartment.id;
    txDepartment.name = txpbDepartment.name;
    txDepartment.avatarUrl = txpbDepartment.classPhoto;
    txDepartment.groupId = txpbDepartment.groupId;
    txDepartment.showParent = txpbDepartment.showParent;
    txDepartment.parentId = txpbDepartment.parentId;
    txDepartment.departmentType = txpbDepartment.type;
}

+ (void)mapTXPBCheckIn:(TXPBCheckin *)txpbCheckIn toTXCheckin:(TXCheckIn *)txCheckIn {
    txCheckIn.cardCode = txpbCheckIn.cardCode;
    txCheckIn.checkInId = txpbCheckIn.id;
    txCheckIn.checkInTime = txpbCheckIn.checkinTime;
    txCheckIn.clientKey = 0;
    txCheckIn.gardenId = txpbCheckIn.gardenId;
    txCheckIn.userId = txpbCheckIn.userId;
    txCheckIn.username = txpbCheckIn.userName;
    txCheckIn.attaches = [[NSMutableArray alloc] init];
    [txCheckIn.attaches addObject:[txpbCheckIn attach].fileurl];
    txCheckIn.className = txpbCheckIn.className;
    txCheckIn.parentName = txpbCheckIn.parentName;
}

+ (void)mapTXPBFeedMedicineTask:(TXPBFeedMedicineTask *)txpbFeedMedicineTask toTXFeedMedicineTask:(TXFeedMedicineTask *)txFeedMedicineTask {
    txFeedMedicineTask.feedMedicineTaskId = txpbFeedMedicineTask.id;
    txFeedMedicineTask.classId = txpbFeedMedicineTask.classId;
    txFeedMedicineTask.className = txpbFeedMedicineTask.className;
    txFeedMedicineTask.classAvatarUrl = txpbFeedMedicineTask.classAvatarUrl;
    txFeedMedicineTask.parentUserId = txpbFeedMedicineTask.parentUserId;
    txFeedMedicineTask.parentUsername = txpbFeedMedicineTask.parentName;
    txFeedMedicineTask.parentAvatarUrl = txpbFeedMedicineTask.parentAvatarUrl;
    txFeedMedicineTask.beginDate = txpbFeedMedicineTask.beginDate;
    txFeedMedicineTask.createdOn = txpbFeedMedicineTask.createdOn;
    txFeedMedicineTask.content = txpbFeedMedicineTask.desc;
    txFeedMedicineTask.attaches = [[NSMutableArray alloc] init];
    for (uint i = 0; i < txpbFeedMedicineTask.attaches.count; ++i) {
        TXPBAttach *txpbAttach = txpbFeedMedicineTask.attaches[i];
        [txFeedMedicineTask.attaches addObject:txpbAttach.fileurl];
    }
    txFeedMedicineTask.updatedOn = txpbFeedMedicineTask.updateOn;
    txFeedMedicineTask.isRead = txpbFeedMedicineTask.hasRead;
}

+ (void)mapTXPBTXGardenMail:(TXPBGardenMail *)txpbGardenMail toTXGardenMail:(TXGardenMail *)txGardenMail {
    txGardenMail.gardenMailId = txpbGardenMail.id;
    txGardenMail.gardenId = txpbGardenMail.gardenId;
    txGardenMail.gardenName = txpbGardenMail.gardenName;
    txGardenMail.gardenAvatarUrl = txpbGardenMail.gardenAvatarUrl;
    txGardenMail.content = txpbGardenMail.content;
    txGardenMail.createdOn = txpbGardenMail.createdOn;
    txGardenMail.isAnonymous = txpbGardenMail.anonymous;
    txGardenMail.fromUserId = txpbGardenMail.fromUserId;
    txGardenMail.fromUsername = txpbGardenMail.fromUsername;
    txGardenMail.fromUserAvatarUrl = txpbGardenMail.fromUserAvatarUrl;
    txGardenMail.updatedOn = txpbGardenMail.updateOn;
    txGardenMail.isRead = txpbGardenMail.hasRead;
}

+ (void)mapTXPBFeed:(TXPBFeed *)txpbFeed toTXFeed:(TXFeed *)txFeed {
    txFeed.content = txpbFeed.content;
    txFeed.createdOn = txpbFeed.createOn;
    txFeed.feedId = txpbFeed.id;
    txFeed.userId = txpbFeed.userId;
    txFeed.userNickName = txpbFeed.userNickName;
    txFeed.userAvatarUrl = txpbFeed.userAvatarUrl;
    txFeed.attaches = [[NSMutableArray alloc] init];
    for (uint i = 0; i < txpbFeed.attaches.count; ++i) {
        TXPBAttach *txpbAttach = txpbFeed.attaches[i];
        [txFeed.attaches addObject:txpbAttach.fileurl];
    }
    txFeed.hasMoreComment = txpbFeed.hasMoreComment;
    txFeed.userType = txpbFeed.userType;
}

+ (void)mapTXPBComment:(TXPBComment *)txpbComment toTXComment:(TXComment *)txComment {
    txComment.commentId = txpbComment.id;
    txComment.targetId = txpbComment.targetId;
    txComment.content = txpbComment.content;
    txComment.createdOn = txpbComment.createOn;
    txComment.targetUserId = txpbComment.targetUserId;
    txComment.targetType = txpbComment.targetType;
    txComment.commentType = txpbComment.commentType;
    txComment.toUserId = txpbComment.toUserId;
    txComment.toUserNickname = txpbComment.toUserNickName;
    txComment.userId = txpbComment.userId;
    txComment.userNickname = txpbComment.userNickName;
    txComment.userAvatarUrl = txpbComment.userAvatarUrl;
}

+ (void)mapTXPBPost:(TXPBPost *)txpbPost groupId:(int64_t)groupId toTXPost:(TXPost *)txPost {
    txPost.postId = txpbPost.id;
    txPost.groupId = groupId;
    txPost.postType = txpbPost.postType;
    txPost.coverImageUrl = txpbPost.coverImageUrl;
    txPost.content = txpbPost.content;
    txPost.summary = txpbPost.summary;
    txPost.title = txpbPost.title;
    txPost.createdOn = txpbPost.createdOn;
    txPost.orderValue = txpbPost.orderValue;
    txPost.postUrl = txpbPost.postUrl;
}

@end