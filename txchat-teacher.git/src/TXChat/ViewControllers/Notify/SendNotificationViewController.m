//
//  SendNotificationViewController.m
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SendNotificationViewController.h"
#import "CHSCharacterCountTextView.h"
#import "ALAssetsLibrary+Util.h"
#import "ELCAsset.h"
#import "AMPhotoPickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "NoticeSelectGroupViewController.h"
#import <TXChatClient.h>
#import "NoticeSelectedModel.h"
#import "TXPhotoBrowserViewController.h"
#import "TXSendNoticeManager.h"
#import "TeacherNoticeListViewController.h"
#import "uploadImageView.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "TXSystemManager.h"

#define KIMAGETAGBASE (0x1000)
#define KMaxNotificationNumber 500
#define KMaxPhotos 9//最大图片数量
#define KRCVTITLEHIGHT 45.0f//收件人 控件高度
#define KPHOTOHIGHT  50.0f//photo的高度
#define KVIEWMARGIN (5.0f)
@interface SendNotificationViewController ()<ELCImagePickerControllerDelegate, AMPhotoPickerControllerDelegate, UIScrollViewDelegate,UploadImageDelegate, CHSCharacterCountTextViewDelegate,UIImagePickerControllerDelegate,
    TXImagePickerControllerDelegate>
{
    CHSCharacterCountTextView   *_textView;
//    NSArray *_photoList;//附带 图片列表
    NSMutableArray *_selectedPhotos;//选中的图片
    UIScrollView *_scrollView;
    UIView *_contentView;
    NSMutableArray *_selectedDeparts;//
    UILabel *_rcvUsersLabel;//接收者名字
    UILabel *_rcvUsersCountLabel;//接收者数目
    UIView  *_rcvViews;//接收者view
    UIView  *_photoBKView;//图片 背景的view
    BOOL _isInputNoticeContent;//是否输入通知内容
    BOOL _isSelectedRcvers;//是否选择收件人
}
@end

@implementation SendNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isInputNoticeContent = NO;
        _isSelectedRcvers = NO;
        _selectedDeparts = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}
//通过 选中人员列表 初始化 通知
-(id)initWithSelectedDeparts:(NSArray *)selectedDeparts
{
    self = [super init];
    if(self)
    {
        if(selectedDeparts != nil && [selectedDeparts count] > 0)
        {
           [_selectedDeparts addObjectsFromArray:selectedDeparts];
        }
    }
    return  self;
}

-(void)updateSelectedDeparts:(NSArray *)newSelectedDeparts
{
    @synchronized(_selectedDeparts)
    {
        [_selectedDeparts removeAllObjects];
        if(newSelectedDeparts != nil && [newSelectedDeparts count] > 0 )
        {
            [_selectedDeparts addObjectsFromArray:newSelectedDeparts];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"通知";
    [self createCustomNavBar];
    [self createPhotoList];
    NSString *selectStr= [NSString stringWithFormat:@"发送"];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRight setEnabled:NO];
    [self setupViews];
    [self updateSelectedCount];
    [self updateRcvTitles];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
    
    [self.view setBackgroundColor:kColorBackground];
}


-(void)setupViews
{
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.userInteractionEnabled = YES;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    contentView.userInteractionEnabled = YES;
    contentView.clipsToBounds = YES;
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    UIView *intervalView = [UIView new];
    [intervalView setBackgroundColor:kColorWhite];
    intervalView.userInteractionEnabled = YES;
    intervalView.clipsToBounds = YES;
    [_contentView addSubview:intervalView];
    
    
    _textView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:KMaxNotificationNumber placeHoder:nil];
    _textView.layer.borderColor = [UIColor clearColor].CGColor;
    _textView.backgroundColor = kColorWhite;
    _textView.userInteractionEnabled = YES;
    _textView.delegate = self;
    [_contentView addSubview:_textView];
    
    CGFloat hight = 135.0f;
    [intervalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView);
        make.top.mas_equalTo(_contentView).with.offset(0);
        make.height.mas_equalTo(hight);
        make.right.mas_equalTo(_contentView);
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView.mas_left).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(_contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(_contentView).with.offset(-kEdgeInsetsLeft);
        make.bottom.mas_equalTo(intervalView.mas_bottom);
    }];
    
    UIView *imageBKView = [UIView new];
    _photoBKView = imageBKView;
    [imageBKView setBackgroundColor:kColorWhite];
    imageBKView.userInteractionEnabled = YES;
    imageBKView.clipsToBounds = YES;
    [_contentView addSubview:imageBKView];
    
    //图片
    uploadImageView *lastView = nil;
//    CGFloat margin = KVIEWMARGIN;
    CGFloat padding1 = kEdgeInsetsLeft;
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
        [imageBKView addSubview:photoImage];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewTapEvent:)];
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
                
                make.top.mas_equalTo(_textView.mas_bottom).with.offset(padding1);
                make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
                make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %count == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
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

    [imageBKView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView);
        make.right.mas_equalTo(contentView);
        make.top.mas_equalTo(intervalView.mas_bottom).with.offset(0);
        make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
    }];
    
    CGFloat rcvHight = KRCVTITLEHIGHT;
    UIView *rcvBk = [UIView new];
    _rcvViews = rcvBk;
    rcvBk.clipsToBounds = YES;
    [rcvBk setBackgroundColor:kColorWhite];
    [_contentView addSubview:rcvBk];
    {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(RcverViewTapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = NO;
        rcvBk.userInteractionEnabled = YES;
        [rcvBk addGestureRecognizer:tap];
    }
    [rcvBk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_contentView);
        make.top.mas_equalTo(imageBKView.mas_bottom).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(viewWidth, rcvHight));
    }];
    
    UILabel *rcvTitle = [UILabel new];
    [rcvTitle setText:@"收件人"];
    [rcvTitle setTextAlignment:NSTextAlignmentLeft];
    [rcvTitle setTextColor:KColorTitleTxt];
    [rcvTitle setFont:kFontTitle];
    [rcvBk addSubview:rcvTitle];
    [rcvTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rcvBk).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(rcvBk);
        make.size.mas_equalTo(CGSizeMake(50, rcvHight));
    }];
    UILabel *rcvNames = [UILabel new];
    _rcvUsersLabel = rcvNames;
    [rcvNames setText:@""];
    [rcvNames setFont:kFontTitle];
    [rcvNames setTextColor:kColorGray1];
    [rcvBk addSubview:rcvNames];

    UILabel *countLabel = [UILabel new];
    _rcvUsersCountLabel = countLabel;
    [countLabel setText:@""];
    [countLabel setFont:kFontSmall];
    [countLabel setTextColor:kColorGray];
    [_rcvUsersCountLabel setTextAlignment:NSTextAlignmentRight];
    [rcvBk addSubview:countLabel];
    
    
    
    UIImageView *rightArrow = [UIImageView new];
    [rightArrow setImage:[UIImage imageNamed:@"rightArrow"]];
    [rcvBk addSubview:rightArrow];
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(rcvBk);
        make.right.mas_equalTo(rcvBk.mas_right).with.offset(-kEdgeInsetsLeft);
        make.size.mas_equalTo(rightArrow.image.size);
    }];
    
    [rcvNames mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rcvBk.mas_left).with.offset(70);
        make.top.mas_equalTo(rcvBk);
        make.height.mas_equalTo(rcvHight);
        make.right.mas_equalTo(countLabel.mas_left).with.offset(-kEdgeInsetsLeft);
    }];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rcvNames.mas_right).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(rightArrow.mas_left).with.offset(-5.0f);
        make.top.mas_equalTo(rcvBk);
        make.height.mas_equalTo(rcvHight);
        make.width.mas_equalTo(@(60));
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(rcvBk.mas_bottom);
    }];

}


-(void)createPhotoList
{
    _selectedPhotos = [NSMutableArray arrayWithCapacity:1];
    UploadImageStatus *status = [[UploadImageStatus alloc] init];
    status.uploadImage = [UIImage imageNamed:@"medicine_AddNewPhoto"];
    [_selectedPhotos addObject:status];
    
}

-(void)updateViews
{
    for(UIView *subView in _photoBKView.subviews)
    {
        //        if([subView isKindOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }
    }
    
    uploadImageView *lastView = nil;
    CGFloat padding1 = kEdgeInsetsLeft;
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
        [_photoBKView addSubview:photoImage];
        [photoImage updateViewStatus:status.uploadStatus];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewTapEvent:)];
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
                
                make.top.mas_equalTo(_textView.mas_bottom).with.offset(padding1);
                make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
                make.size.mas_equalTo(CGSizeMake(photoHight, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %count == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(_photoBKView.mas_left).with.offset(kEdgeInsetsLeft);
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
    
    [_photoBKView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(kEdgeInsetsLeft);
    }];
    
    [_rcvViews mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_photoBKView.mas_bottom).with.offset(5);;
    }];
    
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_rcvViews.mas_bottom);
    }];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    TXAsyncRunInMain(^{
        [weakSelf updateProcessStatus];
    });
    
}
-(void)updateProcessStatus
{
    for(NSInteger index = 0; index < [_selectedPhotos count] && index < KMaxPhotos; index++)
    {
        UploadImageStatus *status = [_selectedPhotos objectAtIndex:index];
        uploadImageView *uploadImage = (uploadImageView *)[_photoBKView viewWithTag:KIMAGETAGBASE + index];
        [uploadImage updateUploadProcess:status.process];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidLayoutSubviews
{
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 620)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self popToTeacherNoticeList];
    }
    else
    {
        //去除键盘
        [_textView resignFirstResponder];
        if([self isUploading])
        {
            [self uploadingDialog];
        }
        else
        {
            [self sendNotice];
        }
    }
}

-(void)sendNotice
{
    TXSendNotice *sendNotice = [[TXSendNotice alloc] init];
    sendNotice.content = [_textView.getContent trim];
    NSRange range = {0, [_selectedPhotos count]-1};
    sendNotice.attachList = [NSArray arrayWithArray:[_selectedPhotos subarrayWithRange:range]];
    sendNotice.toUsers = _selectedDeparts;
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXSendNoticeManager shareInstance] addNoticeSender:sendNotice completeBlock:^(NSError *error, int64_t taskId) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(error)
        {
            [MobClick event:@"send_notice" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"发送通知", nil] counter:1];
            DDLogDebug(@"error:%@", error);
            [weakSelf showFailedHudWithError:error];
        }
        else
        {
            [[TXChatClient sharedInstance].dataReportManager reportEvent:XCSDPBEventTypeNotice];
            
            [MobClick event:@"send_notice" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"发送通知", nil] counter:1];
            TXAsyncRunInMain(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SEND_NOTICES object:nil];
            });
            [weakSelf popToTeacherNoticeList];
        }
    }];
}

-(void)popToTeacherNoticeList
{
    TeacherNoticeListViewController *lastVC = nil;
    for(UIViewController *index in self.navigationController.viewControllers)
    {
        if([index isKindOfClass:[TeacherNoticeListViewController class]])
        {
            lastVC = (TeacherNoticeListViewController *)index;
        }
    }
    if(lastVC == nil)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popToViewController:lastVC animated:YES];
    }
}


//更新接收人数
-(void)updateRcvTitles
{
    NSInteger count = 0;
    NSMutableString *str = [NSMutableString stringWithCapacity:5];
    for(NoticeSelectedModel *index in _selectedDeparts)
    {
        [str appendFormat:@"%@;", index.departmentName];
        count += [index.selectedUsers count];
    }
    [_rcvUsersLabel setText:str];
    [_rcvUsersCountLabel setText:[NSString stringWithFormat:@"%ld人", (long)count]];
}
//更新选中人数
-(void)updateSelectedCount;
{
    NSInteger count = 0;
    for(NoticeSelectedModel *index in _selectedDeparts)
    {
        count += [index.selectedUsers count];
    }
    if(count > 0)
    {
        _isSelectedRcvers = YES;
    }
    else
    {
        _isSelectedRcvers = NO;
    }
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
-(void)RcverViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    [self showSelectGroup];
}
-(void)showSelectGroup
{
    NoticeSelectGroupViewController *selectGroup = [[NoticeSelectGroupViewController alloc] initWithSelectedDepartments:_selectedDeparts];
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    selectGroup.groupSelectedUpdate = ^(NSArray *selectedDeparments){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateSelectedDeparts:selectedDeparments];
            [weakSelf updateSelectedCount];
            [weakSelf updateRcvTitles];
            [weakSelf updateRightBtnStatus];
        });
    };
    [self.navigationController pushViewController:selectGroup animated:YES];
}

-(void)reuploadImageItem:(UploadImageStatus *)uploadImageItem index:(NSUInteger)index
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
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

-(void)uploadingDialog
{
    [self showFailedHudWithTitle:@"图片正在上传请稍等"];
}



#pragma mark - UIPhotoPickerControllerDelegate
- (void)photoPickerController:(AMPhotoPickerController *)picker didFinishPickingMediaWithInfos:(NSArray *)infos
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
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
        __weak __typeof(&*self) weakSelf=self;  //by sck
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
    __weak __typeof(&*self) weakSelf=self;  //by sck
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
        __weak __typeof(&*self) weakSelf=self;  //by sck
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateViews];
        });
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    [picker dismissViewControllerAnimated:YES completion:^{
        CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kImageMaxWidthPixelSize];
        UIImage *retImage = [UIImage scaleImage:image scale:scale];
        if(retImage != nil)
        {
            [self insertImageToUploadingList:retImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViews];
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
    __weak __typeof(&*self) weakSelf=self;  //by sck
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
                    uploadImageView *uploadImage = (uploadImageView *)[_photoBKView viewWithTag:KIMAGETAGBASE + idx];
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
    __weak __typeof(&*self) weakSelf=self;  //by sck
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
                 uploadImageView *uploadImage = (uploadImageView *)[_photoBKView viewWithTag:KIMAGETAGBASE + idx];
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
    uploadImageView *uploadImage = (uploadImageView *)[_photoBKView viewWithTag:KIMAGETAGBASE + index];
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



//点击图片后处理
-(void)timeViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    [self.view endEditing:YES];
    NSInteger index = recognizer.view.tag - KIMAGETAGBASE;
    DLog(@"tag:%ld", (long)index);
    __weak __typeof(&*self) weakSelf=self;  //by sck
    if(index == [_selectedPhotos count] -1)
    {
        @weakify(self);
        [self showNormalSheetWithTitle:nil items:@[@"拍照",@"从手机相册选择"] clickHandler:^(NSInteger index) {
            @strongify(self);
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
                [[TXSystemManager sharedManager] requestPhotoPermissionWithBlock:^(BOOL photoGranted) {
                    if (photoGranted) {
                        //已授权相册访问
                        [self showImagePickerControllerWithCurrentSelectedCount:[_selectedPhotos count] -1];
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

- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    //去除键盘
    [_textView resignFirstResponder];
}

#pragma mark - CHSCharacterCountTextViewDelegate
-(void)characterCountTextViewIsShowPlaceholder:(BOOL)isShowPlaceholder
{
    if([_textView.getContent trim].length == 0)
    {
        _isInputNoticeContent = NO;
    }
    else
    {
        _isInputNoticeContent = !isShowPlaceholder;
    }
    [self updateRightBtnStatus];
}

-(void)updateRightBtnStatus
{
    [self.btnRight setEnabled:_isInputNoticeContent&&_isSelectedRcvers];
}
@end
