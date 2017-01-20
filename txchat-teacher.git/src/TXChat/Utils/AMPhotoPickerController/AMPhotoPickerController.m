//
//  UIPhotoPickerController.m
//  ImagePickerDemo
//
//  Created by Alan on 13-9-23.
//  Copyright (c) 2013年 raozhongxiong. All rights reserved.
//

#import "AMPhotoPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

#define kPreviewStartTag 1000
#define kPreviewWidth 100

@interface AMPhotoPickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
{
}

@property (nonatomic, assign) BOOL canTake;
@property (nonatomic, strong) UILabel *tipsLb;

@end

@implementation AMPhotoPickerController

- (void)loadView
{
    self.showsCameraControls = NO;
    [super loadView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 初始化自定义叠加层
    
    if(!_isAuth){
        UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.textColor = kColorBlack;
        label.font = kFontLarge_1;
        [self.view addSubview:label];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString *str = [NSString stringWithFormat:@"没有权限访问您的相机\n\n请到“设置-隐私照片”里\n把”%@“的开关打开即可",app_Name];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedString addAttribute:NSFontAttributeName value:kFontSuper range:[str rangeOfString:@"没有权限访问您的相册"]];
        label.attributedText = attributedString;
        [label sizeToFit];
        label.frame = CGRectMake(0, 0, label.width_, label.height_);
        label.center = CGPointMake(kScreenWidth/2, self.view.height_/2);
        
        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        settingBtn.frame = CGRectMake(0, 0, 140, 40);
        settingBtn.backgroundColor = kColorBlue;
        settingBtn.layer.cornerRadius = 5;
        settingBtn.layer.masksToBounds = YES;
        [settingBtn setTitle:@"去设置" forState:UIControlStateNormal];
        [settingBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
        settingBtn.titleLabel.font = kFontLarge_1;
        [self.view addSubview:settingBtn];
        
        settingBtn.center = CGPointMake(kScreenWidth/2, label.centerY + 5 + 20 + label.height_/2);
        [settingBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
        }];
        
        return;
        
    }
    
    [self initCustomBottomBar];
    
    // 注册旋转事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //    AMLog(@"%@", [self.view stringViewStruct]);
}


- (void)initCustomBottomBar
{
    CGFloat bottomBarH = 53;
    // 初始化叠加层
    _vCameraOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    
    // 初始化控制层
    _vCameraControl = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _vCameraOverlay.width_, _vCameraOverlay.height_ - bottomBarH)];
    
    // 闪光灯
    _vCameraFlash = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
    _vCameraFlash.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _vCameraFlash.titleLabel.font = [UIFont systemFontOfSize:12];
    _vCameraFlash.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_vCameraFlash setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_vCameraFlash setTitle:@" 自动" forState:UIControlStateNormal];
    [_vCameraFlash setImage:[UIImage imageNamed:@"takephoto_flash_icon"] forState:UIControlStateNormal];
    [_vCameraFlash addTarget:self action:@selector(onClickFlash:) forControlEvents:UIControlEventTouchUpInside];
    
    if (![UIImagePickerController isFlashAvailableForCameraDevice:self.cameraDevice])
        _vCameraFlash.hidden = YES;
    
    // 前后镜
    _vCameraToggle = [[UIButton alloc] initWithFrame:CGRectMake(_vCameraControl.width_ - 70, 10, 60, 30)];
    _vCameraToggle.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    _vCameraToggle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_vCameraToggle setImage:[UIImage imageNamed:@"takephoto_turn_icon"] forState:UIControlStateNormal];
    [_vCameraToggle addTarget:self action:@selector(onClickToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    // 多拍图片滚动视图
    _svPhotoPreview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _vCameraControl.height_ - 80, _vCameraControl.width_, 80)];
    _svPhotoPreview.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _svPhotoPreview.showsHorizontalScrollIndicator = NO;
    _svPhotoPreview.pagingEnabled = YES;
    _svPhotoPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [_vCameraControl addSubview:_vCameraFlash];
    [_vCameraControl addSubview:_vCameraToggle];
    [_vCameraControl addSubview:_svPhotoPreview];
    
    // 底部工具栏
    _vBottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, _vCameraOverlay.height_ - bottomBarH, _vCameraOverlay.width_, bottomBarH)];
    _vBottomBar.backgroundColor = kColorBlack;
    
    // 取消
    _btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _vBottomBar.height_, _vBottomBar.height_)];
    [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_btnCancel setTitleColor:kColorBlue forState:UIControlStateNormal];
    [_btnCancel setTitleColor:kColorBlack forState:UIControlStateHighlighted];
    [_btnCancel addTarget:self action:@selector(onClickCancel) forControlEvents:UIControlEventTouchUpInside];
    [_btnCancel setExclusiveTouch:YES];
    
    // 拍照
    _btnTake = [[UIButton alloc] initWithFrame:CGRectMake((_vBottomBar.width_ - _vBottomBar.height_) / 2, 0, _vBottomBar.height_, _vBottomBar.height_)];
    [_btnTake setImage:[UIImage imageNamed:@"takephoto_btn"] forState:UIControlStateNormal];
    [_btnTake setImage:[UIImage imageNamed:@"takephoto_btn_h"] forState:UIControlStateHighlighted];
    [_btnTake addTarget:self action:@selector(onClickTake) forControlEvents:UIControlEventTouchUpInside];
    [_btnTake setExclusiveTouch:YES];
    
    // 完成
    _btnDone = [[UIButton alloc] initWithFrame:CGRectMake(_vBottomBar.width_ - _vBottomBar.height_, 0, _vBottomBar.height_, _vBottomBar.height_)];
    [_btnDone setTitle:@"完成" forState:UIControlStateNormal];
    [_btnDone setTitleColor:kColorBlue forState:UIControlStateNormal];
    [_btnDone setTitleColor:kColorBlack forState:UIControlStateHighlighted];
    [_btnDone addTarget:self action:@selector(onClickDone) forControlEvents:UIControlEventTouchUpInside];
    [_btnDone setExclusiveTouch:YES];
    
    [_vBottomBar addSubview:_btnCancel];
    [_vBottomBar addSubview:_btnTake];
    [_vBottomBar addSubview:_btnDone];
    
    [_vCameraOverlay addSubview:_vCameraControl];
    [_vCameraOverlay addSubview:_vBottomBar];
    
    self.cameraOverlayView = _vCameraOverlay;
    
    [self onDeviceOrientationChange];
    
    _svPhotoPreview.hidden = YES;
    CGSize screenBounds = _vCameraOverlay.bounds.size;
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    self.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, scale, scale);
    
}

- (void)onDeviceOrientationChange
{
    @synchronized(_svPhotoPreview) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        CGAffineTransform transform;
        CGRect frame;
        
        if (orientation == UIDeviceOrientationPortrait) {
            transform = CGAffineTransformIdentity;
            frame = CGRectMake(0, 0, _vCameraOverlay.width_, _vCameraOverlay.height_ - _vBottomBar.height_);
        } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
            frame = CGRectMake(0, 0, _vCameraOverlay.width_, _vCameraOverlay.height_ - _vBottomBar.height_);
        } else if (orientation == UIDeviceOrientationLandscapeLeft) {
            transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
            frame = CGRectMake(0, 0, _vCameraOverlay.width_, _vCameraOverlay.height_ - _vBottomBar.height_);
        } else if (orientation == UIDeviceOrientationLandscapeRight) {
            transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
            frame = CGRectMake(0, 0, _vCameraOverlay.width_, _vCameraOverlay.height_ - _vBottomBar.height_);
        } else
            return;
        
        if (CGAffineTransformEqualToTransform(_vCameraControl.transform, transform))
            return;
        
        [UIView animateWithDuration:0.3 animations:^{
            _btnCancel.transform = transform;
            _btnTake.transform = transform;
            _btnDone.transform = transform;
        }];
        
        [UIView animateWithDuration:0.15 animations:^{
            _vCameraControl.alpha = 0;
        } completion:^(BOOL finished) {
            _vCameraControl.transform = transform;
            _vCameraControl.frame = frame;
            
            // 重新计算间距 横屏4个 竖屏3个
            NSInteger itemNum = 4;
            CGFloat spaceWidth = _svPhotoPreview.width_ - kPreviewWidth * itemNum;
            if (spaceWidth > 0)
                spaceWidth = spaceWidth / 5;
            else {
                itemNum = 3;
                spaceWidth = _svPhotoPreview.width_ - kPreviewWidth * itemNum;
                spaceWidth = spaceWidth / 4;
            }
            
            // 调整图片预览的显示位置
            for (int i = 0; i < _photoInfos.count; i++) {
                UIView *previewView = [_svPhotoPreview viewWithTag:kPreviewStartTag + i];
                previewView.minX = previewView.width_ * i + (i + 1) * spaceWidth + spaceWidth * (i / itemNum);
            }
            
            BOOL isNeedChangeOffset = [self adjustContentSize:[_svPhotoPreview viewWithTag:kPreviewStartTag + (_photoInfos.count - 1)].maxX];
            if (isNeedChangeOffset)
                _svPhotoPreview.contentOffset = CGPointMake(_svPhotoPreview.contentSize.width - _svPhotoPreview.width_, 0);
            
            [UIView animateWithDuration:0.15 animations:^{
                _vCameraControl.alpha = 1;
            }];
        }];
        
        
    }
}


- (void)setPhotoDelegate:(id<AMPhotoPickerControllerDelegate>)photoDelegate
{
    _photoDelegate = photoDelegate;
    self.delegate = self;
}

- (void)onClickFlash:(UIButton *)btn
{
    NSString *title = nil;
    switch (btn.tag) {
        case -1: btn.tag = 0; title = @" 自动"; break;
        case 0: btn.tag = 1; title = @" 打开"; break;
        case 1: btn.tag = -1; title = @" 关闭"; break;
    }
    
    [btn setTitle:title forState:UIControlStateNormal];
    self.cameraFlashMode = btn.tag;
    
}

- (void)onClickToggle:(UIButton *)btn
{
    btn.tag = btn.tag == 0 ? 1 : 0;
    self.cameraDevice = btn.tag;
    // 检查是否有闪光灯
    
    [UIView animateWithDuration:0.3 animations:^{
        _vCameraFlash.alpha = [UIImagePickerController isFlashAvailableForCameraDevice:self.cameraDevice];
    }];
}

- (void)setCanTake:(BOOL)canTake{
    _canTake = canTake;
    _btnTake.enabled = canTake;
}

- (void)onClickCancel
{
    if ([_photoDelegate respondsToSelector:@selector(photoPickerControllerDidCancel:)])
        [_photoDelegate photoPickerControllerDidCancel:self];
}


- (void)onClickTake
{
    // 默认最大15张
    if (_photoInfos.count >= (self.maxPickerNumber == 0 ? 15 : self.maxPickerNumber)) {
        if ([_photoDelegate respondsToSelector:@selector(photoPickerControllerBeyondMaxNumber:)])
            [_photoDelegate photoPickerControllerBeyondMaxNumber:self];
    }
    // 没超最大张数执行拍照
    else {
        // 间隔1秒
        if ([AMPhotoPickerController isValidClick:1]) {
            // 拍照
            [self takePicture];
        }
    }
}

/* 是否有效点击 */
static NSTimeInterval lastClickTime;
+ (BOOL)isValidClick:(NSTimeInterval)intervalTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if (fabs(time - lastClickTime) < intervalTime)
        return NO;
    lastClickTime = time;
    return YES;
}

- (void)onClickDone
{
    if ([_photoDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingMediaWithInfos:)])
        [_photoDelegate photoPickerController:self didFinishPickingMediaWithInfos:_photoInfos];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    @synchronized(_svPhotoPreview) {
        if (!_photoInfos)
            _photoInfos = [[NSMutableArray alloc] init];
        if (!_assetsLibrary) {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        image = [image imageTo4b3AtSize:CGSizeMake(400, 300)];
        
        [_photoInfos addObject:[NSDictionary dictionaryWithObjectsAndKeys:image, UIImagePickerControllerOriginalImage, nil]];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        [_assetsLibrary saveImage:image toAlbum:app_Name withCompletionBlock:^(ALAsset *asset, NSError *error) {
            //AMLog(@"error: %@ \n asset: %@", error, asset);
            if (error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"图片保存到%@相册失败",app_Name] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
        
        // 图片预览
        [self addPhotoToPreview:[image imageToSize:CGSizeMake(80, 60)]];
    }
}

- (void)addPhotoToPreview:(UIImage *)img
{
    
    // 图片预览布局
    UIView *vPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
    vPreview.tag = kPreviewStartTag + (_photoInfos.count - 1);
    
    // 计算间距 横屏4个 竖屏3个
    NSInteger itemNum = 4;
    CGFloat spaceWidth = _svPhotoPreview.width_ - vPreview.width_ * itemNum;
    if (spaceWidth > 0)
        spaceWidth = spaceWidth / 5;
    else {
        itemNum = 3;
        spaceWidth = _svPhotoPreview.width_ - vPreview.width_ * itemNum;
        spaceWidth = spaceWidth / 4;
    }
    
    vPreview.minX = vPreview.width_ * (_photoInfos.count - 1) + _photoInfos.count * spaceWidth + spaceWidth * ((_photoInfos.count - 1) / itemNum);
    
    UIImageView *ivPreview = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 80, 60)];
    ivPreview.layer.masksToBounds = YES;
    //    ivPreview.layer.cornerRadius = 7.5;
    //    ivPreview.layer.borderWidth = 0.6;
    //    ivPreview.layer.borderColor = kColorGrey.CGColor;
    ivPreview.image = img;
    //    ivPreview.contentMode = UIViewContentModeCenter;
    
    // 删除
    UIImage *imgBtnDel = [UIImage imageNamed:@"publish_delete"];
    UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imgBtnDel.size.width + 10, imgBtnDel.size.height + 10)];
    btnDel.exclusiveTouch = YES;
    [btnDel setImage:imgBtnDel forState:UIControlStateNormal];
    [btnDel addTarget:self action:@selector(onClickDelPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    [vPreview addSubview:ivPreview];
    [vPreview addSubview:btnDel];
    
    [_svPhotoPreview addSubview:vPreview];
    
    BOOL isNeedChangeOffset = [self adjustContentSize:vPreview.maxX];
    if (isNeedChangeOffset) {
        [UIView animateWithDuration:0.2 animations:^{
            _svPhotoPreview.contentOffset = CGPointMake(_svPhotoPreview.contentSize.width - _svPhotoPreview.width_, 0);
        }];
    }
    
    _svPhotoPreview.hidden = NO;
}

- (void)onClickDelPhoto:(UIButton *)btn
{
    @synchronized(_svPhotoPreview) {
        UIView *vPreview = btn.superview;
        NSUInteger index = vPreview.tag - kPreviewStartTag;
        __block CGRect lackFrame = vPreview.frame;
        
        // 删除对应图片数据
        [_photoInfos removeObjectAtIndex:index];
        
        [UIView animateWithDuration:0.2 animations:^{
            vPreview.transform = CGAffineTransformMakeScale(0.1, 0.1);
            vPreview.alpha = 0;
        } completion:^(BOOL finished) {
            [vPreview removeFromSuperview];
        }];
        
        // 调整图片位置
        [UIView animateWithDuration:0.2 animations:^{
            for (NSInteger i = index + 1; i <= _photoInfos.count; i++) {
                UIView *previewView = [_svPhotoPreview viewWithTag:kPreviewStartTag + i];
                previewView.tag -= 1;
                CGRect tmpFrame = previewView.frame;
                previewView.frame = lackFrame;
                lackFrame = tmpFrame;
            }
        } completion:^(BOOL finished) {
            // 调整滚动布局大小
            [UIView animateWithDuration:0.2 animations:^{
                [self adjustContentSize:[_svPhotoPreview viewWithTag:kPreviewStartTag + (_photoInfos.count - 1)].maxX];
            }];
        }];
    }
    
    _svPhotoPreview.hidden = NO;
}

/* 调整图片预览的滚动范围 */
- (BOOL)adjustContentSize:(CGFloat)maxX
{
    BOOL isNeedChangeOffset = NO;
    int pageIndex = maxX / _svPhotoPreview.width_;
    if (pageIndex > 0) {
        _svPhotoPreview.contentSize = CGSizeMake((pageIndex + 1) * _svPhotoPreview.width_, _svPhotoPreview.height_);
        isNeedChangeOffset = _svPhotoPreview.contentOffset.x != _svPhotoPreview.contentSize.width;
    } else {
        _svPhotoPreview.contentSize = CGSizeMake(_svPhotoPreview.width_ + 1, _svPhotoPreview.height_);
    }
    return isNeedChangeOffset;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    if (_tipsLb) {
        [_tipsLb removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
