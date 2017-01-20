//
//  JFImagePickerController.m
//  JFImagePickerController
//
//  Created by Johnil on 15-7-3.
//  Copyright (c) 2015年 Johnil. All rights reserved.
//

#import "JFImagePickerController.h"
#import "JFImageGroupTableViewController.h"
#import "JFPhotoBrowserViewController.h"
#import "JFImageCollectionViewController.h"
#import "JFAssetHelper.h"
#import "JFImageManager.h"

@interface JFImagePickerController () <JDPhotoBrowserDelegate>

@end

@implementation JFImagePickerController {
	UIBarButtonItem *selectNum;
	UIBarButtonItem *preview;
	UIToolbar *toolbar;
	JFImageCollectionViewController *collectionViewController;
    UIStatusBarStyle tempBarStyle;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__func__);
}
- (JFImagePickerController *)initWithPreviewIndex:(NSInteger)index{
    self = [super initWithRootViewController:[JFImageGroupTableViewController new]];
    if (self) {
        _maxSelectionNumber = 9;
        _currentSelectedCount = 0;
        ASSETHELPER.previewIndex = index;
        ASSETHELPER.currentBrowerPage = -1;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController{
	self = [super initWithRootViewController:[JFImageGroupTableViewController new]];
	if (self) {
        _maxSelectionNumber = 9;
        _currentSelectedCount = 0;
        ASSETHELPER.previewIndex = -1;
        ASSETHELPER.currentBrowerPage = -1;
	}
	return self;
}

- (id)init
{
    self = [super initWithRootViewController:[JFImageGroupTableViewController new]];
    if (self) {
        _maxSelectionNumber = 9;
        _currentSelectedCount = 0;
        ASSETHELPER.previewIndex = -1;
        ASSETHELPER.currentBrowerPage = -1;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	if (ASSETHELPER.selectdPhotos.count>0) {
		preview.title = @"预览";
	} else {
		preview.title = @"";
	}
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tempBarStyle = [UIApplication sharedApplication].statusBarStyle;
        if (tempBarStyle!=UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
    });

	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-44, [UIScreen mainScreen].bounds.size.width, 44)];
	toolbar.tintColor = [UIColor whiteColor];
	toolbar.barStyle = UIBarStyleBlack;
	[self.view addSubview:toolbar];
    UIBarButtonItem *leftFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	UIBarButtonItem *rightFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	preview = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(preview)];
	UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    selectNum = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"0/%@",@((_maxSelectionNumber - _currentSelectedCount) ?: 0)] style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem *fix2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(choiceDone)];
	[toolbar setItems:@[leftFix, preview, fix, selectNum, fix2, done, rightFix]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCount:) name:@"selectdPhotos" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPhotoReachMaxSelectionNumberLimit:) name:@"reachMaxPhotoNumber" object:nil];
	selectNum.title = [NSString stringWithFormat:@"%ld/%@", (unsigned long)ASSETHELPER.selectdPhotos.count,@((_maxSelectionNumber - _currentSelectedCount) ?: 0)];
}
//设置最大的图片选择数
- (void)setMaxSelectionNumber:(NSInteger)maxSelectionNumber
{
    _maxSelectionNumber = maxSelectionNumber;
    ASSETHELPER.maxSelectionNumber = _maxSelectionNumber;
    selectNum.title = [NSString stringWithFormat:@"%ld/%@", (unsigned long)ASSETHELPER.selectdPhotos.count,@((_maxSelectionNumber - _currentSelectedCount) ?: 0)];
}
//设置当前已选择的数量
- (void)setCurrentSelectedCount:(NSInteger)currentSelectedCount
{
    _currentSelectedCount = currentSelectedCount;
    ASSETHELPER.currentSelectedCount = _currentSelectedCount;
    selectNum.title = [NSString stringWithFormat:@"%ld/%@", (unsigned long)ASSETHELPER.selectdPhotos.count,@((_maxSelectionNumber - _currentSelectedCount) ?: 0)];
}
//达到照片最大选择数量的通知
- (void)onPhotoReachMaxSelectionNumberLimit:(NSNotification *)notifi
{
    if (_pickerDelegate && [_pickerDelegate respondsToSelector:@selector(imagePickerReachedMaxSelectionLimit:)]) {
        [_pickerDelegate imagePickerReachedMaxSelectionLimit:self];
    }
}
- (void)setLeftTitle:(NSString *)title{
	preview.title = title;
}

- (UIToolbar *)customToolbar{
	return toolbar;
}

- (void)changeCount:(NSNotification *)notifi{
	selectNum.title = [NSString stringWithFormat:@"%ld/%@", (unsigned long)ASSETHELPER.selectdPhotos.count,@((_maxSelectionNumber - _currentSelectedCount) ?: 0)];
	if (![preview.title isEqualToString:@"取消"]) {
		if (ASSETHELPER.selectdPhotos.count>0) {
			preview.title = @"预览";
		} else {
			preview.title = @"";
		}
	}
}

- (void)cancel{
	if (_pickerDelegate) {
        if (tempBarStyle!=UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:tempBarStyle animated:NO];
        }
		[_pickerDelegate imagePickerDidCancel:self];
	}
}

- (void)preview{
	if (preview.title.length<=0) {
		return;
	}
	if ([preview.title isEqualToString:@"取消"]) {
		[self cancel];
		return;
	}
	if ([preview.title isEqualToString:@"预览"]) {
		preview.title = @"取消";
        ASSETHELPER.previewIndex = 0;
		collectionViewController = (JFImageCollectionViewController *)self.visibleViewController;
		JFPhotoBrowserViewController *photoBrowser = [[JFPhotoBrowserViewController alloc] initWithPreview];
		photoBrowser.delegate = self;
		[self pushViewController:photoBrowser animated:YES];
	} else {
        [self cancel];
	}
}

- (void)choiceDone{
	if (_pickerDelegate) {
        if (tempBarStyle!=UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:tempBarStyle animated:NO];
        }
        if ([ASSETHELPER.selectdAssets count] == 0) {
            //未选择图片，用当前brower的图片
            if (ASSETHELPER.currentBrowerPage != -1) {
                //读取图片
                [ASSETHELPER.selectdPhotos addObject:@{[NSString stringWithFormat:@"%ld-%ld",(long)ASSETHELPER.currentBrowerPage, (long)ASSETHELPER.currentGroupIndex]: @(ASSETHELPER.selectdPhotos.count+1)}];
                ALAsset *assert = [ASSETHELPER getAssetAtIndex:ASSETHELPER.currentBrowerPage];
                [ASSETHELPER.selectdAssets addObject:assert];
            }
        }
		[_pickerDelegate imagePickerDidFinished:self];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numOfPhotosFromPhotoBrowser:(JFPhotoBrowserViewController *)browser{
	return ASSETHELPER.selectdPhotos.count;
}

- (NSInteger)currentIndexFromPhotoBrowser:(JFPhotoBrowserViewController *)browser{
	return ASSETHELPER.previewIndex;
}

- (ALAsset *)assetWithIndex:(NSInteger)index fromPhotoBrowser:(JFPhotoBrowserViewController *)browser{
    return ASSETHELPER.selectdAssets[index];
}

- (JFImagePickerViewCell *)cellForRow:(NSInteger)row{
	return (JFImagePickerViewCell *)[[collectionViewController collectionView] cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

- (NSArray *)imagesWithType:(NSInteger)type{
    NSMutableArray *temp = [NSMutableArray array];
    for (ALAsset *asset in ASSETHELPER.selectdAssets) {
        [temp addObject:[ASSETHELPER getImageFromAsset:asset type:type]];
    }
    return temp;
}

- (NSArray *)assets{
    return ASSETHELPER.selectdAssets;
}

+ (void)clear{
    [ASSETHELPER clearData];
    [[JFImageManager sharedManager] clearMem];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}

@end
