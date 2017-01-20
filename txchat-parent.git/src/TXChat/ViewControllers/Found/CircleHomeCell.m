//
//  CircleHomeCell.m
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleHomeCell.h"
#import "NSDate+TuXing.h"
#import "UIButton+EMWebCache.h"
#import <UIImageView+Utils.h>
#import "CirclePublishViewController.h"
#import "CircleHomeViewController.h"
#import "CircleDetailViewController.h"
#import "UILabel+ContentSize.h"
#import "CircleUploadCenter.h"
#import "VideoRecordViewController.h"
#import "TXSystemManager.h"
#import "AppDelegate.h"

@implementation CircleHomeCell

- (void)onSendBtn{
    if ([[CircleUploadCenter shareInstance] isForbiddenAddFeed]) {
        [_homeVC showFailedHudWithTitle:@"亲子圈暂不可用"];
        return;
    }
    [_homeVC showNormalSheetWithTitle:nil items:@[@"小视频",@"照片"] clickHandler:^(NSInteger index) {
        if (index == 0) {
            [[TXSystemManager sharedManager] requestCameraAndMicrophonePermissionWithBlock:^(BOOL cameraGranted, BOOL microphoneGranted) {
                TXAsyncRunInMain(^{
                    if (cameraGranted && microphoneGranted) {
                        //已授权
                        VideoRecordViewController *recordVc = [[VideoRecordViewController alloc] init];
                        recordVc.backVc = _homeVC;
                        [_homeVC.navigationController pushViewController:recordVc animated:YES];
                    }else{
                        //未授权
                        [_homeVC showPermissionAlertWithCameraGranted:cameraGranted microphoneGranted:microphoneGranted];
                    }
                });
            }];
        }else if (index == 1) {
            CirclePublishViewController *avc = [[CirclePublishViewController alloc] init];
            [_homeVC.navigationController pushViewController:avc animated:YES];
        }
    } completion:nil];
    //    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"小视频",@"照片", nil];
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    UIView *sheetView;
    //    if (IOS8AFTER) {
    //        sheetView = _homeVC.view;
    //    }else{
    //        sheetView = appDelegate.window.rootViewController.view;
    //    }
    //    [sheet showInView:sheetView withCompletionHandler:^(NSInteger buttonIndex) {
    //        if (buttonIndex == 0) {
    //            [[TXSystemManager sharedManager] requestCameraAndMicrophonePermissionWithBlock:^(BOOL cameraGranted, BOOL microphoneGranted) {
    //                TXAsyncRunInMain(^{
    //                    if (cameraGranted && microphoneGranted) {
    //                        //已授权
    //                        VideoRecordViewController *recordVc = [[VideoRecordViewController alloc] init];
    //                        recordVc.backVc = _homeVC;
    //                        [_homeVC.navigationController pushViewController:recordVc animated:YES];
    //                    }else{
    //                        //未授权
    //                        [_homeVC showPermissionAlertWithCameraGranted:cameraGranted microphoneGranted:microphoneGranted];
    //                    }
    //                });
    //            }];
    //        }else if (buttonIndex == 1) {
    //            CirclePublishViewController *avc = [[CirclePublishViewController alloc] init];
    //            [_homeVC.navigationController pushViewController:avc animated:YES];
    //        }
    //    }];
}

- (void)showDetail:(TXFeed *)feed{
    CircleDetailViewController *avc = [[CircleDetailViewController alloc] init];
    avc.feed = feed;
    avc.presentVC = _homeVC;
    [_homeVC.navigationController pushViewController:avc animated:YES];
}


-(void)setCellContent:(NSArray *)feedArr andUserId:(int64_t)userId{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.contentView.clipsToBounds = YES;
    self.clipsToBounds = YES;
    CGFloat X = 0;
    CGSize daySize = [UILabel contentSizeForLabelWithText:@"22" maxWidth:MAXFLOAT font:[UIFont boldSystemFontOfSize:25.f]];
    CGSize monthSize = [UILabel contentSizeForLabelWithText:@"12月" maxWidth:MAXFLOAT font:[UIFont systemFontOfSize:18.f]];

    if (_isToday) {
        UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        label.text = @"今天";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont boldSystemFontOfSize:25.f];
        label.textColor = kColorBlack;
        [self.contentView addSubview:label];
        label.frame = CGRectMake(10, 9, daySize.width + monthSize.width, daySize.height);
        
        X = label.maxX + 10;
        
    }else{
        if (![feedArr count]) {
            return;
        }
        TXFeed *feed = [feedArr objectAtIndex:0];
        
        NSString *createOn = [NSDate timeForShortStyle:[NSString stringWithFormat:@"%@", @(feed.createdOn/1000)]];
        NSArray *arr = [createOn componentsSeparatedByString:@"-"];
        
        UILabel *monthLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        NSString *tmpMonth = arr[1];
        monthLb.font = [UIFont systemFontOfSize:18.f];
        monthLb.backgroundColor = [UIColor clearColor];
        monthLb.textColor = kColorBlack;
        [self.contentView addSubview:monthLb];
        monthLb.text = [NSString stringWithFormat:@"%@月",[CircleHomeCell getMonth:tmpMonth]];
        [monthLb sizeToFit];
        monthLb.frame = CGRectMake(10 + daySize.width + monthSize.width - monthLb.width_, 8, monthLb.width_, daySize.height);
        
        UILabel *dayLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        dayLb.backgroundColor = [UIColor clearColor];
        dayLb.font = [UIFont boldSystemFontOfSize:25.f];
        dayLb.textColor = kColorBlack;
        dayLb.text = arr[2];
        [self.contentView addSubview:dayLb];
        [dayLb sizeToFit];
        dayLb.frame = CGRectMake(monthLb.minX -  dayLb.width_, 6, dayLb.width_, dayLb.height_);
        
        X = monthLb.maxX + 10;
    }
    
    int width = (kScreenWidth - 78 - 8)/3;
    CGFloat Y = 10;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (_isToday && userId == user.userId) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(X + 5, 0, width, width);
        btn.adjustsImageWhenHighlighted = NO;
        [btn addTarget:self action:@selector(onSendBtn) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"circle_camera"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"circle_camera_1"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:btn];
        
        Y = CGRectGetMaxY(btn.frame) + 10;
        //        X = btn.minX - 5;
    }
    
    for (TXFeed *feed in feedArr) {
        
        CGFloat tmpY = Y;
        NSMutableArray *photoArr = [NSMutableArray array];
        NSString *content = feed.content;
        UILabel *contentLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        contentLb.userInteractionEnabled = YES;
        contentLb.textColor = kColorBlack;
        contentLb.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLb.numberOfLines = 2;
        contentLb.textAlignment = NSTextAlignmentLeft;
        contentLb.font = kFontMiddle;
        contentLb.text = content;
        
        CGSize contentSize;
        
        NSArray *fileKeyList = feed.attaches;
        if (fileKeyList && [fileKeyList count]) {
            
            contentSize = [contentLb sizeThatFits:CGSizeMake(kScreenWidth - X - 94 - (width - 70), width/2)];
            if (contentSize.height > (width/2)) {
                contentSize = CGSizeMake(kScreenWidth - X - 94 - (width - 70), width/2);
            }
            contentLb.frame = CGRectMake(X + 12 + width, Y + 2,contentSize.width , contentSize.height);
            [self.contentView addSubview:contentLb];
            
            if ([fileKeyList count] > 1) {
                
                CGFloat newY = Y;
                for (int i = 0; i < [fileKeyList count]; ++i) {
                    if (i > 3) {
                        UILabel *numLb = [[UILabel alloc] initWithFrame:CGRectZero];
                        numLb.backgroundColor = [UIColor clearColor];
                        numLb.font  = kFontSmall;
                        numLb.textColor = [UIColor grayColor];
                        numLb.text = [NSString stringWithFormat:@"共%d张",(int)[fileKeyList count]];
                        [self.contentView addSubview:numLb];
                        
                        CGSize size = [numLb.text sizeWithFont:numLb.font];
                        numLb.frame = CGRectMake(X + width + 12, newY + width - size.height, size.width, size.height);
                        break;
                    }
                    
                    
                    if ([fileKeyList count] == 2) {
                        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(X + 5 + i%2 * (width/2 + 2), newY, width/2, width);
                        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                        }];
                        TXPBAttach *txAttach = [fileKeyList objectAtIndex:i];
                        NSString *attach = txAttach.fileurl;
                        NSString *imgUrl = [attach getFormatPhotoUrl:width/2 hight:width];
                        btn.backgroundColor = kColorCircleBg;
                        [btn TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil];
                        
                        [photoArr addObject:attach];
                        [self.contentView addSubview:btn];
                        Y = btn.maxY;
                    }else if ([fileKeyList count] == 3){
                        TXPBAttach *txAttach = [fileKeyList objectAtIndex:i];
                        NSString *attach = txAttach.fileurl;
                        UIButton *btn;
                        if (i == 0) {
                            btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(X + 5, newY, width/2, width);
                            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                            NSString *imgUrl = [attach getFormatPhotoUrl:width/2 hight:width];
                            [btn TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil];
                            [photoArr addObject:attach];
                            [self.contentView addSubview:btn];
                            Y = CGRectGetMaxY(btn.frame);
                        }else if (i == 1){
                            btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(X + width/2 + 5 + 2, newY, width/2, width/2);
                            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                            NSString *imgUrl = [attach getFormatPhotoUrl:width/2 hight:width/2];
                            [btn TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil];
                        }else{
                            btn = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn.frame = CGRectMake(X + width/2 + 5 + 2, newY + width/2 + 2, width/2, width/2);
                            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                            NSString *imgUrl = [attach getFormatPhotoUrl:width/2 hight:width/2];
                            [btn TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil];
                        }
                        btn.backgroundColor = kColorCircleBg;
                        [photoArr addObject:attach];
                        [self.contentView addSubview:btn];
                        Y = CGRectGetMaxY(btn.frame);
                    }else {
                        UIButton *btn;
                        btn = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn.frame = CGRectMake(X + 5 + (width/2 + 2) * (i/2), newY + (width/2 + 2) * (i%2), width/2, width/2);
                        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                        }];
                        
                        TXPBAttach *txAttach = [fileKeyList objectAtIndex:i];
                        NSString *attach = txAttach.fileurl;
                        NSString *imgUrl = [attach getFormatPhotoUrl:width/2 hight:width/2];
                        [btn TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil];
                        btn.backgroundColor = kColorCircleBg;
                        [photoArr addObject:attach];
                        [self.contentView addSubview:btn];
                        Y = CGRectGetMaxY(btn.frame);
                    }
                }
                Y += 5;
                
                
            }else{
                TXPBAttach *txAttach = [fileKeyList objectAtIndex:0];
                NSString *attach = txAttach.fileurl;
                [photoArr addObject:attach];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(X + 5, Y, width, width) ;
                btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                }];
                NSString *imgUrl;
                if (txAttach.attachType == TXPBAttachTypeVedio) {
                    //视频文件
                    imgUrl = [attach getFormatVideoUrl:160 hight:120];
                }else{
                    //照片
                    imgUrl = [attach getFormatPhotoUrl:width hight:width];
                }
                [btn TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil];
                btn.backgroundColor = kColorCircleBg;
                [self.contentView addSubview:btn];
                if (txAttach.attachType == TXPBAttachTypeVedio) {
                    //视频半透视图
                    UIView *playBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
                    playBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
                    playBgView.userInteractionEnabled = NO;
                    [btn addSubview:playBgView];
                    //视频播放视图
                    UIImageView *playVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    playVideoView.center = CGPointMake(width / 2, width / 2);
                    playVideoView.backgroundColor = [UIColor clearColor];
                    playVideoView.image = [UIImage imageNamed:@"chat_video_play"];
                    [btn addSubview:playVideoView];
                }
                
                Y = CGRectGetMaxY(btn.frame) + 5;
            }
            
        }else{
            contentSize = [contentLb sizeThatFits:CGSizeMake(kScreenWidth - X - 94, width/2)];
            if (contentSize.height > width/2) {
                contentSize = CGSizeMake(kScreenWidth - X - 94, width/2);
            }
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(X + 5, Y, kScreenWidth - X - 17, contentSize.height + 16)];
            bgView.userInteractionEnabled = NO;
            bgView.backgroundColor = kColorGray3;
            [self.contentView addSubview:bgView];
            
            
            CGSize size =  [contentLb sizeThatFits:CGSizeMake(kScreenWidth - X - 17 - 10, width/2) ];
            if (size.height > width/2) {
                size = CGSizeMake(kScreenWidth - X - 17 - 10, width/2);
            }
            contentLb.frame = CGRectMake(5, 8, size.width, size.height);
            [bgView addSubview:contentLb];
            Y = CGRectGetMaxY(bgView.frame) + 5;
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, tmpY, kScreenWidth, Y - tmpY);
//        __weak typeof(self)tmpObject = self;
        WEAKTEMP
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            [tmpObject showDetail:feed];
        }];
        [self.contentView addSubview:btn];
    }
    
    
    //    UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
    //    lineView.frame = CGRectMake(0, Y + 5 - kLineHeight, kScreenWidth, kLineHeight);
    //    [self.contentView addSubview:lineView];
}

+ (CGFloat)GetHomeCellHeight:(NSArray *)feedArr
                  andIsToday:(BOOL)isToday
                   andUserId:(int64_t)userId{
    
    int width = (kScreenWidth - 78 - 8)/3;
    CGFloat X = 0;
    if (isToday) {
        X = 12 + [UILabel contentSizeForLabelWithText:@"今天" maxWidth:MAXFLOAT font:[UIFont boldSystemFontOfSize:20.f]].width;
        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
        if (!feedArr.count && user.userId != userId) {
            return 0;
        }
    }else{
        if (![feedArr count]) {
            return 0;
        }
        TXFeed *feed = [feedArr objectAtIndex:0];
        
        NSString *createOn = [NSDate timeForShortStyle:[NSString stringWithFormat:@"%@", @(feed.createdOn/1000)]];
        NSArray *arr = [createOn componentsSeparatedByString:@"-"];
        
        CGSize daySize = [UILabel contentSizeForLabelWithText:arr[2] maxWidth:MAXFLOAT font:[UIFont boldSystemFontOfSize:20.f]];
        CGSize monthSize = [UILabel contentSizeForLabelWithText:[NSString stringWithFormat:@"%@月",[CircleHomeCell getMonth:arr[1]]] maxWidth:MAXFLOAT font:[UIFont systemFontOfSize:14.f]];
        X = 12 + daySize.width + monthSize.width;
    }
    
    CGFloat Y = 10;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (isToday && userId == user.userId) {
        Y = width;
        X = width;
    }
    for (TXFeed *feed in feedArr) {
        NSString *content = feed.content;
        CGSize contentSize;
        
        NSArray *fileKeyList = feed.attaches;
        if (fileKeyList && [fileKeyList count]) {
            contentSize = [content sizeWithFont:kFontMiddle constrainedToSize:CGSizeMake(kScreenWidth - X - 94 - (width - 70), width/2)];
            if ([fileKeyList count] > 1) {
                CGFloat newY = Y;
                for (int i = 0; i < [fileKeyList count]; ++i) {
                    if (i > 3) {
                        break;
                    }
                    if ([fileKeyList count] == 2) {
                        Y = newY + width;
                    }else if ([fileKeyList count] == 3){
                        if (i == 0) {
                            Y = newY + width;
                        }else if (i == 1){
                            Y = newY + width/2;
                        }else{
                            Y = newY + width/2 + 2+ width/2;
                        }
                    }else {
                        Y = newY + (width/2 + 2) * (i%2) + width/2;
                    }
                }
                Y += 5;
            }else{
                Y = (Y + width + 5);
            }
        }else{
            contentSize = [content sizeWithFont:kFontMiddle constrainedToSize:CGSizeMake(kScreenWidth - X - 94, 35)];
            Y = Y + contentSize.height + 16 + 5;
        }
    }
    
    return Y + 10 - kLineHeight;
}

+ (NSString *)getMonth:(NSString *)month{
    if ([month hasPrefix:@"0"]) {
        return [month substringFromIndex:1];
    }
    return month;
//    if ([month isEqualToString:@"01"]) {
//        return @"一";
//    }else if ([month isEqualToString:@"02"]){
//        return @"二";
//    }else if ([month isEqualToString:@"02"]){
//        return @"二";
//    }else if ([month isEqualToString:@"02"]){
//        return @"二";
//    }else if ([month isEqualToString:@"03"]){
//        return @"三";
//    }else if ([month isEqualToString:@"04"]){
//        return @"四";
//    }else if ([month isEqualToString:@"05"]){
//        return @"五";
//    }else if ([month isEqualToString:@"06"]){
//        return @"六";
//    }else if ([month isEqualToString:@"07"]){
//        return @"七";
//    }else if ([month isEqualToString:@"08"]){
//        return @"八";
//    }else if ([month isEqualToString:@"09"]){
//        return @"九";
//    }else if ([month isEqualToString:@"10"]){
//        return @"十";
//    }else if ([month isEqualToString:@"11"]){
//        return @"十一";
//    }else if ([month isEqualToString:@"12"]){
//        return @"十二";
//    }
//    return @"";
}

@end
