//
//  CircleDetailViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleDetailViewController.h"
#import "HTCopyableLabel.h"
#import "CircleListOtherCell.h"
#import <UIImageView+Utils.h>
#import "UIImageView+EMWebCache.h"
#import "UIButton+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "CircleHomeViewController.h"
#import "TXMessageInputView.h"
#import "UILabel+ContentSize.h"
#import "TXPhotoBrowserViewController.h"
#import "TXFeed+Circle.h"
#import "UILabel+ContentSize.h"
#import "MJRefresh.h"
#import "CircleUploadCenter.h"
#import "TXVideoPreviewViewController.h"
#import "TXVideoCacheManager.h"
#import "CircleVideoView.h"
#import "NSMutableAttributedString+NimbusKitAttributedLabel.h"
#import "PublishmentDetailViewController.h"

#define kCommentImgBaseTag          231231

@interface CircleDetailViewController ()<
MoreViewDelegate,
XHMessageInputViewDelegate,
UIGestureRecognizerDelegate,
UITableViewDataSource,
UITableViewDelegate,
MLEmojiLabelDelegate,
NIAttributedLabelDelegate>
{
    UIView *_photoView;
    UIImageView *_likesView;
    CGFloat _contentHeight;
}

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) MoreView *moreView;
@property (nonatomic, strong) TXMessageInputView *msgInputView;
@property (nonatomic, strong) TXFeed *currentFeed;
@property (nonatomic, strong) NSString *currentToUserName;
@property (nonatomic, strong) NSNumber *currentToUserId;
@property (nonatomic, strong) NSArray *photoArr;

@end

@implementation CircleDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
    self.msgInputView.associatedScrollView = _listTableView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = kColorWhite;
    self.titleStr = @"详情";
    [self createCustomNavBar];
    
    _contentHeight = 0;
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.customNavigationView.maxY,self.view.width_ ,self.view.height_ - self.customNavigationView.maxY - 10) style:UITableViewStylePlain];
    _listTableView.backgroundColor = [UIColor clearColor];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.showsVerticalScrollIndicator = YES;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    tapGesture.delegate = self;
    [_listTableView addGestureRecognizer:tapGesture];
    
    [self setupChatToolBarView];
    
    if (!_feed.circleComments || !_feed.circleLikes) {
        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
        [self fetchComments];
    }
    
    if (_feed.hasMore.boolValue) {
        [self setupRefresh];
    }
}

//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _listTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
}

- (void)footerRereshing{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [self fetchComments];
}

- (void)fetchComments{
    int64_t maxCommentId;
    if (!_feed.circleComments) {
        maxCommentId = LLONG_MAX;
    }else if ([_feed.circleComments.lastObject isKindOfClass:[NSMutableDictionary class]]) {
        NSDictionary *dic = _feed.circleComments.lastObject;
        NSNumber *num = dic[@"commentId"];
        maxCommentId = num.integerValue;
    }else{
        TXComment *comment = _feed.circleComments.lastObject;
        maxCommentId = comment.commentId;
    }
    DDLogDebug(@"fetchCommentsByTargetId");
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] fetchCommentsByTargetId:_feed.feedId targetType:TXPBTargetTypeFeed maxCommentId:maxCommentId onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        [tmpObject.listTableView.footer endRefreshing];
        if (!error) {
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"commentType == %d",TXPBCommentTypeReply];
            NSArray *arr = [comments filteredArrayUsingPredicate:pre];
            if (!tmpObject.feed.circleLikes) {
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"commentType == %d",TXPBCommentTypeLike];
                NSArray *arr = [comments filteredArrayUsingPredicate:pre];
                tmpObject.feed.circleLikes = [NSMutableArray arrayWithArray:arr];
            }
            if (!hasMore) {
                [tmpObject.listTableView.footer noticeNoMoreData];
            }
            if (!tmpObject.feed.circleComments) {
                tmpObject.feed.circleComments = [NSMutableArray array];
            }
            [tmpObject.feed.circleComments addObjectsFromArray:arr];
            [tmpObject.listTableView reloadData];
        }
    }];
}

//创建聊天工具栏视图
- (void)setupChatToolBarView
{
    // 设置Message TableView 的bottom edg
    [self setTableViewInsetsWithBottomValue:kChatToolBarHeight];
    
    _msgInputView = [[TXMessageInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), kChatToolBarHeight)];
    _msgInputView.delegate = self;
    _msgInputView.associatedScrollView = _listTableView;;
    _msgInputView.contentViewController = self;
    _msgInputView.shouldShowInputViewWhenFinished = NO;
    [_msgInputView setupView];
    [self.view addSubview:_msgInputView];
    [self.view bringSubviewToFront:_msgInputView];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[NIAttributedLabel class]] ||
       [touch.view isKindOfClass:[MLEmojiLabel class]] ||
       [touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    //tag为100的view是评论cell的按钮，改为可响应
    if ([touch.view isKindOfClass:[UIButton class]] || touch.view.tag == 100) {
        return NO;
    }
    return YES;
}


- (void)onTapGesture:(UIGestureRecognizer *)gesture{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideMoreView object:nil];
    [self.msgInputView endEdit];
}

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    //    UIEdgeInsets insets = UIEdgeInsetsZero;
    //    insets.bottom = bottom;
    //    _listTableView.contentInset = insets;
    //    _listTableView.scrollIndicatorInsets = insets;
}
/**
 *  展示删除或者回复的选择sheet
 *
 *  @param block 点击的回调,0是回复，1是删除
 */
- (void)showCommentDeleteOrAddChooseSheetWithCompletion:(void(^)(NSInteger index))block
{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",@"删除", nil];
//    [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//        block(buttonIndex);
//    }];
    [self showNormalSheetWithTitle:nil items:@[@"回复",@"删除"] clickHandler:^(NSInteger index) {
        block(index);
    } completion:nil];
}
//添加评论
- (void)onFeedCommentAddResponse:(TXFeed *)feed
                  andPlaceholder:(NSString *)placeholder
                     andToUserId:(NSNumber *)toUserId
                   andToUserName:(NSString *)toUserName{
    if ([CircleUploadCenter shareInstance].isForbiddenAddFeed) {
        //已禁言
        [self showFailedHudWithTitle:@"亲子圈暂不可用"];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideMoreView object:nil];
    if (placeholder && placeholder.length) {
        self.msgInputView.inputTextView.placeHolder = placeholder;
        _currentToUserId = toUserId;
        _currentToUserName = toUserName;
    }else{
        _currentToUserId = nil;
        _currentToUserName = nil;
        self.msgInputView.inputTextView.placeHolder = @"";
    }
    [self.msgInputView.inputTextView becomeFirstResponder];
    
    _currentFeed = feed;
}
//删除feed的评论
- (void)deleteCommentWithFeed:(TXFeed *)feed andComment:(id)feedComment
{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    int64_t commentId;
    if ([feedComment isKindOfClass:[NSMutableDictionary class]]) {
        NSDictionary *dic = feedComment;
        NSNumber *num = dic[@"commentId"];
        commentId = num.integerValue;
    }else{
        TXComment *comment = feedComment;
        commentId = comment.commentId;
    }
    
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] deleteComment:commentId onCompleted:^(NSError *error) {
        if (error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:NO];
            [tmpObject showFailedHudWithError:error];
        }else{
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            [feed.circleComments removeObject:feedComment];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tmpObject.listTableView reloadData];
                [tmpObject.msgInputView endEdit];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:feed];
            });
        }
    }];
}
//删除评论
- (void)onFeedCommentDeleteResponse:(TXFeed *)feed andComment:(id)feedComment{
    [self.view endEditing:YES];
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
//    
//    [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//        if (!buttonIndex) {
//            [self deleteCommentWithFeed:feed andComment:feedComment];
//        }
//    }];
    [self showNormalSheetWithTitle:nil items:@[@"删除"] clickHandler:^(NSInteger index) {
        if (index == 0) {
            [self deleteCommentWithFeed:feed andComment:feedComment];
        }
    } completion:nil];
}

- (void)sendComment:(NSString *)comment{
    if ([CircleUploadCenter shareInstance].isForbiddenAddFeed) {
        //已禁言
        [self showFailedHudWithTitle:@"亲子圈暂不可用"];
        return;
    }
    [_moreView onHideMoreView];
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] sendComment:comment commentType:TXPBCommentTypeReply toUserId:_currentToUserId?_currentToUserId.integerValue:0 targetId:_currentFeed.feedId targetType:TXPBTargetTypeFeed onCompleted:^(NSError *error, int64_t commentId) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }else{
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:comment forKey:@"comment"];
            [dic setValue:@(commentId) forKey:@"commentId"];
            [dic setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"time"];
            if (tmpObject.currentToUserName) {
                [dic setValue:_currentToUserId forKey:@"userId"];
                [dic setValue:_currentToUserName forKey:@"userName"];
            }
            [tmpObject.currentFeed.circleComments addObject:dic];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [tmpObject.listTableView reloadData];
                [tmpObject.msgInputView endEdit];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:tmpObject.currentFeed];
            });
        }
    }];
    
}



- (void)createLikesView{
    [_likesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *likeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle_like"]];
    likeImgView.frame = CGRectMake(6, 20, 12, 12);
    [_likesView addSubview:likeImgView];
    
    __block UIButton *tmpBtn = nil;
    __block CGFloat X = likeImgView.maxX + 8;
    __block CGFloat Y = 10.5;
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    [_feed.circleLikes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *urlStr = nil;
        int64_t userId = 0;
        NSString *nickName = nil;
        if ([obj isKindOfClass:[TXComment class]]) {
            TXComment *feed = obj;
            urlStr = feed.userAvatarUrl;
            userId = feed.userId;
            nickName = feed.userNickname;
        }else{
            urlStr = user.avatarUrl;
            userId = user.userId;
            nickName = user.nickname;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 2.f;
        [btn setBackgroundImage:[UIImage imageNamed:@"userDefaultIcon"] forState:UIControlStateNormal];
        btn.layer.masksToBounds = YES;
        [_likesView addSubview:btn];
        [btn TX_setImageWithURL:[NSURL URLWithString:[urlStr getFormatPhotoUrl:30 hight:30]] forState:UIControlStateNormal placeholderImage:nil];
        [_likesView addSubview:btn];
        btn.frame = CGRectMake(X, Y, 30, 30);
        __weak typeof(self)tmpObject = self;
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
            avc.userId = userId;
            avc.nickName = nickName;
            avc.portraitUrl = urlStr;
            [tmpObject.navigationController pushViewController:avc animated:YES];
        }];
        
        X += 37;
        
        if (X + 37 >= (kScreenWidth - 73)) {
            X = likeImgView.maxX + 8;
            Y += 37;
        }
        
        tmpBtn = btn;
    }];
    if (tmpBtn) {
        _likesView.frame = CGRectMake(60, 0, kScreenWidth - 73, tmpBtn.maxY + 7);
    }else{
        _likesView.frame = CGRectMake(60, 0, kScreenWidth - 73, 0);
    }
    
    if (_feed.circleComments.count) {
        [_likesView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, _likesView.maxY - kLineHeight, _likesView.width_, kLineHeight)]];
    }
}

- (void)createPhotoView:(HTCopyableLabel *)contentLb{
    //照片墙
    NSInteger count = _feed.attaches.count;
    __block CGFloat Y = 0;
    __weak typeof(self)tmpObject = self;
    int width = (kScreenWidth - 78 - 10)/3;
    [_feed.attaches enumerateObjectsUsingBlock:^(TXPBAttach *attach, NSUInteger idx, BOOL *stop) {
        if (count == 1) {
            UIButton *photoImgView;
            NSString *imgStr;
            BOOL isVideo = NO;
            TXPBAttachType attachType = attach.attachType;
            int width = (kScreenWidth - 78)/3 * 2;
            int height = width * 3 /4;
            if (attachType == TXPBAttachTypeVedio) {
                //视频文件
                isVideo = YES;
                imgStr = [attach.fileurl getFormatVideoUrl:width hight:height];
                photoImgView = [[CircleVideoView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
            }else{
                //照片
                imgStr = [attach.fileurl getFormatPhotoUrl:width hight:height];
                photoImgView = [UIButton buttonWithType:UIButtonTypeCustom];
                photoImgView.frame = CGRectMake(0, 0, width, height);
            }
            photoImgView.backgroundColor = kColorCircleBg;
            [photoImgView TX_setImageWithURL:[NSURL URLWithString:imgStr] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_320x240"] forState:UIControlStateNormal];
                }
            }];
            [_photoView addSubview:photoImgView];
            [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                if (isVideo) {
                    [tmpObject playVideoWithURLString:attach.fileurl thumbnailImageURLString:imgStr];
                }else{
                    [tmpObject showPhotoView:_feed.attaches andIndex:(int)idx];
                }
            }];
            
            Y = photoImgView.maxY;
        }else if (count == 4 || count == 1){
            int width = (kScreenWidth - 78 - 5)/2;
            UIButton *photoImgView = [UIButton buttonWithType:UIButtonTypeCustom];
            photoImgView.frame = CGRectMake(idx%2 * (width + 5), idx/2 * (width + 5), width, width);
            photoImgView.backgroundColor = kColorCircleBg;
            [photoImgView TX_setImageWithURL:[NSURL URLWithString:[attach.fileurl getFormatPhotoUrl:width hight:width]] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_148x148"] forState:UIControlStateNormal];
                }
            }];
            [_photoView addSubview:photoImgView];
            [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [tmpObject showPhotoView:_feed.attaches andIndex:(int)idx];
            }];
            
            Y = photoImgView.maxY;
        }else{
            UIButton *photoImgView = [UIButton buttonWithType:UIButtonTypeCustom];
            photoImgView.frame = CGRectMake(idx%3 * (width + 5), idx/3 * (width + 5), width, width);
            photoImgView.backgroundColor = kColorCircleBg;
            [photoImgView TX_setImageWithURL:[NSURL URLWithString:[attach.fileurl getFormatPhotoUrl:width hight:width]] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_148x148"] forState:UIControlStateNormal];
                }
            }];
            [_photoView addSubview:photoImgView];
            [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [tmpObject showPhotoView:_feed.attaches andIndex:(int)idx];
            }];
            
            Y = photoImgView.maxY;
        }
    }];
    if (contentLb.maxY > 53) {
        _photoView.frame = CGRectMake(contentLb.minX, contentLb.maxY + 13, self.view.width_ - 78, Y);
    }else{
        _photoView.frame = CGRectMake(contentLb.minX, 63, self.view.width_ - 78, Y);
    }
}

//播放视频
- (void)playVideoWithURLString:(NSString *)urlString
       thumbnailImageURLString:(NSString *)imageUrlString
{
    TXVideoPreviewViewController *videoVc = [[TXVideoPreviewViewController alloc] initWithVideoURLString:urlString];
    videoVc.mustCachedFirst = YES;
    videoVc.thumbImageURLString = imageUrlString;
    videoVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:videoVc animated:YES completion:nil];
}
//展示图片
- (void)showPhotoView:(NSArray *)arr andIndex:(int)index
{
    NSMutableArray *tmpArr = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(NSString *attach, NSUInteger idx, BOOL *stop) {
        [tmpArr addObject:attach];
    }];
    self.photoArr = tmpArr;
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:tmpArr currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onFeedLikeResponse:(TXFeed *)feed andIsLike:(BOOL)isLike{
//    if ([CircleUploadCenter shareInstance].isForbiddenAddFeed) {
//        //已禁言
//        [self showFailedHudWithTitle:@"亲子圈暂不可用"];
//        return;
//    }
    [self.msgInputView endEdit];
    [_moreView onHideMoreView];
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    __weak typeof(self)tmpObject = self;
    if (isLike) {
        //点赞
        [[TXChatClient sharedInstance] sendComment:nil commentType:TXPBCommentTypeLike toUserId:feed.userId targetId:feed.feedId targetType:TXPBTargetTypeFeed onCompleted:^(NSError *error, int64_t commentId) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [tmpObject showFailedHudWithError:error];
            }else{
                if (feed.circleLikes.count) {
                    [feed.circleLikes insertObject:@(commentId) atIndex:0];
                }else{
                    feed.circleLikes = [NSMutableArray array];
                    [feed.circleLikes addObject:@(commentId)];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tmpObject.listTableView reloadData];
                    tmpObject.moreView.loveBtn.selected = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:feed];
                });
            }
        }];
        
    }else{
        
        BOOL isMine = NO;
        int64_t commentId;
        if (feed.circleLikes.count && [feed.circleLikes[0] isKindOfClass:[NSNumber class]]) {
            isMine = YES;
            NSNumber *tmpCommentId = feed.circleLikes[0];
            commentId = tmpCommentId.integerValue;
        }else{
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
            NSArray *arr1 = [feed.circleLikes filteredArrayUsingPredicate:predicate1];
            if (arr1.count) {
                TXPBLike *like = arr1[0];
                commentId = like.commentId;
            }else{
                [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
                return;
            }
        }
        
        [[TXChatClient sharedInstance] deleteComment:commentId onCompleted:^(NSError *error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                //                [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
                [tmpObject showFailedHudWithError:error];
            }else{
                if (isMine) {
                    [feed.circleLikes removeObjectAtIndex:0];
                }else{
                    
                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
                    NSArray *arr1 = [feed.circleLikes filteredArrayUsingPredicate:predicate1];
                    if (arr1.count) {
                        [feed.circleLikes removeObject:arr1[0]];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tmpObject.listTableView reloadData];
                    tmpObject.moreView.loveBtn.selected = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:feed];
                });
            }
        }];
    }
}

- (void)onFeedDeleteResponse:(TXFeed *)feed{
    [self.msgInputView endEdit];
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] deleteFeed:feed.feedId onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }else{
            __block BOOL found = NO;
            __block NSMutableArray *tmpArr = nil;
            if ([tmpObject.presentVC isKindOfClass:[CircleHomeViewController class]]) {
                CircleHomeViewController *homeVC = (CircleHomeViewController *)tmpObject.presentVC;
                [homeVC.dataArr enumerateObjectsUsingBlock:^(NSMutableArray *arr, NSUInteger idx, BOOL *stop) {
                    if ([arr containsObject:feed]) {
                        [arr removeObject:feed];
                        found = YES;
                        if (!arr.count) {
                            tmpArr = arr;
                        }
                        *stop = YES;
                    }
                }];
                if (tmpArr) {
                    [homeVC.dataArr removeObject:tmpArr];
                }
                if (!found && [homeVC.todayArr containsObject:feed]) {
                    [homeVC.todayArr removeObject:feed];
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([tmpObject.presentVC isKindOfClass:[CircleHomeViewController class]]) {
                    CircleHomeViewController *homeVC = (CircleHomeViewController *)tmpObject.presentVC;
                    [homeVC.listTableView reloadData];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:@{@"feed":feed}];
                [tmpObject.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

#pragma mark - TXMessageEmotionViewDelegate methods
//发送表情
- (void)sendEmotionText:(NSString *)text
{
    if (text.length > 0) {
        self.msgInputView.inputTextView.text = @"";
        [self sendComment:text];
        [self.msgInputView.inputTextView resignFirstResponder];
    }
}
//发送文字
- (void)didSendTextAction:(NSString *)text {
    //判断是否是空消息
    NSString *trimString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimString length] == 0) {
        //Alert提醒不能输入空白消息
        [self showFailedHudWithTitle:@"不能发送空白消息"];
    }else{
        //清空已发送文本
        self.msgInputView.inputTextView.text = @"";
        [self sendComment:text];
        [self.msgInputView.inputTextView resignFirstResponder];
    }
}

//底部insets改变
- (void)onBottomInsetsChanged:(CGFloat)bottom
               isShowKeyboard:(BOOL)isShow
{
    [self setTableViewInsetsWithBottomValue:bottom];
    if (isShow)
        [self scrollToBottomAnimated:NO];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    //    NSInteger rows = [self.dataSource numberOfMessages];
    //
    //    if (rows > 0) {
    //        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
    //                                     atScrollPosition:UITableViewScrollPositionBottom
    //                                             animated:animated];
    //    }
    //TODO:
    
    //    [_listTableView scrollRectToVisible:_tableView.frame animated:YES];
    
    CGFloat offsetY = _listTableView.contentSize.height - (_listTableView.bounds.size.height - _listTableView.contentInset.bottom);
    if (offsetY > 0) {
        [_listTableView setContentOffset:CGPointMake(0, _listTableView.contentSize.height - (_listTableView.bounds.size.height - _listTableView.contentInset.bottom)) animated:animated];
    }
}
#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.msgInputView associatedScrollViewWillBeginDragging];
//}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.msgInputView associatedScrollViewWillBeginDragging];
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        //回复或删除
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            UIButton *view = (UIButton *)[cell.contentView viewWithTag:100];
            MLEmojiLabel *commentLabel = (MLEmojiLabel *)[view viewWithTag:100000];
            [self clickCommentCellAndHandledFeedComment:commentLabel];
        }
    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section != 2) {
        return 1;
    }
    return _feed.circleComments.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self getContentViewHeight];
    }else if (indexPath.section == 1){
        return [self getLikesViewHeight];
    }else{
        return [self getCommentViewHeight:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        //头像
        UIButton *portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        portraitBtn.frame = CGRectMake(10, 13, 40, 40);
        portraitBtn.layer.cornerRadius = 2.f;
        portraitBtn.layer.masksToBounds = YES;
        [portraitBtn setBackgroundImage:[UIImage imageNamed:@"userDefaultIcon"] forState:UIControlStateNormal];
        [cell.contentView addSubview:portraitBtn];
        [portraitBtn TX_setImageWithURL:[NSURL URLWithString:[_feed.userAvatarUrl getFormatPhotoUrl:41 hight:41]] forState:UIControlStateNormal placeholderImage:nil];
        
        //昵称
        UILabel *nameLb = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLb.backgroundColor = kColorClear;
        nameLb.font = kFontSubTitle;
        nameLb.textColor = kColorGray1;
        nameLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:nameLb];
        
        //昵称
        nameLb.text = _feed.userNickName;
        [nameLb sizeToFit];
        nameLb.frame = CGRectMake(portraitBtn.maxX + 10, portraitBtn.minY + 1, nameLb.width_, nameLb.height_);
        
        HTCopyableLabel *contentLb = [[HTCopyableLabel alloc] initClearColorWithFrame:CGRectZero];
        contentLb.textAlignment = NSTextAlignmentLeft;
        contentLb.numberOfLines = 0;
        contentLb.delegate = self;
        contentLb.textColor = kColorBlack;
        contentLb.font = kFontSubTitle;
        contentLb.autoDetectLinks = YES;
        //下划线
        contentLb.linksHaveUnderlines = NO;
        [cell.contentView addSubview:contentLb];
        
        //内容
        NSString *str = _feed.content;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedString nimbuskit_setTextColor:kColorBlack];
        [attributedString nimbuskit_setFont:kFontSubTitle];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:4];//调整行间距
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        contentLb.attributedText = attributedString;
        
        CGSize contentSize = [contentLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
        
        contentLb.frame = CGRectMake(nameLb.minX, portraitBtn.maxY - nameLb.height_ + 1, contentSize.width, contentSize.height);
        
        _photoView = [[UIView alloc] initWithFrame:CGRectZero];
        [cell.contentView addSubview:_photoView];
        [self createPhotoView:contentLb];
        
        
        //更多操作
        self.moreView = [[MoreView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 78, 29)];
        _moreView.clipsToBounds = YES;
        [cell.contentView addSubview:_moreView];
        _moreView.frame = CGRectMake(_photoView.minX, _photoView.maxY + 5, kScreenWidth - 78, 29);
        //操作框
        _moreView.delegate = self;
        _moreView.feed = _feed;
        CGSize timeSize = [UILabel contentSizeForLabelWithText:[NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(_feed.createdOn/1000)]] maxWidth:MAXFLOAT font:kFontSmall];
        [_moreView.timeLabel setTitle:[NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(_feed.createdOn/1000)]] forState:UIControlStateDisabled];
        _moreView.timeLabel.frame = CGRectMake(0, 0, timeSize.width, _moreView.height_ - 8);
        _moreView.deleteBtn.frame = CGRectMake(_moreView.timeLabel.maxX, _moreView.timeLabel.minY, _moreView.deleteBtn.width_, _moreView.timeLabel.height_);
        
        _moreView.loveBtn.selected = NO;
            
        NSError *error = nil;
        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
        
        if (_feed.circleLikes.count) {
            if ([_feed.circleLikes[0] isKindOfClass:[NSNumber class]]) {
                _moreView.loveBtn.selected = YES;
            }else{
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
                NSArray *arr1 = [_feed.circleLikes filteredArrayUsingPredicate:predicate1];
                _moreView.loveBtn.selected = arr1.count?YES:NO;
            }
        }
//            TXUser *feedUser = [[TXChatClient sharedInstance] getUserByUserId:_feed.userId error:nil];
        if (user.userId == _feed.userId || (user.userType == TXPBUserTypeTeacher && _feed.userType == TXPBUserTypeParent) || (user.positionId == GardenLeader) || (user.positionId == GardenLeader1)) {
            _moreView.deleteBtn.hidden = NO;
        }else{
            _moreView.deleteBtn.hidden = YES;
        }
//            if (user.userId == _feed.userId) {
//                _moreView.deleteBtn.hidden = NO;
//            }else{
//                _moreView.deleteBtn.hidden = YES;
//            }
    
        return cell;
    }else if (indexPath.section == 1){
        static NSString *CellIdentifier = @"CellIdentifier1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImage* stretchableImage = [[UIImage imageNamed:@"circle_comment_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 0, 0) resizingMode:UIImageResizingModeStretch];
            //赞
            _likesView = [[UIImageView alloc] initWithFrame:CGRectZero];
            _likesView.clipsToBounds = YES;
            _likesView.userInteractionEnabled = YES;
            _likesView.image = stretchableImage;
            [cell.contentView addSubview:_likesView];
        }
        [self createLikesView];
        return cell;
    }else{
        static NSString *CellIdentifier = @"CellIdentifier2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.tag = 100;
            view.backgroundColor = kColorBackground;
            [cell.contentView addSubview:view];
            
            UIImageView *likeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle_comment"]];
            likeImgView.tag = kCommentImgBaseTag;
            likeImgView.frame = CGRectMake(6, 17, 12, 12);
            [view addSubview:likeImgView];
            
            UIButton *portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            portraitBtn.frame = CGRectMake(likeImgView.maxX + 8, 7, 30, 30);
            portraitBtn.layer.cornerRadius = 2.f;
            portraitBtn.layer.masksToBounds = YES;
            [portraitBtn setBackgroundImage:[UIImage imageNamed:@"userDefaultIcon"] forState:UIControlStateNormal];
            portraitBtn.tag = 1000;
            [view addSubview:portraitBtn];
            
            UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            nameBtn.titleLabel.font = kFontSmall;
            [nameBtn setTitleColor:kColorGray1 forState:UIControlStateNormal];
            nameBtn.tag = 10000;
            [view addSubview:nameBtn];
            
            MLEmojiLabel *commentLabel = [[MLEmojiLabel alloc]init];
            commentLabel.userInteractionEnabled = YES;
            commentLabel.backgroundColor = kColorClear;
            commentLabel.numberOfLines = 0;
            commentLabel.emojiDelegate = self;
            commentLabel.disableThreeCommon = YES;
            commentLabel.font = kFontSmall;
            NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
            [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor clearColor] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
            commentLabel.activeLinkAttributes = mutableActiveLinkAttributes;
            [commentLabel setTextColor:kColorGray];
            commentLabel.isNeedAtAndPoundSign = YES;
            commentLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
            commentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            commentLabel.customEmojiPlistName = @"emotion.plist";
            commentLabel.tag = 100000;
            [view addSubview:commentLabel];
            
            UILabel *timeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            timeLb.userInteractionEnabled = NO;
            timeLb.textColor = kColorLightGray;
            timeLb.font = kFontMini;
            timeLb.tag = 1000000;
            [view addSubview:timeLb];
            
            UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
            lineView.tag = 10000000;
            [view addSubview:lineView];
            
        }
        id obj = _feed.circleComments[indexPath.row];
        UIButton *view = (UIButton *)[cell.contentView viewWithTag:100];
        
        UIImageView *commentImgView = (UIImageView *)[view viewWithTag:kCommentImgBaseTag];
        commentImgView.hidden = YES;
        if (!indexPath.row) {
            commentImgView.hidden = NO;
        }
        
        NSString *urlStr = nil;
        NSString *time = nil;
        NSString *content = nil;
        NSString *nickName = nil;
        NSNumber *userId = nil;
        NSString *replyName = nil;
        NSNumber *toUserId = nil;
        BOOL isCurrentUser = NO;
        if ([obj isKindOfClass:[TXComment class]]) {
            TXComment *comment = obj;
            userId = @(comment.userId);
            nickName = comment.userNickname;
            urlStr = comment.userAvatarUrl;
            time = [NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(comment.createdOn/1000)]];
            if (comment.toUserNickname.length) {
                content = [NSString stringWithFormat:@"回复%@：%@",comment.toUserNickname,comment.content];
                replyName = comment.toUserNickname;
                toUserId = @(comment.toUserId);
            }else{
                content = comment.content;
            }
            if (userId.integerValue == user.userId) {
                isCurrentUser = YES;
            }
        }else{
            isCurrentUser = YES;
            NSDictionary *dic = obj;
            NSNumber *num = dic[@"time"];
            urlStr = user.avatarUrl;
            userId = @(user.userId);
            nickName = user.nickname;
            time = [NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", num]];
            if (dic[@"userId"]) {
                replyName = dic[@"userName"];
                toUserId = dic[@"userId"];
                content = [NSString stringWithFormat:@"回复%@：%@",dic[@"userName"],dic[@"comment"]];
            }else{
                content = dic[@"comment"];
            }
        }
        __weak typeof(self)tmpObject = self;
        UIButton *portraitBtn = (UIButton *)[view viewWithTag:1000];
        [portraitBtn TX_setImageWithURL:[NSURL URLWithString:[urlStr getFormatPhotoUrl:30 hight:30]] forState:UIControlStateNormal placeholderImage:nil];
        [portraitBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
            avc.userId = userId.integerValue;
            avc.nickName = nickName;
            avc.portraitUrl = urlStr;
            [tmpObject.navigationController pushViewController:avc animated:YES];
            
        }];
        
        UIButton *nameBtn = (UIButton *)[view viewWithTag:10000];
        [nameBtn setTitle:nickName forState:UIControlStateNormal];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [nameBtn.titleLabel sizeToFit];
            nameBtn.frame = CGRectMake(portraitBtn.maxX + 5, portraitBtn.minY, nameBtn.titleLabel.width_, nameBtn.titleLabel.height_);
        }else{
            [nameBtn sizeToFit];
            nameBtn.frame = CGRectMake(portraitBtn.maxX + 5, portraitBtn.minY, nameBtn.titleLabel.width_, nameBtn.titleLabel.height_);
        }
        
        [nameBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
            avc.userId = userId.integerValue;
            avc.nickName = nickName;
            avc.portraitUrl = urlStr;
            [tmpObject.navigationController pushViewController:avc animated:YES];
        }];
        
        MLEmojiLabel *commentLabel = (MLEmojiLabel *)[view viewWithTag:100000];
        [commentLabel setEmojiText:content];
        commentLabel.feedComment = obj;
        commentLabel.replyUserName = nickName;
        commentLabel.feed = _feed;
        commentLabel.replyUser = userId;
        if (commentLabel.replyUserName && replyName.length) {
            [commentLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",toUserId]] withRange:[content rangeOfString:replyName]];
        }
        CGFloat width = kScreenWidth - 73 - 10 - portraitBtn.width_ - 7 - 18;
        CGSize size = [commentLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        commentLabel.frame = CGRectMake(nameBtn.minX, nameBtn.maxY + 2, width, size.height);
        
        if ((commentLabel.height_ > nameBtn.titleLabel.height_  * 2)) {
            view.frame = CGRectMake(60, 0, kScreenWidth - 73, commentLabel.maxY + 8);
        }else{
            view.frame = CGRectMake(60, 0, kScreenWidth - 73, 44);
        }
        
        UILabel *timeLb = (UILabel *)[view viewWithTag:1000000];
        timeLb.text = time;
        [timeLb sizeToFit];
        timeLb.frame = CGRectMake(view.width_ - 7 - timeLb.width_, nameBtn.minY + (nameBtn.height_ - nameBtn.titleLabel.height_)/2, timeLb.width_, timeLb.height_);
        
        UIView *lineView = [view viewWithTag:10000000];
        lineView.frame = CGRectMake(portraitBtn.minX, view.height_ - kLineHeight, view.width_ - portraitBtn.minX, kLineHeight);
        lineView.hidden = _feed.circleComments.count - 1 == indexPath.row?YES:NO;
        
        return cell;
    }
    return nil;
}

- (CGFloat)getContentViewHeight{
    if (_contentHeight != 0) {
        return _contentHeight;
    }
    //内容
    HTCopyableLabel *contentLb = [[HTCopyableLabel alloc] initClearColorWithFrame:CGRectZero];
    contentLb.textAlignment = NSTextAlignmentLeft;
    contentLb.numberOfLines = 0;
    contentLb.textColor = kColorBlack;
    
    NSString *str = _feed.content;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString nimbuskit_setTextColor:kColorBlack];
    [attributedString nimbuskit_setFont:kFontSubTitle];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:4];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    contentLb.attributedText = attributedString;
    
    
    CGSize nameSize = [UILabel contentSizeForLabelWithText:_feed.userNickName maxWidth:kScreenWidth - 78 font:kFontSubTitle];
    CGSize contentSize = [contentLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
    
    CGFloat Height = 0;
    if (53 + 1 - nameSize.height + contentSize.height < 53) {
        Height = 53 + 10;
    }else{
        Height = 53 + 1 - nameSize.height + contentSize.height + 13;
    }
    
    
    __block CGFloat Y = 0;
    int width = (kScreenWidth - 78 - 10)/3;
    [_feed.attaches enumerateObjectsUsingBlock:^(NSString *attach, NSUInteger idx, BOOL *stop) {
        if (_feed.attaches.count == 1) {
            int width = (kScreenWidth - 78)/3 * 2;
            int height = width * 3 /4;
            Y = height;
        }else if (_feed.attaches.count == 4 || _feed.attaches.count == 2){
            int width = (kScreenWidth - 78 - 5)/2;
            Y = idx/2 * (width + 5) + width;
        }else{
            Y = idx/3 * (width + 5) + width;
        }
    }];
    
    Height += (Y + 29 + 2);
    
    _contentHeight = Height;
    
    return _contentHeight;
}

- (CGFloat)getLikesViewHeight{
    __block CGFloat X = 18 + 8;
    __block CGFloat Y = 10.5;
    [_feed.circleLikes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        X += 37;
        
        if (X + 37 >= (kScreenWidth - 73)) {
            X = 18 + 8;
            Y += 37;
        }
        
    }];
    if (_feed.circleLikes.count) {
        return Y + 30 + 7;
    }else{
        return 0;
    }
}

- (CGFloat)getCommentViewHeight:(NSUInteger)index{
    id obj = _feed.circleComments[index];
    NSString *content = nil;
    NSString *nickName = nil;
    NSNumber *userId = nil;
    NSString *replyName = nil;
    NSNumber *toUserId = nil;
    if ([obj isKindOfClass:[TXComment class]]) {
        TXComment *comment = obj;
        nickName = comment.userNickname;
        userId = @(comment.userId);
        if (comment.toUserNickname.length) {
            replyName = comment.toUserNickname;
            toUserId = @(comment.toUserId);
            content = [NSString stringWithFormat:@"回复%@：%@",comment.toUserNickname,comment.content];
        }else{
            content = comment.content;
        }
    }else{
        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
        userId = @(user.userId);
        NSDictionary *dic = obj;
        nickName = user.nickname;
        if (dic[@"userId"]) {
            replyName = dic[@"userName"];
            toUserId = dic[@"userId"];
            content = [NSString stringWithFormat:@"回复%@：%@",dic[@"userName"],dic[@"comment"]];
        }else{
            content = dic[@"comment"];
        }
    }
    
    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nameBtn.titleLabel.font = kFontSmall;
    [nameBtn setTitle:nickName forState:UIControlStateNormal];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [nameBtn.titleLabel sizeToFit];
    }else{
        [nameBtn sizeToFit];
    }
    
    MLEmojiLabel *commentLabel = [[MLEmojiLabel alloc] init];
    commentLabel.numberOfLines = 0;
    commentLabel.disableThreeCommon = NO;
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor clearColor] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    commentLabel.activeLinkAttributes = mutableActiveLinkAttributes;
    [commentLabel setTextColor:kColorGray];
    commentLabel.font = kFontSmall;
    [commentLabel setEmojiText:content];
    commentLabel.isNeedAtAndPoundSign = YES;
    commentLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    commentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    commentLabel.customEmojiPlistName = @"emotion.plist";
    CGFloat width = kScreenWidth - 73 - 10 - 30 - 7 - 18;
    CGSize size = [commentLabel sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    commentLabel.frame = CGRectMake(nameBtn.minX, nameBtn.maxY, width, size.height);
    
    CGFloat height = 7 + nameBtn.titleLabel.height_ + 1 + commentLabel.height_ ;
    if (commentLabel.height_ > nameBtn.titleLabel.height_  * 2) {
        return height + 8;
    }else{
        return 44;
    }
}

#pragma mark - cell回复或删除
- (void)clickCommentCellAndHandledFeedComment:(MLEmojiLabel *)emojiLabel
{
    __weak typeof(self)tmpObject = self;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    int64_t currentUserId = user.userId;
    if ([emojiLabel.feedComment isKindOfClass:[TXComment class]]) {
        TXComment *comment = emojiLabel.feedComment;
        TXUser *commenterUser = [[TXChatClient sharedInstance] getUserByUserId:comment.userId error:nil];
        if (comment.userId != currentUserId) {
            if (commenterUser && user.userType == TXPBUserTypeTeacher && commenterUser.userType == TXPBUserTypeParent) {
                [tmpObject showCommentDeleteOrAddChooseSheetWithCompletion:^(NSInteger index) {
                    if (index == 0) {
                        //回复
                        [tmpObject onFeedCommentAddResponse:emojiLabel.feed
                                             andPlaceholder:[NSString stringWithFormat:@"回复:%@",comment.userNickname]
                                                andToUserId:emojiLabel.replyUser
                                              andToUserName:emojiLabel.replyUserName];
                    }else if (index == 1) {
                        //删除
                        [tmpObject deleteCommentWithFeed:emojiLabel.feed andComment:emojiLabel.feedComment];
                    }
                }];
            }else{
                [tmpObject onFeedCommentAddResponse:emojiLabel.feed
                                     andPlaceholder:[NSString stringWithFormat:@"回复:%@",comment.userNickname]
                                        andToUserId:emojiLabel.replyUser
                                      andToUserName:emojiLabel.replyUserName];
            }
        }else{
            [tmpObject onFeedCommentDeleteResponse:emojiLabel.feed andComment:emojiLabel.feedComment];
        }
    }else{
        [tmpObject onFeedCommentDeleteResponse:emojiLabel.feed andComment:emojiLabel.feedComment];
        
    }
}
#pragma mark - MLEmojiLabel delegate method
- (void)attributedLabel:(MLEmojiLabel *)emojiLabel didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result{
    if ([[result.URL absoluteString] hasPrefix:@"http"]) {
        NSString *resultStr = [result.URL absoluteString];
        //跳转到网页链接
        PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:resultStr];
        [self.navigationController pushViewController:detailVc animated:YES];
        return;
    }
    NSError *error = nil;
    __weak typeof(self)tmpObject = self;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    if (!result){

    }else{
        int64_t userId = [[result.URL absoluteString] intValue];
        CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
        avc.userId = userId;
        id tmpComment = emojiLabel.feedComment;
        if ([tmpComment isKindOfClass:[NSMutableDictionary class]]) {
            NSDictionary *dic = tmpComment;
            if (userId == user.userId) {
                avc.nickName = user.username;
                avc.portraitUrl = user.avatarUrl;
            }else{
                avc.nickName = dic[@"userName"];
                TXUser *otherUser = [[TXChatClient sharedInstance] getUserByUserId:userId error:nil];
                avc.portraitUrl = otherUser.avatarUrl;
            }
        }else{
            TXComment *pbComment = tmpComment;
            if (pbComment.userId == userId) {
                avc.nickName = pbComment.userNickname;
                avc.portraitUrl = pbComment.userAvatarUrl;
            }else{
                avc.nickName = pbComment.toUserNickname;
                avc.portraitUrl = pbComment.userAvatarUrl;
            }
        }
        [tmpObject.navigationController pushViewController:avc animated:YES];
    }
}

#pragma mark - NIAttributedLabelDelegate
- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    NSString *resultStr = [result.URL absoluteString];
    //跳转到网页链接
    PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:resultStr];
    [self.navigationController pushViewController:detailVc animated:YES];
    
}



@end
