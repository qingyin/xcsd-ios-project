//
//  ShareSelectCell.h
//  TXChatTeacher
//
//  Created by gaoju on 16/11/15.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareSelectCell : UITableViewCell

@property (nonatomic, assign) TXDepartment *department;

@property (nonatomic, assign) TXUser *user;

@property (nonatomic, assign, getter=isCheck) BOOL check;

@end
