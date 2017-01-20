//
//  TXImagePickerController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/20.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXImagePickerController.h"
#import "JFImagePickerController.h"
#import "GMImagePickerController.h"
#import <Photos/PhotosTypes.h>
#import <objc/runtime.h>

#define iOSSystemVersionGreaterThanOrEqualTo(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static char kTXImagePickerAssociatedKey;

@interface TXImagePickerController()
<GMImagePickerControllerDelegate,
JFImagePickerDelegate>
{
    BOOL _isGreaterThanOrEqualToiOS8;
}
@property (nonatomic,strong) GMImagePickerController *gmImagePicker;
@property (nonatomic,strong) JFImagePickerController *jfImagePicker;

@end

@implementation TXImagePickerController

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isGreaterThanOrEqualToiOS8 = iOSSystemVersionGreaterThanOrEqualTo(@"8");
//        _isGreaterThanOrEqualToiOS8 = NO;
        if (_isGreaterThanOrEqualToiOS8) {
            self.gmImagePicker = [[GMImagePickerController alloc] init];
            self.gmImagePicker.mediaTypes = @[@(PHAssetMediaTypeImage)];
            self.gmImagePicker.delegate = self;
            //设置关联
            objc_setAssociatedObject(_gmImagePicker, &kTXImagePickerAssociatedKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else{
            self.jfImagePicker = [[JFImagePickerController alloc] init];
            self.jfImagePicker.pickerDelegate = self;
            //设置关联
            objc_setAssociatedObject(_jfImagePicker, &kTXImagePickerAssociatedKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        //默认最多选择9张照片
        self.maxSelectionNumber = 9;
        _currentSelectedCount = 0;
    }
    return self;
}
- (void)setMaxSelectionNumber:(NSInteger)maxSelectionNumber
{
    _maxSelectionNumber = maxSelectionNumber;
    if (_isGreaterThanOrEqualToiOS8) {
        self.gmImagePicker.maxSelectionNumber = _maxSelectionNumber;
    }else{
        self.jfImagePicker.maxSelectionNumber = _maxSelectionNumber;
    }
}
- (void)setCurrentSelectedCount:(NSInteger)currentSelectedCount
{
    if (currentSelectedCount >= _maxSelectionNumber) {
        NSLog(@"当前的照片选择数已经大于最大选择数,currentSelectedCount将被置为0");
        currentSelectedCount = 0;
    }
    _currentSelectedCount = currentSelectedCount;
    if (_isGreaterThanOrEqualToiOS8) {
        self.gmImagePicker.currentSelectedCount = _currentSelectedCount;
    }else{
        self.jfImagePicker.currentSelectedCount = _currentSelectedCount;
    }
}
//弹出图片选择器
- (void)showImagePickerBy:(UIViewController *)viewControllerToBePresentIn animated:(BOOL)flag completion:(void(^)(void))completion
{
    if (!viewControllerToBePresentIn) {
        return;
    }
    if (_isGreaterThanOrEqualToiOS8) {
        [viewControllerToBePresentIn presentViewController:self.gmImagePicker animated:flag completion:completion];
    }else{
        [viewControllerToBePresentIn presentViewController:self.jfImagePicker animated:flag completion:completion];
    }
}
//关闭图片选择器
- (void)dismissImagePickerControllerWithAnimated:(BOOL)flag
{
    if (_isGreaterThanOrEqualToiOS8) {
        objc_setAssociatedObject(_gmImagePicker, &kTXImagePickerAssociatedKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [_gmImagePicker dismissViewControllerAnimated:flag completion:nil];
    }else{
        objc_setAssociatedObject(_jfImagePicker, &kTXImagePickerAssociatedKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [_jfImagePicker dismissViewControllerAnimated:flag completion:^{
            [JFImagePickerController clear];
        }];
    }
}
//展示处理图片HUD
- (UIView *)currentViewContent
{
    if (_isGreaterThanOrEqualToiOS8) {
        return _gmImagePicker.view;
    }
    return _jfImagePicker.view;
}
#pragma mark - GMImagePickerControllerDelegate methods
- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerStartProcessingImages:)]) {
            [_delegate imagePickerControllerStartProcessingImages:self];
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *imageArray = [NSMutableArray array];
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        option.resizeMode = PHImageRequestOptionsResizeModeExact;
        [assets enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
            if (obj.pixelWidth != 0) {
                CGSize imageSize = CGSizeMake(1080, (float)obj.pixelHeight * 1080 / (float)obj.pixelWidth);
                [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:imageSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
                    if (result) {
                        [imageArray addObject:result];
                    }
                }];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didFinishPickingImages:)]) {
                [_delegate imagePickerController:self didFinishPickingImages:imageArray];
            }
        });
    });
}
- (void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerDidCancelled:)]) {
            [_delegate imagePickerControllerDidCancelled:self];
        }
    });
}
- (void)assetsPickerControllerDidReachMaxSelection:(GMImagePickerController *)picker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerReachMaxSelectNumber:)]) {
            [_delegate imagePickerControllerReachMaxSelectNumber:self];
        }
    });
}
#pragma mark - JFImagePickerDelegate methods
- (void)imagePickerDidFinished:(JFImagePickerController *)picker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerStartProcessingImages:)]) {
            [_delegate imagePickerControllerStartProcessingImages:self];
        }
    });
    NSMutableArray *imagesArr = [NSMutableArray array];
    //创建图片操作group
    dispatch_group_t imageGroup = dispatch_group_create();
    [picker.assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
        dispatch_group_enter(imageGroup);
        [[JFImageManager sharedManager] imageWithAsset:asset resultHandler:^(CGImageRef imageRef, BOOL longImage) {
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            [imagesArr addObject:image];
            dispatch_group_leave(imageGroup);
        }];
    }];
    dispatch_group_notify(imageGroup, dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(imagePickerController:didFinishPickingImages:)]) {
            [_delegate imagePickerController:self didFinishPickingImages:imagesArr];
        }
    });
}
- (void)imagePickerDidCancel:(JFImagePickerController *)picker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerDidCancelled:)]) {
            [_delegate imagePickerControllerDidCancelled:self];
        }
    });
}
- (void)imagePickerReachedMaxSelectionLimit:(JFImagePickerController *)picker
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(imagePickerControllerReachMaxSelectNumber:)]) {
            [_delegate imagePickerControllerReachMaxSelectNumber:self];
        }
    });
}
@end
