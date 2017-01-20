//
//  TXFeed+Circle.h
//  TXChat
//
//  Created by Cloud on 15/7/6.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NIAttributedLabel.h"
#import "MLEmojiLabel.h"

@interface TXFeed (Circle)

@property (nonatomic) NSNumber *isFold;
@property (nonatomic) NIAttributedLabel *likeLb;
@property (nonatomic) NSMutableArray *commentLbArr;
@property (nonatomic) NSMutableArray *circleLikes;
@property (nonatomic) NSMutableArray *circleComments;
@property (nonatomic) NSNumber *height;
@property (nonatomic) NSNumber *contentLbHeight;
@property (nonatomic) NSNumber *hasMore;//有没有更多地评论


@end
