//
//  XCSDHomeWork.h
//  Pods
//
//  Created by gaoju on 16/3/15.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"
#import "TXPBChat.pb.h"

@interface XCSDHomeWork : TXEntityBase
@property (nonatomic) int64_t HomeWorkId ;
@property(nonatomic) int64_t memberId;
@property(nonatomic, strong) NSString *title;
@property(nonatomic) int64_t sendUserId;
@property(nonatomic, strong) NSString *senderName;
@property(nonatomic, strong) NSString *senderAvatar;
@property(nonatomic, strong) NSString *targetName;
@property(nonatomic) XCSDPBHomeworkStatus status;
@property(nonatomic) bool hasRead;
@property(nonatomic) int64_t sendTime;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBHomework *)xcsdHomeWork;

@end




