//
//  HomePublishmentEntity.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomePublishmentEntity : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *descriptionString;
@property (nonatomic,copy) NSString *imageUrlString;
@property (nonatomic,copy) NSString *postUrl;
@property (nonatomic) SInt64 postId;
@property (nonatomic,copy) NSString *timeString;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) BOOL isHideImage;
@property (nonatomic) BOOL isRead;

- (instancetype)initWithPBPost:(TXPost *)post;

@end
