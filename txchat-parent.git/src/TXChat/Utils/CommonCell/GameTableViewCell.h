//
//  GameTableViewCell.h
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^setData)(id data);
//@property (nonatomic, copy) GameTableViewCell *(^setData)(id data);

//- (GameTableViewCell *(^)(id data)) setData2;

@end
