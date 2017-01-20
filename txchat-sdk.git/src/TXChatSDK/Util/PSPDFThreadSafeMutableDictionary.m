/*
 * https://gist.github.com/steipete/5928916
 *
 * Simple implementation of a thread safe mutable dictionary. In most cases, you want NSCache instead, but it can be
 * useful in situations where you want to manually control what is evicted from the cache in low memory situations.
 *
 * **Warning:** I only use this for setting/getting keys. Enumeration is not thread safe here and will still throw
 * exception
 * */

// ----------------------------------------------------------------

//
//  PSPDFThreadSafeMutableDictionary.m
//  PSPDFKit
//
//  Copyright (c) 2013 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY AUSTRIAN COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <libkern/OSAtomic.h>
#import "PSPDFThreadSafeMutableDictionary.h"

#define LOCKED(...) OSSpinLockLock(&_lock); \
__VA_ARGS__; \
OSSpinLockUnlock(&_lock);

@implementation PSPDFThreadSafeMutableDictionary {
    OSSpinLock _lock;
    NSMutableDictionary *_dictionary; // Class Cluster!
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (id)init {
    return [self initWithCapacity:0];
}

#pragma clang diagnostic pop

- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    if ((self = [self initWithCapacity:objects.count])) {
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            _dictionary[keys[idx]] = obj;
        }];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity {
    if ((self = [super init])) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSMutableDictionary

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    LOCKED(_dictionary[aKey] = anObject)
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    LOCKED([_dictionary addEntriesFromDictionary:otherDictionary]);
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    LOCKED([_dictionary setDictionary:otherDictionary]);
}

- (void)removeObjectForKey:(id)aKey {
    LOCKED([_dictionary removeObjectForKey:aKey])
}

- (void)removeAllObjects {
    LOCKED([_dictionary removeAllObjects]);
}

- (NSUInteger)count {
    LOCKED(NSUInteger count = _dictionary.count)
    return count;
}

- (NSArray *)allKeys {
    LOCKED(NSArray *allKeys = _dictionary.allKeys)
    return allKeys;
}

- (NSArray *)allValues {
    LOCKED(NSArray *allValues = _dictionary.allValues)
    return allValues;
}

- (id)objectForKey:(id)aKey {
    LOCKED(id obj = _dictionary[aKey])
    return obj;
}

- (NSEnumerator *)keyEnumerator {
    LOCKED(NSEnumerator *keyEnumerator = [_dictionary keyEnumerator])
    return keyEnumerator;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    LOCKED(NSUInteger count = [[_dictionary copy] countByEnumeratingWithState:state objects:stackbuf count:len]);
    return count;
}

- (void)performLockedWithDictionary:(void (^)(NSDictionary *dictionary))block {
    if (block) LOCKED(block(_dictionary));
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;

    if ([object isKindOfClass:PSPDFThreadSafeMutableDictionary.class]) {
        PSPDFThreadSafeMutableDictionary *other = object;
        __block BOOL isEqual = NO;
        [other performLockedWithDictionary:^(NSDictionary *dictionary) {
            [self performLockedWithDictionary:^(NSDictionary *otherDictionary) {
                isEqual = [dictionary isEqual:otherDictionary];
            }];
        }];
        return isEqual;
    }
    return NO;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
    LOCKED(BOOL ok = [_dictionary writeToFile:path atomically:useAuxiliaryFile]);
    return ok;
}

@end
