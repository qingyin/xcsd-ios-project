//
//  TXPBResource+Utils.h
//  TXChatParent
//
//  Created by lyt on 16/1/20.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <TXChatSDK/TXChatSDK.h>

@interface TXPBResource (Utils)
/**
 *  变更点赞数据
 *
 *  @param likedNumber 变更的点赞数据数
 */
-(void)addLikedNumber:(int64_t)likedNumber;
/**
 *  获取点赞数据
 *
 *  @return 当前的点赞数
 */
-(int64_t)getLikedNumber;

/**
 *  是否被自己点赞
 *
 *  @return 是否被自己点赞
 */
-(BOOL)isLiked;

/**
 *  增加查看次数
 *
 *  @param viewedNumber 增加的查看次数
 */
-(void)addViewedNumber:(int64_t)viewedNumber;

/**
 *  当前的查看次数
 *
 *  @return 查看次数
 */
-(int64_t)getViewedNumber;

@end
