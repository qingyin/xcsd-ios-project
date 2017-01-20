//
//  IdentityViewController.h
//  TXChat
//
//  Created by Cloud on 15/6/4.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface IdentityViewController : BaseViewController


@property (nonatomic,strong)  TXUser *child;
@property (nonatomic, strong) TXUser *txUser;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, copy) NSString *userName;

- (void)updateParentType:(NSInteger)type;
- (void)updateName:(NSString *)name;

@end
