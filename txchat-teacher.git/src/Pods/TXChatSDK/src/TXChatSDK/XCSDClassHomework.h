//
//  XCSDClassHomework.h
//  Pods
//
//  Created by gaoju on 16/4/5.
//
//


#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"


@interface XCSDClassHomework : TXEntityBase
@property (nonatomic) int64_t  homeworkId;
@property (nonatomic,strong) NSString *className; //班级名称
@property (nonatomic,strong) NSString *title;
@property (nonatomic) XCSDPBHomeworkType type; //1定制作业 2统一作业
@property (nonatomic) int64_t sendTime;
@property (nonatomic) int32_t finishedCount; //完成作业的数量
@property (nonatomic) int32_t totalCount; //总数量

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBClassHomework *)classHomework;

@end
