//
// Created by lingqingwan on 9/21/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDeletedMessageManager.h"
#import "TXApplicationManager.h"


@implementation TXDeletedMessageManager {

}
- (NSArray *)queryAllDeletedMessage {
    return [[TXApplicationManager sharedInstance]
            .currentUserDbManager
            .deletedMessageDao
            queryAllDeletedMessage];
}

- (void)addDeletedMessage:(TXDeletedMessage *)txDeletedMessage error:(NSError **)outError {
    [[TXApplicationManager sharedInstance].currentUserDbManager.deletedMessageDao addDeletedMessage:txDeletedMessage error:outError];
}

- (void)deleteDeletedMessageByMsgId:(NSString *)msgId {
    [[TXApplicationManager sharedInstance].currentUserDbManager.deletedMessageDao deleteDeletedMessageByMsgId:msgId];
}

@end