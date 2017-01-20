//
//  ReadUserListView.h
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadUserListView : UIView

@property(nonatomic, strong)NSArray *userList;

-(id)initWithReadStatus:(BOOL)isRead;

-(void)setupSubViews;
@end
