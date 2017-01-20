//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXCounterManager.h"
#import "TXApplicationManager.h"


@implementation TXCounterManager {
    NSTimer *timer;
}

- (instancetype)init {
    if (self = [super init]) {
        _countersDictionary = [NSMutableDictionary dictionary];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startOrStopCounterRefreshTimer)
                                                     name:TX_NOTIFICATION_CURRENT_USER_CHANGED
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TX_NOTIFICATION_CURRENT_USER_CHANGED
                                                  object:nil];
}

- (void)fetchCounters:(void (^)(NSError *error, NSMutableDictionary *countersDictionary))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBFetchCounterRequestBuilder *requestBuilder = [TXPBFetchCounterRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_counter"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchCounterResponse *txpbFetchCounterResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchCounterResponse, txpbFetchCounterResponse);

                                       for (TXPBCounter *txpbCounter in txpbFetchCounterResponse.counters) {
                                           NSString *prevKey = [NSString stringWithFormat:@"%@%@", TX_COUNTER_PREV_PREFIX, txpbCounter.item];
                                           TX_RUN_ON_MAIN(
                                                          //bay gaoju (重复请求问题 oldValue值)
//                                                   [_countersDictionary setObject:txpbCounter.item forKey:prevKey];
                                                          NSNumber *oldValue = [_countersDictionary valueForKey:txpbCounter.item];
                                                          if(oldValue)
                                                          {
                                                              [_countersDictionary setObject:oldValue forKey:prevKey];
                                                          }

                                                   [_countersDictionary setObject:@(txpbCounter.count) forKey:txpbCounter.item];
                                           )
                                       }

                                       TX_RUN_ON_MAIN(
                                               [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_COUNTER_REFRESHED
                                                                                                   object:nil
                                                                                                 userInfo:nil];
                                       )

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           if (onCompleted) {
                                               TX_RUN_ON_MAIN(
                                                       onCompleted(innerError, _countersDictionary);
                                               )
                                           }
                                       };
                                   }];
}

- (void)setCountersDictionaryValue:(int)value
                            forKey:(NSString *)key {
    dispatch_async(dispatch_get_main_queue(), ^{
        _countersDictionary[key] = @(value);
        [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_COUNTER_REFRESHED object:nil userInfo:nil];
    });
}

- (void)doFetchCounter {
    [self fetchCounters:^(NSError *error, NSMutableDictionary *countersDictionary) {

    }];
}

/**
* 启动/暂停定时拉取计数器的timer
*/
- (void)startOrStopCounterRefreshTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }

    if ([TXApplicationManager sharedInstance].currentUser) {
        timer = [NSTimer scheduledTimerWithTimeInterval:60
                                                 target:self
                                               selector:@selector(doFetchCounter)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [timer fire];
    }
}

@end