//
//  HomeworkDetailCell.h
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCSDPBGameLevel;

@interface HomeworkDetailCell : UITableViewCell

@property (nonatomic, copy) void (^setData)(XCSDPBGameLevel *data,XCSDHomeWork *homework);

@end

@interface HomeworkStarsView : UIView

@property (nonatomic,assign) NSInteger numOfStars;

@end
