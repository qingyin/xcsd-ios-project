//
//  CircleUploadCenter.h
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleUploadCenter : NSObject

@property (nonatomic, strong) NSMutableArray *uploadArr;
@property (nonatomic, assign) BOOL isUploading;

+ (instancetype)shareInstance;

//是否禁言
- (BOOL)isForbiddenAddFeed;

//发布亲子圈
- (void)sendFeed:(NSString *)content attaches:(NSMutableArray *)attaches departmentIds:(NSArray *)departmentIds;
//刷新亲子圈上传图片
- (void)refreshAttaches:(NSString *)serverFileKey andFile:(NSString *)serverFile;

@end
