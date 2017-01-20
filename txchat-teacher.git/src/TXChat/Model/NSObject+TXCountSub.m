//
//  NSObject+TXCountSub.m
//  TXChat
//
//  Created by 陈爱彬 on 15/7/21.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NSObject+TXCountSub.h"
#import <objc/runtime.h>

@implementation TXCountEvent

- (instancetype)initWithType:(TXClientCountType)type refreshBlock:(TXSingleCountRefreshBlock)block
{
    self = [super init];
    if (self) {
        self.type = type;
        self.singleBlock = block;
        self.name = TXClientCountRefreshName(type);
    }
    return self;
}
- (instancetype)initWithTypes:(NSArray *)types refreshBlock:(TXMultipleCountRefreshBlock)block
{
    self = [super init];
    if (self) {
        self.type = TXClientCountType_Multiple;
        self.multipleBlock = block;
        self.name = TXClientCountRefreshName(TXClientCountType_Multiple);
        self.typeList = types;
    }
    return self;
}
@end

NSString * const TXClientCountOldValueKey = @"txClientCountOldValueKey";
NSString * const TXClientCountNewValueKey = @"txClientCountNewValueKey";
NSString * const TXClientCountSubType = @"txClientCountSubType";

static char kTXClientCountSubscriptionsKey;

@implementation NSObject (TXCountSub)

//订阅单个事件,是否立即刷新
- (void)subscribeCountType:(TXClientCountType)type
              refreshBlock:(TXSingleCountRefreshBlock)block
                 invokeNow:(BOOL)isInvokeNow
{
    [self subscribeCountType:type refreshBlock:block];
    if (isInvokeNow) {
        [self onClientCountRefreshed:nil];
    }
}
//订阅单个事件
- (void)subscribeCountType:(TXClientCountType)type
              refreshBlock:(TXSingleCountRefreshBlock)block
{
    NSMutableDictionary *subscriptions = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXClientCountSubscriptionsKey);
    if (!subscriptions) {
        subscriptions = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &kTXClientCountSubscriptionsKey, subscriptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClientCountRefreshed:) name:TX_NOTIFICATION_COUNTER_REFRESHED object:nil];
    }
    NSMutableSet *observers = [subscriptions objectForKey:TXClientCountRefreshName(type)];
    if (!observers) {
        observers = [[NSMutableSet alloc] init];
        [subscriptions setObject:observers forKey:TXClientCountRefreshName(type)];
    }
    TXCountEvent *event = [[TXCountEvent alloc] initWithType:type refreshBlock:block];
    [observers addObject:event];
}
//订阅多个count事件,是否立即刷新
- (void)subscribeMultipleCountTypes:(NSArray *)types
                       refreshBlock:(TXMultipleCountRefreshBlock)block
                          invokeNow:(BOOL)isInvokeNow
{
    [self subscribeMultipleCountTypes:types refreshBlock:block];
    if (isInvokeNow) {
        [self onClientCountRefreshed:nil];
    }
}
//订阅多个count事件
- (void)subscribeMultipleCountTypes:(NSArray *)types
                       refreshBlock:(TXMultipleCountRefreshBlock)block
{
    NSMutableDictionary *subscriptions = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXClientCountSubscriptionsKey);
    if (!subscriptions) {
        subscriptions = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &kTXClientCountSubscriptionsKey, subscriptions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onClientCountRefreshed:) name:TX_NOTIFICATION_COUNTER_REFRESHED object:nil];
    }
    NSMutableSet *observers = [subscriptions objectForKey:TXClientCountRefreshName(TXClientCountType_Multiple)];
    if (!observers) {
        observers = [[NSMutableSet alloc] init];
        [subscriptions setObject:observers forKey:TXClientCountRefreshName(TXClientCountType_Multiple)];
    }
    TXCountEvent *event = [[TXCountEvent alloc] initWithTypes:types refreshBlock:block];
    [observers addObject:event];
}
//count刷新了
- (void)onClientCountRefreshed:(NSNotification *)notification
{
    //判断是否有count数据源
    NSDictionary *unreadCountDic = [TXChatClient sharedInstance].counterManager.countersDictionary;
    if(!unreadCountDic)
        return ;
    //判断是否有订阅该事件的观察者
    NSMutableDictionary *subscriptions = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXClientCountSubscriptionsKey);
    if (!subscriptions)
        return;
    //通知外部数据刷新
    NSArray *unreadAllKeys = [unreadCountDic allKeys];
    [subscriptions enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableSet *set, BOOL *stop) {
        for (TXCountEvent *event in set) {
            if (event.type == TXClientCountType_Multiple) {
                //多个数据订阅
                NSMutableArray *listArray = [NSMutableArray array];
                NSArray *types = event.typeList;
                for (NSInteger i = 0; i < [types count]; i++) {
                    NSMutableDictionary *subDict = [NSMutableDictionary dictionary];
                    TXClientCountType subType = [types[i] integerValue];
                    NSInteger subOldValue = 0;
                    NSInteger subNewValue = 0;
                    NSString *preKey = [NSString stringWithFormat:@"%@%@",TX_COUNTER_PREV_PREFIX, TXClientCountRefreshName(subType)];
                    if ([unreadAllKeys containsObject:preKey]) {
                        subOldValue = [[unreadCountDic objectForKey:preKey] integerValue];
                    }
                    if ([unreadAllKeys containsObject:TXClientCountRefreshName(subType)]) {
                        subNewValue = [[unreadCountDic objectForKey:TXClientCountRefreshName(subType)] integerValue];
                    }
                    [subDict setValue:@(subOldValue) forKey:TXClientCountOldValueKey];
                    [subDict setValue:@(subNewValue) forKey:TXClientCountNewValueKey];
                    [subDict setValue:@(subType) forKey:TXClientCountSubType];
                    //添加进返回列表中
                    [listArray addObject:subDict];
                }
                //block回调
                event.multipleBlock(listArray);
            }else{
                //单数据订阅
                NSInteger oldValue = 0;
                NSInteger newValue = 0;
                NSString *preKey = [NSString stringWithFormat:@"%@%@",TX_COUNTER_PREV_PREFIX, event.name];
                if ([unreadAllKeys containsObject:preKey]) {
                    oldValue = [[unreadCountDic objectForKey:preKey] integerValue];
                }
                if ([unreadAllKeys containsObject:event.name]) {
                    newValue = [[unreadCountDic objectForKey:event.name] integerValue];
                }
                event.singleBlock(oldValue,newValue,event.type);
            }
        }
    }];
}
//取消单个订阅事件
- (void)unSubscribeCountType:(TXClientCountType)type
{
    NSMutableDictionary *subscriptions = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXClientCountSubscriptionsKey);
    if (!subscriptions)
        return;
    NSMutableSet *observers = [subscriptions objectForKey:TXClientCountRefreshName(type)];
    if (observers) {
        for (TXCountEvent *event in observers) {
            //置空block，避免循环引用
            event.singleBlock = nil;
        }
        [subscriptions removeObjectForKey:TXClientCountRefreshName(type)];
    }
    if ([[subscriptions allKeys] count] == 0) {
        //没有订阅的类型时移除通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TX_NOTIFICATION_COUNTER_REFRESHED object:nil];
        objc_setAssociatedObject(self, &kTXClientCountSubscriptionsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
//取消多个订阅事件
- (void)unSubscribeMultipleCountType
{
    NSMutableDictionary *subscriptions = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXClientCountSubscriptionsKey);
    if (!subscriptions)
        return;
    NSMutableSet *observers = [subscriptions objectForKey:TXClientCountRefreshName(TXClientCountType_Multiple)];
    if (observers) {
        for (TXCountEvent *event in observers) {
            //置空block，避免循环引用
            event.multipleBlock = nil;
        }
        [subscriptions removeObjectForKey:TXClientCountRefreshName(TXClientCountType_Multiple)];
    }
    if ([[subscriptions allKeys] count] == 0) {
        //没有订阅的类型时移除通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TX_NOTIFICATION_COUNTER_REFRESHED object:nil];
        objc_setAssociatedObject(self, &kTXClientCountSubscriptionsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
//取消所有的订阅事件
- (void)unSubscribeAll
{
    NSMutableDictionary *subscriptions = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXClientCountSubscriptionsKey);
    if (!subscriptions)
        return;
    [subscriptions enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableSet *set, BOOL *stop) {
        for (TXCountEvent *event in set) {
            if (event.type == TXClientCountType_Multiple) {
                //多个数据订阅
                event.multipleBlock = nil;
            }else{
                //单数据订阅
                event.singleBlock = nil;
            }
        }
    }];
    [subscriptions removeAllObjects];
    //没有订阅的类型时移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TX_NOTIFICATION_COUNTER_REFRESHED object:nil];
    objc_setAssociatedObject(self, &kTXClientCountSubscriptionsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//获取当前类型的countvalue
- (NSDictionary *)countValueForType:(TXClientCountType)type
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSInteger oldValue = 0;
    NSInteger newValue = 0;
    //判断是否有count数据源
    NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
    if(unreadCountDic){
        NSArray *unreadAllKeys = [unreadCountDic allKeys];
        NSString *preKey = [NSString stringWithFormat:@"%@%@",TX_COUNTER_PREV_PREFIX, TXClientCountRefreshName(type)];
        if ([unreadAllKeys containsObject:preKey]) {
            oldValue = [[unreadCountDic objectForKey:preKey] integerValue];
        }
        if ([unreadAllKeys containsObject:TXClientCountRefreshName(type)]) {
            newValue = [[unreadCountDic objectForKey:TXClientCountRefreshName(type)] integerValue];
        }
    }
    [dict setValue:@(oldValue) forKey:TXClientCountOldValueKey];
    [dict setValue:@(newValue) forKey:TXClientCountNewValueKey];
    return dict;
}
@end
