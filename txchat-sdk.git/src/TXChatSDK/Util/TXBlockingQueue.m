//
// Created by lingqingwan on 9/23/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <pthread.h>
#import "TXBlockingQueue.h"


@implementation TXBlockingQueue {
    int _maxSize;
    NSMutableArray *_queue;
    pthread_mutex_t _queueLock;
    pthread_cond_t _notEmpty;
    pthread_cond_t _notFull;
}

- (instancetype)init {
    if (self = [super init]) {
        _maxSize = INT_MAX;
        _queue = [NSMutableArray array];

        pthread_mutex_init(&_queueLock, NULL);
        pthread_cond_init(&_notEmpty, NULL);
        pthread_cond_init(&_notFull, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_queueLock);
    pthread_cond_destroy(&_notFull);
    pthread_cond_destroy(&_notEmpty);
}

- (void)put:(NSObject *)object {
    pthread_mutex_lock(&_queueLock);
    while ([_queue count] == _maxSize) {
        pthread_cond_wait(&_notFull, &_queueLock);
    }
    [_queue addObject:object];
    pthread_cond_signal(&_notEmpty);
    pthread_mutex_unlock(&_queueLock);
}

- (NSObject *)take {
    NSObject *firstObject;

    pthread_mutex_lock(&_queueLock);
    while (_queue.count == 0) {
        pthread_cond_wait(&_notEmpty, &_queueLock);
    }
    firstObject = _queue[0];
    [_queue removeObjectAtIndex:0];

    pthread_cond_signal(&_notFull);
    pthread_mutex_unlock(&_queueLock);

    return firstObject;
}

- (void)removeAll {
    pthread_mutex_lock(&_queueLock);
    [_queue removeAllObjects];
    pthread_cond_signal(&_notFull);
    pthread_mutex_unlock(&_queueLock);
}

@end