//
//  THAskQuestionViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THAskQuestionViewController.h"
#import "CHSCharacterCountTextView.h"
#import "THQuestionSelectTagViewController.h"
#import "UploadImageStatus.h"
#import "uploadImageView.h"
#import <SDiPhoneVersion.h>
#import "TXPhotoBrowserViewController.h"
#import "NSString+MessageInputView.h"
#import "TXSystemManager.h"

static NSInteger const kMaxQuestionDescTextNumber = 500;
static NSInteger const kImageButtonTag = 100;
static NSInteger const kTitleMaxCharacterCount = 20;

@interface THAskQuestionViewController ()
<CHSCharacterCountTextViewDelegate,
UploadImageDelegate,
TXImagePickerControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UILabel *tagLabel;
@property (nonatomic,strong) UITextField *titleTextField;
@property (nonatomic,strong) CHSCharacterCountTextView *descTextView;
@property (nonatomic,strong) UIView *photoListView;
@property (nonatomic,strong) NSMutableArray *uploadPhotos;

@end

@implementation THAskQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorBackground;
    [self setupDefaultPhotoData];
    [self createCustomNavBar];
    if (_isAddNewAnswer) {
        [self setupAddAnswerView];
    }else{
        [self setupQuestionView];
    }
}
#pragma mark - UI视图创建
- (void)createCustomNavBar
{
    [super createCustomNavBar];
    if (_isAddNewAnswer) {
        self.titleStr = @"添加回答";
    }
    [self.btnRight setTitle:@"发布" forState:UIControlStateNormal];
}
//初始化提问问题界面
- (void)setupQuestionView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    //创建标签视图
    UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tagButton.backgroundColor = [UIColor whiteColor];
    tagButton.frame = CGRectMake(0, 0, self.view.width_, 45);
    [tagButton addTarget:self action:@selector(onChangeTagButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:tagButton];
    //标签image
    UIImageView *tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 13, 19, 19)];
    tagImageView.image = [UIImage imageNamed:@"question_tag"];
    [tagButton addSubview:tagImageView];
    //标签label
    self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, tagButton.width_ - 70, tagButton.height_)];
    self.tagLabel.backgroundColor = [UIColor clearColor];
    self.tagLabel.font = kFontMiddle;
    self.tagLabel.textColor = KColorTitleTxt;
    self.tagLabel.text = self.tag.name;
    [tagButton addSubview:self.tagLabel];
    //添加右侧箭头
    if (!_forbiddenChangeTag) {
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tagButton.width_ - 30, 14, 15, 15)];
        arrowImageView.image = [UIImage imageNamed:@"rightArrow"];
        [tagButton addSubview:arrowImageView];
    }
    //内容视图
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, tagButton.maxY + 5, self.view.width_, 250)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.contentView];
    //标题
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(13, 0, self.view.width_ - 26, 39)];
    self.titleTextField.backgroundColor = [UIColor clearColor];
    self.titleTextField.textColor = KColorTitleTxt;
    self.titleTextField.font = kFontSubTitle;
    self.titleTextField.placeholder = @"请输入问题标题:5-20字";
    self.titleTextField.delegate = self;
    [self.contentView addSubview:self.titleTextField];
    //设置placeholder
    NSDictionary *attributes = @{NSFontAttributeName:kFontSubTitle,
                                 NSForegroundColorAttributeName:RGBCOLOR(0xca, 0xca, 0xca)
                                 };
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"请输入问题标题:5-20字" attributes:attributes];
    self.titleTextField.attributedPlaceholder = attString;
    //设置通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChanged)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:self.titleTextField];
    //画线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleTextField.maxY, self.view.width_, kLineHeight)];
    lineView.backgroundColor = kColorLine;
    [self.contentView addSubview:lineView];
    //详情描述
    self.descTextView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:kMaxQuestionDescTextNumber placeHoder:@"填写问题相关描述信息，5-500个字"];
    self.descTextView.frame = CGRectMake(10, self.titleTextField.maxY + 1, self.view.width_ - 20, 120);
    self.descTextView.layer.borderColor = [UIColor clearColor].CGColor;
    self.descTextView.backgroundColor = kColorWhite;
    self.descTextView.placeholderFont = kFontSubTitle;
    self.descTextView.placeholderColor = RGBCOLOR(0xca, 0xca, 0xca);
    self.descTextView.userInteractionEnabled = YES;
    self.descTextView.delegate = self;
    [self.contentView addSubview:self.descTextView];
    //创建图片视图
    self.photoListView = [[UIView alloc] initWithFrame:CGRectMake(0, self.descTextView.maxY, self.contentView.width_, 90)];
    self.photoListView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.photoListView];
    //创建图片视图
    [self updatePhotoListView];
}
//添加回答界面
- (void)setupAddAnswerView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    //内容视图
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 210)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.contentView];
    //详情描述
    self.descTextView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:kMaxQuestionDescTextNumber placeHoder:@"填写回答内容"];
    self.descTextView.frame = CGRectMake(10, 0, self.view.width_ - 20, 120);
    self.descTextView.layer.borderColor = [UIColor clearColor].CGColor;
    self.descTextView.backgroundColor = kColorWhite;
    self.descTextView.userInteractionEnabled = YES;
    self.descTextView.delegate = self;
    [self.contentView addSubview:self.descTextView];
    //创建图片视图
    self.photoListView = [[UIView alloc] initWithFrame:CGRectMake(0, self.descTextView.maxY, self.contentView.width_, 90)];
    self.photoListView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.photoListView];
    //创建图片视图
    [self updatePhotoListView];
}
//刷新图片列表视图
-(void)updatePhotoListView
{
    //移除旧视图
    [self.photoListView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //添加新的视图
    NSMutableArray *photoList = [NSMutableArray array];
    [photoList addObjectsFromArray:self.uploadPhotos];
    if ([self.uploadPhotos count] < 9) {
        //添加+号
        UploadImageStatus *status = [[UploadImageStatus alloc] init];
        status.uploadImage = [UIImage imageNamed:@"medicine_AddNewPhoto"];
        [photoList addObject:status];
    }
    NSInteger columns = 3;
    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        columns = 4;
    }else if ([SDiPhoneVersion deviceSize] == iPhone55inch){
        columns = 4;
    }
    CGFloat verticalSpace = 10;
    CGFloat space = (self.view.width_ - 24 - columns * 80) / (CGFloat)(columns - 1);
    CGFloat photoHeight = 0;
    for (int i = 0; i < [photoList count]; i++) {
        uploadImageView *photoImage  = nil;
        UploadImageStatus *status = photoList[i];
        if(status.uuidKey == nil){
            //+号按钮
            photoImage = [[uploadImageView alloc] initWithImage:status.uploadImage isShowDelImage:NO];
        }else{
            //用户上传的照片
            photoImage = [[uploadImageView alloc] initWithImage:status.uploadImage isShowDelImage:YES];
        }
        photoImage.frame = CGRectMake(12 + (80 + space) * (i % columns), (80 + verticalSpace) * (i / columns), 80, 80);
        [photoImage updateUploadProcess:status.process];
        photoImage.delegate = self;
        [photoImage setBackgroundColor:kColorWhite];
        photoImage.tag = kImageButtonTag + i;
        [_photoListView addSubview:photoImage];
        [photoImage updateViewStatus:status.uploadStatus];
        //添加点击手势
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPhotoTapGestureHandled:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = NO;
        photoImage.userInteractionEnabled = YES;
        [photoImage addGestureRecognizer:tap];
        //设置高度值
        if (i == [photoList count] - 1) {
            photoHeight = photoImage.maxY;
        }
    }
    //设置contentView的Frame
    self.photoListView.frame = CGRectMake(0, self.photoListView.frame.origin.y, self.contentView.width_, photoHeight + 10);
    self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.view.width_, 170 + photoHeight);
    self.scrollView.contentSize = CGSizeMake(self.view.width_, self.contentView.height_ + 50);
}
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        if (_backVc) {
            [self.navigationController popToViewController:_backVc animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        //发布
        [self.view endEditing:YES];
        if (_isAddNewAnswer) {
            [self addNewAnswerToServer];
            
        }else{
            [self postNewQuestionToServer];
        }
    }
}
//点击了切换标签按钮
- (void)onChangeTagButtonTapped
{
    if (_forbiddenChangeTag) {
        //禁止更改标签
        return;
    }
    WEAKSELF
    THQuestionSelectTagViewController *tagVc = [[THQuestionSelectTagViewController alloc] init];
    tagVc.currentTag = _tag;
    tagVc.tagBlock = ^(TXPBTag *tag) {
        STRONGSELF
        if (strongSelf) {
            strongSelf.tag = tag;
            strongSelf.tagLabel.text = tag.name;
        }
    };
    [self.navigationController pushViewController:tagVc animated:YES];
}
#pragma mark - 手势点击
- (void)onPhotoTapGestureHandled:(UITapGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
    NSInteger index = gesture.view.tag - kImageButtonTag;
    WEAKSELF
    BOOL isAddButton = NO;
    if (!_uploadPhotos || ![_uploadPhotos count]) {
        isAddButton = YES;
    }
    if (index >= [_uploadPhotos count]) {
        isAddButton = YES;
    }
    if(isAddButton)
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
                            [strongSelf showImagePickerControllerWithCurrentSelectedCount:([strongSelf.uploadPhotos count])];
                        }else{
                            [strongSelf showPhotoPermissionDeniedAlert];
                        }
                    }];
                }
            }
        } completion:nil];
    }else{
        //正在上传的无法点击 失败的提示重传
        if(index >= 0 && index < [_uploadPhotos count]) {
            UploadImageStatus *uploadImageItem = [_uploadPhotos objectAtIndex:index];
            if(uploadImageItem.uploadStatus == UPLOADIMAGE_STATUS_FAILED) {
                [self reuploadImageItem:uploadImageItem index:index];
                return;
            }
        }
        NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:2];
        for(UploadImageStatus *uploadStatus in _uploadPhotos) {
            [imageUrls addObject:uploadStatus.uploadImage];
        }
        TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
        [browerVc showBrowserWithImages:imageUrls currentIndex:index];
        browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:browerVc animated:YES completion:nil];
    }
}
#pragma mark - 数据处理
- (void)setupDefaultPhotoData
{
    //照片
    self.uploadPhotos = [NSMutableArray array];
}
-(void)insertImageToUploadingList:(UIImage *)newImage
{
    NSUUID *uploadKey = [NSUUID UUID];
    UploadImageStatus *status = [[UploadImageStatus alloc] init];
    status.uploadImage = newImage;
    status.uploadStatus = UPLOADIMAGE_STATUS_UPLOADING;
    status.uuidKey = uploadKey;
    [_uploadPhotos addObject:status];
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.8f);
    WEAKSELF
    [[TXChatClient sharedInstance] uploadData:imageData uuidKey:uploadKey fileExtension:@"jpg" cancellationSignal:^BOOL{
        if (weakSelf == nil) {
//            NSLog(@"视图被销毁了，取消上传");
            return YES;
        }
        return NO;
    } progressHandler:^(NSString *key, float percent) {
        STRONGSELF
        if (strongSelf) {
            [strongSelf updateProcess:key process:percent];
        }
    } onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl) {
        NSString *uploadKey = [serverFileKey stringByDeletingPathExtension];
        //更新 上传view状态
        [_uploadPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
                uploadImageView *uploadImage = (uploadImageView *)[_photoListView viewWithTag:kImageButtonTag + idx];
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
    reuploadImageItem.uploadStatus = UPLOADIMAGE_STATUS_UPLOADING;
    WEAKSELF
    [[TXChatClient sharedInstance] uploadData:imageData uuidKey:reuploadImageItem.uuidKey fileExtension:@"jpg" cancellationSignal:^BOOL{
        if (weakSelf == nil) {
            return YES;
        }
        return NO;
    } progressHandler:^(NSString *key, float percent) {
        STRONGSELF
        if (strongSelf) {
            [strongSelf updateProcess:key process:percent];
        }
    } onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl) {
         NSString *uploadKey = [serverFileKey stringByDeletingPathExtension];
         //更新 上传view状态
         [_uploadPhotos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             UploadImageStatus *status = (UploadImageStatus *)obj;
             if([[status.uuidKey UUIDString] isEqualToString:uploadKey]){
                 if(error){
                     status.uploadStatus = UPLOADIMAGE_STATUS_FAILED;
                 }else{
                     status.uploadStatus = UPLOADIMAGE_STATUS_NORMAL;
                     status.serverFileKey = serverFileKey;
                     status.serverFileUrl = serverFileUrl;
                 }
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 uploadImageView *uploadImage = (uploadImageView *)[_photoListView viewWithTag:kImageButtonTag + idx];
                 [uploadImage updateViewStatus:status.uploadStatus];
             });
         }];
     }];
    
}
-(void)updateProcess:(NSString *)key process:(CGFloat)processValue
{
    NSString *uploadKey = [key stringByDeletingPathExtension];
    NSUInteger index = [self getIndex:uploadKey];
    if(index == NSNotFound){
        return;
    }
    UploadImageStatus *currentUploadImage = [_uploadPhotos objectAtIndex:index];
    currentUploadImage.process = processValue;
    uploadImageView *uploadImage = (uploadImageView *)[_photoListView viewWithTag:kImageButtonTag + index];
    [uploadImage updateUploadProcess:processValue];
    
}
-(NSUInteger)getIndex:(NSString *)key
{
    NSUInteger index = NSNotFound;
    NSArray *photos = [_uploadPhotos copy];
    for(NSUInteger i = 0; i < [photos count]; i++)
    {
        UploadImageStatus *currentImageStatus = [_uploadPhotos objectAtIndex:i];
        if([[currentImageStatus.uuidKey UUIDString] isEqualToString:key])
        {
            index = i;
            break;
        }
    }
    return index;
}
//判断这个图片是否已经被删除
- (BOOL)isPhotoDeletedByKey:(NSString *)key
{
    NSArray *photos = [_uploadPhotos copy];
    __block BOOL isDeleted = NO;
    [photos enumerateObjectsUsingBlock:^(UploadImageStatus *obj, NSUInteger idx, BOOL *stop) {
        NSString *uuidString = [obj.uuidKey UUIDString];
        if ([uuidString isEqualToString:key]) {
            isDeleted = YES;
            *stop = YES;
        }
    }];
    return isDeleted;
}
-(void)reuploadImageItem:(UploadImageStatus *)uploadImageItem index:(NSUInteger)index
{
    WEAKSELF
    ButtonItem *reuploadAgain = [ButtonItem itemWithLabel:@"重试" andTextColor:kColorBlack action:^{
        STRONGSELF
        if (strongSelf) {
            [strongSelf reuploadImage:uploadImageItem];
            [strongSelf updatePhotoListView];
        }
    } ];
    ButtonItem *delItem = [ButtonItem itemWithLabel:@"删除" andTextColor:kColorBlack action:^{
        STRONGSELF
        if (strongSelf) {
            [strongSelf delItem:index +kImageButtonTag];
        }
    } ];
    [self showAlertViewWithMessage:@"重新上传图片" andButtonItems:reuploadAgain, delItem,nil];
}
#pragma mark - 网络请求
//发送新的提问
- (void)postNewQuestionToServer
{
    if (!self.titleTextField.text || ![self.titleTextField.text length]) {
        [self showFailedHudWithTitle:@"请输入问题标题"];
        return;
    }else{
        NSString *trimTitle = [self.titleTextField.text stringByTrimingWhitespace];
        if ([trimTitle length] == 0) {
            [self showFailedHudWithTitle:@"不能输入空白标题"];
            return;
        }
    }
    if ([self.titleTextField.text length] < 5) {
        [self showFailedHudWithTitle:@"您输入的标题少于5个字"];
        return;
    }
    if (![self.descTextView getContent] || ![[self.descTextView getContent] length]) {
        [self showFailedHudWithTitle:@"请填写问题相关描述信息"];
        return;
    }else{
        NSString *trimDesc = [[self.descTextView getContent] stringByTrimingWhitespace];
        if ([trimDesc length] == 0) {
            [self showFailedHudWithTitle:@"不能输入空白描述信息"];
            return;
        }
    }
    if ([[self.descTextView getContent] length] < 5) {
        [self showFailedHudWithTitle:@"您输入的问题描述少于5个字"];
        return;
    }
    //判断是否有未上传的图片
    __block BOOL isUploadFinished = YES;
    [_uploadPhotos enumerateObjectsUsingBlock:^(UploadImageStatus *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.uploadStatus != UPLOADIMAGE_STATUS_NORMAL) {
            //有未上传的图片
            isUploadFinished = NO;
            *stop = YES;
        }
    }];
    if (!isUploadFinished) {
        [self showFailedHudWithTitle:@"图片还未上传完毕"];
        return;
    }
    //网络请求
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableArray *photos = [NSMutableArray array];
    [_uploadPhotos enumerateObjectsUsingBlock:^(UploadImageStatus *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
        txpbAttachBuilder.attachType = TXPBAttachTypePic;
        txpbAttachBuilder.fileurl = obj.serverFileKey;
        TXPBAttach *txpbAttach = [txpbAttachBuilder build];
        [photos addObject:txpbAttach];
    }];
    [[TXChatClient sharedInstance].txJsbMansger askQuestionWithTagId:_tag.id expertId:_expertId ?: 0 title:self.titleTextField.text content:[self.descTextView getContent] anonymous:NO attaches:photos onCompleted:^(NSError *error) {
        //隐藏HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            
            [[TXChatClient sharedInstance].dataReportManager reportEvent:XCSDPBEventTypeAskQuestion];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TeacherHelpRefreshNewQuestionNotification object:nil];
                if (_backVc) {
                    [self.navigationController popToViewController:_backVc animated:YES];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        }
    }];
}
//添加新的回答
- (void)addNewAnswerToServer
{
    if (![self.descTextView getContent] || ![[self.descTextView getContent] length]) {
        [self showFailedHudWithTitle:@"请填写回答内容"];
        return;
    }else{
        NSString *trimDesc = [[self.descTextView getContent] stringByTrimingWhitespace];
        if ([trimDesc length] == 0) {
            [self showFailedHudWithTitle:@"不能输入空白的回答内容"];
            return;
        }
    }
    //判断是否有未上传的图片
    __block BOOL isUploadFinished = YES;
    [_uploadPhotos enumerateObjectsUsingBlock:^(UploadImageStatus *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.uploadStatus != UPLOADIMAGE_STATUS_NORMAL) {
            //有未上传的图片
            isUploadFinished = NO;
            *stop = YES;
        }
    }];
    if (!isUploadFinished) {
        [self showFailedHudWithTitle:@"图片还未上传完毕"];
        return;
    }
    //网络请求
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableArray *photos = [NSMutableArray array];
    [_uploadPhotos enumerateObjectsUsingBlock:^(UploadImageStatus *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
        txpbAttachBuilder.attachType = TXPBAttachTypePic;
        txpbAttachBuilder.fileurl = obj.serverFileKey;
        TXPBAttach *txpbAttach = [txpbAttachBuilder build];
        [photos addObject:txpbAttach];
    }];
    [[TXChatClient sharedInstance].txJsbMansger answerQuestionWithQuestionId:_questionId content:[self.descTextView getContent] anonymous:NO attaches:photos onCompleted:^(NSError *error) {
        //隐藏HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            
            [self reportEvent:XCSDPBEventTypeAnswerQuestion bid:[NSString stringWithFormat:@"%lld", self.questionId]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TeacherHelpRefreshNewAnswerNotification object:nil userInfo:@{@"questionId":@(_questionId)}];
            if (_backVc) {
                [self.navigationController popToViewController:_backVc animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}
#pragma mark - UploadImageDelegate
-(void)delItem:(NSInteger)viewTag
{
    NSInteger index = viewTag - kImageButtonTag;
    if(index >= 0 && index < [_uploadPhotos count])
    {
        [_uploadPhotos removeObjectAtIndex:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updatePhotoListView];
        });
    }
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
        [self updatePhotoListView];
    });
    [super didFinishImagePicker:picker];
}
#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:^{
        CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
        UIImage *retImage = [UIImage scaleImage:image scale:scale];
        if(retImage != nil)
        {
            [self insertImageToUploadingList:retImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updatePhotoListView];
        });
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 文字更改通知
//文字更改了
- (void)textDidChanged
{
    if (self.titleTextField.markedTextRange == nil && self.titleTextField.text.length > kTitleMaxCharacterCount) {
        self.titleTextField.text = [self.titleTextField.text substringToIndex:kTitleMaxCharacterCount];
    }
}
#pragma mark - UITextFieldDelegate methods
//结束编辑
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}
//是否允许添加新字符
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (string && [string length] && existedLength - selectedLength + replaceLength > kTitleMaxCharacterCount) {
        //        NSLog(@"字符数超过：%@",@(_maxInputCharacterCount));
        return NO;
    }
    //    NSLog(@"当前字符数:%@",@([textView.text length]));
    return YES;
}
#pragma mark - CHSCharacterCountTextViewDelegate
-(void)characterCountTextViewIsShowPlaceholder:(BOOL)isShowPlaceholder
{
//    if([_descTextView.getContent trim].length == 0){
//
//    }else{
//
//    }
}
@end
