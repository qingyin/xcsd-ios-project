//
//  CircleHomeCell.h
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleHomeViewController;

@interface CircleHomeCell : UITableViewCell
@property (nonatomic, assign) BOOL isToday;
@property (nonatomic, assign) CircleHomeViewController *homeVC;

-(void)setCellContent:(NSArray *)feedArr andUserId:(int64_t)userId;

+ (CGFloat)GetHomeCellHeight:(NSArray *)feedArr
                  andIsToday:(BOOL)isToday
                   andUserId:(int64_t)userId;
@end
