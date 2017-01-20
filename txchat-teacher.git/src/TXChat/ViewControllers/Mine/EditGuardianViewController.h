//
//  EditGuardianViewController.h
//  TXChat
//
//  Created by Cloud on 15/6/8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface EditGuardianViewController : BaseViewController

@property (nonatomic, strong) NSMutableDictionary *detailDic;

- (id)initWithDetailDic:(NSMutableDictionary *)detailDic;

@end
