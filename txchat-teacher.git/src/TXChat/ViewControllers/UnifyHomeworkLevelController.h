//
//  UnifyHomeworkLevelController.h
//  TXChatTeacher
//
//  Created by gaoju on 16/6/28.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface UnifyHomeworkLevelController : BaseViewController

@property (nonatomic, copy) void (^getSelectedLevels)(NSString *levels);

- (void) setLevels:(NSInteger) levels AndSelectdLevels:(NSString *) selectedLevels remainingHomework:(NSInteger) remainingHomework;

@end
