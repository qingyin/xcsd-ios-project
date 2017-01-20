//
//  HomeworkDetailCell.h
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCSDHomeWork.h"

@class XCSDPBGameLevel;

@interface HomeworkDetailCell : UITableViewCell

//@property (nonatomic, copy) void (^setData)(XCSDPBGameLevel *data);

@property (nonatomic, copy) HomeworkDetailCell *(^setData)(XCSDPBGameLevel *gameLevel);

@property (nonatomic, copy) HomeworkDetailCell *(^showStarsView)(BOOL showStarsView);

@end

@interface HomeworkStarsView : UIView

@property (nonatomic,assign) NSInteger numOfStars;

@end
