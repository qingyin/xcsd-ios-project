//
//  CircleListOtherCell.h
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXFeed+Circle.h"

#define kDeleteBtnMargin 10

@protocol MoreViewDelegate <NSObject>

- (void)onFeedLikeResponse:(id)feed andIsLike:(BOOL)isLike;
- (void)onFeedDeleteResponse:(id)feed;
- (void)onFeedCommentAddResponse:(id)feed
                  andPlaceholder:(NSString *)placeholder
                     andToUserId:(NSNumber *)toUserId
                   andToUserName:(NSString *)toUserName;

@end

@interface MoreView : UIView<UIAlertViewDelegate>

@property (nonatomic, assign) float viewWidth;
@property (nonatomic, strong) UIButton *loveBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *timeLabel;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) BOOL showMore;
@property (nonatomic, strong) id feed;
@property (nonatomic, weak) id<MoreViewDelegate>delegate;

- (void)onHideMoreView;

@end

@class CircleListViewController;

@interface CircleListOtherCell : UITableViewCell

@property (nonatomic, strong) TXFeed *feed;
@property (nonatomic, weak) CircleListViewController *listVC;

+ (CGFloat)GetListOtherCellHeight:(TXFeed *)feed;

@end
