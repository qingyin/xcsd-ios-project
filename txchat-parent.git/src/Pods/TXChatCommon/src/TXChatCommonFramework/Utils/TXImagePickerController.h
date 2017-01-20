//
//  TXImagePickerController.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/20.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TXImagePickerController;
@protocol TXImagePickerControllerDelegate <NSObject>

@required
/**
 *  选中图片后的代理
 *
 *  @param picker     ImagePicker对象
 *  @param imageArray 图片队列
 */
- (void)imagePickerController:(TXImagePickerController *)picker didFinishPickingImages:(NSArray *)imageArray;

@optional
/**
 *  选择完图片之后开始处理Asset为图片数组
 *
 *  @param picker ImagePicker对象
 */
- (void)imagePickerControllerStartProcessingImages:(TXImagePickerController *)picker;


/**
 *  取消选取图片后的代理
 *
 *  @param picker ImagePicker对象
 */
- (void)imagePickerControllerDidCancelled:(TXImagePickerController *)picker;

/**
 *  图片选择器达到最大的选择数限制
 *
 *  @param picker ImagePicker对象
 */
- (void)imagePickerControllerReachMaxSelectNumber:(TXImagePickerController *)picker;

@end

@interface TXImagePickerController : NSObject

/**
 *  图片选取器的代理
 */
@property (nonatomic,weak) id<TXImagePickerControllerDelegate> delegate;

/**
 *  最大的选择张数,默认是9张
 */
@property (nonatomic, assign) NSInteger maxSelectionNumber;

/**
 *  当前已选择的最大张数,默认是0
 */
@property (nonatomic, assign) NSInteger currentSelectedCount;

/**
 *  弹出图片选择器
 *
 *  @param viewControllerToBePresentIn 用来弹出图片选择器的控制器
 *  @param flag                        是否有动画
 *  @param completion                  completion的block回调
 */
- (void)showImagePickerBy:(UIViewController *)viewControllerToBePresentIn animated:(BOOL)flag completion:(void(^)(void))completion;

/**
 *  关闭图片选择器并进行清理工作
 *
 *  @param flag   是否有动画
 */
- (void)dismissImagePickerControllerWithAnimated:(BOOL)flag;

/**
 *  获取当前图片选择器的视图
 *
 *  @return 当前展示的视图
 */
- (UIView *)currentViewContent;

@end
