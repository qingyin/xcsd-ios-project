//
//  TXPhotoBrowserViewController.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/12.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXPhotoBrowserViewController.h"
#import "MWPhotoBrowser.h"
#import "CirclePhotosViewController.h"

NSString *photosEnd = @"end";


@interface TXPhotoBrowserViewController ()
<MWPhotoBrowserDelegate,
UIActionSheetDelegate>

@property (strong, nonatomic) MWPhotoBrowser *photoBrowser;
@property (strong, nonatomic) NSMutableArray *photos;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic, strong) UILabel *indexView;
@property (nonatomic, strong) NSMutableArray *currentImgsArr;

@end

@implementation TXPhotoBrowserViewController

- (instancetype)initWithFullScreen:(BOOL)isFullScreen
{
    self = [super init];
    if (self) {
        self.isFullScreen = isFullScreen;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_isFullScreen) {
        [self createCustomNavBar];
    }
    _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    if (_isFullScreen) {
        _photoBrowser.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    }else{
        _photoBrowser.view.frame = CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY);
    }
    _photoBrowser.displayActionButton = NO;
    _photoBrowser.displayNavArrows = NO;
    _photoBrowser.displaySelectionButtons = NO;
    _photoBrowser.alwaysShowControls = NO;
//    if ([_photoBrowser respondsToSelector:@selector(setWantsFullScreenLayout:)]) {
//        [_photoBrowser setWantsFullScreenLayout:YES];
//    }
    _photoBrowser.zoomPhotosToFill = YES;
    _photoBrowser.enableGrid = NO;
    _photoBrowser.startOnGrid = NO;
    [_photoBrowser setCurrentPhotoIndex:_currentIndex];
    [_photoBrowser willMoveToParentViewController:self];
    [self.view addSubview:_photoBrowser.view];
    [self addChildViewController:_photoBrowser];
    //添加index视图
    self.indexView = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 100) / 2, CGRectGetHeight(self.view.bounds) - 100, 100, 40)];
    self.indexView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.indexView.layer.cornerRadius = 5;
    self.indexView.layer.masksToBounds = YES;
    self.indexView.textAlignment = NSTextAlignmentCenter;
    self.indexView.textColor = kColorWhite;
    self.indexView.font = kFontNormal;
    [self.view addSubview:self.indexView];
    //添加长按手势
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGestureHandled:)];
//    gesture.minimumPressDuration = 1.f;
    gesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //tabbar效果
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

#pragma mark - getter
- (NSMutableArray *)photos
{
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    
    return _photos;
}

#pragma mark - 按钮点击方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//重新加载图片
- (void)reloadImageWithPhoto:(MWPhoto *)photo
{
    [photo reloadURLImage];
}
#pragma mark - 长按手势
- (void)onLongPressGestureHandled:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        NSInteger currentIndex = [_photoBrowser currentIndex];
        MWPhoto *photo = self.photos[currentIndex];
        NSMutableArray *items = [NSMutableArray arrayWithObject:@"保存到手机"];
        if (photo.photoURL) {
            [items addObject:@"用浏览器打开"];
            [items addObject:@"重新加载"];
        }
        [self showNormalSheetWithTitle:nil items:items clickHandler:^(NSInteger index) {
            if (index == 0) {
                NSInteger currentIndex = [_photoBrowser currentIndex];
                UIImage *img = [_photoBrowser imageForPhoto:self.photos[currentIndex]];
                if (img) {
                    UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
                }
            }
            else if (index == 1) {
                [[UIApplication sharedApplication] openURL:photo.photoURL];
            }else if (index == 2) {
                //重新加载
                [self reloadImageWithPhoto:photo];
            }
        } completion:nil];
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [self.photos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count)
    {
        return [self.photos objectAtIndex:index];
    }
    
    return nil;
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser singleTappedForPhotoAtIndex:(NSUInteger)index
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index
{
    MWPhoto *photo = _photos[index];
    if ([photo.photoURL isEqual:[NSURL URLWithString:photosEnd]] && _hasMore) {
        [self fetchPhotos];
    }
    
    if ([self.photos count] > 1) {
        self.indexView.hidden = NO;
        NSNumber *totalCount = @([self.photos count]);
        if ([_preVC isKindOfClass:[CirclePhotosViewController class]]) {
            totalCount = @(_totalCount);
        }
        self.indexView.text = [NSString stringWithFormat:@"%@/%@",@(index + 1),totalCount];
    }else{
        self.indexView.hidden = YES;
    }
}
#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
                 currentIndex:(NSInteger)index
{
    self.currentImgsArr = [NSMutableArray arrayWithArray:imageArray];
    self.currentIndex = index;
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            MWPhoto *photo;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [MWPhoto photoWithImage:object];
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                photo = [MWPhoto photoWithURL:object];
            }else if ([object isKindOfClass:[EMMessage class]]) {
                photo = [MWPhoto photoWithCustomPhoto:object];
            }else if ([object isKindOfClass:[NSString class]]){
                if([object isEqualToString:photosEnd])
                {
                    photo = [MWPhoto photoWithURL:[NSURL URLWithString:object]];
                }
                else
                {
                    photo = [MWPhoto photoWithURL:[NSURL URLWithString:[object getFormatPhotoUrl]]];
                }
            }else if ([object isKindOfClass:[NSDictionary class]]){
                UIImage *img = [UIImage imageWithData:object[@"data"]];
                photo = [MWPhoto photoWithImage:img];
            }else if ([object isKindOfClass:[TXPBAttach class]]){
                TXPBAttach *attach = object;
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:[attach.fileurl getFormatPhotoUrl]]];
            }else if ([object isKindOfClass:[TXDepartmentPhoto class]]){
                TXDepartmentPhoto *departmentPhoto = object;
                photo = [MWPhoto photoWithURL:[NSURL URLWithString:[departmentPhoto.fileUrl getFormatPhotoUrl]]];
            }
            if(photo)
            {
                [photoArray addObject:photo];
            }
        }
        
        self.photos = photoArray;
    }
//    [_photoBrowser reloadData];
    [_photoBrowser setCurrentPhotoIndex:_currentIndex];

//    UIViewController *rootController = [self.keyWindow rootViewController];
//    [rootController presentViewController:self.photoNavigationController animated:YES completion:nil];
}

//获取相册网络数据
- (void)fetchPhotos{
    [TXProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)tmpObject = self;
    TXDepartmentPhoto *photo = _currentImgsArr[_currentImgsArr.count - 2];
    NSInteger index = _currentImgsArr.count;
    [[TXChatClient sharedInstance].departmentPhotoManager fetchDepartmentPhotos:_departmentId maxDepartmentPhotoId:photo.departmentPhotoId onCompleted:^(NSError *error, NSArray *txDepartmentPhotos,int64_t totalCount ,BOOL hasMore) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }else{
            [tmpObject.currentImgsArr removeObject:photosEnd];
            [tmpObject.currentImgsArr addObjectsFromArray:txDepartmentPhotos];
            if(hasMore)
            {
                [tmpObject.currentImgsArr addObject:photosEnd];
            }
            tmpObject.hasMore = hasMore;
            [tmpObject showBrowserWithImages:tmpObject.currentImgsArr currentIndex:index];
            [tmpObject.photoBrowser reloadData];
        }
    }];
}


@end
