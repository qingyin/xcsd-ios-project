//
//  NSObject+TXCountSub.h
//  TXChat
//
//  Created by 陈爱彬 on 15/7/21.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TXClientCountType) {
    TXClientCountType_Announcement = 0,          //公告
    TXClientCountType_Activity,                  //活动
    TXClientCountType_Medicine = 3,              //喂药
    TXClientCountType_Checkin,                   //刷卡
    TXClientCountType_Notice,                    //通知
    TXClientCountType_Mail,                      //园长信箱
    TXClientCountType_Feed,                      //亲子圈
    TXClientCountType_FeedComment,               //亲子圈评论
    TXClientCountType_LearnGarden,               //微学院
    TXClientCountType_GardenPost,                //园公众号
    TXClientCountType_Rest,                      //请假的红点
    TXClientCountType_Approve,                   //审批的红点
    TXClientCountType_JSB,                       //教师帮
    TXClientCountType_Multiple,                  //多个类型
};

static inline NSString * TXClientCountRefreshName(TXClientCountType type) {
    switch (type) {
        case TXClientCountType_Activity:
            return TX_COUNT_ACTIVITY;
            break;
        case TXClientCountType_Announcement:
            return TX_COUNT_ANNOUNCEMENT;
            break;
        case TXClientCountType_Checkin:
            return TX_COUNT_CHECK_IN;
            break;
        case TXClientCountType_Feed:
            return TX_COUNT_FEED;
            break;
        case TXClientCountType_FeedComment:
            return TX_COUNT_FEED_COMMENT;
            break;
        case TXClientCountType_Mail:
            return TX_COUNT_MAIL;
            break;
        case TXClientCountType_Medicine:
            return TX_COUNT_MEDICINE;
            break;
        case TXClientCountType_Notice:
            return TX_COUNT_NOTICE;
            break;
        case TXClientCountType_LearnGarden:
            return TX_COUNT_LEARN_GARDEN;
            break;
        case TXClientCountType_GardenPost:
            return TX_COUNT_GARDEN_OFFICIAL_ACCOUNT;
            break;
        case TXClientCountType_Rest:
            return TX_COUNT_REST;
            break;
        case TXClientCountType_Approve:
            return TX_COUNT_APPROVE;
            break;
        case TXClientCountType_JSB:
            return TX_COUNT_JSB;
            break;
        case TXClientCountType_Multiple:
            return @"multiple";
            break;
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"none";
#pragma clang diagnostic pop
            break;
        }
    }
}

//定义block
typedef void(^TXSingleCountRefreshBlock)(NSInteger oldValue,NSInteger newValue,TXClientCountType type);
typedef void(^TXMultipleCountRefreshBlock)(NSArray *values);

//定义外部可直接访问数据的key值
extern NSString * const TXClientCountOldValueKey;
extern NSString * const TXClientCountNewValueKey;
extern NSString * const TXClientCountSubType;

@interface TXCountEvent : NSObject
//事件名称
@property (nonatomic, copy) NSString *name;
//单个事件的回调block
@property (nonatomic, copy) TXSingleCountRefreshBlock singleBlock;
//多个事件的回调block
@property (nonatomic, copy) TXMultipleCountRefreshBlock multipleBlock;
//事件类型
@property (nonatomic) TXClientCountType type;
//多个事件类型
@property (nonatomic, copy) NSArray *typeList;

- (instancetype)initWithType:(TXClientCountType)type refreshBlock:(TXSingleCountRefreshBlock)block;

- (instancetype)initWithTypes:(NSArray *)types refreshBlock:(TXMultipleCountRefreshBlock)block;

@end

@interface NSObject (TXCountSub)

//订阅单个事件,是否立即刷新
- (void)subscribeCountType:(TXClientCountType)type
              refreshBlock:(TXSingleCountRefreshBlock)block
                 invokeNow:(BOOL)isInvokeNow;

//订阅单个count事件
- (void)subscribeCountType:(TXClientCountType)type
              refreshBlock:(TXSingleCountRefreshBlock)block;

/**
 *  订阅多个count事件
 *
 *  @param types 事件类型，传递数据如@[@(TXClientCountType_Activity),@(TXClientCountType_Checkin)]
 *  @param block 回调block,返回数据是NSArray，每个item是NSDictionary,key分别为TXClientCountOldValueKey,TXClientCountNewValueKey,TXClientCountSubType
 */
- (void)subscribeMultipleCountTypes:(NSArray *)types
                       refreshBlock:(TXMultipleCountRefreshBlock)block;

//订阅多个count事件,是否立即刷新
- (void)subscribeMultipleCountTypes:(NSArray *)types
                       refreshBlock:(TXMultipleCountRefreshBlock)block
                          invokeNow:(BOOL)isInvokeNow;

//取消订阅红点事件
- (void)unSubscribeCountType:(TXClientCountType)type;

//取消多个订阅事件
- (void)unSubscribeMultipleCountType;

//取消所有的订阅事件
- (void)unSubscribeAll;

//获取当前类型的countvalue
- (NSDictionary *)countValueForType:(TXClientCountType)type;

@end
