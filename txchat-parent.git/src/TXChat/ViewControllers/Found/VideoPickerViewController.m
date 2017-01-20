//
//  VideoPickerViewController.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/6/21.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "VideoPickerViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VideoPlayerView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <JFImageManager.h>
#import "TXCropVideoButton.h"
#import <Photos/PHAsset.h>
#import <Photos/PHImageManager.h>
#import <Photos/PHFetchOptions.h>

static NSInteger const kAddVideoButtonTag = 100;
static NSInteger const kVideoButtonTag = 200;
static double const kVideoMaximumDuration = 300;  //最长5分钟
static double const kVideoMinimalDuration = 3;  //最短3秒钟
static CGFloat const kVideoMargin = 10;

@interface VideoPickerViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
{
    UIView *_topLineView;
    UIScrollView *_videoScrollView;
    UIView *_lastVideoView;
    ALAssetsLibrary *_assetsLibrary;  //须强持有library对象，避免存储asset到array之后获取不到数据的问题
    NSInteger _currentIndex;
}
@property (nonatomic,strong) VideoPlayerView *playerView;
@property (nonatomic,strong) NSMutableArray *allVideos;
@end

@implementation VideoPickerViewController

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [self.playerView stopPlay];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_interactivePopDisabled = YES;
    self.allVideos = [[NSMutableArray alloc] init];
    _currentIndex = -1;
    [self createDarkNavigationBar];
    [self setupVideoPlayView];
    [self setupVideosScrollView];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.playerView stopPlay];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self playCurrentVideo];
}
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
#pragma mark - 视图创建
- (void)createDarkNavigationBar
{
    self.view.backgroundColor = RGBCOLOR(0x21, 0x21, 0x21);
    _topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationHeight + kStatusBarHeight, self.view.width_, 0.5)];
    _topLineView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_topLineView];
    //取消
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, kStatusBarHeight, 60, kNavigationHeight);
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [backButton setTitleColor:RGBCOLOR(0xfa, 0xfa, 0xfa) forState:UIControlStateNormal];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    //导入
    UIButton *importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    importButton.frame = CGRectMake(self.view.width_ - 70, kStatusBarHeight, 60, kNavigationHeight);
    importButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    importButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [importButton setTitleColor:RGBCOLOR(0xfa, 0xfa, 0xfa) forState:UIControlStateNormal];
    [importButton setTitle:@"导入" forState:UIControlStateNormal];
    [importButton addTarget:self action:@selector(onSelectVideoAndCropButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:importButton];
}
- (void)setupVideoPlayView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat ratio = 480.f / 360.f;
    CGFloat height = width / ratio;
    self.playerView = [[VideoPlayerView alloc] initWithFrame:CGRectMake(0, _topLineView.maxY, width, height) type:VideoPlayType_Normal];
    WEAKSELF
    self.playerView.playStatusBlock = ^(BOOL isCanPlay) {
        if (!isCanPlay) {
            STRONGSELF
            if (strongSelf) {
                [strongSelf showFailedHudWithTitle:@"视频无法播放"];
            }
        }
    };
    [self.view addSubview:self.playerView];
    //添加分割线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.playerView.maxY, self.view.width_, 0.5)];
    bottomLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomLine];
    //添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectVideoAndCrop)];
    [self.playerView addGestureRecognizer:tapGesture];
}
- (void)setupVideosScrollView
{
    CGFloat height = 90;
    CGFloat y = self.playerView.maxY + 63;
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        y = self.playerView.maxY + 34;
    }
    _videoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, self.view.width_, height)];
    _videoScrollView.backgroundColor = [UIColor clearColor];
    _videoScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_videoScrollView];
    //添加相册按钮
    [self setupAddVideoView];
    //读取本地视频集
    [self fetchAllVideoLessThanSeconds:kVideoMaximumDuration];
}
//从本地相册添加按钮
- (void)setupAddVideoView
{
    UIButton *addVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addVideoBtn.frame = CGRectMake(kVideoMargin, 0, 90, 90);
    addVideoBtn.tag = kAddVideoButtonTag;
    [addVideoBtn setImage:[UIImage imageNamed:@"crop_addLocalVideo"] forState:UIControlStateNormal];
    [addVideoBtn addTarget:self action:@selector(onAddLocalVideoPickHandled:) forControlEvents:UIControlEventTouchUpInside];
    [_videoScrollView addSubview:addVideoBtn];
    _lastVideoView = addVideoBtn;
}
- (void)updateScrollViewWithVideos:(NSArray *)videos
{
    [self.allVideos addObjectsFromArray:videos];
    _currentIndex = 0;
    //移除旧视图
    [_videoScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupAddVideoView];
    //更新视图
    for (NSInteger i = 0; i < [self.allVideos count]; i++) {
        TXCropVideoButton *videoBtn = [[TXCropVideoButton alloc] initWithFrame:CGRectMake(_lastVideoView.maxX + kVideoMargin, 0, 90, 90)];
        videoBtn.tag = kVideoButtonTag + i;
        videoBtn.layer.cornerRadius = 2.f;
        videoBtn.layer.masksToBounds = YES;
        [videoBtn addTarget:self action:@selector(onClickVideoButton:) forControlEvents:UIControlEventTouchUpInside];
        [_videoScrollView addSubview:videoBtn];
        _lastVideoView = videoBtn;
        //显示缩略图
        id video = self.allVideos[i];
        if ([video isKindOfClass:[ALAsset class]]) {
            ALAsset *asset = (ALAsset *)video;
            //缩略图
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            videoBtn.thumbImage = image;
            //时长
            id length = [asset valueForProperty:ALAssetPropertyDuration];
            if (length && [length integerValue] > 0) {
                videoBtn.videoLength = [NSString stringWithFormat:@"%02ld:%02ld",[length integerValue] / 60,[length integerValue] % 60];
            }
        }else if ([video isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = (PHAsset *)video;
            //缩略图
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.synchronous = YES;
            option.resizeMode = PHImageRequestOptionsResizeModeExact;
            option.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(160, 160) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    videoBtn.thumbImage = result;
                });
            }];
            //时长
            NSTimeInterval length = asset.duration;
            if (length && length > 0) {
                videoBtn.videoLength = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)length / 60,(NSInteger)length % 60];
            }
        }
        //选中第一个
        if (i == _currentIndex) {
            [videoBtn setSelected:YES];
        }
    }
    //更新contentSize
    [_videoScrollView setContentSize:CGSizeMake(_lastVideoView.maxX + kVideoMargin, _videoScrollView.height_)];
    //显示视频总数及时长限制
    CGFloat totalOffset = 16;
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        totalOffset = 13;
    }
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height_ - 30, self.view.width_, 20)];
    totalLabel.backgroundColor = [UIColor clearColor];
    totalLabel.textColor = RGBCOLOR(0xfa, 0xf9, 0xf9);
    totalLabel.font = [UIFont systemFontOfSize:11];
    totalLabel.textAlignment = NSTextAlignmentCenter;
    totalLabel.text = [NSString stringWithFormat:@"%@个视频（仅支持少于5分钟的视频）",@(self.allVideos.count)];
    [self.view addSubview:totalLabel];
    CGSize size = [totalLabel sizeThatFits:CGSizeMake(self.view.width_, 20)];
    totalLabel.frame = CGRectMake(0, self.view.height_ - size.height - totalOffset, self.view.width_, size.height);
    //选中第一个视频并播放
    [self playCurrentVideo];
}
#pragma mark - 按钮点击响应
- (void)onBackButtonTapped
{
    if (_isPresentType) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)onSelectVideoAndCropButtonTapped
{
    [self selectVideoAndCrop];
}
//点击了添加按钮
- (void)onAddLocalVideoPickHandled:(UIButton *)btn
{
    UIImagePickerController *photoPickerController = [[UIImagePickerController alloc]init];
    photoPickerController.view.backgroundColor = kColorClear;
    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPickerController.sourceType = sourcheType;
    photoPickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
    photoPickerController.allowsEditing = YES;
    photoPickerController.videoMaximumDuration = kVideoMaximumDuration;
    photoPickerController.delegate = self;
    [self.navigationController presentViewController:photoPickerController animated:YES completion:NULL];
}
- (void)onClickVideoButton:(TXCropVideoButton *)btn
{
    NSInteger index = btn.tag - kVideoButtonTag;
    if (index == _currentIndex) {
        return;
    }
    //取消选中效果
    TXCropVideoButton *previousBtn = [_videoScrollView viewWithTag:kVideoButtonTag + _currentIndex];
    [previousBtn setSelected:NO];
    [btn setSelected:YES];
    id video = self.allVideos[index];
    if ([video isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)video;
        NSURL *videoURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        if (videoURL) {
            [self.playerView playWithURL:videoURL];
            _currentIndex = index;
        }
    }else if ([video isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = (PHAsset *)video;
        //获取URL
        PHVideoRequestOptions *option = [PHVideoRequestOptions new];
        option.networkAccessAllowed = YES;
        option.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    NSURL *videoURL = urlAsset.URL;
                    if (videoURL) {
                        [self.playerView playWithURL:videoURL];
                        _currentIndex = index;
                    }
                }
            });
        }];
    }
}
#pragma mark - 视频读取+播放
- (void)playCurrentVideo
{
    if (_currentIndex != -1) {
        //播放视频
        if ([self.allVideos count] == 0) {
            return;
        }
        id video = self.allVideos[_currentIndex];
        if ([video isKindOfClass:[ALAsset class]]) {
            ALAsset *asset = (ALAsset *)video;
            NSURL *videoURL = [asset valueForProperty:ALAssetPropertyAssetURL];
            if (videoURL) {
                [self.playerView playWithURL:videoURL];
            }
        }else if ([video isKindOfClass:[PHAsset class]]) {
            PHAsset *asset = (PHAsset *)video;
            //获取URL
            PHVideoRequestOptions *option = [PHVideoRequestOptions new];
            option.networkAccessAllowed = YES;
            option.version = PHVideoRequestOptionsVersionOriginal;
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([asset isKindOfClass:[AVURLAsset class]]) {
                        AVURLAsset *urlAsset = (AVURLAsset *)asset;
                        NSURL *videoURL = urlAsset.URL;
                        if (videoURL) {
                            [self.playerView playWithURL:videoURL];
                        }
                    }
                });
            }];
        }
    }
}
//选择视频裁剪
- (void)selectVideoAndCrop
{
    if (self.allVideos.count == 0) {
        NSLog(@"没有视频");
        return;
    }
    id video = self.allVideos[_currentIndex];
    NSURL *videoURL;
    if ([video isKindOfClass:[ALAsset class]]) {
        ALAsset *asset = (ALAsset *)video;
        videoURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        if (!videoURL) {
            NSLog(@"视频URL为空");
            return;
        }
        AVAsset *videoAsset = [AVAsset assetWithURL:videoURL];
        if (!videoAsset.composable) {
            DDLogDebug(@"不可composable");
            [self showFailedHudWithTitle:@"该视频内容不支持编辑，请重新选择视频"];
            return;
        }
        if (!videoAsset.exportable) {
            DDLogDebug(@"不可export");
            [self showFailedHudWithTitle:@"该视频内容不支持导出，请重新选择视频"];
            return;
        }
        if (videoAsset.hasProtectedContent) {
            DDLogDebug(@"有含保护的内容");
            [self showFailedHudWithTitle:@"该视频含有被保护的内容，请重新选择视频"];
            return;
        }
        NSDate *videoDate = nil;
        AVMetadataItem *creationDate = videoAsset.creationDate;
        id value = creationDate.value;
        if ([value isKindOfClass:[NSDate class]]) {
            videoDate = (NSDate *)value;
        }
        VideoCropViewController *vc = [[VideoCropViewController alloc] initWithVideoURL:videoURL];
        vc.finishBlock = self.finishBlock;
        vc.videoDate = videoDate;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([video isKindOfClass:[PHAsset class]]) {
        PHAsset *asset = (PHAsset *)video;
        //获取URL
        PHVideoRequestOptions *option = [PHVideoRequestOptions new];
        option.networkAccessAllowed = YES;
        option.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    NSURL *videoURL = urlAsset.URL;
                    if (videoURL) {
                        if (!asset.composable) {
                            DDLogDebug(@"不可composable");
                            [self showFailedHudWithTitle:@"该视频内容不支持编辑，请重新选择视频"];
                            return;
                        }
                        if (!asset.exportable) {
                            DDLogDebug(@"不可export");
                            [self showFailedHudWithTitle:@"该视频内容不支持导出，请重新选择视频"];
                            return;
                        }
                        if (asset.hasProtectedContent) {
                            DDLogDebug(@"有含保护的内容");
                            [self showFailedHudWithTitle:@"该视频含有被保护的内容，请重新选择视频"];
                            return;
                        }
                        NSDate *videoDate = nil;
                        AVMetadataItem *creationDate = urlAsset.creationDate;
                        id value = creationDate.value;
                        if ([value isKindOfClass:[NSDate class]]) {
                            videoDate = (NSDate *)value;
                        }
                        VideoCropViewController *vc = [[VideoCropViewController alloc] initWithVideoURL:videoURL];
                        vc.finishBlock = self.finishBlock;
                        vc.videoDate = videoDate;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
            });
        }];
    }
}
- (void)fetchAllVideoLessThanSeconds:(NSUInteger)seconds
{
    if (IOS8AFTER) {
        //iOS8+
        NSArray *videos = [self fetchPHVideosWithMaxDuration:seconds];
//        NSLog(@"videos:%@",videos);
        [self updateScrollViewWithVideos:videos];
//        [self fetchALVideosWithMaxDuration:seconds result:^(NSArray<ALAsset *> *assets) {
//            NSLog(@"assets:%@",assets);
//            [self updateScrollViewWithVideos:assets];
//        }];
    }else{
        //iOS7
        [self fetchALVideosWithMaxDuration:seconds result:^(NSArray<ALAsset *> *assets) {
//            NSLog(@"videos:%@",assets);
            [self updateScrollViewWithVideos:assets];
        }];
    }
}
//iOS8+获取所有可用视频
- (NSArray *)fetchPHVideosWithMaxDuration:(double)duration
{
    NSMutableArray *allVideos = [[NSMutableArray alloc] init];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    PHFetchResult<PHAsset *> *assetsFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:option];
    for (PHAsset *asset in assetsFetchResult) {
        NSTimeInterval vLength = asset.duration;
        if (vLength >= kVideoMinimalDuration && vLength <= duration) {
            [allVideos addObject:asset];
        }
    }
    NSArray *reverseVideos = [[allVideos reverseObjectEnumerator] allObjects];
    return reverseVideos;
}
//获取iOS7上小于duration时长的视频合集
- (void)fetchALVideosWithMaxDuration:(double)duration
                              result:(void (^)(NSArray<ALAsset *> *))result
{
    [self fetchALVideoAlbumsWithResult:^(NSArray *albums) {
        if (albums && [albums count] > 0) {
            NSMutableArray *allVideos = [[NSMutableArray alloc] init];
            [albums enumerateObjectsUsingBlock:^(ALAssetsGroup *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setAssetsFilter:[ALAssetsFilter allVideos]];
                //逆序遍历
                [obj enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    id vLength = [result valueForProperty:ALAssetPropertyDuration];
                    if (result && vLength && [vLength doubleValue] >= kVideoMinimalDuration && [vLength doubleValue] <= duration) {
                        [allVideos addObject:result];
                    }
//                    NSLog(@"group:%@ asset:%@",obj,result);
                }];
            }];
            result(allVideos);
        }else{
            result(nil);
        }
    }];
}
//获取iOS7上的视频相册
- (void)fetchALVideoAlbumsWithResult:(void (^)(NSArray<ALAssetsGroup *> *))result
{
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *albumsArray = [[NSMutableArray alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //只获取视频
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if (group) {
            if (group.numberOfAssets > 0) {
                [albumsArray addObject:group];
            }
        } else {
            result(albumsArray);
            return;
        }
    } failureBlock:^(NSError *error) {
        DDLogDebug(@"获取视频相册组Error : %@", [error description]);
        result(nil);
    }];
}
#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    NSURL *videoURL;
    AVAsset *videoAsset;
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        //如果是视频
        videoURL = info[UIImagePickerControllerMediaURL];
        videoAsset = [AVAsset assetWithURL:videoURL];
        CMTime duration = videoAsset.duration;
        double length = CMTimeGetSeconds(duration);
        if (length <= 3.0) {
            //展示时间过段HUD
            UIView *contentView = [picker view];
            MBProgressHUD *failedHud = [[MBProgressHUD alloc] initWithView:contentView];
            failedHud.mode = MBProgressHUDModeNone;
            failedHud.labelText = @"请选择时间大于3秒的视频";
            [contentView addSubview:failedHud];
            [failedHud show:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [failedHud removeFromSuperview];
                [picker popViewControllerAnimated:YES];
            });
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                if (videoURL) {
                    if (!videoAsset.composable) {
                        DDLogDebug(@"不可composable");
                        [self showFailedHudWithTitle:@"该视频内容不支持编辑，请重新选择视频"];
                    }
                    if (!videoAsset.exportable) {
                        DDLogDebug(@"不可export");
                        [self showFailedHudWithTitle:@"该视频内容不支持导出，请重新选择视频"];
                    }
                    if (videoAsset.hasProtectedContent) {
                        DDLogDebug(@"有含保护的内容");
                        [self showFailedHudWithTitle:@"该视频含有被保护的内容，请重新选择视频"];
                    }
                    
                    VideoCropViewController *vc = [[VideoCropViewController alloc] initWithVideoURL:videoURL];
                    vc.finishBlock = self.finishBlock;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }
            }];
        }
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
