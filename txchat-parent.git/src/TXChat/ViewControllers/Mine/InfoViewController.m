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
#import "TXUser+Utils.h"
#import "CNPPopupController.h"

#define KUIViewTagBase1 0x1000
#define KUIViewTagBase2 0x2000
const CGFloat cellHight = 44.0f;


typedef enum : NSUInteger {
    ListType_ParentType = 0,
    ListType_TwoDimensionCode,
    ListType_ParentName,
    ListType_BabyName,
    ListType_BabySex,
    ListType_BabyBirthDay,
    ListType_Class,
    ListType_School,
    ListType_BabyAvatar,
} ListType;

@interface InfoViewController ()<
    ELCAlbumPickerControllerDelegate,
    ELCImagePickerControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UISelectorViewDelegate,
    UITextFieldDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    CNPPopupControllerDelegate>
{
    NSArray *_listArr;
    NSArray *_sexArr;
}

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) TXUser *childUser;
@property (nonatomic, strong) UISelectorView *vSelector;
@property (nonatomic, strong) UIButton *btnCloseKeyboard;       // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;                   // 键盘高度
@property (nonatomic, assign) TXPBSexType tmpSexType;
@property (nonatomic, strong) id currentControl;
@property (nonatomic, strong) UITextField *currentTextField;
@property (nonatomic, strong) UIImage *portraitImage;
@property (nonatomic, strong) CNPPopupController *popupController;
@property (nonatomic, assign) BOOL isUpdateChildAvatar;

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
    // 初始化选择器
    _vSelector = [[UISelectorView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 216)];
    _vSelector.delegate = self;
    _vSelector.backgroundColor = kColorBackground;
    _vSelector.colorSelector = kColorBlue;
    _vSelector.colorStateNormal = kColorBlack;
    
    _sexArr = @[@"男",@"女"];
    
    _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_) style:UITableViewStylePlain];
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.backgroundColor = kColorBackground;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listView];
    _listArr = @[@[@{}],
                 @[@{@"title":@"我是孩子的",@"type":@(ListType_ParentType)}],
//  bay  gaoju                 @{@"title":@"我的二维码",@"type":@(ListType_TwoDimensionCode)}],
                 @[@{@"title":@"孩子",@"type":@(ListType_BabyName)},
                   @{@"title":@"孩子头像",@"type":@(ListType_BabyAvatar)},
                   @{@"title":@"监护人姓名",@"type":@(ListType_ParentName)},
                   @{@"title":@"孩子性别",@"type":@(ListType_BabySex)},
                   @{@"title":@"孩子生日",@"type":@(ListType_BabyBirthDay)},
                   @{@"title":@"班级",@"type":@(ListType_Class)},
                   @{@"title":@"学校",@"type":@(ListType_School)}]];
    [self getChildUserInfo];
    
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
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    UILabel *detailLb = (UILabel *)[_currentTextField.superview viewWithTag:KUIViewTagBase2+2];
    _childUser.sex = [detailLb.text isEqualToString:@"男"]?TXPBSexTypeMale: TXPBSexTypeFemale;
    [[TXChatClient sharedInstance] updateUserInfo:_childUser onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            tmpObject.childUser.sex = tmpObject.tmpSexType;
            detailLb.text = [NSString getSexTypeStr:tmpObject.tmpSexType];
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
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
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    _childUser.sex = [childSelectedSex isEqualToString:@"男"]?TXPBSexTypeMale: TXPBSexTypeFemale;
    TXAsyncRunInMain(^{
        [_listView reloadData];
    });
    [[TXChatClient sharedInstance] updateUserInfo:_childUser onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            tmpObject.childUser.sex = tmpObject.tmpSexType;
            [tmpObject showFailedHudWithError:error];
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
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

- (void)getChildUserInfo{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    [[TXChatClient sharedInstance] fetchChild:^(NSError *error, TXUser *childUser) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
            tmpObject.childUser = childUser;
            tmpObject.tmpSexType = childUser.sex;
            TXAsyncRunInMain(^{
                [tmpObject.listView reloadData];
            });
        }
    }];

}

- (void)updatePortrait:(NSString *)imgStr{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    NSError *error = nil;
    TXUser *user = nil;

    if(_isUpdateChildAvatar)
    {
        user = [[TXChatClient sharedInstance] getUserByUserId:_childUser.userId error:nil];
    }
    else
    {
        user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    }
    user.avatarUrl = imgStr;
    [[TXChatClient sharedInstance] updateUserInfo:user onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"更换头像", nil] counter:1];
            _portraitImage = nil;
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
            [MobClick event:@"mime_changeAvatarUrl" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"更换头像", nil] counter:1];
            
            if(_isUpdateChildAvatar)
            {
                [tmpObject getChildUserInfo];
            }
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUseInfo object:nil];
                [tmpObject.listView reloadData];
            });
        }
        _isUpdateChildAvatar = NO;
    }];
    
}

- (void)uploadToQiniu:(NSData *)data{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
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
    TXAsyncRunInMain(^{
        [_listView reloadData];
    });
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
    if(section == 1)
    {
        UIView *beginLine = [[UIView alloc] init];
        beginLine.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
        beginLine.frame = CGRectMake(0, 0, tableView.width_, kLineHeight);
        [view addSubview:beginLine];
        
        UIView *endLine = [[UIView alloc] init];
        endLine.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
        endLine.frame = CGRectMake(0, height-kLineHeight, tableView.width_, kLineHeight);
        [view addSubview:endLine];
    }
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    if (indexPath.section == 0) {
        static NSString *Identifier1 = @"CellIdentifier1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier1];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = kColorWhite;
            cell.backgroundColor = kColorWhite;
            
            UIButton *bgImgView = [UIButton buttonWithType:UIButtonTypeCustom];
            bgImgView.backgroundColor = kColorBlue;
            [bgImgView addTarget:self action:@selector(onPicture) forControlEvents:UIControlEventTouchUpInside];
            bgImgView.frame = CGRectMake(0, 0, tableView.width_, 132);
            bgImgView.clipsToBounds = YES;
            [bgImgView setBackgroundImage:[UIImage imageNamed:@"mime_infoHeaderBk"] forState:UIControlStateNormal];
            [bgImgView setBackgroundImage:[UIImage imageNamed:@"mime_infoHeaderBk"] forState:UIControlStateHighlighted];
            bgImgView.tag = KUIViewTagBase1+1;
            [cell.contentView addSubview:bgImgView];
            
            UIView *backView = [[UIView alloc] init];
            backView.backgroundColor = kColorWhite;
            backView.layer.cornerRadius = 4.0f/2.0f;
            backView.layer.masksToBounds = YES;
            backView.userInteractionEnabled  = NO;
            [cell.contentView addSubview:backView];
            
            UIImageView *portraitImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            portraitImgView.layer.cornerRadius = 4.0f/2.0f;
            portraitImgView.layer.masksToBounds = YES;
            portraitImgView.center = bgImgView.center;
            portraitImgView.tag = KUIViewTagBase1+2;
            portraitImgView.userInteractionEnabled = NO;
            [cell.contentView addSubview:portraitImgView];
            backView.frame = CGRectMake(portraitImgView.minX-1, portraitImgView.minY-1, 68, 68);
            
            UIImageView *cameraImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mime_camera"]];
            cameraImgView.frame = CGRectMake(portraitImgView.maxX -14-3, portraitImgView.maxY - 14-3, 14, 14);
            [cell.contentView addSubview:cameraImgView];
        }
        
        UIImageView *portraitImgView = (UIImageView *)[cell.contentView viewWithTag:KUIViewTagBase1+2];
        [portraitImgView TX_setImageWithURL:[NSURL URLWithString:[user.avatarUrl getFormatPhotoUrl:78 hight:78]] placeholderImage:_portraitImage ? _portraitImage : [UIImage imageNamed:@"userDefaultIcon"]];
        return cell;
    }else {
        NSDictionary *listDic = _listArr[indexPath.section][indexPath.row];
        static NSString *Identifier2 = @"CellIdentifier2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier2];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier2];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIView *backgroundView = [[UIView alloc] init];
            backgroundView.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
            cell.selectedBackgroundView = backgroundView;
            cell.contentView.backgroundColor = kColorWhite;
            cell.backgroundColor = kColorWhite;
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            titleLb.font = kFontMiddle;
            titleLb.textColor = KColorTitleTxt;
            titleLb.tag = KUIViewTagBase2+1;
            titleLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:titleLb];
            
            UILabel *detailLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            detailLb.font = kFontMiddle;
            detailLb.textColor = kColorLightGray;
            detailLb.tag = KUIViewTagBase2+2;
            detailLb.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:detailLb];
            
            UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(12, cellHight - kLineHeight, self.view.width_ - 15, kLineHeight)];
            lineView.tag = KUIViewTagBase2+3;
            lineView.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
            [cell.contentView addSubview:lineView];
            
            UIImageView *imageView = [[UIImageView alloc] initLineWithFrame:CGRectZero];
            imageView.tag = KUIViewTagBase2+4;
            imageView.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:imageView];
        }
        
        
        
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:KUIViewTagBase2+1];
        UILabel *detailLb = (UILabel *)[cell.contentView viewWithTag:KUIViewTagBase2+2];
        UIView *lineView = [cell.contentView viewWithTag:KUIViewTagBase2+3];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:KUIViewTagBase2+4];

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
        imageView.hidden = YES;
        switch (type.integerValue) {
            case ListType_ParentType:
            {
                detailLb.text = [NSString getParentTypeStr:user.parentType];
            }
                break;
//            case ListType_TwoDimensionCode:
//            {
//                detailLb.hidden = YES;
//                imageView.hidden = NO;
//                [imageView setImage:[UIImage imageNamed:@"mime_twodimensioncode"]];
//            }
//                break;
            case ListType_ParentName:
            {
                NSString *guarder = [user getGuarDerStr];
                if(guarder == nil || [guarder length] == 0)
                {
                    detailLb.text = KGUARDERDEFAULT;
                }
                else
                {
                    detailLb.text = guarder;
                }
            }
                break;
            case ListType_BabyName:
            {
                detailLb.text = _childUser.nickname;
            }
                break;
            case ListType_BabySex:
            {
                detailLb.text = [NSString getSexTypeStr:_childUser.sex];
//                textField.hidden = NO;
            }
                break;
            case ListType_BabyBirthDay:
            {
                if(_childUser && _childUser.birthday != 0)
                {
                    detailLb.text = [NSDate timeForShortStyle:[NSString stringWithFormat:@"%@", @(_childUser.birthday/1000)]];
                }
            }
                break;
            case ListType_Class:
            {
                detailLb.text = _childUser.className;
            }
                break;
            case ListType_School:{
                detailLb.text = _childUser.gardenName;
            }
                break;
            case ListType_BabyAvatar:
            {
                detailLb.hidden = YES;
                imageView.hidden = NO;
                [imageView TX_setImageWithURL:[NSURL URLWithString:[_childUser.avatarUrl getFormatPhotoUrl:40 hight:40]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            }
            default:
                break;
        }
        if(!detailLb.isHidden)
        {
            [detailLb sizeToFit];
        }
        //修改起始位置 保证起始位置和标题之间有足够空隙
        CGFloat detailLbBeginX = tableView.width_ - 33 - detailLb.width_;
        if(detailLbBeginX < CGRectGetMaxX(titleLb.frame) + kEdgeInsetsLeft)
        {
            detailLb.width_ -= (CGRectGetMaxX(titleLb.frame) + kEdgeInsetsLeft) - detailLbBeginX;
            detailLbBeginX = CGRectGetMaxX(titleLb.frame) + kEdgeInsetsLeft;
        }
        detailLb.frame = CGRectMake(detailLbBeginX-5, 0, detailLb.width_+5, cellHight);
        if(type.integerValue == ListType_BabyAvatar)
        {
            imageView.frame = CGRectMake(self.view.width_ -33-33, (cellHight-33)/2, 33, 33);
            imageView.layer.cornerRadius = 4.0f/2;
            imageView.layer.masksToBounds = YES;
        }
        else
        {
            imageView.layer.cornerRadius = 0;
            imageView.layer.masksToBounds = NO;
            imageView.frame = CGRectMake(self.view.width_ -33-20, (cellHight-20)/2, 20, 20);
        }
        if (type.integerValue != ListType_BabyName &&
            type.integerValue != ListType_Class &&
            type.integerValue != ListType_School) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *detailLb = (UILabel *)[cell.contentView viewWithTag:KUIViewTagBase2+2];
    
    NSDictionary *listDic = _listArr[indexPath.section][indexPath.row];
    NSNumber *type = listDic[@"type"];
    if (!type) {
        return;
    }
    switch (type.integerValue) {
        case ListType_ParentType:
        {
            SelectIdentityViewController *avc = [[SelectIdentityViewController alloc] init];
            avc.txUser = user;
            avc.isEditInfo = YES;
            avc.parentVC = self;
            avc.selected = user.parentType;
            [self.navigationController pushViewController:avc animated:YES];
        }
            break;
//        case ListType_TwoDimensionCode:
//        {
//            [self showTwoDimensionCode];
//        }
//            break;
        case ListType_ParentName:
        {
            EditViewController *avc = [[EditViewController alloc] init];
            avc.name = [user getGuarDerStr];
            avc.presentVC = self;
            [self.navigationController pushViewController:avc animated:YES];
        }
            break;
        case ListType_BabySex:
        {
//            NSString *defaultSex = @"女";
//            if(_childUser.sex == TXPBSexTypeMale)
//            {
//                defaultSex = @"男";
//            }
//            __weak typeof(self)tmpObject = self;
//            SexViewController *sexVC = [[SexViewController alloc] initWithDefaultSex:defaultSex onCompleted:^(NSString *selectedSex) {
//                [tmpObject updateChildSex:selectedSex];
//            }];
//            [self.navigationController pushViewController:sexVC animated:YES];
            @weakify(self);
            [self showNormalSheetWithTitle:nil items:@[@"男", @"女"] clickHandler:^(NSInteger index) {
                @strongify(self);
                if(index == 0)
                {
                    [self updateChildSex:@"男"];
                }
                else
                {
                    [self updateChildSex:@"女"];
                }
                
            } completion:nil];
            
        }
            break;
        case ListType_BabyBirthDay:
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%@", @(_childUser.birthday/1000)] doubleValue]];
            NSTimeZone *z = [NSTimeZone systemTimeZone];
            NSInteger val = [z secondsFromGMTForDate:date];
            NSDate *tDate = [date dateByAddingTimeInterval: val];
            //bay gaoju 孩子生日，个人信息栏
            NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%@", @( [NSDate date].timeIntervalSince1970 - 60 * 60 * 24 * 365*16)] doubleValue]];
            @weakify(self);
            [self showDatePickerWithCurrentDate:tDate minimumDate:minDate maximumDate:[NSDate date] selectedDate:date selectedBlock:^(NSDate *selectedDate) {
                @strongify(self);
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                if (selectedDate) {
                    detailLb.text = [dateFormatter stringFromDate: selectedDate];
                    [self updateBirthDay:selectedDate];
                }
            }];
        }
            break;
        case ListType_BabyAvatar:
        {
            _isUpdateChildAvatar = YES;
            [self onPicture];
        }
            break;
        default:
            break;
    }
}

- (void)updateBirthDay:(NSDate *)date{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    _childUser.birthday = [date timeIntervalSince1970] * 1000;
    [[TXChatClient sharedInstance] updateUserInfo:_childUser onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }
        else
        {
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
        }
    }];
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
            if(!_isUpdateChildAvatar)
            {
                _portraitImage = newImage;
            }
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
    if (_childUser.sex == TXPBSexTypeFemale) {
        row0 = 1;
    }
    _vSelector.dataSource = [NSMutableArray arrayWithObjects:_sexArr, nil];
    [_vSelector selectRow:row0 inComponent:0 animated:NO];
}


#pragma mark - UISelectorViewDelegate
- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel *detailLb = (UILabel *)[_currentTextField.superview viewWithTag:KUIViewTagBase2+2];
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
//二维码
-(void)showTwoDimensionCode
{
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    if(user == nil)
    {
        return;
    }
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = kColorWhite;

    UILabel *title = [[UILabel alloc] init];
    title.text = [NSString getParentTypeStr:user.parentType];
    title.font = kFontTitle;
    title.textColor = KColorTitleTxt;
    [contentView addSubview:title];

    
    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = [NSString stringWithFormat:@"%@%@",_childUser.nickname, [NSString getParentTypeStr:user.parentType]];
    subtitle.textColor = KColorSubTitleTxt;
    subtitle.font = kFontSubTitle;
    [contentView addSubview:subtitle];

    NSString *str = [NSString stringWithFormat:@"wjyteacher://check_in_with_user_id?user_id=%@&user_name=%@",@(user.userId), user.nickname];
    
    UIImage *qrImg = [self createQRForString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    UIImageView *twoDimensionCodeView = [[UIImageView alloc] init];
    [twoDimensionCodeView setImage:qrImg];
    [contentView addSubview:twoDimensionCodeView];
    [twoDimensionCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(subtitle.mas_bottom).with.offset(13);
        make.centerX.mas_equalTo(contentView);
        make.size.mas_equalTo(CGSizeMake(174, 174));
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(twoDimensionCodeView);
        make.top.mas_equalTo(@(42));
        make.size.mas_equalTo(CGSizeMake(60, 28));
    }];
    [subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(title.mas_left);
        make.top.mas_equalTo(title.mas_bottom).with.offset(-3);
        make.size.mas_equalTo(CGSizeMake(100, 24));
    }];
    
    UIImageView *icon = [[UIImageView alloc] init];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [icon setImage:[UIImage imageNamed:@"appLogo"]];
    icon.layer.cornerRadius = 5.0f;
    icon.layer.masksToBounds = YES;
    icon.layer.borderWidth = 2.0f;
    icon.layer.borderColor = kColorWhite.CGColor;
    [contentView addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.center.mas_equalTo(twoDimensionCodeView);
    }];
    
    contentView.frame = CGRectMake(0, 0, 247, 341);
    self.popupController = [[CNPPopupController alloc] initWithContents:@[contentView]];
    CNPPopupTheme *customTheme = [CNPPopupTheme defaultTheme];
    customTheme.popupContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    customTheme.backgroundColor = [UIColor blueColor];
    customTheme.contentVerticalPadding = 0.0f;
    customTheme.maxPopupWidth = 247.0f;
    self.popupController.theme = customTheme;
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTab:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;
    contentView.userInteractionEnabled = YES;
    [contentView addGestureRecognizer:tap];
}

-(void)dismissTab:(UITapGestureRecognizer*)recognizer
{
    [self.popupController dismissPopupControllerAnimated:YES];
    self.popupController = nil;
}

/**
 *  创建二维码
 */
- (UIImage *)createQRForString:(NSString *)qrString {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    return [self createNonInterpolatedUIImageFormCIImage:qrFilter.outputImage withSize:kScreenWidth - 100];
#else
    UIImage *img = [QRCodeGenerator qrImageForString:qrString imageSize:kScreenWidth - 100];
    return img;
    
#endif
}

/**
 *  将CIImage转换成UIImage
 *
 *  @param image CIImage
 *  @param size  生成UIImage的宽
 *
 *  @return UIImage
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *retImg =  [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return retImg;
}


#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidDismiss:(CNPPopupController *)controller
{
    NSLog(@"Dismissed with button");
    self.popupController = nil;
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
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
