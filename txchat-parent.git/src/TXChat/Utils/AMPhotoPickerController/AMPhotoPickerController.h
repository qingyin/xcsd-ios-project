//
//  UIPhotoPickerController.h
//  ImagePickerDemo
//
//  Created by Alan on 13-9-23.
//  Copyright (c) 2013年 raozhongxiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetsLibrary+Util.h"

@protocol AMPhotoPickerControllerDelegate;

@interface AMPhotoPickerController : UIImagePickerController {
    // 自定义叠加层
    UIView *_vCameraOverlay;
    
    // 控制层
    UIView *_vCameraControl;
    // 闪光灯
    UIButton *_vCameraToggle;
    // 前后镜
    UIButton *_vCameraFlash;
    // 图片预览
    UIScrollView *_svPhotoPreview;
    
    // 底边栏
    UIView *_vBottomBar;
    UIButton *_btnCancel;
    UIButton *_btnTake;
    UIButton *_btnDone;
    
    // 图片数据
    NSMutableArray *_photoInfos;
    
    ALAssetsLibrary *_assetsLibrary;
    
//    BOOL isTaking;
}

@property(nonatomic, weak) id <AMPhotoPickerControllerDelegate> photoDelegate;
@property(nonatomic) NSUInteger maxPickerNumber;
@property (nonatomic, assign) BOOL isAuth;

@end

@protocol AMPhotoPickerControllerDelegate <UIImagePickerControllerDelegate>
@optional

- (void)photoPickerController:(AMPhotoPickerController *)picker didFinishPickingMediaWithInfos:(NSArray *)infos;
- (void)photoPickerControllerDidCancel:(AMPhotoPickerController *)picker;
- (void)photoPickerControllerBeyondMaxNumber:(AMPhotoPickerController *)picker;

@end

//@interface UIPhotoPreview : UIView 
//
//@end
