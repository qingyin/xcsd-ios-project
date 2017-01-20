//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "TXPBChat.pb.h"
#import "TXEntities.h"

@interface TXUser : TXEntityBase
/**
* 用户中心的用户id，同时也作为环信的id
*/
@property(nonatomic) int64_t userId;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *nickname;
@property(nonatomic, strong) NSString *nicknameFirstLetter;
@property(nonatomic, strong) NSString *avatarUrl;
//@property(nonatomic) int64_t childUserId;

@property(nonatomic, strong) NSString *mobilePhoneNumber;
@property(nonatomic, strong) NSString *sign;
@property(nonatomic, strong) NSString *realName;
@property(nonatomic) TXPBUserType userType;
@property(nonatomic) BOOL isInit;
@property(nonatomic) TXPBSexType sex;
//@property(nonatomic) TXPBParentType parentType;
//@property(nonatomic) TXPBChild *childs;


/**
 *  从2.2.4起支持多幼儿，相关信息存放到 childUserIdAndRelationsList
 */
@property(nonatomic, strong) NSString *customName;
@property(nonatomic) int64_t childUserId  __attribute__ ((deprecated));


/**
 *  从2.2.4起支持多幼儿，相关信息存放到 childUserIdAndRelationsList
 */
@property(nonatomic) TXPBParentType parentType  __attribute__ ((deprecated));
/**
 *  家长和小孩关系
 */
@property(nonatomic, strong) NSMutableArray *childUserIdAndRelationsList;

/**
 *  组合昵称
 */
@property(nonatomic, strong) NSString *combinedNickName;





/**
* 地区
*/
@property(nonatomic, strong) NSString *location;

@property(nonatomic) int64_t positionId;
/**
* 职位
*/
@property(nonatomic, strong) NSString *positionName;

/**
* 生日
*/
@property(nonatomic) int64_t birthday;

/**
* 班级名称
*/
@property(nonatomic, strong) NSString *className;

/**
* 幼儿园名称
*/
@property(nonatomic, strong) NSString *gardenName;

@property(nonatomic) int64_t gardenId;
@property(nonatomic) int64_t classId;

/**
* 入园时间
*/
//@property(nonatomic) int64_t enrollmentDate;

@property(nonatomic) NSString *guarder;

@property(nonatomic) BOOL activated;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(TXPBUser *)txpbUser;

@end