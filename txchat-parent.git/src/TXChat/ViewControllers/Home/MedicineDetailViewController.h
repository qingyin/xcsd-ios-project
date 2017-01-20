//
//  MedicineDetailViewController.h
//  TXChat
//
//  Created by lyt on 15-6-29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import <TXChatClient.h>

@interface MedicineDetailViewController : BaseViewController

//根据 medicine初始化详情
-(id)initWithMedicine:(TXFeedMedicineTask *)medicine;

@end
