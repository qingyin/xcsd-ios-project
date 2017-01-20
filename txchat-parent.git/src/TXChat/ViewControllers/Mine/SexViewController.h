//
//  SexViewController.h
//  TXChat
//
//  Created by lyt on 15/7/15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^SexSelectedCompleted)(NSString *selectedSex);

@interface SexViewController : BaseViewController

//初始化 默认性别 和 选中后处理
-(id)initWithDefaultSex:(NSString *)defaultSex onCompleted:(SexSelectedCompleted)onComplted;
@end
