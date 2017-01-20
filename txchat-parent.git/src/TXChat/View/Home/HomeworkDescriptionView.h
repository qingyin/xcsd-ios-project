//
//  HomeworkDescriptionView.h
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCSDPBHomeworkDetailResponse;

@interface HomeworkDescriptionView : UIView

@property (nonatomic, copy) HomeworkDescriptionView *(^setData)(XCSDPBHomeworkDetailResponse *homework);

@property (nonatomic, copy) CGFloat (^getHeight)();

@end
