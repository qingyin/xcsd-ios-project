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
#import <AVFoundation/AVFoundation.h>

#define KIMAGETAGBASE (0x1000)
#define KMaxNotificationNumber 500
@interface SendNotificationViewController ()<ELCImagePickerControllerDelegate, AMPhotoPickerControllerDelegate>
{
    CHSCharacterCountTextView   *_textView;
    NSArray *_photoList;//附带 图片列表
   UIScrollView *_scrollView;
}
@end

@implementation SendNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
//    WEAKSELF
    CGFloat viewWidth = self.view.frame.size.width;
    _scrollView= [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.frame.size.width, self.view.frame.size.height - self.customNavigationView.maxY)];
    //    _scrollView = [UIScrollView new];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:_scrollView];

    UIView *superView = _scrollView;
    
    UIView *titleView = [UIView new];
    [titleView setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).with.offset(0);
        make.left.mas_equalTo(superView);
//        make.right.mas_equalTo(superView);
        make.width.mas_equalTo(viewWidth);
        make.height.mas_equalTo(28.0f);
    }];
    
    UILabel *titleLabel = [UILabel new];
    [titleLabel setText:@"正文"];
    [titleLabel setTextColor:[UIColor grayColor]];
    [titleView addSubview:titleLabel];
    CGFloat padding1 = 15.0f;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleView).with.offset(padding1);
        make.top.mas_equalTo(titleView);
        make.bottom.mas_equalTo(titleView);
        make.width.mas_equalTo(100.0f);
    }];
    
    _textView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:KMaxNotificationNumber placeHoder:nil];
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = RGBCOLOR(0xd4, 0xd4, 0xd4).CGColor;
    _textView.layer.cornerRadius = 2.5f;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.userInteractionEnabled = YES;
    [_scrollView addSubview:_textView];

    
    CGFloat padding = 10.0f;
    CGFloat hight = 200.0f;
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(superView.mas_left).with.offset(0);
        make.top.mas_equalTo(titleView.mas_bottom);
//        make.right.mas_equalTo(superView.mas_right).with.offset(0);
        make.width.mas_equalTo(viewWidth);
        make.height.mas_equalTo(hight);
    }];
    
    
    UIView *imageBKView = [UIView new];
    [imageBKView setBackgroundColor:[UIColor whiteColor]];
    imageBKView.userInteractionEnabled = YES;
    [_scrollView addSubview:imageBKView];
    
//    CGFloat padding2 = 10.0f;

    //图片
    UIImageView *lastView = nil;
//    CGFloat padding2 = 10.0f;
    CGFloat photoHight = 60.0f;
    NSInteger lines = ceilf([_photoList count]/3.0);
    
    CGFloat photoBkHight = lines*photoHight + (lines+1)*padding1;
    [imageBKView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_textView.mas_bottom).with.offset(padding);
        make.left.mas_equalTo(titleView);
//        make.right.mas_equalTo(titleView);
        make.width.mas_equalTo(viewWidth);
        make.height.mas_equalTo(photoBkHight);
    }];
    

    for(NSInteger index = 0; index < [_photoList count]; index++)
    {
        UIImageView *photoImage  = [UIImageView new];
        [photoImage setImage:[UIImage imageNamed:[_photoList objectAtIndex:index]]];
        [photoImage setBackgroundColor:kColorCircleBg];
        photoImage.tag = KIMAGETAGBASE + index;
        [imageBKView addSubview:photoImage];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FromViewTapEvent:)];
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
                
                make.top.mas_equalTo(imageBKView.mas_top).with.offset(padding1);
                make.left.mas_equalTo(imageBKView.mas_left).with.offset(padding1);
                make.size.mas_equalTo(CGSizeMake((viewWidth-5*padding1)/3.0f, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %3 == 0)
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(imageBKView.mas_left).with.offset(padding1);
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
                    make.size.mas_equalTo(CGSizeMake((viewWidth-5*padding1)/3.0f, photoHight));
                    
                }];
            }
            else//左排第2，3
            {
                [photoImage mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(lastView.mas_right).with.offset(padding1);
                    make.top.mas_equalTo(lastView.mas_top).with.offset(0);
                    make.size.mas_equalTo(CGSizeMake((viewWidth-5*padding1)/3.0f, photoHight));
                    
                }];
            }
            
        }
        lastView = photoImage;
    }
    CGFloat rcvHight = 45.0f;
    UIView *rcvBk = [UIView new];
    [rcvBk setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:rcvBk];
    {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(RcverViewTapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        //        tap.delegate = self;
        tap.cancelsTouchesInView = NO;
        rcvBk.userInteractionEnabled = YES;
        [rcvBk addGestureRecognizer:tap];
    }
    [rcvBk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(superView);
        make.top.mas_equalTo(imageBKView.mas_bottom).with.offset(padding1);
        make.size.mas_equalTo(CGSizeMake(viewWidth, rcvHight));
    }];
    
    UILabel *rcvTitle = [UILabel new];
    [rcvTitle setText:@"收件人"];
    [rcvTitle setTextAlignment:NSTextAlignmentRight];
    [rcvBk addSubview:rcvTitle];
    [rcvTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rcvBk);
        make.top.mas_equalTo(rcvBk);
        make.size.mas_equalTo(CGSizeMake(70, rcvHight));
    }];
    UILabel *rcvNames = [UILabel new];
    [rcvNames setText:@"超超;宁宁;超超家长;超超;宁宁;超超家长;超超;宁宁;超超家长;超超;宁宁;超超家长;超超;宁宁;超超家长;超超;宁宁;超超家长;"];
    [rcvNames setTextColor:[UIColor grayColor]];
    [rcvBk addSubview:rcvNames];
    [rcvNames mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rcvTitle.mas_right).with.offset(5);
        make.top.mas_equalTo(rcvBk);
        make.size.mas_equalTo(CGSizeMake(240, rcvHight));
    }];
    
    UIImageView *rightArrow = [UIImageView new];
    [rightArrow setImage:[UIImage imageNamed:@"rightArrow"]];
    [rcvBk addSubview:rightArrow];
    [rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(rcvBk);
        make.centerY.mas_equalTo(rcvBk);
        make.right.mas_equalTo(rcvBk.mas_right);
        make.size.mas_equalTo(rightArrow.image.size);
    }];
    
    
    
}
-(void)createPhotoList
{
    _photoList = @[@"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected", @"third_selected"];
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
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        
//        [[TXChatClient sharedInstance] sendNotice:@"1111222" attaches:@[@"test", @"test"] toDepartments:nil onCompleted:^(NSError *error, TXNotice *txNotice) {
//            DLog(@"error:%@", error);
//            
//        }];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    NoticeSelectGroupViewController *selectGroup = [[NoticeSelectGroupViewController alloc] init];
    [self.navigationController pushViewController:selectGroup animated:YES];
}

-(void)FromViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    
    //    NSInteger section = recognizer.view.tag - KHEADERVIEWBASETAG;
    //    DLog(@"section:%ld", (long)section);
//    [self showFromDetailVC];
    NSInteger index = recognizer.view.tag - KIMAGETAGBASE;
    DLog(@"tag:%ld", (long)index);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
    [actionSheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
    if (buttonIndex == 0) {
        //拍照
        AMPhotoPickerController *photoPickerController = [[AMPhotoPickerController alloc] init];
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            photoPickerController.isAuth = NO;
        }else{
            photoPickerController.isAuth = YES;
        }
        photoPickerController.maxPickerNumber = 1;
        photoPickerController.photoDelegate = self;
        photoPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentViewController:photoPickerController animated:YES completion:NULL];
    }else if (buttonIndex == 1){
        //相册
        ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
        ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];        
        [albumController setParent:imagePicker];
        [imagePicker setDelegate:self];
        [self.navigationController presentViewController:imagePicker animated:YES completion:NULL];
        }
    }];
}


#pragma mark - UIPhotoPickerControllerDelegate
- (void)photoPickerController:(AMPhotoPickerController *)picker didFinishPickingMediaWithInfos:(NSArray *)infos
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //        //处理图片
        //        for (NSDictionary *info in infos) {
        //            UIImage *image = info[UIImagePickerControllerOriginalImage];
        //            image = [self saveImage:image];
        //            [_photoArr addObject:image];
        //        }
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
    [picker dismissViewControllerAnimated:YES completion:^{
        //        for (NSDictionary *info in infos) {
        //            UIImage *image = info[UIImagePickerControllerOriginalImage];
        //            image = [self saveImage:image];
        //            [_photoArr addObject:image];
        //        }
    }];
}

- (UIImage *)saveImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    image = [image imageTo4b3AtSize:CGSizeMake(400, 300)];
    return image;
}


- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker didSelcetedNumber:(NSInteger)number
{
    if(number >= 9)
    {
        return NO;
    }
    return YES;
}

@end
