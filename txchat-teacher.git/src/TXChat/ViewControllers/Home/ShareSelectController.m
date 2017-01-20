//
//  ShareSelectController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/11/15.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ShareSelectController.h"
#import "UIColor+Hex.h"
#import "ShareSelectCell.h"
#import "ShareTextField.h"
#import "TXChatSendHelper.h"
#import "KLCPopup.h"
#import "ShareDetailView.h"
#import "UIView+Utils.h"
#import "ShareJumpSelectView.h"
#import "CustomTabBarController.h"
#import "ShareSelectIconsView.h"


#define kIconsMaxCount 6

@interface ShareSelectController()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) ShareTextField *searchTF;

@property (nonatomic, weak) ShareSelectIconsView *iconsV;

@property (nonatomic, strong) NSArray<NSArray *> *dataArr;

@property (nonatomic, strong) NSArray<NSMutableArray *> *selectArr;

@property (nonatomic, strong) NSArray<NSArray *> *resultArr;

@property (nonatomic, strong) NSArray<NSString *> *titleArr;

@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, weak) ShareDetailView *detailView;

@property (nonatomic, weak) UIView *headerSearchView;

@property (nonatomic, weak) UILabel *qunLbl;

@property (nonatomic, weak) UIButton *cancleBtn;

@end

@implementation ShareSelectController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustomNavBar];
    self.btnRight.enabled = false;
    
    [self getData];
    
    [self initViews];
    
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChangedNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)initViews {
    
    self.view.backgroundColor = [UIColor colorWithHexRGB:@"F3F3F3"];
    CGFloat tableViewY = self.customNavigationView.height_;
    CGRect tableViewFrame = CGRectMake(0, tableViewY, kScreenWidth, kScreenHeight - tableViewY);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    tableView.rowHeight = 59;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableHeaderView = self.headerSearchView = [self createTopSearchView];
    tableView.sectionIndexColor = kColorGray;
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, 50, kNavigationHeight)];
    [cancleBtn setTitleColor:KColorAppMain forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = kFontMiddle;
    [self.customNavigationView addSubview:cancleBtn];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancleBtn = cancleBtn;
    @weakify(self);
    [cancleBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        [self.searchTF endEditing:YES];
    }];
    cancleBtn.hidden = YES;
}

- (void)getData {
    
    NSArray *departmentArr = [[TXChatClient sharedInstance] getAllDepartments:nil];
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    NSMutableArray *tmpTitleArr = [NSMutableArray array];
    
    [departmentArr enumerateObjectsUsingBlock:^(TXDepartment *department, NSUInteger idx, BOOL * _Nonnull stop) {
       
        TXPBUserType userType = TXPBUserTypeChild;
        
        if(department.departmentType != TXPBDepartmentTypeClazz)
        {
            userType = TXPBUserTypeTeacher;
        }
        
        NSArray *allUsers = [[TXChatClient sharedInstance] getDepartmentMembers:department.departmentId userType:userType error:nil];
        
        if (allUsers.count > 0) {
            [tmpArr addObjectsFromArray:allUsers];
        }
    }];
    
    NSArray *userArr = tmpArr.copy;
    
    [tmpArr removeAllObjects];
    
    [tmpArr addObject:departmentArr];
    
    for (char i = 'a'; i <= 'z'; i++) {
        
        NSString *str = [NSString stringWithFormat:@"\\b%c.*", i];
        
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"nicknameFirstLetter MATCHES %@", str];
        
        NSArray *fileterArr = [userArr filteredArrayUsingPredicate:pre];
        if (fileterArr.count > 0) {
            [tmpArr addObject:fileterArr];
            [tmpTitleArr addObject:[NSString stringWithFormat:@"%c", i - 32]];
        }
    }
    
    self.dataArr = tmpArr.copy;
    self.titleArr = tmpTitleArr.copy;
}

- (void)createCustomNavBar {
    [super createCustomNavBar];
    
    self.titleStr = @"选择收件人";
    
    [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
    [self.btnRight setTitleColor:KColorAppMain forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender {
    
    if (sender.tag == TopBarButtonLeft) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        NSAssert(self.selectArr.count > 0, @"选中数组为空");
        [self.searchTF endEditing:YES];
        [self showSelectDetail];
    }
}

- (void)showSelectDetail {
    
    @weakify(self);
    
    ShareDetailView *detailView = [[ShareDetailView alloc] init];
    self.detailView = detailView;
    if (self.selectArr.firstObject.count + self.selectArr.lastObject.count > 6) {
        detailView.frame = CGRectMake(0, 0, 291, 290);
    }else {
        detailView.frame = CGRectMake(0, 0, 291, 251);
    }
    
    detailView.center = self.view.center;
    detailView.articleTitle = self.articleTitle;
    detailView.selectArr = self.selectArr;
    [detailView sl_setCornerRadius:5];
    KLCPopup *popView = [KLCPopup popupWithContentView:detailView showType:KLCPopupShowTypeFadeIn dismissType:KLCPopupDismissTypeFadeOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    popView.didTouchOnBackGround = ^() {
        
        @strongify(self);
        [detailView endEditing];
        
        [UIView animateWithDuration:0.25 animations:^{
            if (self.selectArr.firstObject.count + self.selectArr.lastObject.count > 6) {
                detailView.frame = CGRectMake(0, 0, 291, 290);
            }else {
                detailView.frame = CGRectMake(0, 0, 291, 251);
            }
        }];
    };
    
    detailView.confirmBlock = ^(NSString *text) {
        @strongify(self);
        NSArray *departmentArr = self.selectArr.firstObject;
        NSArray *userArr = self.selectArr.lastObject;
        
        NSString *shareText = [NSString stringWithFormat:@"[链接]%@", self.articleTitle];
        
        [departmentArr enumerateObjectsUsingBlock:^(TXDepartment *_Nonnull department, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [TXChatSendHelper sendTextMessageWithString:shareText toUsername:[NSString stringWithFormat:@"%@", department.groupId] isChatGroup:YES requireEncryption:NO ext:[self messageExtUserInfoIsShare:YES]];
            if (text.length > 0) {
                [TXChatSendHelper sendTextMessageWithString:text toUsername:[NSString stringWithFormat:@"%@", department.groupId] isChatGroup:YES requireEncryption:NO ext:[self messageExtUserInfoIsShare:NO]];
            }
        }];
        
        [userArr enumerateObjectsUsingBlock:^(TXUser *_Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray *parents = [[TXChatClient sharedInstance] getParentUsersByChildUserId:user.userId error:nil];
            
            if (parents.count == 0) {
                [TXChatSendHelper sendTextMessageWithString:shareText toUsername:[NSString stringWithFormat:@"%lld", user.userId] isChatGroup:NO requireEncryption:NO ext:[self messageExtUserInfoIsShare:YES]];
                if (text.length > 0) {
                    [TXChatSendHelper sendTextMessageWithString:text toUsername:[NSString stringWithFormat:@"%lld", user.userId] isChatGroup:NO requireEncryption:NO ext:[self messageExtUserInfoIsShare:NO]];
                }
            }else {
                for (TXUser *userParent in parents) {
                    [TXChatSendHelper sendTextMessageWithString:shareText toUsername:[NSString stringWithFormat:@"%lld", userParent.userId] isChatGroup:NO requireEncryption:NO ext:[self messageExtUserInfoIsShare:YES]];
                    
                    if (text.length > 0) {
                        [TXChatSendHelper sendTextMessageWithString:text toUsername:[NSString stringWithFormat:@"%lld", userParent.userId] isChatGroup:NO requireEncryption:NO ext:[self messageExtUserInfoIsShare:NO]];
                    }
                }
            }
        }];
        
        [popView dismiss:YES];
        
        [self jump2ArticleOrMsg];
    };
    detailView.cancleBlock = ^(){
        [popView dismiss:YES];
    };
    
    [popView show];
    
    popView.didFinishDismissingCompletion = ^() {
        self.detailView = nil;
    };
}

- (void)keyboardShowNotification:(NSNotification *) notifi {
    
    @weakify(self);
    NSDictionary *userInfo = [notifi userInfo];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    
    if (keyboardHeight > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            //
            
            CGFloat originY = kScreenHeight / 2 - self.detailView.width_ / 2;
            CGFloat currentY = kScreenHeight / 2 - self.detailView.width_ / 2 - keyboardHeight;
            
            NSLog(@"%f", currentY - originY);
            
            self.detailView.maxY = keyboardHeight - 50 - 10;
            //        self.detailView.frame = CGRectMake(0, -80, 291, 251);
        }];
    }
}

- (void)keyboardFrameChangedNotification:(NSNotification *) notifi {
    
    NSDictionary *userInfo = [notifi userInfo];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    @weakify(self);
    if (!self.detailView) {
        
        [UIView animateWithDuration:0.25 animations:^{
            @strongify(self);
            self.tableView.height_ = keyboardRect.origin.y - self.customNavigationView.height_;
        }];
    }
}

- (void)jump2ArticleOrMsg {
    @weakify(self);
    ShareJumpSelectView *jumpView = [[ShareJumpSelectView alloc] initWithFrame:CGRectMake(0, 0, 291, 138)];
    jumpView.center = self.view.center;
    
    KLCPopup *popView = [KLCPopup popupWithContentView:jumpView showType:KLCPopupShowTypeFadeIn dismissType:KLCPopupDismissTypeFadeOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    jumpView.articleBlock = ^() {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        [popView dismiss:YES];
    };
    
    jumpView.msgBlock = ^() {
        @strongify(self);
        
        [popView dismiss:YES];
        
        CustomTabBarController *tabVC = self.navigationController.viewControllers.firstObject;
        [self.navigationController setViewControllers:@[tabVC]];
        
        [tabVC setSelectedIndex:0];
    };
    
    [popView show];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.isSearch ? self.resultArr.count : self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isSearch ? self.resultArr[section].count : self.dataArr[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"ShareSelectController";
    NSInteger section = indexPath.section ? 1 : 0;
    
    ShareSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ShareSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    id userOrDepart = self.isSearch ? self.resultArr[indexPath.section][indexPath.row] : self.dataArr[indexPath.section][indexPath.row];
    if (!indexPath.section) {
        TXDepartment *department = userOrDepart;
        cell.department = department;
    }else {
        TXUser *user = userOrDepart;
        cell.user = user;
    }
    
    cell.check = [self.selectArr[section] containsObject:userOrDepart];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSInteger section = indexPath.section ? 1 : 0;
    
    ShareSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.isCheck) {
        cell.check = NO;
        
        [self addOrDelete:NO selected:indexPath];
        return;
    }
    
    if (self.selectArr.firstObject.count + self.selectArr.lastObject.count >= 9) {
        [self showFailedHudWithTitle:@"不能超过9个哦!"];
        return;
    }
    
    cell.check = YES;
    [self addOrDelete:YES selected:indexPath];
}

- (void)addOrDelete:(BOOL) isAdd selected:(NSIndexPath *) indexPath {
    
    NSInteger section = indexPath.section ? 1 : 0;
    
    if (!self.isSearch) {
        
        id selected = self.dataArr[indexPath.section][indexPath.row];
        
        if (!isAdd) {
            [self.selectArr[section] removeObject:selected];
            [self updateSearchTFLeftViewIsAdd:NO select:selected];
        }else {
            [self.selectArr[section] addObject:selected];
            [self updateSearchTFLeftViewIsAdd:YES select:selected];
        }
    }else {
        id selected = self.resultArr[indexPath.section][indexPath.row];
        
        if (!isAdd) {
            [self.selectArr[section] removeObject:selected];
            [self updateSearchTFLeftViewIsAdd:NO select:selected];
        }else {
            [self.selectArr[section] addObject:selected];
            [self updateSearchTFLeftViewIsAdd:YES select:selected];
        }
        self.resultArr = nil;
    }
    
    [self setTitleWithSelectCount];
    self.isSearch = NO;
}

- (void)updateSearchTFLeftViewIsAdd:(BOOL) isAdd select:(id) selected {
    
    NSInteger iconsCount = self.selectArr.firstObject.count + self.selectArr.lastObject.count;
    if (iconsCount <= kIconsMaxCount) {
        
//        [UIView animateWithDuration:0.25 animations:^{
//            self.iconsV.frame = CGRectMake(0, 9, kLeftMargin + (kIconWH + 8) * iconsCount + 8, 50);
//            self.searchTF.frame = CGRectMake(self.iconsV.maxX, 9, kScreenWidth - self.iconsV.width_, 50);
//        }];
        self.iconsV.frame = CGRectMake(0, 9, kLeftMargin + (kIconWH + 8) * iconsCount + 8, 50);
        self.searchTF.frame = CGRectMake(self.iconsV.maxX, 9, kScreenWidth - self.iconsV.width_, 50);
    }
    
    if (isAdd) {
        [self.searchTF revertDeleteCount];
        [self.iconsV revertHalfAnimation];
        [self.searchTF setHolderLeftAndLeftViewHidden:YES];
        
        [self.iconsV addSelectPerson:selected];
//        [self.searchTF.leftV addSelectPerson:selected];
        
    }else {
        [self.iconsV deleteSelectPerson:selected];
//        [self.searchTF.leftV deleteSelectPerson:selected];
    }
    
    if (iconsCount > 0) {
        
        [self.searchTF setHolderLeftAndLeftViewHidden:YES];
    }else {
        [self.searchTF setHolderLeftAndLeftViewHidden:NO];
    }
}

- (void)setTitleWithSelectCount {
    NSInteger selectCount = self.selectArr.firstObject.count + self.selectArr.lastObject.count;
    if (selectCount > 0) {
        [self.btnRight setTitle:[NSString stringWithFormat:@"确定(%ld)", selectCount] forState:UIControlStateNormal];
        self.btnRight.enabled = YES;
    }else {
        self.btnRight.enabled = NO;
        [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (!self.isSearch) {
        
        if (section == 1){
            
            return [self createHeaderViewWithsection:section hasTitleView:YES];
        }
        
        return [self createHeaderViewWithsection:section hasTitleView:NO];
    }else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.isSearch) {
        if (!section) {
            return 0;
        }else if (section == 1) {
            return 50.0f;
        }
        return 25.0f;
    }else {
        if (!section) {
            return 0;
        }
        
        return 0;
    }
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (!self.isSearch) {
        
        return self.titleArr;
    }
    
    return nil;
}

- (UIView *)createHeaderViewWithsection:(NSInteger)section hasTitleView:(BOOL)isHas {
    
    UIView *container = [UIView new];
    container.frame = CGRectMake(0, 0, kScreenWidth, 46);
    container.backgroundColor = [UIColor colorWithHexRGB:@"F3F3F3"];
    
    if (isHas) {
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor colorWithHexRGB:@"818183"];
        label.text = @"联系人";
        label.frame = CGRectMake(10, 0, kScreenWidth, 25);
        [container addSubview:label];
    }
    
    UILabel *label2 = [UILabel new];
    label2.backgroundColor = [UIColor clearColor];
    label2.font = [UIFont systemFontOfSize:17];
    label2.textColor = [UIColor colorWithHexRGB:@"818183"];
    label2.frame = CGRectMake(10, isHas ? 25 : 0, kScreenWidth, 25);
    
    TXUser *user = self.dataArr[section].firstObject;
    char c = [user.nicknameFirstLetter characterAtIndex:0] - 32;
    label2.text = [NSString stringWithFormat:@"%c", c];
    
    [container addSubview:label2];
    
    return container;
}

- (UIView *)createTopSearchView {
    
    UIView *container = [UIView new];
    container.frame = CGRectMake(0, 0, kScreenWidth, 100);
    container.backgroundColor = [UIColor colorWithHexRGB:@"F3F3F3"];
    
    UIView *lineOne = [[UIView alloc] initWithFrame:CGRectMake(0, 8.5, kScreenWidth, 0.5)];
    lineOne.backgroundColor = RGBCOLOR(218, 218, 218);
    [container addSubview:lineOne];
    
    ShareTextField *textField = [[ShareTextField alloc ] initWithFrame:CGRectMake(0, 9, kScreenWidth, 50)];
    self.searchTF = textField;
    [container addSubview: textField];
    textField.delegate = self;
    
    ShareSelectIconsView *iconView = [[ShareSelectIconsView alloc] initWithFrame:CGRectMake(0, 9, 0, 0)];
    [container addSubview:iconView];
    self.iconsV = iconView;
    
    @weakify(self);
    textField.deleteClick = ^(NSInteger count) {
        @strongify(self);
        
        if (count % 2 == 0) {
            
            if (self.selectArr.firstObject.count + self.selectArr.lastObject.count > 0) {
                
                id person = [iconView deleteLastPerson];
                if ([person isKindOfClass:[TXUser class]]) {
                    [self.selectArr.lastObject removeObject:person];
                    
                    ShareSelectCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArr.lastObject indexOfObject:person] inSection:1]];
                    cell.check = NO;
                    
                }else {
                    [self.selectArr.firstObject removeObject:person];
                    
                    ShareSelectCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArr.firstObject indexOfObject:person] inSection:0]];
                    cell.check = NO;
                }
                
                NSInteger iconsCount = self.selectArr.firstObject.count + self.selectArr.lastObject.count;
                if (iconsCount <= kIconsCount) {
                    self.iconsV.frame = CGRectMake(0, 9, kLeftMargin + (kIconWH + 8) * iconsCount + 8, 50);
                }else {
                    self.iconsV.frame = CGRectMake(0, 9, kLeftMargin + (kIconWH + 8) * kIconsCount + 8, 50);
                }
                self.searchTF.frame = CGRectMake(self.iconsV.maxX, 9, kScreenWidth - self.iconsV.width_, 50);
                [self setTitleWithSelectCount];
            }
        }else {
            [iconView deleteHalfAnimation];
        }
    };
    
    UIView *lineTwo = [[UIView alloc] initWithFrame:CGRectMake(0, textField.maxY, kScreenWidth, 0.5)];
    lineTwo.backgroundColor = RGBCOLOR(218, 218, 218);
    [container addSubview:lineTwo];
    
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor colorWithHexRGB:@"818183"];
    label.text = @"群";
    label.frame = CGRectMake(10, lineTwo.maxY + 13.5, kScreenWidth, 25);
    [container addSubview:label];
    self.qunLbl = label;
    
    return container;
}

- (NSArray<NSMutableArray *> *)selectArr {
    
    if (!_selectArr) {
        NSMutableArray *one = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *two = [NSMutableArray arrayWithCapacity:1];
        _selectArr = @[one, two];
    }
    return _selectArr;
}


- (void)textDidChanged {
    
    if (self.searchTF.text.length > 0) {
        self.searchTF.imageView.hidden = YES;
        
        NSString *filterStr = [self.searchTF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (filterStr.length > 0) {
            
            unichar ca = [filterStr characterAtIndex:0];
            
            if (ca >= 0x4E00 && ca< 0x9FFF) {
                [self searchWithName:filterStr];
            }else {
                [self searchWithLetters:filterStr];
            }
            
            self.isSearch = YES;
            self.headerSearchView.frame = CGRectMake(0, 0, kScreenWidth, 100);
            self.qunLbl.hidden = YES;
        }
    }else {
        [self setIsSearch:NO isEnd:NO];
    }
}

- (void)searchWithName:(NSString *)name {
    
//        TXDepartment
    NSMutableArray *array = [NSMutableArray array];
    NSString *regular = [NSString stringWithFormat:@"^.*%@.*$", name];
    
    NSPredicate *depart = [NSPredicate predicateWithFormat:@"name MATCHES %@", regular];
    
    [array addObject:[self.dataArr.firstObject filteredArrayUsingPredicate:depart]];
    
//        TXUser
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nickname MATCHES %@", regular];
    
    for (NSInteger i = 1; i < self.dataArr.count; ++i) {
        
        NSArray *userArr = self.dataArr[i];
        [array addObject:[userArr filteredArrayUsingPredicate:predicate]];
    }
    self.resultArr = array.copy;
}

- (void)searchWithLetters:(NSString *)letters {
    
//    TXDepartment
    NSMutableArray *array = [NSMutableArray array];
    NSString *regular = [NSString stringWithFormat:@"^.*%@.*$", letters];
    
    NSPredicate *depart = [NSPredicate predicateWithFormat:@"nameFirstLetter MATCHES %@", regular];
    
    [array addObject:[self.dataArr.firstObject filteredArrayUsingPredicate:depart]];
    
//    TXUser
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nicknameFirstLetter MATCHES %@", regular];
    
    for (NSInteger i = 1; i < self.dataArr.count; ++i) {
        
        NSArray *userArr = self.dataArr[i];
        [array addObject:[userArr filteredArrayUsingPredicate:predicate]];
    }
    
    self.resultArr = array.copy;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    self.isSearch = YES;
//    self.headerSearchView.frame = CGRectMake(0, 0, kScreenWidth, 100);
//    self.qunLbl.hidden = YES;
    
    self.cancleBtn.hidden = NO;
    self.btnLeft.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.isSearch = NO;
    self.headerSearchView.frame = CGRectMake(0, 0, kScreenWidth, 100);
    self.qunLbl.hidden = NO;
    
    self.cancleBtn.hidden = YES;
    self.btnLeft.hidden = NO;
    
    [self.iconsV revertHalfAnimation];
    [self.searchTF revertDeleteCount];
    
    if (self.selectArr.firstObject.count + self.selectArr.lastObject.count <= 0) {
        [self.searchTF setHolderLeftAndLeftViewHidden:NO];
        self.searchTF.imageView.hidden = NO;
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField endEditing:YES];
//    return YES;
//}
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    
//}


//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [self.searchTF endEditing:YES];
//}
         
- (NSDictionary *)messageExtUserInfoIsShare:(BOOL) isShare;
{
    
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSDictionary *extDict;
    if (!currentUser) {
        if (isShare) {
            extDict = @{@"name": @"", @"url" : self.url, @"articleTitle" : self.articleTitle, @"coverImageUrl" : self.coverImageUrl};
        }else {
            extDict = @{@"name": @"",};
        }
    }else{
        if (isShare) {
            extDict = @{@"name": currentUser.nickname ?: @"", @"url" : self.url, @"articleTitle" : self.articleTitle, @"coverImageUrl" : self.coverImageUrl};
        }else {
            extDict = @{@"name": currentUser.nickname ?: @"",};
        }
    }
    return extDict;
}

- (void)setIsSearch:(BOOL)isSearch isEnd:(BOOL) isEnd{
    _isSearch = isSearch;
    
    [self.tableView reloadData];
    
    if (!isSearch) {
        
        self.searchTF.text = nil;
        if (isEnd) {
            [self.searchTF endEditing:YES];
        }
    }
}

- (void)setIsSearch:(BOOL)isSearch {
    [self setIsSearch:isSearch isEnd:NO];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

@end
