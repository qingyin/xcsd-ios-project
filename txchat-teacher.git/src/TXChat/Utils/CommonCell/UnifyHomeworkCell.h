//
//  UnifyHomeworkCell.h
//  TXChatTeacher
//
//  Created by gaoju on 16/6/27.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCSDPBGameListResponseGame;

@interface UnifyHomeworkCell : UITableViewCell

@property (nonatomic, copy) UnifyHomeworkCell *(^setGame)(XCSDPBGameListResponseGame *game);

@property (nonatomic, copy) UnifyHomeworkCell *(^setText)(NSString *text);

@property (nonatomic, copy) NSString *(^getText)();

@property (nonatomic, copy) UnifyHomeworkCell *(^setCustomBackgroundColor)();

@property (nonatomic, copy) UnifyHomeworkCell *(^clearCustomBackgroundColor)();


@end
