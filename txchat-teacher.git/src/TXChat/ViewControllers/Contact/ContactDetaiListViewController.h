//
//  ContactDetaiListViewController.h
//  TXChat
//
//  Created by Cloud on 15/7/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    ContactType_Teachers,
    ContactType_Parents,
} ContactType;

@interface ContactDetaiListViewController : BaseViewController

@property (nonatomic, assign) ContactType type;

@end
