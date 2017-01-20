//
//  CircleListViewController.h
//  TXChat
//
//  Created by Cloud on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "EventViewController.h"

@class NIAttributedLabel;

@interface CircleListViewController : EventViewController

/**
 *  是不是显示新消息提示
 */
@property (nonatomic, assign) BOOL isShowNews;

/**
 *  刷新列表
 */
- (void)reloadData;

/**
 *  删除评论
 *
 *  @param feed        当前评论所在feed
 *  @param feedComment 当前评论
 */
- (void)onFeedCommentDeleteResponse:(TXFeed *)feed andComment:(id)feedComment;

/**
 *  添加新评论
 *
 *  @param feed        当前操作的feed
 *  @param placeholder 如果是回复某人的评论，需要把评论人带过来（回复：XXX）
 *  @param toUserId    被回复人的id
 *  @param toUserName  被回复人的名字
 */
- (void)onFeedCommentAddResponse:(TXFeed *)feed
                  andPlaceholder:(NSString *)placeholder
                     andToUserId:(NSNumber *)toUserId
                   andToUserName:(NSString *)toUserName;

//播放视频
- (void)playVideoWithURLString:(NSString *)urlString
       thumbnailImageURLString:(NSString *)imageUrlString;

/**
 *  亲子圈点击图片显示大图
 *
 *  @param arr   图片列表
 *  @param index 需要展示的图片的index
 */
- (void)showPhotoView:(NSArray *)arr andIndex:(int)index;

/**
 *  创建赞的列表，目的是为了避免每次滚动tableview都要重绘赞和评论，导致页面卡顿
 *
 *  @param likeList 赞的列表
 *
 *  @return 可点击名字的label
 */
+ (NIAttributedLabel *)getNIAttributedLabelWith:(NSArray *)likeList;

/**
 *  创建评论的列表，目的是为了避免每次滚动tableview都要重绘赞和评论，导致页面卡顿
 *
 *  @param feed 当前feed
 *
 *  @return 返回评论列表
 */
+ (NSMutableArray *)getAttrobuteLabelArr:(TXFeed *)feed;

/**
 *  展示删除或者回复的选择sheet
 *
 *  @param block 点击的回调,0是回复，1是删除
 */
- (void)showFeedDeleteOrAddChooseSheetWithCompletion:(void(^)(NSInteger index))block;

//删除feed的评论
- (void)deleteCommentWithFeed:(TXFeed *)feed andComment:(id)feedComment;

@end
