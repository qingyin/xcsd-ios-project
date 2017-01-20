;//
//  CircleListOtherCell.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleListOtherCell.h"
#import "HTCopyableLabel.h"
#import "CircleListViewController.h"
#import "UIImageView+EMWebCache.h"
#import <UIImageView+Utils.h>
#import "NSDate+TuXing.h"
#import "UIButton+EMWebCache.h"
#import "CircleHomeViewController.h"
#import "CircleDetailViewController.h"
#import "UILabel+ContentSize.h"
#import "CircleVideoView.h"
#import "FoundWebViewController.h"
#import "NSMutableAttributedString+NimbusKitAttributedLabel.h"
#import "PublishmentDetailViewController.h"

#define GardenLeader                 1

@implementation MoreView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHideMoreView) name:kHideMoreView object:nil];
        self.clipsToBounds = YES;
        _viewWidth = 130;
        
        //发布时间
        self.timeLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeLabel.titleLabel.font = kFontSmall;
        [_timeLabel setTitleColor:kColorGray forState:UIControlStateDisabled];
        _timeLabel.enabled = NO;
        [self addSubview:_timeLabel];
        
        //删除
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.titleLabel.font = kFontSmall;
        [_deleteBtn setTitleColor:kColorGray1 forState:UIControlStateNormal];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(onDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteBtn];
        [_deleteBtn sizeToFit];
        
        _showMore = NO;
        
        //操作区视图
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 29, 0, _viewWidth, 29)];
        _bgView.userInteractionEnabled = YES;
        _bgView.layer.cornerRadius = 3.f;
        _bgView.layer.masksToBounds = YES;
        _bgView.backgroundColor = kColorGray;
        [self addSubview:_bgView];
        
        //赞
        self.loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loveBtn.frame = CGRectMake(0, 0, 65, 29);
        [_loveBtn setImage:[UIImage imageNamed:@"btn_love"] forState:UIControlStateNormal];
        [_loveBtn setImage:[UIImage imageNamed:@"btn_love_1"] forState:UIControlStateHighlighted];
        [_loveBtn setTitle:@" 赞" forState:UIControlStateNormal];
        [_loveBtn setTitle:@" 取消" forState:UIControlStateSelected];
        _loveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
        [_loveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loveBtn addTarget:self action:@selector(onLikeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_loveBtn];
        
        //评论
        self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentBtn.frame = CGRectMake(65, 0, 65, 29);
        [_commentBtn setImage:[UIImage imageNamed:@"btn_comment"] forState:UIControlStateNormal];
        [_commentBtn setImage:[UIImage imageNamed:@"btn_comment_1"] forState:UIControlStateHighlighted];
        [_commentBtn setTitle:@"评论" forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
        [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_commentBtn addTarget:self action:@selector(onCommentBtn) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:_commentBtn];
        
        
        //操作按钮
        UIImage *moreImg = [UIImage imageNamed:@"btn_more"];
        self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 29, 0, 29, 29);
        [_moreBtn setImage:[UIImage imageNamed:@"btn_more"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"btn_more_1"] forState:UIControlStateHighlighted];
        [_moreBtn addTarget:self action:@selector(onMoreBtn) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn.imageEdgeInsets = UIEdgeInsetsMake((29 - moreImg.size.height)/2, 29 - moreImg.size.width, (29 - moreImg.size.height)/2, 0);
        _moreBtn.backgroundColor = [UIColor whiteColor];
        [self addSubview:_moreBtn];
    }
    return self;
}

- (void)onHideMoreView{
    _showMore = NO;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _bgView.frame = CGRectMake(CGRectGetWidth(self.frame) - 29, 0, _viewWidth, 29);
    } completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hideMoreView" object:nil];
}


//赞
- (void)onLikeBtn:(UIButton *)btn{
    if (_delegate && [_delegate respondsToSelector:@selector(onFeedLikeResponse:andIsLike:)]) {
        [_delegate onFeedLikeResponse:_feed andIsLike:!btn.selected];
    } 
}

//删除状态
- (void)onDeleteBtn{
    __weak typeof(self)tmpObject = self;
    if ([_feed isKindOfClass:[TXFeed class]] && ((TXFeed *)_feed).feedType == TXFeedTypeActivity) {
        [tmpObject.delegate onFeedDeleteResponse:tmpObject.feed];
        return;
    }
    [self showAlertViewWithMessage:@"确定删除吗？" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
        if (tmpObject.delegate && [tmpObject.delegate respondsToSelector:@selector(onFeedDeleteResponse:)]) {
            [tmpObject.delegate onFeedDeleteResponse:tmpObject.feed];
        }
    }], nil];
}

//评论
- (void)onCommentBtn{
    if (_delegate && [_delegate respondsToSelector:@selector(onFeedCommentAddResponse:andPlaceholder:andToUserId:andToUserName:)]) {
        [_delegate onFeedCommentAddResponse:_feed andPlaceholder:nil andToUserId:nil andToUserName:nil];
    }
}

- (void)onMoreBtn{
    _showMore = !_showMore;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_showMore) {
            _bgView.frame = CGRectMake(CGRectGetWidth(self.frame) - 29 - _viewWidth, 0, _viewWidth, 29);
        }else{
            _bgView.frame = CGRectMake(CGRectGetWidth(self.frame)  - 29, 0, _viewWidth, 29);
        }
    } completion:nil];
    
}


@end

@interface CircleListOtherCell ()<MLEmojiLabelDelegate>
{
    UIButton *_portraitBtn;         //头像
    UILabel *_nameLb;               //昵称
    HTCopyableLabel *_contentLb;    //内容
    UIButton *_fullBtn;             //全文按钮
    UIView *_photoView;             //照片墙
    MoreView *_moreView;            //操作框
    UIImageView *_commentView;           //赞和评论列表
    UIView *_lineView;
}

@end



@implementation CircleListOtherCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //头像
        _portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _portraitBtn.layer.cornerRadius = 2.f;
        _portraitBtn.layer.masksToBounds = YES;
        _portraitBtn.frame = CGRectMake(10, 13, 40, 40);
        [self.contentView addSubview:_portraitBtn];
        
        //昵称
        _nameLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLb.backgroundColor = kColorClear;
        _nameLb.userInteractionEnabled = YES;
        _nameLb.font = kFontSubTitle;
        _nameLb.textColor = kColorGray1;
        _nameLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_nameLb];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_nameLb addSubview:btn];
        __weak typeof(self)tmpObject = self;
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            if (tmpObject.feed.feedType == TXFeedTypePlain) {
                CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
                avc.userId = tmpObject.feed.userId;
                avc.portraitUrl = tmpObject.feed.userAvatarUrl;
                avc.nickName = tmpObject.feed.userNickName;
                [tmpObject.listVC.navigationController pushViewController:avc animated:YES];
            }
        }];
        
        _contentLb = [[HTCopyableLabel alloc] initClearColorWithFrame:CGRectZero];
        _contentLb.textAlignment = NSTextAlignmentLeft;
        _contentLb.numberOfLines = 6;
        _contentLb.delegate = self;
        _contentLb.textColor = kColorBlack;
        _contentLb.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLb.font = kFontSubTitle;
        _contentLb.autoDetectLinks = YES;
        //下划线
        _contentLb.linksHaveUnderlines = NO;
        [self.contentView addSubview:_contentLb];

        
        //全文
        _fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullBtn setTitleColor:kColorGray1 forState:UIControlStateNormal];
        _fullBtn.titleLabel.font = kFontSmall;
        [_fullBtn addTarget:self action:@selector(onFullBtn) forControlEvents:UIControlEventTouchUpInside];
        _fullBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_fullBtn setTitle:@"全文" forState:UIControlStateNormal];
        [self.contentView addSubview:_fullBtn];
        
        _photoView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_photoView];
        
        //更多操作
        _moreView = [[MoreView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 78, 29)];
        _moreView.clipsToBounds = YES;
        [self.contentView addSubview:_moreView];
        
        //赞和评论列表
        UIImage* stretchableImage = [[UIImage imageNamed:@"circle_comment_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 0, 0) resizingMode:UIImageResizingModeStretch];
        _commentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _commentView.userInteractionEnabled = YES;
        _commentView.image = stretchableImage;
        [self.contentView addSubview:_commentView];

        
        _lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
        [self.contentView addSubview:_lineView];
    }
    return self;
}

//全文按钮
- (void)onFullBtn{
    if ([_fullBtn.titleLabel.text isEqualToString:@"全文"]) {
        [_fullBtn setTitle:@"收起" forState:UIControlStateNormal];
        _feed.isFold = @(NO);
        _feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:_feed]];
        [_listVC reloadData];
    }else{
        [_fullBtn setTitle:@"全文" forState:UIControlStateNormal];
        _feed.isFold = @(YES);
        _feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:_feed]];
        [_listVC reloadData];
    }
}

- (void)setFeed:(TXFeed *)feed{
    __weak typeof(self)tmpObject = self;
    [_portraitBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        if (tmpObject.feed.feedType == TXFeedTypePlain) {
            CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
            avc.userId = feed.userId;
            avc.portraitUrl = feed.userAvatarUrl;
            avc.nickName = feed.userNickName;
            [tmpObject.listVC.navigationController pushViewController:avc animated:YES];
        }
    }];
    _feed = feed;
    //昵称
    _nameLb.text = feed.userNickName;
    [_nameLb sizeToFit];
    _nameLb.frame = CGRectMake(_portraitBtn.maxX + 10, _portraitBtn.minY + 1, _nameLb.width_, _nameLb.height_);
    
    //头像
    NSString *imgStr = [feed.userAvatarUrl getFormatPhotoUrl:82 hight:82];
    [_portraitBtn TX_setImageWithURL:[NSURL URLWithString:imgStr] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    
    //内容
    NSString *str = _feed.content;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString nimbuskit_setTextColor:kColorBlack];
    [attributedString nimbuskit_setFont:kFontSubTitle];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:4];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    _contentLb.attributedText = attributedString;

    CGFloat fullHeight = 0;
    CGSize size = CGSizeZero;
    if (!_feed.isFold.boolValue) {
        [_fullBtn setTitle:@"收起" forState:UIControlStateNormal];
        _contentLb.numberOfLines = 0;
        size = [_contentLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
        fullHeight = 20;
    }else{
        _contentLb.numberOfLines = 6;
        size = [_contentLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
        
        HTCopyableLabel *tmpLb = [[HTCopyableLabel alloc] initWithFrame:CGRectZero];
        tmpLb.font = _contentLb.font;
        tmpLb.textAlignment = NSTextAlignmentLeft;
        tmpLb.numberOfLines = 0;
        tmpLb.attributedText = attributedString;
        CGSize tmpSize = [tmpLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
        if (tmpSize.height > size.height) {
            [_fullBtn setTitle:@"全文" forState:UIControlStateNormal];
            fullHeight = 20;
        }else{
            _contentLb.numberOfLines = 6;
            [_fullBtn setTitle:@"" forState:UIControlStateNormal];
        }
    }
    _contentLb.frame = CGRectMake(_nameLb.minX, _portraitBtn.maxY + 1 - _nameLb.height_ , kScreenWidth - 78, size.height);
    _fullBtn.frame = CGRectMake(_contentLb.minX, _contentLb.maxY, 40, fullHeight);

    //照片墙
    [_photoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger count = feed.attaches.count;
    int width = (kScreenWidth - 78 - 10)/3;
    __block CGFloat Y = 0;
    [_feed.attaches enumerateObjectsUsingBlock:^(TXPBAttach *attach, NSUInteger idx, BOOL *stop) {
        NSString *fileUrl = attach.fileurl;
        if (count == 1) {
            int width = (kScreenWidth - 78)/3 * 2;
            int height = width * 3 /4;
            TXPBAttachType fileType = attach.attachType;
            if (fileType == TXPBAttachTypeVedio) {
                NSString *imgUrl = [fileUrl getFormatVideoUrl:width hight:height];
                CircleVideoView *photoImgView = [[CircleVideoView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
                photoImgView.backgroundColor = kColorCircleBg;
                [photoImgView TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                    if (error) {
                        [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_320x240"] forState:UIControlStateNormal];
                    }
                }];
                [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(CircleVideoView *sender) {
                    [_listVC playVideoWithURLString:fileUrl thumbnailImageURLString:imgUrl];
                }];
                [_photoView addSubview:photoImgView];
                
                Y = photoImgView.maxY;
            }else if (_feed.feedType == TXFeedTypeActivity){
                NSString *imgUrl = [fileUrl getFormatPhotoUrl:width hight:height];
                UIButton *photoImgView = [UIButton buttonWithType:UIButtonTypeCustom];
                photoImgView.frame = CGRectMake(0, 0, width, height);
                photoImgView.backgroundColor = kColorCircleBg;
                photoImgView.imageView.contentMode = UIViewContentModeScaleAspectFill;
                [photoImgView TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                    if (error) {
                        [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_148x148"] forState:UIControlStateNormal];
                    }else{
                        [photoImgView setBackgroundColor:[UIColor clearColor]];
                    }
                }];
                [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                    FoundWebViewController *avc = [[FoundWebViewController alloc] initWithURLString:tmpObject.feed.activityUrl];
                    avc.foundType = FoundType_Circle;
                    [tmpObject.listVC.navigationController pushViewController:avc animated:YES];
                }];
                [_photoView addSubview:photoImgView];
                
                Y = photoImgView.maxY;
            }
            else{
                //图片文件
                NSString *imgUrl = [fileUrl getFormatPhotoUrl:width hight:height];
                UIButton *photoImgView = [UIButton buttonWithType:UIButtonTypeCustom];
                photoImgView.frame = CGRectMake(0, 0, width, height);
                photoImgView.backgroundColor = kColorCircleBg;
                photoImgView.imageView.contentMode = UIViewContentModeScaleAspectFill;
                [photoImgView TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                    if (error) {
                        [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_320x240"] forState:UIControlStateNormal];
                    }else{
                        [photoImgView setBackgroundColor:[UIColor clearColor]];
                    }
                }];
                [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                    [tmpObject.listVC showPhotoView:tmpObject.feed.attaches andIndex:(int)idx];
                }];
                [_photoView addSubview:photoImgView];
                
                Y = photoImgView.maxY;
            }
        }else if (count == 4 || count == 2){
            int width = (kScreenWidth - 78 - 5)/2;
            NSString *imgUrl = [fileUrl getFormatPhotoUrl:width hight:width];
            UIButton *photoImgView = [UIButton buttonWithType:UIButtonTypeCustom];
            photoImgView.backgroundColor = kColorCircleBg;
            photoImgView.frame = CGRectMake(idx%2 * (width + 5), idx/2 * (width + 5), width, width);
            photoImgView.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [photoImgView TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_148x148"] forState:UIControlStateNormal];
                }else{
                    [photoImgView setBackgroundColor:[UIColor clearColor]];
                }
            }];
            [_photoView addSubview:photoImgView];
            [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [_listVC showPhotoView:_feed.attaches andIndex:(int)idx];
            }];
            
            Y = photoImgView.maxY;
        }else{
            NSString *imgUrl = [fileUrl getFormatPhotoUrl:width hight:width];
            UIButton *photoImgView = [UIButton buttonWithType:UIButtonTypeCustom];
            photoImgView.backgroundColor = kColorCircleBg;
            photoImgView.frame = CGRectMake(idx%3 * (width + 5), idx/3 * (width + 5), width, width);
            photoImgView.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [photoImgView TX_setImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    [photoImgView setBackgroundImage:[UIImage imageNamed:@"tp_148x148"] forState:UIControlStateNormal];
                }else{
                    [photoImgView setBackgroundColor:[UIColor clearColor]];
                }
            }];
            [_photoView addSubview:photoImgView];
            [photoImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [_listVC showPhotoView:_feed.attaches andIndex:(int)idx];
            }];
            
            Y = photoImgView.maxY;
        }
    }];
    if (size.height == 0 && Y != 0) {
        _photoView.frame = CGRectMake(_fullBtn.minX, _nameLb.maxY + 10, kScreenWidth - 78, Y);
    }else if (fullHeight == 0 && _contentLb.maxY < _portraitBtn.maxY) {
        _photoView.frame = CGRectMake(_fullBtn.minX, _portraitBtn.maxY + 10, kScreenWidth - 78, Y);
    }else{
        _photoView.frame = CGRectMake(_fullBtn.minX, _fullBtn.maxY + 10, kScreenWidth - 78, Y);
    }
    
    //操作框
    _moreView.delegate = _listVC;
    _moreView.feed = _feed;
    if (Y) {
        _moreView.frame = CGRectMake(_photoView.minX, _photoView.maxY + 5, _moreView.width_, _moreView.height_);
    }else{
        _moreView.frame = CGRectMake(_photoView.minX, _fullBtn.maxY + 5, _moreView.width_, _moreView.height_);
    }
    CGSize timeSize = [UILabel contentSizeForLabelWithText:[NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(feed.createdOn/1000)]] maxWidth:MAXFLOAT font:kFontSmall];
    [_moreView.timeLabel setTitle:[NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(feed.createdOn/1000)]] forState:UIControlStateDisabled];
    _moreView.timeLabel.frame = CGRectMake(0, 0, timeSize.width, _moreView.height_);
    if (_feed.feedType == TXFeedTypeActivity) {
        [_moreView.deleteBtn setTitle:@"  不感兴趣" forState:UIControlStateNormal];
    }else{
        [_moreView.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    }
    [_moreView.deleteBtn sizeToFit];
    _moreView.deleteBtn.frame = CGRectMake(_moreView.timeLabel.maxX + kDeleteBtnMargin, _moreView.timeLabel.minY, _moreView.deleteBtn.width_, _moreView.timeLabel.height_);
    _moreView.loveBtn.selected = NO;
    [_moreView onHideMoreView];

    
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
//    TXUser *feedUser = [[TXChatClient sharedInstance] getUserByUserId:feed.userId error:nil];
    _moreView.moreBtn.hidden = NO;
    _moreView.bgView.hidden = NO;
    if (user.userId == feed.userId || (user.userType == TXPBUserTypeTeacher && _feed.userType == TXPBUserTypeParent) || _feed.feedType == TXFeedTypeActivity || (user.positionId == GardenLeader) || (user.positionId == GardenLeader1)) {
        _moreView.deleteBtn.hidden = NO;
        if (_feed.feedType == TXFeedTypeActivity) {
            _moreView.moreBtn.hidden = YES;
            _moreView.bgView.hidden = YES;
        }
    }else{
        _moreView.deleteBtn.hidden = YES;
    }
    
    //赞和评论列表
    [_commentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _commentView.frame = CGRectMake(_photoView.minX, _moreView.maxY, kScreenWidth - 78, 0);
    _commentView.clipsToBounds = NO;
    __block CGFloat commentY = 0;
    if (feed.circleLikes.count) {
        
        if ([_feed.circleLikes[0] isKindOfClass:[NSNumber class]]) {
            _moreView.loveBtn.selected = YES;
        }else{
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
            NSArray *arr1 = [feed.circleLikes filteredArrayUsingPredicate:predicate1];
            _moreView.loveBtn.selected = arr1.count?YES:NO;
        }
        
        UIImageView *likeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle_like"]];
        likeImgView.frame = CGRectMake(6, 7 + 3.5, 12, 12);
        [_commentView addSubview:likeImgView];
        feed.likeLb.delegate = self;
        
        [_commentView addSubview:feed.likeLb];
        
        _commentView.frame = CGRectMake(_photoView.minX, _moreView.maxY, kScreenWidth - 78, feed.likeLb.maxY + 7);
        likeImgView.minY = feed.likeLb.minY + 1;

        commentY = feed.likeLb.maxY + 7;
        
        if (feed.commentLbArr.count) {
            [_commentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, commentY - kLineHeight, kScreenWidth - 78, kLineHeight)]];
        }
    }
    if (feed.commentLbArr.count) {
        if (!commentY) {
            commentY += 7;
        }
        commentY += 7;
        UIImageView *commentImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle_comment"]];
        commentImgView.frame = CGRectMake(6, commentY + 5, 12, 12);
        [_commentView addSubview:commentImgView];
        
        
        [feed.commentLbArr enumerateObjectsUsingBlock:^(MLEmojiLabel *obj, NSUInteger idx, BOOL *stop) {
            obj.emojiDelegate = self;
            obj.minY = commentY;
            //            obj.height_ -= 1;
            [_commentView addSubview:obj];
            commentY += (obj.height_);
            if (idx == feed.commentLbArr.count - 1 ) {
                commentY += 7;
            }
        }];
        if (feed.hasMore.boolValue) {
            UIButton *moreCommentsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [moreCommentsBtn setTitle:@"更多评论" forState:UIControlStateNormal];
            [moreCommentsBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
            moreCommentsBtn.titleLabel.font = kFontMiddle;
            moreCommentsBtn.frame = CGRectMake(0, commentY, kScreenWidth - 78, 23);
            [_commentView addSubview:moreCommentsBtn];
            //            [_commentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, moreCommentsBtn.maxY - kLineHeight, moreCommentsBtn.width_, kLineHeight)]];
            [moreCommentsBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                CircleDetailViewController *avc = [[CircleDetailViewController alloc] init];
                avc.feed = feed;
                avc.presentVC = _listVC;
                [_listVC.navigationController pushViewController:avc animated:YES];
                
            }];
            
            commentY += 30;
        }
        _commentView.frame = CGRectMake(_photoView.minX, _moreView.maxY, kScreenWidth - 78, commentY);
    }

    if (_commentView.height_) {
        _lineView.frame = CGRectMake(0, _commentView.maxY + 12 - kLineHeight, kScreenWidth, kLineHeight);
    }else{
        _lineView.frame = CGRectMake(0, _moreView.maxY + 12 - (_moreView.height_ - timeSize.height)/2 - kLineHeight, kScreenWidth, kLineHeight);
    }
//    _lineView.frame = CGRectMake(0, height - kLineHeight, kScreenWidth, kLineHeight);
}

- (void)attributedLabel:(MLEmojiLabel *)emojiLabel didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result{
    if ([[result.URL absoluteString] hasPrefix:@"http"]) {
        NSString *resultStr = [result.URL absoluteString];
        //跳转到网页链接
        PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:resultStr];
        [_listVC.navigationController pushViewController:detailVc animated:YES];
        return;
    }
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    if (!result){

        int64_t currentUserId = user.userId;
        if ([emojiLabel.feedComment isKindOfClass:[TXComment class]]) {
            TXComment *comment = emojiLabel.feedComment;
            TXUser *commenterUser = [[TXChatClient sharedInstance] getUserByUserId:comment.userId error:nil];
            if (comment.userId != currentUserId) {
                if (commenterUser && user.userType == TXPBUserTypeTeacher && commenterUser.userType == TXPBUserTypeParent) {
                    //教师对家长操作
                    [_listVC showFeedDeleteOrAddChooseSheetWithCompletion:^(NSInteger index) {
                        if (index == 0) {
                            //回复
                            [_listVC onFeedCommentAddResponse:emojiLabel.feed
                                               andPlaceholder:[NSString stringWithFormat:@"回复:%@",comment.userNickname]
                                                  andToUserId:emojiLabel.replyUser
                                                andToUserName:emojiLabel.replyUserName];
                        }else if (index == 1) {
                            //删除
                            [_listVC deleteCommentWithFeed:emojiLabel.feed andComment:emojiLabel.feedComment];
                        }
                    }];
                }else{
                    //家长操作或者教师对教师操作
                    [_listVC onFeedCommentAddResponse:emojiLabel.feed
                                       andPlaceholder:[NSString stringWithFormat:@"回复:%@",comment.userNickname]
                                          andToUserId:emojiLabel.replyUser
                                        andToUserName:emojiLabel.replyUserName];
                }
            }else{
                [_listVC onFeedCommentDeleteResponse:emojiLabel.feed andComment:emojiLabel.feedComment];
            }
        }else{
            [_listVC onFeedCommentDeleteResponse:emojiLabel.feed andComment:emojiLabel.feedComment];

        }
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
        [_listVC.navigationController pushViewController:avc animated:YES];
    }
}

#pragma mark - NIAttributedLabelDelegate
- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    if ([attributedLabel isEqual:_contentLb] || (NSTextCheckingTypeLink == result.resultType && [[result.URL absoluteString] hasPrefix:@"http"])) {
        NSString *resultStr = [result.URL absoluteString];
        //跳转到网页链接
        PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:resultStr];
        [_listVC.navigationController pushViewController:detailVc animated:YES];
        return;
    }
    NSString *resultStr = [result.URL absoluteString];
    NSString *resultStr1 = (NSString*)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)resultStr,CFSTR(""),kCFStringEncodingUTF8));
    NSArray *arr = [resultStr1 componentsSeparatedByString:@";;"];
    CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
    avc.userId = [[arr objectAtIndex:1] intValue];
    avc.nickName = [arr objectAtIndex:0];
    TXUser *otherUser = [[TXChatClient sharedInstance] getUserByUserId:[[arr objectAtIndex:1] intValue] error:nil];
    avc.portraitUrl = otherUser.avatarUrl;
    [_listVC.navigationController pushViewController:avc animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideMoreView" object:nil];
}

+ (CGFloat)GetListOtherCellHeight:(TXFeed *)feed
{
    CGSize nameSize = [UILabel contentSizeForLabelWithText:feed.userNickName maxWidth:MAXFLOAT font:kFontSubTitle];
    //    CGFloat height = 18 + nameSize.height;
    
    CGFloat height = 13 + 40 + 1 - nameSize.height;
    
    
    HTCopyableLabel *contentLb = [[HTCopyableLabel alloc] initClearColorWithFrame:CGRectZero];
    contentLb.textAlignment = NSTextAlignmentLeft;
    contentLb.numberOfLines = 6;
    contentLb.textColor = kColorBlack;
    contentLb.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //内容
    NSString *str = feed.content;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString nimbuskit_setTextColor:kColorBlack];
    [attributedString nimbuskit_setFont:kFontSubTitle];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:4];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    contentLb.attributedText = attributedString;
    
    CGFloat fullHeight = 0;
    CGSize size = CGSizeZero;
    if (!feed.isFold.boolValue) {
        contentLb.numberOfLines = 0;
        size = [contentLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
        fullHeight = 20;
    }else{
        contentLb.numberOfLines = 6;
        size = [contentLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
        
        HTCopyableLabel *tmpLb = [[HTCopyableLabel alloc] initWithFrame:CGRectZero];
        tmpLb.textAlignment = NSTextAlignmentLeft;
        tmpLb.numberOfLines = 0;
        tmpLb.attributedText = contentLb.attributedText;
        CGSize tmpSize = [tmpLb sizeThatFits:CGSizeMake(kScreenWidth - 78, MAXFLOAT)];
        if (tmpSize.height > size.height) {
            fullHeight = 20;
        }else{
            contentLb.numberOfLines = 6;
        }
    }
    if (fullHeight == 0 && (53 + 1 - nameSize.height + size.height) < 53) {
        height = 53;
    }else{
        height += (size.height + fullHeight);
    }
    
    
    NSInteger count = feed.attaches.count;
    __block CGFloat Y = 0;
    
    int width = (kScreenWidth - 78 - 10)/3;
    [feed.attaches enumerateObjectsUsingBlock:^(NSString *fileUrl, NSUInteger idx, BOOL *stop) {
        if (count == 1) {
//            if (feed.feedType == TXFeedTypeActivity) {
//                Y = (kScreenWidth - 78) * 3/4;
//            }else{
                int width = (kScreenWidth - 78)/3 * 2;
                int height = width * 3 /4;
                Y = height;
//            }
        }else if (count == 4 || count == 2){
            int width = (kScreenWidth - 78 - 5)/2;
            Y = idx/2 * (width + 5) + width;
        }else{
            Y = idx/3 * (width + 5) + width;
        }
    }];
    if (Y) {
        if (size.height == 0) {
            height = 14 + nameSize.height;
        }
        height += (10 + Y + 5 + 29);
    }else{
        height += (5 + 29);
    }
    
    __block CGFloat commentY = 0;
    if (feed.circleLikes.count) {
        commentY = feed.likeLb.maxY + 7;
    }
    if (feed.commentLbArr.count) {
        if (!commentY) {
            commentY += 7;
        }
        
        commentY += 7;
        
        [feed.commentLbArr enumerateObjectsUsingBlock:^(MLEmojiLabel *obj, NSUInteger idx, BOOL *stop) {
            obj.minY = commentY;
            obj.height_ -= 1;
            commentY += obj.height_;
            if (idx == feed.commentLbArr.count - 1 ) {
                commentY += 7;
            }
        }];
        if (feed.hasMore.boolValue) {
            commentY += 30;
        }
    }
    
    if (commentY) {
        height += (13 + commentY);
        height -= 3;
    }else{
        CGSize timeSize = [UILabel contentSizeForLabelWithText:[NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(feed.createdOn/1000)]] maxWidth:MAXFLOAT font:kFontSmall];
        height += 13 - (29 - timeSize.height)/2;
    }
    return height;
}


@end
