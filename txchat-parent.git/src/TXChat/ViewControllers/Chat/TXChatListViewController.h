//
//  TXChatListViewController.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXChatConversationData.h"
#import "BaseViewController.h"

@protocol TXChatListDataSource <NSObject>

@required
- (NSInteger)numberOfRowsInChatConversations;
- (id<TXChatConversationData>)conversationDataForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)canEditChatConversationsRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forChatConversationsRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol TXChatListDelegate <NSObject>

@optional
- (void)didSelectChatConversationAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForDeleteConfirmationButtonForChatConversationsRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TXChatListViewController : BaseViewController

@property (nonatomic,weak) id<TXChatListDataSource> dataSource;
@property (nonatomic,weak) id<TXChatListDelegate> delegate;
@property (nonatomic,strong) UITableView *tableView;

//无聊天列表时的背景图，子类可继承自定义
- (UIView *)backgroundViewForNoChatList;
//重新刷新视图
- (void)reloadChatList;
//设置网络状态是否显示
- (void)updateNetworkStateViewVisible:(NSNumber *)isVisible;

//触发下拉刷新的响应方法
- (void)triggleHeaderRefreshing;

//结束下拉刷新
- (void)endHeaderRefreshing;

@end
