//
//  InfoViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "InfoViewController.h"
#import "EditViewController.h"
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+ParentType.h"
#import "NSDate+TuXing.h"
#import "SelectIdentityViewController.h"
#import "UIImageView+EMWebCache.h"
#import "EditViewController.h"
#import "UISelectorView.h"
#import "UIButton+EMWebCache.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SexViewController.h"
#import "TXContactManager.h"

typedef enum : NSUInteger {
    ListType_TeacherName,
    ListType_TeacherSex,
    ListType_Position,
    ListType_School
} ListType;

#define cellHight 44.0f

@interface InfoViewController ()<
ELCAlbumPickerControllerDelegate,
ELCImagePickerControllerDelegate,
UITableViewDataSource,
UITableViewDelegate,
UISelectorViewDelegate,
UITextFieldDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
{
    NSArray *_listArr;
    NSArray *_sexArr;
}

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) TXUser *currentUser;
@property (nonatomic, strong) UISelectorView *vSelector;
@property (nonatomic, strong) UIButton *btnCloseKeyboard;       // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;                   // 键盘高度
@property (nonatomic, assign) TXPBSexType tmpSexType;
@property (nonatomic, strong) id currentControl;
@property (nonatomic, strong) UITextField *currentTextField;
@property (nonatomic, strong) UIImage *portraitImage;

@end

@implementation InfoViewController
- (id)init{
    self = [super init];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"个人信息";
    [self createCustomNavBar];
    
    self.currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    
    
    // 初始化选择器
    _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 216)];
    _vSelector.delegate = self;
    _vSelector.backgroundColor = kColorBackground;
    _vSelector.colorSelector = kColorBlue;
    _vSelector.colorStateNormal = kColorBlack;
    
    _sexArr = @[@"男",@"女"];
    
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.height_) style:UITableViewStylePlain];
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.backgroundColor = kColorBackground;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listView];
    
    _listArr = @[@[@{}],
                 @[@{@"title":@"姓名",@"type":@(ListType_TeacherName)},
                   //                 @{@"title":@"性别",@"type":@(ListType_TeacherSex)},
                   @{@"title":@"学校",@"type":@(ListType_School)},
                   @{@"title":@"职位",@"type":@(ListType_Position)}]];
    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    self.btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width_ - imgClose.size.width, self.view.height_, imgClose.size.width + 10, imgClose.size.height + 10)];
    [self.btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [self.btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    self.btnCloseKeyboard.alpha = 0;
    [self.view addSubview:self.btnCloseKeyboard];
    
    // Do any additional setup after loading the view.
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    UILabel *detailLb = (UILabel *)[_currentTextField.superview viewWithTag:1000];
    _currentUser.sex = [detailLb.text isEqualToString:@"男"]?TXPBSexTypeMale: TXPBSexTypeFemale;
    [[TXChatClient sharedInstance] updateUserInfo:_currentUser onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            tmpObject.currentUser.sex = tmpObject.tmpSexType;
            detailLb.text = [NSString getSexTypeStr:tmpObject.tmpSexType];
            [tmpObject showFailedHudWithError:error];
        }
        else
        {
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
        }
    }];
}

-(void)updateChildSex:(NSString *)childSelectedSex
{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    _currentUser.sex = [childSelectedSex isEqualToString:@"男"]?TXPBSexTypeMale: TXPBSexTypeFemale;
    [_listView reloadData];
    [[TXChatClient sharedInstance] updateUserInfo:_currentUser onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            tmpObject.currentUser.sex = tmpObject.tmpSexType;
            [tmpObject showFailedHudWithError:error];
        }
        else
        {
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
        }
    }];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}

- (void)updatePortrait:(NSString *)imgStr{
    __weak typeof(self)tmpObject = self;
    _currentUser.avatarUrl = imgStr;
    [[TXChatClient sharedInstance] updateUserInfo:_currentUser onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"更换头像", nil] counter:1];
            _portraitImage = nil;
            [tmpObject showFailedHudWithError:error];
        }else{
            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"更换头像", nil] counter:1];
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUseInfo object:nil];
                [tmpObject.listView reloadData];
            });
        }
    }];
    
}

- (void)uploadToQiniu:(NSData *)data{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    NSUUID *uploadKey = [NSUUID UUID];
    [[TXChatClient sharedInstance] uploadData:data uuidKey:uploadKey fileExtension:@"jpg" cancellationSignal:nil progressHandler:nil onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl) {
        if (error) {
            _portraitImage = nil;
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            //            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
            [tmpObject updatePortrait:serverFileUrl];
        }
    }];
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)reloadData{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUseInfo object:nil];
    [_listView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate and dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = _listArr[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 132;
    }
    return cellHight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CGFloat height = section == 1 ?10:0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, height)];
    view.backgroundColor = kColorBackground;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 10.f;
    }
    return 0.f;
}

- (void)onPicture{
    [self showNormalSheetWithTitle:nil items:@[@"拍照",@"从手机相册选择"] clickHandler:^(NSInteger index) {
        if (index == 0) {
            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"拍照", @"更换头像", nil] counter:1];
            UIImagePickerController *photoPickerController = [[UIImagePickerController alloc]init];
            photoPickerController.view.backgroundColor = kColorClear;
            UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
            photoPickerController.sourceType = sourcheType;
            photoPickerController.delegate = self;
            photoPickerController.allowsEditing = YES;
            [self.navigationController presentViewController:photoPickerController animated:YES completion:NULL];
        }else if (index == 1){
            //相册
            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"相册", @"更换头像", nil] counter:1];
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            imagePicker.delegate = self;
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
            
        }
    } completion:nil];
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从手机相册选择", nil];
//    [actionSheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//        if (buttonIndex == 0) {
//            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"拍照", @"更换头像", nil] counter:1];
//            UIImagePickerController *photoPickerController = [[UIImagePickerController alloc]init];
//            photoPickerController.view.backgroundColor = kColorClear;
//            UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
//            photoPickerController.sourceType = sourcheType;
//            photoPickerController.delegate = self;
//            photoPickerController.allowsEditing = YES;
//            [self.navigationController presentViewController:photoPickerController animated:YES completion:NULL];
//        }else if (buttonIndex == 1){
//            //相册
//            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"相册", @"更换头像", nil] counter:1];
//            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//            imagePicker.allowsEditing = YES;
//            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//            imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
//            imagePicker.delegate = self;
//            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
//            
//        }
//    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (indexPath.section == 0) {
        static NSString *Identifier = @"CellIdentifier1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = kColorWhite;
            cell.backgroundColor = kColorWhite;
            
            UIButton *bgImgView = [UIButton buttonWithType:UIButtonTypeCustom];
            [bgImgView addTarget:self action:@selector(onPicture) forControlEvents:UIControlEventTouchUpInside];
            bgImgView.frame = CGRectMake(0, 0, tableView.width_, 132);
            bgImgView.clipsToBounds = YES;
            [bgImgView setBackgroundImage:[UIImage imageNamed:@"mime_infoHeaderBk"] forState:UIControlStateNormal];
            [bgImgView setBackgroundImage:[UIImage imageNamed:@"mime_infoHeaderBk"] forState:UIControlStateHighlighted];
            bgImgView.imageView.contentMode = UIViewContentModeScaleAspectFill;
            bgImgView.tag = 100;
            [cell.contentView addSubview:bgImgView];
            
            UIView *backView = [[UIView alloc] init];
            backView.backgroundColor = kColorWhite;
            backView.layer.cornerRadius = 4.0f/2.0f;
            backView.layer.masksToBounds = YES;
            backView.userInteractionEnabled = NO;
            [cell.contentView addSubview:backView];
            
            UIImageView *portraitImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            portraitImgView.layer.cornerRadius = 4.0f/2.0f;
            portraitImgView.layer.masksToBounds = YES;
//            portraitImgView.layer.borderWidth = 1.0f;
//            portraitImgView.layer.borderColor = kColorWhite.CGColor;
            portraitImgView.center = bgImgView.center;
            portraitImgView.tag = 1000;
            portraitImgView.userInteractionEnabled = NO;
            [cell.contentView addSubview:portraitImgView];
            backView.frame = CGRectMake(portraitImgView.minX-1, portraitImgView.minY-1, 68, 68);

            
            
            UIImageView *cameraImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mime_camera"]];
            cameraImgView.frame = CGRectMake(portraitImgView.maxX -14-3, portraitImgView.maxY - 14-3, 14, 14);
            [cell.contentView addSubview:cameraImgView];
        }
        
        UIImageView *portraitImgView = (UIImageView *)[cell.contentView viewWithTag:1000];
        NSString *imgStr = [user.avatarUrl getFormatPhotoUrl:78 hight:78];
        [portraitImgView TX_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:_portraitImage ? _portraitImage : [UIImage imageNamed:@"userDefaultIcon"]];
        return cell;
    }else {
        NSDictionary *listDic = _listArr[indexPath.section][indexPath.row];
        static NSString *Identifier = @"CellIdentifier2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = kColorWhite;
            cell.backgroundColor = kColorWhite;
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            titleLb.font = kFontMiddle;
            titleLb.textColor = KColorTitleTxt;
            titleLb.tag = 100;
            titleLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:titleLb];
            
            UILabel *detailLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            detailLb.font = kFontMiddle;
            detailLb.textColor = kColorLightGray;
            detailLb.tag = 1000;
            detailLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:detailLb];
            
             UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(12, cellHight - kLineHeight, self.view.width_ - 12, kLineHeight)];
            lineView.tag = 10000;
            [cell.contentView addSubview:lineView];
        }
        
        
        
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *detailLb = (UILabel *)[cell.contentView viewWithTag:1000];
        UIView *lineView = [cell.contentView viewWithTag:10000];
        
        titleLb.text = listDic[@"title"];
        [titleLb sizeToFit];
        titleLb.frame = CGRectMake(12, 0, titleLb.width_, cellHight);
        
        NSArray *arr = _listArr[indexPath.section];
        if (indexPath.row != arr.count - 1) {
            lineView.hidden = NO;
        }else{
            lineView.hidden = YES;
        }
        
        NSNumber *type = listDic[@"type"];
        
        detailLb.hidden = NO;
        switch (type.integerValue) {
            case ListType_TeacherName:
            {
                detailLb.text = _currentUser.realName;
            }
                break;
            case ListType_TeacherSex:
            {
                detailLb.text = [NSString getSexTypeStr:_currentUser.sex];
            }
                break;
            case ListType_Position:
            {
                detailLb.text = _currentUser.positionName;
            }
                break;
            case ListType_School:{
                detailLb.text = _currentUser.gardenName;
            }
                break;
                
            default:
                break;
        }
        [detailLb sizeToFit];
        //修改起始位置 保证起始位置和标题之间有足够空隙
//        CGFloat detailLbBeginX = tableView.width_ - 33 - detailLb.width_;
        CGFloat detailLbBeginX = tableView.width_ - kEdgeInsetsLeft - detailLb.width_;
        if(detailLbBeginX < CGRectGetMaxX(titleLb.frame) + kEdgeInsetsLeft)
        {
            detailLb.width_ -= (CGRectGetMaxX(titleLb.frame) + kEdgeInsetsLeft) - detailLbBeginX;
            detailLbBeginX = CGRectGetMaxX(titleLb.frame) + kEdgeInsetsLeft;
        }
        detailLb.frame = CGRectMake(detailLbBeginX, 0, detailLb.width_, cellHight);
        
        if (type.integerValue != ListType_Position &&
            type.integerValue != ListType_School && type.integerValue != ListType_TeacherName) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *listDic = _listArr[indexPath.section][indexPath.row];
    NSNumber *type = listDic[@"type"];
    if (!type) {
        return;
    }
    switch (type.integerValue) {
        case ListType_TeacherName:
        {
            //            EditViewController *avc = [[EditViewController alloc] init];
            //            avc.name = _currentUser.realName;
            //            avc.presentVC = self;
            //            [self.navigationController pushViewController:avc animated:YES];
        }
            break;
        case ListType_TeacherSex:
        {
            NSString *defaultSex = @"女";
            if(_currentUser.sex == TXPBSexTypeMale)
            {
                defaultSex = @"男";
            }
            __weak typeof(self)tmpObject = self;
            SexViewController *sexVC = [[SexViewController alloc] initWithDefaultSex:defaultSex onCompleted:^(NSString *selectedSex) {
                [tmpObject updateChildSex:selectedSex];
            }];
            [self.navigationController pushViewController:sexVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIPhotoPickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        @autoreleasepool {
            UIImage *image = info[UIImagePickerControllerEditedImage];
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:200];
            UIImage *newImage = [UIImage scaleImage:image scale:scale];
            image = nil;
            _portraitImage = newImage;
            NSData *imgData = UIImageJPEGRepresentation(newImage, 0.5);
            [self uploadToQiniu:imgData];
        }
    }];
    
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)infos
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (infos.count) {
            UIImage *image = infos[0][UIImagePickerControllerOriginalImage];
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:200];
            image = [UIImage scaleImage:image scale:scale];
            NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
            [self uploadToQiniu:imgData];
        }
    }];
}


- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker didSelcetedNumber:(NSInteger)number
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _currentTextField = textField;
    int row0 = 0;
    if (_currentUser.sex == TXPBSexTypeFemale) {
        row0 = 1;
    }
    _vSelector.dataSource = [NSMutableArray arrayWithObjects:_sexArr, nil];
    [_vSelector selectRow:row0 inComponent:0 animated:NO];
}


#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *detailLb = (UILabel *)[_currentTextField.superview viewWithTag:1000];
    NSInteger row0 = [(NSIndexPath *)[selectorView.selectedIndexPaths objectAtIndex:0] row];
    detailLb.text = row0?@"女":@"男";
    [detailLb sizeToFit];
    detailLb.frame = CGRectMake(self.view.width_ - 35 - detailLb.width_, 0, detailLb.width_, 50);
}


#pragma mark - keyboard did show & hide
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 过滤重复
    if (_keyboardHeight == keyboardHeight)
        return;
    _keyboardHeight = keyboardHeight;
    
    UIView *vFirstResponder = [self.view subviewWithFirstResponder];
    if (vFirstResponder) {
        [UIView animateWithDuration:animateSpeed animations:^{
            _btnCloseKeyboard.maxY = self.view.height_ - keyboardHeight + 5;
            _btnCloseKeyboard.alpha = 1;
        }];
    }
    
    _currentTextField.hidden = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (_keyboardHeight == 0)
        return;
    
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    _keyboardHeight = 0;
    
    [UIView animateWithDuration:animateSpeed animations:^{
        _btnCloseKeyboard.maxY = self.view.height_;
        _btnCloseKeyboard.alpha = 0;
    }];
    _currentTextField.hidden = NO;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
