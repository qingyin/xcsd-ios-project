//
//  TXBudgeButton.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/12.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXBudgeButton : UIControl

@property (nonatomic) NSInteger budge;

/**
 *  初始化方法
 *
 *  @param frame        视图Frame
 *  @param normalName   普通状态下的图片名称
 *  @param selectedName 选中状态下的图片名称
 *  @param budge        默认的Budge角标数
 *
 *  @return 角标按钮
 */
- (instancetype)initWithFrame:(CGRect)frame
                   normalName:(NSString *)normalName
                 selectedName:(NSString *)selectedName
                        budge:(NSInteger)budge;

@end
