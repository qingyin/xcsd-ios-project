//
//  TXPBFeed+Circle.m
//  TXChat
//
//  Created by Cloud on 15/7/6.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXFeed+Circle.h"

static void *IsFoldKey = (void *)@"IsFoldKey";
static void *LikeLbKey = (void *)@"LikeLbKey";
static void *CommentLbArrKey = (void *)"CommentLbArr";
static void *CircleLikesKey = (void *)"CircleLikes";
static void *CircleCommentsKey = (void *)"CircleComments";
static void *CircleHeightKey = (void *)"CircleHeight";
static void *ContentLbHeight = (void *)"contentLbHeight";
static void *HasMore = (void *)"HasMore";



@implementation TXFeed (Circle)

- (NSNumber *)hasMore{
    return objc_getAssociatedObject(self, HasMore);
}

- (void)setHasMore:(NSNumber *)hasMore{
    objc_setAssociatedObject(self, HasMore, hasMore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)contentLbHeight{
    return objc_getAssociatedObject(self, ContentLbHeight);
}

- (void)setContentLbHeight:(NSNumber *)contentLbHeight{
    objc_setAssociatedObject(self, ContentLbHeight, contentLbHeight, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)height{
    return objc_getAssociatedObject(self, CircleHeightKey);
}

- (void)setHeight:(NSNumber *)height{
    objc_setAssociatedObject(self, CircleHeightKey, height, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)isFold{
    return objc_getAssociatedObject(self, IsFoldKey);
}

- (void)setIsFold:(NSNumber *)isFold{
    objc_setAssociatedObject(self, IsFoldKey, isFold, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NIAttributedLabel *)likeLb{
    return objc_getAssociatedObject(self, LikeLbKey);
}

- (void)setLikeLb:(NIAttributedLabel *)likeLb{
    objc_setAssociatedObject(self, LikeLbKey, likeLb, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)commentLbArr{
    return objc_getAssociatedObject(self, CommentLbArrKey);
}

- (void)setCommentLbArr:(NSMutableArray *)commentLbArr{
    objc_setAssociatedObject(self, CommentLbArrKey, commentLbArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)circleLikes{
    return objc_getAssociatedObject(self, CircleLikesKey);
}

- (void)setCircleLikes:(NSMutableArray *)circleLikes{
    objc_setAssociatedObject(self, CircleLikesKey, circleLikes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)circleComments{
    return objc_getAssociatedObject(self, CircleCommentsKey);
}

- (void)setCircleComments:(NSMutableArray *)circleComments{
    objc_setAssociatedObject(self, CircleCommentsKey, circleComments, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
