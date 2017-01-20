//
//  CirclePublishViewController.h
//  TXChat
//
//  Created by Cloud on 15/7/6.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface CirclePublishViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *departmentIds;
@property (nonatomic, strong) UILabel *rcvUsersLabel;//接收者名字
//上传的是视频类型，默认为NO
@property (nonatomic) BOOL videoType;
@property (nonatomic) NSURL *videoURL;
@property (nonatomic, strong) UIImage *videoThumbImage;
@property (nonatomic, weak) UIViewController *videoBackVc;

@property (nonatomic, strong) NSMutableArray *photoItemsArr;

@end
