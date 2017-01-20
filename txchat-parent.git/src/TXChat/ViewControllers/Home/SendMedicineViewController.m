//
//  SendMedicineViewController.m
//  TXChat
//
//  Created by lyt on 15-6-29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SendMedicineViewController.h"
#import "CHSCharacterCountTextView.h"
#import "ALAssetsLibrary+Util.h"
#import "ELCAsset.h"
#import "AMPhotoPickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "TXPhotoBrowserViewController.h"
#import "uploadImageView.h"
#import <TXChatClient.h>
#import "UploadImageStatus.h"
#import "TXRequestHelper.h"
#import "AppDelegate.h"
#import "TXSystemManager.h"
#import <NSDate+DateTools.h>
#import "TXSystemManager.h"

#define KMaxMedicineNumber 100//喂药输入文字最大长度
#define KMaxPhotos 9//最大图片数量
#define KPHOTOHIGHT  50.0f//photo的高度
#define KIMAGETAGBASE (1000)
#define KVIEWMARGIN (5.0f)

@interface SendMedicineViewController ()<ELCImagePickerControllerDelegate, AMPhotoPickerControllerDelegate, UploadImageDelegate, CHSCharacterCountTextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate,
    TXImagePickerControllerDelegate>
{
    UIScrollView *_scrollView;
    NSMutableArray *_selectedPhotos;//选中的图片
    UIView  *_photoBackground;//图片部分
    UIView *_contentView;//滚动条内的view;
    UILabel *_medicineDate;//选择时间
    BOOL _isInputMedicineContent;//是否输入喂药内容
    NSDate *_selectedDate;//选中的日期
    CHSCharacterCountTextView *_textView;//喂药详情部分
}
@end

@implementation SendMedicineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isInputMedicineContent = NO;
        _selectedDate  = [NSDate date];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self createCustomNavBar];
    [self.btnRight setTitle:@"发送" forState:UIControlStateNormal];
    [self.btnRight setEnabled:NO];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    self.titleStr = @"喂药要求";
    [self createPhotoList];
    [self setupViews];
    self.view.backgroundColor = kColorBackground;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    
}

-(void)setupViews
{
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    UIView *dateBackView = [UIView new];
    
    dateBackView.backgroundColor = [UIColor clearColor];
    dateBackView.userInteractionEnabled = YES;
    [_contentView addSubview:dateBackView];
    
    
    UILabel *medicineDateTitle = [UILabel new];
    [medicineDateTitle setText:@"喂药日期"];
    [medicineDateTitle setFont:kFontTiny];
    [medicineDateTitle setTextColor:kColorGray1];
    [medicineDateTitle setBackgroundColor:[UIColor clearColor]];
    [dateBackView addSubview:medicineDateTitle];
    [medicineDateTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dateBackView).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(dateBackView).with.offset(0.0f);
        make.height.mas_equalTo(30.0f);
        make.width.mas_equalTo(80.0f);
    }];
    
    CGFloat margin = KVIEWMARGIN;
    //喂药日期 部分
    CGFloat headerViewHight = 40.0f;
    UIView *headerView = [UIView new];
    [headerView setBackgroundColor:kColorWhite];
    [dateBackView addSubview:headerView];
    UITapGestureRecognizer* dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedNewDate:)];
    dateTap.numberOfTapsRequired = 1;
    dateTap.numberOfTouchesRequired = 1;
    //        tap.delegate = self;
    dateTap.cancelsTouchesInView = NO;
    headerView.userInteractionEnabled = YES;
    [headerView addGestureRecognizer:dateTap];
    
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(dateBackView).with.offset(0);
        make.right.mas_equalTo(dateBackView);
        make.top.mas_equalTo(medicineDateTitle.mas_bottom).with.offset(0);
        make.height.mas_equalTo(headerViewHight);
    }];
    [dateBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.right.mas_equalTo(@(0));
        make.top.mas_equalTo(@(0));
        make.bottom.mas_equalTo(headerView.mas_bottom);
    }];
    

    
    UILabel *medicineDate = [UILabel new];
    _medicineDate = medicineDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    medicineDate.text = [dateFormatter stringFromDate: _selectedDate];
    [medicineDate setFont:kFontNormal];
    [medicineDate setTextColor:kColorGray];
    [headerView addSubview:medicineDate];
    medicineDate.textAlignment = NSTextAlignmentLeft;
    [medicineDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_left).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(headerView);
        make.bottom.mas_equalTo(headerView);
        make.width.mas_equalTo(200.0f);
    }];
    
    UIButton *selectedMedicineDateBtn = [UIButton new];
    [selectedMedicineDateBtn setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    [headerView addSubview:selectedMedicineDateBtn];
    [selectedMedicineDateBtn addTarget:self action:@selector(selectedNewDate:) forControlEvents:UIControlEventTouchUpInside];
    [selectedMedicineDateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(headerView.mas_right).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(headerView);
        make.size.mas_equalTo(selectedMedicineDateBtn.imageView.image.size);
    }];
    
    UIView *contentBackView = [UIView new];
    
    contentBackView.backgroundColor = [UIColor clearColor];
    contentBackView.userInteractionEnabled = YES;
    [_contentView addSubview:contentBackView];
    

    
    
    UILabel *contentTitle = [UILabel new];
    [contentTitle setText:@"喂药说明"];
    [contentTitle setFont:kFontTiny];
    [contentTitle setTextColor:kColorGray1];
    [contentTitle setBackgroundColor:[UIColor clearColor]];
    contentTitle.textAlignment = NSTextAlignmentLeft;
    [contentBackView addSubview:contentTitle];
    [contentTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentBackView).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(contentBackView).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    //喂药文字部分
    UIView *medicineContentBackground = [UIView new];
    [medicineContentBackground setBackgroundColor:kColorWhite];
    [contentBackView addSubview:medicineContentBackground];
    [medicineContentBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentTitle.mas_bottom).with.offset(0);
        make.left.mas_equalTo(contentBackView);
        make.right.mas_equalTo(contentBackView);
        make.height.mas_equalTo(120.0f);
    }];
    
    [contentBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.right.mas_equalTo(@(0));
        make.top.mas_equalTo(dateBackView.mas_bottom);
        make.bottom.mas_equalTo(medicineContentBackground.mas_bottom);
    }];
    
    _textView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:KMaxMedicineNumber placeHoder:@"请向老师说明药名,服用剂量,喂药时间"];
    _textView.layer.borderColor = [UIColor clearColor].CGColor;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.userInteractionEnabled = YES;
    _textView.delegate = self;
    [medicineContentBackground addSubview:_textView];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(medicineContentBackground).with.offset(kEdgeInsetsLeft-5);
        make.top.mas_equalTo(medicineContentBackground).with.offset(margin);
        make.right.mas_equalTo(medicineContentBackground).with.offset(-kEdgeInsetsLeft+5);
        make.bottom.mas_equalTo(medicineContentBackground.mas_bottom).with.offset(-margin);
    }];
    
    
    UIView *attachBK = [UIView new];
    attachBK.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:attachBK];
    
    UILabel *photoTitle = [UILabel new];
    [photoTitle setTextColor:kColorGray1];
    [photoTitle setText:@"添加图片(最多可添加9张图片)"];
    [photoTitle setFont:kFontTiny];
    [photoTitle setBackgroundColor:[UIColor clearColor]];
    [attachBK addSubview:photoTitle];
    [photoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(attachBK).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(attachBK).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    
    UIView *photoBackground = [UIView new];
    _photoBackground = photoBackground;
    [photoBackground setBackgroundColor:kColorWhite];
    [attachBK addSubview:photoBackground];
    
    //图片
    uploadImageView *lastView = nil;
    CGFloat padding1 = 15.0f;
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
        [photoBackground addSubview:photoImage];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewTapEvent:)];
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
                
                make.top.mas_equalTo(photoBackground.mas_top).with.offset(kEdgeInsetsLeft);
                make.left.mas_equalTo(photoBackground.mas_left).with.offset(kEdgeInsetsLeft);
                make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %count == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(photoBackground.mas_left).with.offset(kEdgeInsetsLeft);
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
    
    [photoBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(attachBK);
        make.right.mas_equalTo(attachBK);
        make.top.mas_equalTo(photoTitle.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];
    
    [attachBK mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView);
        make.right.mas_equalTo(contentView);
        make.top.mas_equalTo(contentBackView.mas_bottom);
        make.bottom.mas_equalTo(photoBackground.mas_bottom);
    }];
    
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(photoBackground.mas_bottom);
    }];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    
}
-(void)updateViews
{
    
    for(UIView *subView in _photoBackground.subviews)
    {
//        if([subView isKindOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }
    }
    
    uploadImageView *lastView = nil;
    CGFloat padding1 = 15.0f;
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
    
//    UILabel *photoTitle = [UILabel new];
//    [photoTitle setTextColor:kColorBlack];
//    [photoTitle setText:@"添加图片"];
//    [photoTitle setFont:kFontNormal];
//    [_photoBackground addSubview:photoTitle];
//    [photoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(_photoBackground).with.offset(kEdgeInsetsLeft);
//        make.top.mas_equalTo(_photoBackground).with.offset(margin);
//        make.size.mas_equalTo(CGSizeMake(75, 30));
//    }];
//    
//    UILabel *photoSubTitle = [UILabel new];
//    [photoSubTitle setTextColor:kColorLightGray];
//    [photoSubTitle setText:@"(最多可添加9张图片)"];
//    [photoSubTitle setFont:kFontSmall];
//    [photoSubTitle setTextAlignment:NSTextAlignmentLeft];
//    [_photoBackground addSubview:photoSubTitle];
//    [photoSubTitle mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(photoTitle.mas_right).with.offset(0);
//        make.centerY.mas_equalTo(photoTitle);
//        make.size.mas_equalTo(CGSizeMake(200, 30));
//    }];
    
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
        [_photoBackground addSubview:photoImage];
        [photoImage updateViewStatus:status.uploadStatus];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewTapEvent:)];
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
                
                make.top.mas_equalTo(_photoBackground.mas_top).with.offset(kEdgeInsetsLeft);
                make.left.mas_equalTo(_photoBackground.mas_left).with.offset(kEdgeInsetsLeft);
                make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %count == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_photoBackground.mas_left).with.offset(kEdgeInsetsLeft);
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
    
    [_photoBackground mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];
    
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_photoBackground.mas_bottom);
    }];
    WEAKSELF
    TXAsyncRunInMain(^{
        [weakSelf updateProcessStatus];
    });
    
}
-(void)updateProcessStatus
{
    for(NSInteger index = 0; index < [_selectedPhotos count] && index < KMaxPhotos; index++)
    {
        UploadImageStatus *status = [_selectedPhotos objectAtIndex:index];
        uploadImageView *uploadImage = (uploadImageView *)[_photoBackground viewWithTag:KIMAGETAGBASE + index];
        [uploadImage updateUploadProcess:status.process];
    }
}



-(void)createPhotoList
{
    _selectedPhotos = [NSMutableArray arrayWithCapacity:1];

    UploadImageStatus *status = [[UploadImageStatus alloc] init];
    status.uploadImage = [UIImage imageNamed:@"medicine_AddNewPhoto"];
    if(status)
    {
        [_selectedPhotos addObject:status];
    }
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        //去除键盘
        [_textView resignFirstResponder];
        
        if([self isUploading])
        {
            [self uploadingDialog];
        }
        else{
            [self sendMedicineDialog];
        }
    }
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
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
//点击图片后处理
-(void)photoViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    
    [self.view endEditing:YES];
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
            }else if (index == 1) {
                //相册
                [[TXSystemManager sharedManager] requestPhotoPermissionWithBlock:^(BOOL photoGranted) {
                    if (photoGranted) {
                        //已授权相册访问
                        [weakSelf showImagePickerControllerWithCurrentSelectedCount:[_selectedPhotos count] -1];
                    }else{
                        //未授权相册访问
                        [self showPhotoPermissionDeniedAlert];
                    }
                }];
            }
        } completion:nil];
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
        
        TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] init];
        [browerVc showBrowserWithImages:imageUrls currentIndex:index];
        [self.navigationController pushViewController:browerVc animated:YES];
    }
}


-(void)reuploadImageItem:(UploadImageStatus *)uploadImageItem index:(NSUInteger)index
{
    WEAKSELF
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

-(void)sendMedicineDialog
{
    WEAKSELF
    ButtonItem *checkAgain = [ButtonItem itemWithLabel:@"再检查一下" andTextColor:kColorBlack action:^{
        
    } ];
    ButtonItem *confirm = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
        [weakSelf sendMedicineRequestToServer];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } ];
    [self showAlertViewWithMessage:@"提交后默认为家长签字同意服药的要求" andButtonItems:checkAgain, confirm,nil];
//    [self showFailedHudWithTitle:@"提交后默认为家长签字同意服药的要求"];
}


-(void)uploadingDialog
{
//    ButtonItem *confirm = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
//        
//    } ];
//    [self showAlertViewWithMessage:@"图片正在上传请稍等" andButtonItems:confirm,nil];
    [self showFailedHudWithTitle:@"图片正在上传请稍等"];
}



-(void)selectedNewDate:(id)button
{
    [_textView resignFirstResponder];
    @weakify(self);
    [self showDatePickerWithCurrentDate:[NSDate date] minimumDate:[NSDate date] maximumDate:[[NSDate date] dateByAddingYears:1] selectedDate:_selectedDate selectedBlock:^(NSDate *selectedDate) {
        @strongify(self);
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        _medicineDate.text = [dateFormatter stringFromDate: selectedDate];
        [self updateRightBtnStatus];
        _selectedDate = selectedDate;
    }];
    
    
}

//提交到服务器
-(void)sendMedicineRequestToServer
{
    NSMutableArray *photoArray = [NSMutableArray arrayWithCapacity:5];
    for(UploadImageStatus *uploadStatusIndex in _selectedPhotos)
    {
        if(uploadStatusIndex == _selectedPhotos.lastObject)
        {
            break;
        }
        if(uploadStatusIndex.uploadStatus == UPLOADIMAGE_STATUS_NORMAL)
        {
            [photoArray addObject:uploadStatusIndex];
            [[TXSystemManager sharedManager] saveImageToCache:uploadStatusIndex.uploadImage forURLString:[uploadStatusIndex.serverFileUrl getFormatPhotoUrl]];
        }

    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    WEAKSELF
    [[TXRequestHelper shareInstance] sendMedicineRequestToServer:photoArray content:[[_textView getContent] trim] beginDate:(int64_t)([_selectedDate timeIntervalSince1970]*1000) completeBlock:^(NSError *error, int64_t taskId) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(!error)
        {
            [MobClick event:@"create_newmessage" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"喂药", nil] counter:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_MEDICINES object:nil];
            });
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MobClick event:@"create_newmessage" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"喂药", nil] counter:1];
//            [weakSelf showAlertViewWithMessage:@"发送失败，请重新发送" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [weakSelf showFailedHudWithTitle:@"发送失败，请重新发送"];
        }
    }];
}

#pragma mark - TXImagePickerControllerDelegate methods
- (void)imagePickerController:(TXImagePickerController *)picker didFinishPickingImages:(NSArray *)imageArray
{
    for (UIImage *image in imageArray) {
        CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
        UIImage *retImage = [UIImage scaleImage:image scale:scale];
        if(retImage != nil)
        {
            [self insertImageToUploadingList:retImage];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateViews];
    });
    [super didFinishImagePicker:picker];
}
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    WEAKSELF
    [picker dismissViewControllerAnimated:YES completion:^{
        @autoreleasepool {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
            UIImage *newImage = [UIImage scaleImage:image scale:scale];
            image = nil;
            if(newImage != nil)
            {
                [weakSelf insertImageToUploadingList:newImage];
            }
            WEAKSELF
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateViews];
            });
        }
    }];
}


#pragma mark - UIPhotoPickerControllerDelegate
- (void)photoPickerController:(AMPhotoPickerController *)picker didFinishPickingMediaWithInfos:(NSArray *)infos
{
    WEAKSELF
    [picker dismissViewControllerAnimated:YES completion:^{
        //处理图片
        for (NSDictionary *info in infos) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            //            image = [self saveImage:image];
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
            UIImage *retImage = [UIImage scaleImage:image scale:scale];
            if(retImage != nil)
            {
                [weakSelf insertImageToUploadingList:retImage];
            }
        }
        WEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateViews];
        });
    }];
}

- (void)photoPickerControllerBeyondMaxNumber:(AMPhotoPickerController *)picker
{
}

- (void)photoPickerControllerDidCancel:(AMPhotoPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)infos
{
    WEAKSELF
    [picker dismissViewControllerAnimated:YES completion:^{
        for (NSDictionary *info in infos) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            //            image = [self saveImage:image];
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
            UIImage *retImage = [UIImage scaleImage:image scale:scale];
            if(retImage != nil)
            {
                [weakSelf insertImageToUploadingList:retImage];
            }
        }
        WEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateViews];
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
    WEAKSELF
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
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    uploadImageView *uploadImage = (uploadImageView *)[_photoBackground viewWithTag:KIMAGETAGBASE + idx];
                    [uploadImage updateViewStatus:status.uploadStatus];
                });
                *stop = YES;
            }

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
    WEAKSELF
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
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadImageView *uploadImage = (uploadImageView *)[_photoBackground viewWithTag:KIMAGETAGBASE + idx];
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
    uploadImageView *uploadImage = (uploadImageView *)[_photoBackground viewWithTag:KIMAGETAGBASE + index];
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


#pragma mark - UploadImageDelegate
-(void)delItem:(NSInteger)viewTag
{
    NSInteger index = viewTag - KIMAGETAGBASE;
    if(index >= 0 && index < [_selectedPhotos count])
    {
        [_selectedPhotos removeObjectAtIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViews];
        });
    }

}


#pragma mark - CHSCharacterCountTextViewDelegate
-(void)characterCountTextViewIsShowPlaceholder:(BOOL)isShowPlaceholder
{
    if([_textView.getContent trim].length == 0)
    {
        _isInputMedicineContent = NO;
    }
    else
    {
        _isInputMedicineContent = !isShowPlaceholder;
    }
    [self updateRightBtnStatus];
}

-(void)updateRightBtnStatus
{
    [self.btnRight setEnabled:_isInputMedicineContent];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_textView resignFirstResponder];
}

- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    //去除键盘
    [_textView resignFirstResponder];
}


@end
