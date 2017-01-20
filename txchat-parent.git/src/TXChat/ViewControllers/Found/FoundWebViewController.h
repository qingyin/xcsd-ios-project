//
//  FoundWebViewController.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/16.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface FoundWebViewController : BaseViewController

/**
 *  发现类型，是活动专区还是积分商城
 */
@property (nonatomic,assign) FoundType foundType;
//入口Vc
@property (nonatomic,weak) UIViewController *enterVc;

- (instancetype)initWithURLString:(NSString *)urlString;

@end
