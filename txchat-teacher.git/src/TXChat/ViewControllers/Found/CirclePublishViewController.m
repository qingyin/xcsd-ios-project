//
//  CirclePublishViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/6.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CirclePublishViewController.h"
#import "CHSCharacterCountTextView.h"
#import "ALAssetsLibrary+Util.h"
#import "ELCAsset.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import <TXChatClient.h>
#import "uploadImageView.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "CircleDepartmentViewController.h"
#import "TXPhotoBrowserViewController.h"
#import "TXVideoPreviewViewController.h"
#import "TXVideoRecordManager.h"
#import "TXVideoCacheManager.h"
#import "TXSystemManager.h"

#define KIMAGETAGBASE (0x1000)
#define KMaxNotificationNumber 500
#define KMaxPhotos 9//最大图片数量
#define KRCVTITLEHIGHT 45.0f//收件人 控件高度
#define KPHOTOHIGHT  50.0f//photo的高度
#define KVIEWMARGIN (5.0f)
#define kVideoViewTag  100

@interface CirclePublishViewController ()<
    ELCImagePickerControllerDelegate,
    UIScrollViewDelegate,
    UploadImageDelegate,
    CHSCharacterCountTextViewDelegate,
    UIImagePickerControllerDelegate,
    TXImagePickerControllerDelegate>
{
    CHSCharacterCountTextView   *_textView;
    NSMutableArray *_selectedPhotos;//选中的图片
    UIScrollView *_scrollView;
    UIView *_contentView;
    UIView  *_rcvViews;             //接收者view
    UIView  *_classView;            //班级相册
    UIView  *_photoBKView;//图片 背景的view
    BOOL _isInputNoticeContent;//是否输入通知内容
    BOOL _isInputPhoto;
    BOOL _addToPhotos;          //是不是加入班级相册
}
@property (nonatomic,strong) NSMutableArray *selectedVideos;
@property (nonatomic,assign) BOOL addToPhotos;
@property (nonatomic,copy) NSString *videoServerFileURLString;

@end

@implementation CirclePublishViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _isInputNoticeContent = NO;
        _videoType = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    [self createPhotoList];
    
    self.addToPhotos = YES;
    
    NSString *selectStr= [NSString stringWithFormat:@"发送"];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (!_videoType) {
        [self.btnRight setEnabled:NO];
    }
    [self setupViews];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.view setBackgroundColor:kColorBackground];
    
    if (self.photoItemsArr.count > 0) {
        for (UIImage *image in self.photoItemsArr) {
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
            UIImage *retImage = [UIImage scaleImage:image scale:scale];
            if(retImage != nil)
            {
                _isInputPhoto = YES;
                [self updateRightBtnStatus];
                [self insertImageToUploadingList:retImage];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViews];
        });
    }
}


-(void)setupViews
{
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    contentView.userInteractionEnabled = YES;
    contentView.clipsToBounds = YES;
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    UIView *intervalView = [UIView new];
    [intervalView setBackgroundColor:kColorWhite];
    intervalView.userInteractionEnabled = YES;
    intervalView.clipsToBounds = YES;
    [_contentView addSubview:intervalView];
    
    
    _textView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:KMaxNotificationNumber placeHoder:nil];
    _textView.layer.borderColor = [UIColor clearColor].CGColor;
    _textView.backgroundColor = kColorWhite;
    _textView.userInteractionEnabled = YES;
    _textView.delegate = self;
    [_contentView addSubview:_textView];
    
    CGFloat hight = 135.0f;
    [intervalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView);
        make.top.mas_equalTo(_contentView).with.offset(0);
        make.height.mas_equalTo(hight);
        make.right.mas_equalTo(_contentView);
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView.mas_left).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(_contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(_contentView).with.offset(-kEdgeInsetsLeft);
        make.bottom.mas_equalTo(intervalView.mas_bottom);
    }];
    
    UIView *imageBKView = [UIView new];
    _photoBKView = imageBKView;
    [imageBKView setBackgroundColor:kColorWhite];
    imageBKView.userInteractionEnabled = YES;
    imageBKView.clipsToBounds = YES;
    [_contentView addSubview:imageBKView];
    
    //图片
    uploadImageView *lastView = nil;
    //    CGFloat margin = KVIEWMARGIN;
    CGFloat padding1 = kEdgeInsetsLeft;
    CGFloat padding2 = 5.0f;
    CGFloat photoHight = KPHOTOHIGHT;
    CGFloat viewWidth = self.view.frame.size.width;
    
    NSInteger count = 5;
    if((viewWidth - 2*kEdgeInsetsLeft)/(photoHight+padding2)  > count)
    {
        count = (viewWidth - 2*kEdgeInsetsLeft)/(photoHight+padding2);
        padding2 = (viewWidth - 2*kEdgeInsetsLeft - count*photoHight)/(count -1);
    }
    else
    {
        padding2 = (viewWidth - 2*kEdgeInsetsLeft - count*photoHight)/(count -1);
    }
    
    if (_videoType == YES) {
        if (_selectedVideos && [_selectedVideos count] > 0) {
            UploadImageStatus *status = _selectedVideos[0];
            uploadImageView *videoImage = [[uploadImageView alloc] initWithImage:status.uploadImage isShowDelImage:NO];
            [videoImage setBackgroundColor:kColorGray];
            videoImage.tag = kVideoViewTag;
            [_photoBKView addSubview:videoImage];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedVideoThumbView:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            tap.cancelsTouchesInView = NO;
            videoImage.userInteractionEnabled = YES;
            [videoImage addGestureRecognizer:tap];
            [videoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(_textView.mas_bottom).with.offset(padding1);
                make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
                make.size.mas_equalTo(CGSizeMake(67, 50));
            }];
            [videoImage updateUploadProcess:status.process];
            lastView = videoImage;
        }
    }else{
        for(NSInteger index = 0; index < [_selectedPhotos count]; index++)
        {
            uploadImageView *photoImage  = nil;
            UploadImageStatus *status = [_selectedPhotos objectAtIndex:index];
            if(index == [_selectedPhotos count] - 1)
            {
                photoImage = [[uploadImageView alloc] initWithImage:status.uploadImage isShowDelImage:NO];
            }
            else
            {
                photoImage = [[uploadImageView alloc] initWithImage:status.uploadImage isShowDelImage:YES];
            }
            photoImage.delegate = self;
            [photoImage setBackgroundColor:kColorWhite];
            photoImage.tag = KIMAGETAGBASE + index;
            [imageBKView addSubview:photoImage];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewTapEvent:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            //        tap.delegate = self;
            tap.cancelsTouchesInView = NO;
            photoImage.userInteractionEnabled = YES;
            [photoImage addGestureRecognizer:tap];
            //第一个
            if(lastView == nil)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.top.mas_equalTo(_textView.mas_bottom).with.offset(padding1);
                    make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
                    make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
                }];
            }
            else
            {
                //左排第一个
                if(index %count == 0)
                {
                    [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
                        make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
                        make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
                        
                    }];
                }
                else//左排第2，3
                {
                    [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(lastView.mas_right).with.offset(padding2);
                        make.top.mas_equalTo(lastView.mas_top).with.offset(0);
                        make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
                        
                    }];
                }
                
            }
            lastView = photoImage;
        }
    }
    
    [imageBKView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView);
        make.right.mas_equalTo(contentView);
        make.top.mas_equalTo(intervalView.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
    }];
    
    CGFloat rcvHight = KRCVTITLEHIGHT;
    UIView *rcvBk = [UIView new];
    _rcvViews = rcvBk;
    rcvBk.clipsToBounds = YES;
    [rcvBk setBackgroundColor:kColorWhite];
    [_contentView addSubview:rcvBk];
    {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(RcverViewTapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = NO;
        rcvBk.userInteractionEnabled = YES;
        [rcvBk addGestureRecognizer:tap];
    }
    
    NSError *error = nil;
    self.departmentIds = [NSMutableArray array];
    [[[TXChatClient sharedInstance] getAllDepartments:&error] enumerateObjectsUsingBlock:^(TXDepartment *department, NSUInteger idx, BOOL *stop) {
        [self.departmentIds addObject:@(department.departmentId)];
    }];
    
    if (!_departmentIds.count || _departmentIds.count == 1) {
        
        [rcvBk mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_contentView);
            make.top.mas_equalTo(imageBKView.mas_bottom).with.offset(5);
            make.size.mas_equalTo(CGSizeZero);
        }];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(rcvBk.mas_bottom);
        }];
        
        return;
    }
    
    [rcvBk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView);
        make.top.mas_equalTo(imageBKView.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(viewWidth, rcvHight));
    }];
    
    UILabel *rcvTitle = [UILabel new];
    [rcvTitle setText:@"可见人员"];
    [rcvTitle setTextAlignment:NSTextAlignmentLeft];
    [rcvTitle setTextColor:KColorTitleTxt];
    [rcvTitle setFont:kFontTitle];
    [rcvBk addSubview:rcvTitle];
    [rcvTitle sizeToFit];
    [rcvTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rcvBk).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(rcvBk);
        make.size.mas_equalTo(CGSizeMake(rcvTitle.width_, rcvHight));
    }];
    UILabel *rcvNames = [UILabel new];
    _rcvUsersLabel = rcvNames;
    rcvNames.textAlignment = NSTextAlignmentRight;
    [rcvNames setText:@"全部"];
    [rcvNames setFont:kFontTitle];
    [rcvNames setTextColor:kColorGray1];
    [rcvBk addSubview:rcvNames];
    
    UIImageView *rightArrow = [UIImageView new];
    [rightArrow setImage:[UIImage imageNamed:@"rightArrow"]];
    [rcvBk addSubview:rightArrow];
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(rcvBk);
        make.right.mas_equalTo(rcvBk.mas_right).with.offset(-kEdgeInsetsLeft);
        make.size.mas_equalTo(rightArrow.image.size);
    }];
    
    [rcvNames mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rcvTitle.mas_right).offset(10);
        make.top.mas_equalTo(rcvBk);
        make.height.mas_equalTo(rcvHight);
        make.right.mas_equalTo(rightArrow.mas_left).offset(-10);
    }];
    
    if (_videoType) {
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(rcvNames.mas_bottom);
        }];
        return;
    }
    UIView *classBk = [UIView new];
    _classView = classBk;
    classBk.clipsToBounds = YES;
    [classBk setBackgroundColor:kColorWhite];
    [_contentView addSubview:classBk];
    
    [classBk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView);
        make.top.mas_equalTo(rcvBk.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(viewWidth, rcvHight));
    }];
    
    UILabel *classTitle = [UILabel new];
    [classTitle setText:@"同步照片到班级相册"];
    [classTitle setTextAlignment:NSTextAlignmentLeft];
    [classTitle setTextColor:KColorTitleTxt];
    [classTitle setFont:kFontTitle];
    [classBk addSubview:classTitle];
    [classTitle sizeToFit];
    [classTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(classBk).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(classBk);
        make.size.mas_equalTo(CGSizeMake(classTitle.width_, rcvHight));
    }];
    UISwitch *classSwitch = [[UISwitch alloc] init];
    [classSwitch setOn:YES];
    [classSwitch setOnTintColor:KColorAppMain];
    [classSwitch addTarget:self action:@selector(onAddClassPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [classBk addSubview:classSwitch];
    [classSwitch sizeToFit];
    [classSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(classBk);
        make.right.mas_equalTo(classBk.mas_right).with.offset(-kEdgeInsetsLeft);
        make.size.mas_equalTo(classSwitch.frame.size);
    }];
    
    if (_classView) {
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(classBk.mas_bottom);
        }];
    }else{
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_photoBKView.mas_bottom);
        }];
    }
    
    
}

- (void)onAddClassPhoto:(UISwitch *)classSwitch{
    self.addToPhotos = classSwitch.on;
}


-(void)createPhotoList
{
    if (_videoType == YES) {
        //视频
        self.selectedVideos = [NSMutableArray array];
        if (_videoURL) {
            UploadImageStatus *status = [[UploadImageStatus alloc] init];
            NSUUID *uploadKey = [NSUUID UUID];
            status.uploadStatus = UPLOADIMAGE_STATUS_UPLOADING;
            status.uuidKey = uploadKey;
            status.videoURL = _videoURL;
            status.process = 0.f;
            if (_videoThumbImage) {
                status.uploadImage = _videoThumbImage;
            }else if(_videoURL){
                UIImage *image = [[TXVideoRecordManager alloc] videoThumbnailFromURL:_videoURL];
                status.uploadImage = image;
            }
            [_selectedVideos addObject:status];
            //开始上传视频
            [self uploadVideoToQiniuWithItem:status];
        }
    }else{
        //照片
        _selectedPhotos = [NSMutableArray arrayWithCapacity:1];
        UploadImageStatus *status = [[UploadImageStatus alloc] init];
        status.uploadImage = [UIImage imageNamed:@"medicine_AddNewPhoto"];
        [_selectedPhotos addObject:status];
    }
}
//上传视频到七牛
- (void)uploadVideoToQiniuWithItem:(UploadImageStatus *)item
{
    @autoreleasepool {
        NSError *error = nil;
        NSString *filePath = [_videoURL relativePath];
        //        NSLog(@"videoURL:%@",_videoURL);
        //        NSLog(@"filePath:%@",filePath);
        NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
        if (error) {
            DDLogDebug(@"上传时转换成data失败:%@",error);
            return;
        }
        if ([data length] == 0) {
            DDLogDebug(@"上传时转换的data为空");
            return;
        }
        WEAKSELF
        [[TXChatClient sharedInstance] uploadData:data uuidKey:item.uuidKey fileExtension:@"mp4" cancellationSignal:^BOOL{
            if (weakSelf == nil) {
                //                NSLog(@"视图被销毁了，取消上传");
                return YES;
            }
            return NO;
        } progressHandler:^(NSString *key, float percent) {
            STRONGSELF
            //            NSLog(@"视频进度:%@",@(percent));
            item.process = percent;
            
            if (strongSelf) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadImageView *uploadImage = (uploadImageView *)[strongSelf->_photoBKView viewWithTag:kVideoViewTag];
                    [uploadImage updateViewStatus:UPLOADIMAGE_STATUS_UPLOADING];
                    [uploadImage updateUploadProcess:item.process];
                });
            }
        } onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl) {
            STRONGSELF
            if (error) {
                item.uploadStatus = UPLOADIMAGE_STATUS_FAILED;
            }else{
                item.uploadStatus = UPLOADIMAGE_STATUS_NORMAL;
                item.serverFileKey = serverFileKey;
                item.serverFileUrl = serverFileUrl;
            }
            if (strongSelf) {
                if (!error) {
                    strongSelf.videoServerFileURLString = serverFileUrl;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadImageView *uploadImage = (uploadImageView *)[strongSelf->_photoBKView viewWithTag:kVideoViewTag];
                    [uploadImage updateViewStatus:item.uploadStatus];
                });
            }
        }];
    }
}

-(void)updateViews
{
    for(UIView *subView in _photoBKView.subviews)
    {
        //        if([subView isKindOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }
    }
    
    uploadImageView *lastView = nil;
    CGFloat padding1 = kEdgeInsetsLeft;
    CGFloat padding2 = 5.0f;
    CGFloat photoHight = KPHOTOHIGHT;
    CGFloat viewWidth = self.view.frame.size.width;
    
    NSInteger count = 3;
    if((viewWidth - 2*kEdgeInsetsLeft)/(photoHight+padding2)  > count)
    {
        count = (viewWidth - 2*kEdgeInsetsLeft)/(photoHight+padding2);
        padding2 = (viewWidth - 2*kEdgeInsetsLeft - count*photoHight)/(count -1);
    }
    else
    {
        padding2 = (viewWidth - 2*kEdgeInsetsLeft - count*photoHight)/(count -1);
    }
    
    for(NSInteger index = 0; index < [_selectedPhotos count] && index < KMaxPhotos; index++)
    {
        uploadImageView *photoImage  = nil;
        UploadImageStatus *status = [_selectedPhotos objectAtIndex:index];
        if(index == [_selectedPhotos count] - 1)
        {
            photoImage = [[uploadImageView alloc] initWithImage:status.uploadImage isShowDelImage:NO];
        }
        else
        {
            photoImage = [[uploadImageView alloc] initWithImage:status.uploadImage isShowDelImage:YES];
        }
        [photoImage updateUploadProcess:status.process];
        photoImage.delegate = self;
        [photoImage setBackgroundColor:kColorWhite];
        photoImage.tag = KIMAGETAGBASE + index;
        [_photoBKView addSubview:photoImage];
        [photoImage updateViewStatus:status.uploadStatus];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewTapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        //        tap.delegate = self;
        tap.cancelsTouchesInView = NO;
        photoImage.userInteractionEnabled = YES;
        [photoImage addGestureRecognizer:tap];
        //第一个
        if(lastView == nil)
        {
            [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.mas_equalTo(_textView.mas_bottom).with.offset(padding1);
                make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
                make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %count == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
                    make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
                    
                }];
            }
            else//左排第2，3
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(lastView.mas_right).with.offset(padding2);
                    make.top.mas_equalTo(lastView.mas_top).with.offset(0);
                    make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
                    
                }];
            }
            
        }
        lastView = photoImage;
    }
    
    [_photoBKView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];
    
    [_rcvViews mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_photoBKView.mas_bottom).with.offset(5);;
    }];
    
    if (_classView) {
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_classView.mas_bottom);
        }];
    }else{
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_photoBKView.mas_bottom);
        }];

    }
}

-(void)viewDidLayoutSubviews
{
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 620)];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        if (_videoType) {
            if (_videoBackVc) {
                NSArray *vcs = self.navigationController.viewControllers;
                if ([vcs containsObject:_videoBackVc]) {
                    [self.navigationController popToViewController:_videoBackVc animated:YES];
                }else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        //去除键盘
        [_textView resignFirstResponder];
        if([self isUploading])
        {
            [self uploadingDialog];
        }
        else
        {
            if (_videoType == YES) {
                if ([self isVideoUploadFailed]) {
                    [self showFailedHudWithTitle:@"视频正在失败,请重试"];
                    return;
                }
                [self sendVideoFeed];
            }else{
                [self sendNotice];
            }
        }
    }
}
//发送视频feed
- (void)sendVideoFeed
{
    if (!_selectedVideos || [_selectedVideos count] <= 0) {
        return;
    }
    __weak __typeof(&*self) weakSelf=self;  //by sck
    UploadImageStatus *item = _selectedVideos[0];
    
    NSMutableArray *videoArray = [NSMutableArray array];
    TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
    txpbAttachBuilder.attachType = TXPBAttachTypeVedio;
    txpbAttachBuilder.fileurl = item.serverFileKey;
    TXPBAttach *txpbAttach = [txpbAttachBuilder build];
    [videoArray addObject:txpbAttach];
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance].feedManager sendFeed:[_textView.getContent trim] attaches:videoArray departmentIds:_departmentIds syncToDepartmentPhoto:NO onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (error) {
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"发布圈子",@"是", @"是否视频",nil] counter:1];
            [weakSelf showFailedHudWithError:error];
        }else{
            
            [[TXChatClient sharedInstance].dataReportManager reportEvent:XCSDPBEventTypeFeed];
            
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"发布圈子",@"是", @"是否视频", nil] counter:1];
            //将视频挪移到缓存目录
            [[TXVideoCacheManager sharedManager] copyVideoToCachedFolderWithPath:_videoURL serverFileUrl:self.videoServerFileURLString deleteOriginalFile:YES];
            //回调返回
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:[NSNumber numberWithBool:YES]];
                if (_videoType) {
                    if (_videoBackVc) {
                        NSArray *vcs = self.navigationController.viewControllers;
                        if ([vcs containsObject:_videoBackVc]) {
                            [self.navigationController popToViewController:_videoBackVc animated:YES];
                        }else{
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }else{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }else{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            });
        }
    }];
}
-(void)sendNotice
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    
    NSRange range = {0, [_selectedPhotos count]-1};
    NSArray *arr = [NSArray arrayWithArray:[_selectedPhotos subarrayWithRange:range]];
    NSMutableArray *photoArray = [NSMutableArray array];
    for(UploadImageStatus *photoIndex in arr)
    {
        TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
        txpbAttachBuilder.attachType = TXPBAttachTypePic;
        txpbAttachBuilder.fileurl = photoIndex.serverFileKey;
        TXPBAttach *txpbAttach = [txpbAttachBuilder build];
        [photoArray addObject:txpbAttach];
        //将图片缓存下来，避免二次加载
        [[TXSystemManager sharedManager] saveImageToCache:photoIndex.uploadImage forURLString:[photoIndex.serverFileUrl getFormatPhotoUrl]];
    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance].feedManager sendFeed:[_textView.getContent trim] attaches:photoArray departmentIds:_departmentIds syncToDepartmentPhoto:_addToPhotos  onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (error) {
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"发布圈子",@(arr.count), @"图片数量",nil] counter:1];
            [weakSelf showFailedHudWithError:error];
        }else{
            
            [[TXChatClient sharedInstance].dataReportManager reportEvent:XCSDPBEventTypeFeed];
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"发布圈子",@(arr.count), @"图片数量", nil] counter:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:[NSNumber numberWithBool:YES]];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)RcverViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    [self showSelectGroup];
}
-(void)showSelectGroup
{
    CircleDepartmentViewController *avc = [[CircleDepartmentViewController alloc] init];
    avc.publishVC = self;
    [self.navigationController pushViewController:avc animated:YES];
}

-(void)reuploadImageItem:(UploadImageStatus *)uploadImageItem index:(NSUInteger)index
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    ButtonItem *reuploadAgain = [ButtonItem itemWithLabel:@"重试" andTextColor:kColorBlack action:^{
        [weakSelf reuploadImage:uploadImageItem];
        [weakSelf updateViews];
    } ];
    ButtonItem *delItem = [ButtonItem itemWithLabel:@"删除" andTextColor:kColorBlack action:^{
        [weakSelf delItem:index +KIMAGETAGBASE];
    } ];
    [self showAlertViewWithMessage:@"重新上传图片" andButtonItems:reuploadAgain, delItem,nil];
}

-(BOOL)isUploading
{
    if (_videoType == YES) {
        if (_selectedVideos && [_selectedVideos count] > 0) {
            UploadImageStatus *status = _selectedVideos[0];
            if (status.uploadStatus == UPLOADIMAGE_STATUS_UPLOADING) {
                return YES;
            }
        }
        return NO;
    }
    __block BOOL ret = NO;
    [_selectedPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UploadImageStatus *uploadStatus = (UploadImageStatus *)obj;
        if(uploadStatus.uploadStatus == UPLOADIMAGE_STATUS_UPLOADING)
        {
            *stop = YES;
            ret = YES;
        }
    }];
    return ret;
}
-(BOOL)isVideoUploadFailed
{
    if (_selectedVideos && [_selectedVideos count] > 0) {
        UploadImageStatus *status = _selectedVideos[0];
        if (status.uploadStatus == UPLOADIMAGE_STATUS_FAILED) {
            return YES;
        }
    }
    return NO;
}
-(void)uploadingDialog
{
    if (_videoType == YES) {
        [self showFailedHudWithTitle:@"视频正在上传请稍等"];
    }else{
        [self showFailedHudWithTitle:@"图片正在上传请稍等"];
    }
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)infos
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [picker dismissViewControllerAnimated:YES completion:^{
        for (NSDictionary *info in infos) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            //            image = [self saveImage:image];
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
            UIImage *retImage = [UIImage scaleImage:image scale:scale];
            if(retImage != nil)
            {
                _isInputPhoto = YES;
                [self updateRightBtnStatus];
                [weakSelf insertImageToUploadingList:retImage];
            }
        }
        __weak __typeof(&*self) weakSelf=self;  //by sck
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateViews];
        });
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    [picker dismissViewControllerAnimated:YES completion:^{
        CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
        UIImage *retImage = [UIImage scaleImage:image scale:scale];
        if(retImage != nil)
        {
            _isInputPhoto = YES;
            [self updateRightBtnStatus];
            [self insertImageToUploadingList:retImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViews];
        });
    }];
}

-(void)insertImageToUploadingList:(UIImage *)newImage
{
    NSUUID *uploadKey = [NSUUID UUID];
    UploadImageStatus *status = [[UploadImageStatus alloc] init];
    status.uploadImage = newImage;
    status.uploadStatus = UPLOADIMAGE_STATUS_UPLOADING;
    status.uuidKey = uploadKey;
    [_selectedPhotos insertObject:status atIndex:[_selectedPhotos count]-1];
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.8f);
    DLog(@"uploadKey:%@", uploadKey);
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] uploadData:imageData uuidKey:uploadKey fileExtension:@"jpg" cancellationSignal:^BOOL{
        
        return NO;
    } progressHandler:^(NSString *key, float percent) {
        [weakSelf updateProcess:key process:percent];
    } onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl) {
        DLog(@"error:%@, key:%@ fileUrl:%@", error, serverFileKey, serverFileUrl);
        NSString *uploadKey = [serverFileKey stringByDeletingPathExtension];
        //更新 上传view状态
        [_selectedPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UploadImageStatus *status = (UploadImageStatus *)obj;
            if([[status.uuidKey UUIDString] isEqualToString:uploadKey])
            {
                if(error)
                {
                    status.uploadStatus = UPLOADIMAGE_STATUS_FAILED;
                }
                else
                {
                    status.uploadStatus = UPLOADIMAGE_STATUS_NORMAL;
                    status.serverFileKey = serverFileKey;
                    status.serverFileUrl = serverFileUrl;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadImageView *uploadImage = (uploadImageView *)[_photoBKView viewWithTag:KIMAGETAGBASE + idx];
                [uploadImage updateViewStatus:status.uploadStatus];
            });
        }];
    }];
}

-(void)reuploadImage:(UploadImageStatus *)reuploadImageItem
{
    if(reuploadImageItem == nil)
    {
        return;
    }
    NSData *imageData = UIImageJPEGRepresentation(reuploadImageItem.uploadImage,  0.8f);
    DLog(@"uploadKey:%@", reuploadImageItem.uuidKey);
    reuploadImageItem.uploadStatus = UPLOADIMAGE_STATUS_UPLOADING;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] uploadData:imageData uuidKey:reuploadImageItem.uuidKey fileExtension:@"jpg" cancellationSignal:^BOOL{
        
        return NO;
    } progressHandler:^(NSString *key, float percent) {
        [weakSelf updateProcess:key process:percent];
    } onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl)
     {
         DLog(@"error:%@, key:%@ fileUrl:%@", error, serverFileKey, serverFileUrl);
         NSString *uploadKey = [serverFileKey stringByDeletingPathExtension];
         //更新 上传view状态
         [_selectedPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             UploadImageStatus *status = (UploadImageStatus *)obj;
             if([[status.uuidKey UUIDString] isEqualToString:uploadKey ])
             {
                 if(error)
                 {
                     status.uploadStatus = UPLOADIMAGE_STATUS_FAILED;
                 }
                 else
                 {
                     status.uploadStatus = UPLOADIMAGE_STATUS_NORMAL;
                     status.serverFileKey = serverFileKey;
                     status.serverFileUrl = serverFileUrl;
                 }
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 uploadImageView *uploadImage = (uploadImageView *)[_photoBKView viewWithTag:KIMAGETAGBASE + idx];
                 [uploadImage updateViewStatus:status.uploadStatus];
             });
         }];
     }];
    
}

-(void)updateProcess:(NSString *)key process:(CGFloat)processValue
{
    NSString *uploadKey = [key stringByDeletingPathExtension];
    NSUInteger index = [self getIndex:uploadKey];
    if(index == NSNotFound)
    {
        return;
    }
    UploadImageStatus *currentUploadImage = [_selectedPhotos objectAtIndex:index];
    currentUploadImage.process = processValue;
    uploadImageView *uploadImage = (uploadImageView *)[_photoBKView viewWithTag:KIMAGETAGBASE + index];
    [uploadImage updateUploadProcess:processValue];
    
}

-(NSUInteger)getIndex:(NSString *)key
{
    NSUInteger index = NSNotFound;
    for(NSUInteger i = 0; i < [_selectedPhotos count]; i++)
    {
        UploadImageStatus *currentImageStatus = [_selectedPhotos objectAtIndex:i];
        if([[currentImageStatus.uuidKey UUIDString] isEqualToString:key])
        {
            index = i;
            break;
        }
    }
    return index;
}


- (UIImage *)saveImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    NSInteger hight = (kImageMaxWidthPixelSize * image.size.height)/image.size.width;
    image = [image imageTo4b3AtSize:CGSizeMake(kImageMaxWidthPixelSize, hight)];
    return image;
}


- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker didSelcetedNumber:(NSInteger)number
{
    NSInteger count = KMaxPhotos - ([_selectedPhotos count] -1);
    
    if(number >= count)
    {
        AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        [appdelegate.window showAlertViewWithMessage:@"最多只能上传9张图片" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
        return NO;
    }
    return YES;
}
#pragma mark - TXImagePickerControllerDelegate methods
- (void)imagePickerController:(TXImagePickerController *)picker didFinishPickingImages:(NSArray *)imageArray
{
    for (UIImage *image in imageArray) {
        CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
        UIImage *retImage = [UIImage scaleImage:image scale:scale];
        if(retImage != nil)
        {
            _isInputPhoto = YES;
            [self updateRightBtnStatus];
            [self insertImageToUploadingList:retImage];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViews];
    });
    [super didFinishImagePicker:picker];
}

#pragma mark - UploadImageDelegate
-(void)delItem:(NSInteger)viewTag
{
    NSInteger index = viewTag - KIMAGETAGBASE;
    if(index >= 0 && index < [_selectedPhotos count])
    {
        [_selectedPhotos removeObjectAtIndex:index];
        if (_selectedPhotos.count<=1) {
            _isInputPhoto = NO;
            [self updateRightBtnStatus];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViews];
        });
    }
    
}

//点击了视频
- (void)tappedVideoThumbView:(UITapGestureRecognizer *)gesture
{
    [_textView endEditing:YES];
    if (_selectedVideos && [_selectedVideos count] > 0) {
        UploadImageStatus *uploadImageItem = _selectedVideos[0];
        TXVideoPreviewViewController *videoVc = [[TXVideoPreviewViewController alloc] initWithVideoURLString:uploadImageItem.videoURL.relativePath];
        videoVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:videoVc animated:YES completion:nil];
    }
}

//点击图片后处理
-(void)timeViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    [_textView endEditing:YES];
    NSInteger index = recognizer.view.tag - KIMAGETAGBASE;
    DLog(@"tag:%ld", (long)index);
    WEAKSELF
    if(index == [_selectedPhotos count] -1)
    {
        [self showNormalSheetWithTitle:nil items:@[@"拍照",@"从手机相册选择"] clickHandler:^(NSInteger index) {
            if (index == 0) {
                UIImagePickerController *photoPickerController = [[UIImagePickerController alloc]init];
                photoPickerController.view.backgroundColor = kColorClear;
                UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
                photoPickerController.sourceType = sourcheType;
                photoPickerController.delegate = self;
                photoPickerController.allowsEditing = NO;
                [weakSelf.navigationController presentViewController:photoPickerController animated:YES completion:NULL];
            }else if (index == 1){
                //相册
                STRONGSELF
                if (strongSelf) {
                    [[TXSystemManager sharedManager] requestPhotoPermissionWithBlock:^(BOOL photoGranted) {
                        if (photoGranted) {
                            //已授权相册访问
                            [strongSelf showImagePickerControllerWithCurrentSelectedCount:([strongSelf->_selectedPhotos count] -1)];
                        }else{
                            //未授权相册访问
                            [strongSelf showPhotoPermissionDeniedAlert];
                        }
                    }];
                }
            }
        } completion:nil];
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
//        [actionSheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//            if (buttonIndex == 0) {
//                UIImagePickerController *photoPickerController = [[UIImagePickerController alloc]init];
//                photoPickerController.view.backgroundColor = kColorClear;
//                UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
//                photoPickerController.sourceType = sourcheType;
//                photoPickerController.delegate = self;
//                photoPickerController.allowsEditing = NO;
//                [weakSelf.navigationController presentViewController:photoPickerController animated:YES completion:NULL];
//            }else if (buttonIndex == 1){
//                //相册
//                STRONGSELF
//                if (strongSelf) {
//                    [strongSelf showImagePickerControllerWithCurrentSelectedCount:([strongSelf->_selectedPhotos count] -1)];
//                }
////                ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
////                ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
////                [albumController setParent:imagePicker];
////                [imagePicker setDelegate:self];
////                [weakSelf.navigationController presentViewController:imagePicker animated:YES completion:NULL];
//            }
//        }];
    }
    else
    {
        //正在上传的无法点击 失败的提示重传
        if(index >= 0 && index < [_selectedPhotos count])
        {
            UploadImageStatus *uploadImageItem = [_selectedPhotos objectAtIndex:index];
            if(uploadImageItem.uploadStatus == UPLOADIMAGE_STATUS_FAILED)
            {
                [self reuploadImageItem:uploadImageItem index:index];
                return;
            }
            else if(uploadImageItem.uploadStatus == UPLOADIMAGE_STATUS_UPLOADING)
            {
                return;
            }
        }
        
        NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:2];
        for(UploadImageStatus *uploadStatus in _selectedPhotos)
        {
            if(uploadStatus != [_selectedPhotos lastObject] && uploadStatus.uploadStatus == UPLOADIMAGE_STATUS_NORMAL)
            {
                [imageUrls addObject:uploadStatus.uploadImage];
            }
        }
        
        TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
        [browerVc showBrowserWithImages:imageUrls currentIndex:index];
        browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:browerVc animated:YES completion:nil];
    }
}

- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    //去除键盘
    [_textView resignFirstResponder];
}

#pragma mark - CHSCharacterCountTextViewDelegate
-(void)characterCountTextViewIsShowPlaceholder:(BOOL)isShowPlaceholder
{
    if([_textView.getContent trim].length == 0)
    {
        _isInputNoticeContent = NO;
    }
    else
    {
        _isInputNoticeContent = !isShowPlaceholder;
    }
    [self updateRightBtnStatus];
}

-(void)updateRightBtnStatus
{
    if (!_videoType) {
        [self.btnRight setEnabled:(_isInputNoticeContent || _isInputPhoto)];
    }
}
@end
