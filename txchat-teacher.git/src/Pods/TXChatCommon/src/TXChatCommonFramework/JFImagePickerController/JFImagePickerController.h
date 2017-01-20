//
//  JFImagePickerController.h
//  JFImagePickerController
//
//  Created by Johnil on 15-7-3.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFAssetHelper.h"
#import "JFImageManager.h"

@interface JFImagePickerController : UINavigationController

@property (nonatomic, weak) id pickerDelegate;
/**
 *  最大的选择张数,默认是9张
 */
@property (nonatomic, assign) NSInteger maxSelectionNumber;

/**
 *  当前已选择的最大张数,默认是0
 */
@property (nonatomic, assign) NSInteger currentSelectedCount;

- (JFImagePickerController *)initWithPreviewIndex:(NSInteger)index;

/**
 当退出编辑模式时需调用clear，用来清理内存，已选择照片的缓存
 **/
+ (void)clear;
- (UIToolbar *)customToolbar;
- (void)setLeftTitle:(NSString *)title;
- (void)cancel;

- (NSArray *)imagesWithType:(NSInteger)type;
- (NSArray *)assets;

@end

@protocol JFImagePickerDelegate <NSObject>

- (void)imagePickerDidFinished:(JFImagePickerController *)picker;
- (void)imagePickerDidCancel:(JFImagePickerController *)picker;
- (void)imagePickerReachedMaxSelectionLimit:(JFImagePickerController*)picker;

@end