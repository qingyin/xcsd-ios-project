//
//  InsuranceOrderViewController.h
//  TXChat
//
//  Created by 陈爱彬 on 15/7/27.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, InsuranceOrderType) {
    InsuranceOrderType_Intro,    //保险介绍页
    InsuranceOrderType_Order     //保单明细页
};

@interface InsuranceOrderViewController : BaseViewController

- (instancetype)initWithInsuranceType:(InsuranceOrderType)type;

@end
