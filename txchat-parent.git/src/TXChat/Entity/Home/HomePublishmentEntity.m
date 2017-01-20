//
//  HomePublishmentEntity.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "HomePublishmentEntity.h"
#import "NSDate+TuXing.h"

@implementation HomePublishmentEntity

- (instancetype)initWithPBPost:(TXPost *)post
{
    if (!post) {
        return nil;
    }
    self = [super init];
    if (self) {
        _title = [NSString stringWithFormat:@"%@",post.title];
        _descriptionString = [NSString stringWithFormat:@"%@",post.summary];
        _imageUrlString = [NSString stringWithFormat:@"%@",post.coverImageUrl];
        _postId = post.postId;
        NSString *timeStampString = [NSString stringWithFormat:@"%@",@(post.createdOn / 1000)];
        _timeString = [NSDate timeForChatListStyle:timeStampString];
        _postUrl = [NSString stringWithFormat:@"%@",post.postUrl];
        //是否已读
        _isRead = post.isRead;
        //计算高度并缓存
        [self calculateRowHeight];
    }
    return self;
}
//计算高度
- (void)calculateRowHeight
{
//    //标题高度
//    CGFloat titleHeight = 35;
//    CGFloat descriptionHeight = 25;
//    CGFloat timeHeight = 25;
//    _rowHeight = titleHeight + descriptionHeight + timeHeight;
    _rowHeight = 94;
}
- (void)setIsHideImage:(BOOL)isHideImage
{
    _isHideImage = isHideImage;
    //去掉图片
    if (_isHideImage) {
        _imageUrlString = @"";
    }
}
- (void)setIsRead:(BOOL)isRead
{
    if (_isRead) {
        //已经是已读状态，忽略
        return;
    }
    _isRead = isRead;
    //保存到数据库
    [[TXChatClient sharedInstance].postManager markPostAsReadWithPostId:_postId];
}
@end
