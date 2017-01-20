//
//  ContactDetaiListViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ContactDetaiListViewController.h"
#import "TXContactManager.h"
#import "UIImageView+EMWebCache.h"
#import "ParentsDetailViewController.h"
#import <UIImageView+Utils.h>
#import "BabyInfoNormalTableViewCell.h"
#import "BabyInfoNoParentTableViewCell.h"
#import "ParnentInfoTableViewCell.h"
#import <extobjc.h>
#import "DropdownView.h"
#import <UIImageView+TXSDImage.h>
#import "UIColor+Hex.h"

//#define KCELLHIGHT          60.f
#define KSECTIONHEIGHT 20.f
#define kCellContentBaseTag             1231231
#define KCELLHIGHT (54.0f*kScale1)
#define KBabyViewHight 30.0f*kScale1

@interface ContactDetaiListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_bgImgView;
    UIButton *_selectedBtn;
    NSInteger _selectedIndex;
    NSMutableArray *_invtedList;
    UIImageView *_arrowImgView;
}

@property (nonatomic, strong) NSMutableArray *titlesArr;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, strong) DropdownView *dropdownView;
@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *listArr;
@property (nonatomic, strong) NSArray *groupList;
@property (nonatomic, strong) NSMutableArray *sectionList;
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation ContactDetaiListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _invtedList = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createCustomNavBar];
    
    _selectedIndex = 0;
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    
    [_listTableView setDelegate:self];
    [_listTableView setDataSource:self];
    [_listTableView setShowsVerticalScrollIndicator:YES];
    [_listTableView setBackgroundColor:self.view.backgroundColor];
    _listTableView.sectionIndexColor = kColorGray;
    _listTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
    if ([self.titleStr isEqualToString:@"学校通讯录"]) {
        self.type = ContactType_Teachers;
        __weak __typeof(&*self) weakSelf=self;  //by sck
//        [TXProgressHUD showHUDAddedTo:weakSelf.view withMessage:@""];
        TXAsyncRun(^{
            [TXProgressHUD showHUDAddedTo:weakSelf.view withMessage:@""];
//            NSDictionary *dic = [[TXContactManager shareInstance] getTeachersListAndFirstLetter];
//            weakSelf.listArr =dic[@"list"];
//            weakSelf.sectionList = dic[@"first"];
            NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:1];
            NSMutableArray *tmpTitleArr = [NSMutableArray arrayWithCapacity:1];
            
            NSArray *teachers =[[TXContactManager shareInstance] getTeachersList];
            for (char i = 'a'; i <= 'z'; i++) {
                
                NSString *str = [NSString stringWithFormat:@"\\b%c.*", i];
                
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"nicknameFirstLetter MATCHES %@", str];
                
                NSArray *fileterArr = [teachers filteredArrayUsingPredicate:pre];
                if (fileterArr.count > 0) {
                    [tmpArr addObject:fileterArr];
                    [tmpTitleArr addObject:[NSString stringWithFormat:@"%c", i - 32]];
                }
            }
            
            self.listArr = tmpArr.copy;
            self.titleArray = tmpArr.copy;
            
            TXAsyncRunInMain(^{
                [_listTableView reloadData];
                [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
            });
        });

    }else{
        self.type = ContactType_Parents;
        self.groupList = [[TXContactManager shareInstance] getParentsGroupList];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"name == %@",@"通讯录全部"];
        NSArray *arr = [_groupList filteredArrayUsingPredicate:pre];
        if (arr.count) {
            NSDictionary *dic = arr[0];
            __weak __typeof(&*self) weakSelf=self;  //by sck
            [TXProgressHUD showHUDAddedTo:weakSelf.view withMessage:@""];
            TXAsyncRun(^{
                NSArray *parentsArr = [[[TXContactManager shareInstance] getParentListByArray:dic[@"type"]] sortedArrayUsingComparator:^NSComparisonResult(NSArray  *_Nonnull arr1, NSArray *_Nonnull arr2) {
                    TXUser *user1 = arr1.firstObject;
                    TXUser *user2 = arr2.firstObject;
                    return [user1.nicknameFirstLetter compare:user2.nicknameFirstLetter] == NSOrderedDescending;
                }];
                self.listArr = parentsArr;
                
                TXAsyncRunInMain(^{
                    [weakSelf.listTableView reloadData];
                    [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
                });
            });
        }
        
        if (_groupList.count == 2) {
            //只有一个组不显示筛选框
            NSDictionary *dic = _groupList[1];
            self.titleStr = dic[@"name"];
            self.titleLb.text = self.titleStr;
            return;
        }else if (_groupList.count < 2){
            self.titleLb.text = @"家长通讯录";
            return;
        }
        
        self.titlesArr = [NSMutableArray array];
        
        [_groupList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_titlesArr addObject:obj[@"name"]];
        }];
        
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.adjustsImageWhenHighlighted = NO;
        _selectedBtn.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, self.customNavigationView.width_, kNavigationHeight);
        [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
        [self.customNavigationView addSubview:_selectedBtn];
        [self.customNavigationView bringSubviewToFront:self.btnLeft];
        [self.customNavigationView bringSubviewToFront:self.btnRight];
        self.titleLb.font = kFontMiddle;
        self.titleLb.text = @"家长通讯录";
        
      
        
        _dropdownView = [[DropdownView alloc] init];
        
        @weakify(self);
        [_dropdownView showInView:self.view andListArr:_titlesArr andDropdownBlock:^(int index) {
            @strongify(self);
            if(index == -1)
            {
                CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
                _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
                _arrowImgView.centerY = self.titleLb.centerY;
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _arrowImgView.transform = CGAffineTransformMakeRotation(0);
                } completion:nil];
                return;
            }
            else
            {
                _selectedIndex = index;
                NSDictionary *dic = _groupList[index];
                NSString *name = dic[@"name"];
                if ([name isEqualToString:@"通讯录全部"]) {
                    name = @"家长通讯录";
                }
                self.titleStr = name;
                self.titleLb.text = self.titleStr;
                CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
                _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
                _arrowImgView.centerY = self.titleLb.centerY;
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _arrowImgView.transform = CGAffineTransformMakeRotation(0);
                } completion:nil];
                [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
                TXAsyncRun(^{
                    self.listArr = [[TXContactManager shareInstance] getParentListByArray:dic[@"type"]];
                    TXAsyncRunInMain(^{
                        [self.listTableView reloadData];
                        [TXProgressHUD hideHUDForView:self.view animated:YES];
                    });
                });
                
            }
        }];

        
        CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
        _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
        _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
        _arrowImgView.centerY = self.titleLb.centerY;
        [self.customNavigationView addSubview:_arrowImgView];
    }

}

#pragma mark - DROPDOWN VIEW

- (void)showDropDownView
{
    [_dropdownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableView delegate and dataSource method
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    NSMutableArray *sectionIndex = [[NSMutableArray alloc] initWithCapacity:5];
    NSArray *array = [NSArray arrayWithArray:_listArr];
    for(NSArray *index in array)
    {
        if([index count] > 0)
        {
            TXUser *user = [index objectAtIndex:0];
            if([user.nicknameFirstLetter length] > 0)
            {
                NSString *title = [NSString stringWithFormat:@"%c",[user.nicknameFirstLetter characterAtIndex:0] - 32];
                
                NSInteger count = 0;
                if ([sectionIndex containsObject:title]) {
                    
                }else{
                    [sectionIndex addObject:[NSString stringWithFormat:@"%c",[user.nicknameFirstLetter characterAtIndex:0] - 32]];
                }
            }
        }
    }
    return sectionIndex;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    if (_type == ContactType_Teachers) {
        return index;
    }else {
        __block NSInteger indexx = 0;
        [self.listArr enumerateObjectsUsingBlock:^(NSArray *_Nonnull arr, NSUInteger idx, BOOL * _Nonnull stop) {
            TXUser *user = arr.firstObject;
            
            if ([user.nicknameFirstLetter characterAtIndex:0] - 32 == [title characterAtIndex:0]) {
                *stop = YES;
                indexx = idx;
            }
        }];
        
        return indexx;
    }
    
    int count = 0;
    for(NSInteger i = 0; i < index && i < [_sectionList count]; i++)
    {
        NSArray *array = [_sectionList objectAtIndex:i];
        count += [array count];
    }
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return _type == ContactType_Teachers?1:_listArr.count;
    return _listArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (_type == ContactType_Teachers) {
//        return _listArr.count;
//    }else{
//        NSArray *arr = _listArr[section];
//        return arr.count;
//    }
    NSArray *arr = _listArr[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_type == ContactType_Teachers)
    {
        return KCELLHIGHT;
    }
    else        
    {
        if(!indexPath.row)
        {
            return KBabyViewHight;
        }
        return KCELLHIGHT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_type == ContactType_Teachers)
    {
        return 25;
    }
    return KSECTIONHEIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(_type == ContactType_Teachers)
    {
        UIView *container = [UIView new];
        container.frame = CGRectMake(0, 0, kScreenWidth, 25);
        container.backgroundColor = [UIColor colorWithHexRGB:@"F3F3F3"];
        
        UILabel *label2 = [UILabel new];
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont systemFontOfSize:17];
        label2.textColor = [UIColor colorWithHexRGB:@"818183"];
        label2.frame = CGRectMake(10, 0, kScreenWidth, 25);
        
        TXUser *user = [self.listArr[section] firstObject];
        char c = [user.nicknameFirstLetter characterAtIndex:0] - 32;
        label2.text = [NSString stringWithFormat:@"%c", c];
        [container addSubview:label2];
        return container;
    }
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT);
    header.backgroundColor = kColorClear;
    return header;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 10000) {
        static NSString *Identifier = @"customCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, tableView.width_, 40 * kScale1)];
            titleLb.font = kFontMiddle;
            titleLb.textAlignment = NSTextAlignmentCenter;
            titleLb.tag = 100;
            [cell.contentView addSubview:titleLb];
        }
        
        NSDictionary *dic = _groupList[indexPath.row];
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:100];
        titleLb.text = dic[@"name"];
        
        if (_selectedIndex == indexPath.row) {
            titleLb.backgroundColor = KColorAppMain;
            titleLb.textColor = kColorWhite;
        }else{
            titleLb.backgroundColor = kColorWhite;
            titleLb.textColor = kColorBlack;
        }
        
        return cell;
    }
    if (_type == ContactType_Teachers) {
        static NSString *Identifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (KCELLHIGHT-40.0f)/2, 40, 40)];
            iconImgView.tag = kCellContentBaseTag;
            iconImgView.layer.masksToBounds = YES;
            iconImgView.layer.cornerRadius = 8.0f/2.0f;
            [cell.contentView addSubview:iconImgView];
            
//            UIImageView *iconBgView = [[UIImageView alloc] initWithFrame:iconImgView.frame];
//            iconBgView.image = [UIImage imageNamed:@"conversation_mask"];
//            [cell.contentView addSubview:iconBgView];
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + kEdgeInsetsLeft, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT)];
            titleLb.font = kFontTitle;
            titleLb.textColor = KColorTitleTxt;
            titleLb.tag = kCellContentBaseTag + 1;
            titleLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:titleLb];
            
            UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
            lineView.frame = CGRectMake(10, KCELLHIGHT - kLineHeight, kScreenWidth - 10, kLineHeight);
            lineView.tag = kCellContentBaseTag + 2;
            [cell.contentView addSubview:lineView];
            
            UILabel *phoneLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + kEdgeInsetsLeft, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT)];
            phoneLb.font = kFontSubTitle;
            phoneLb.textColor = KColorSubTitleTxt;
            phoneLb.tag = kCellContentBaseTag + 3;
            phoneLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:phoneLb];
            
            UILabel *inActiveLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(kScreenWidth -17-44, 0, 44, KCELLHIGHT)];
            inActiveLb.font = kFontChildSection;
            inActiveLb.textColor = KColorSubTitleTxt;
            inActiveLb.tag = kCellContentBaseTag + 4;
            inActiveLb.textAlignment = NSTextAlignmentRight;
            inActiveLb.text = @"未激活";
            [cell.contentView addSubview:inActiveLb];
            
        }
        
        UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentBaseTag];
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 1];
        UIView *lineView = [cell.contentView viewWithTag:kCellContentBaseTag + 2];
        UILabel *phoneLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 3];
        UILabel *inActiveLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 4];
        
        TXUser *user = _listArr[indexPath.section][indexPath.row];
        titleLb.text = user.nickname;
        phoneLb.text = user.mobilePhoneNumber;
        [titleLb sizeToFit];
        [phoneLb sizeToFit];
        titleLb.frame = CGRectMake(iconImgView.maxX + 5, iconImgView.minY+1, titleLb.width_, titleLb.height_);
        phoneLb.frame = CGRectMake(titleLb.minX, iconImgView.maxY - phoneLb.height_-1, phoneLb.width_, phoneLb.height_);
        NSString *urlStr = [user.avatarUrl getFormatPhotoUrl:40 hight:40];
        [iconImgView TX_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        lineView.hidden = indexPath.row == _listArr.count - 1?YES:NO;
        [cell.contentView setBackgroundColor:kColorWhite];
        [inActiveLb setHidden:user.activated];
        return cell;
    }else{
//        static NSString *Identifier = @"CellIdentifier";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
//        if (cell == nil)
//        {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            
//            UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
//            iconImgView.tag = kCellContentBaseTag;
//            [cell.contentView addSubview:iconImgView];
//            
//            UIImageView *iconBgView = [[UIImageView alloc] initWithFrame:iconImgView.frame];
//            iconBgView.image = [UIImage imageNamed:@"conversation_mask"];
//            iconBgView.tag = kCellContentBaseTag+4;
//            [cell.contentView addSubview:iconBgView];
//            
//            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
//            titleLb.font = kFontTitle;
//            titleLb.textColor = KColorSubTitleTxt;
//            titleLb.tag = kCellContentBaseTag + 1;
//            titleLb.textAlignment = NSTextAlignmentLeft;
//            [cell.contentView addSubview:titleLb];
//            
//            UILabel *phoneLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + 5, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT)];
//            phoneLb.font = kFontSubTitle;
//            phoneLb.textColor = KColorSubTitleTxt;
//            phoneLb.tag = kCellContentBaseTag + 3;
//            phoneLb.textAlignment = NSTextAlignmentLeft;
//            [cell.contentView addSubview:phoneLb];
//            
//            UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
//            lineView.frame = CGRectMake(10, KCELLHIGHT - kLineHeight, kScreenWidth - 10, kLineHeight);
//            lineView.tag = kCellContentBaseTag + 2;
//            [cell.contentView addSubview:lineView];
//            UILabel *inActiveLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(kScreenWidth -17-44, 0, 44, KCELLHIGHT)];
//            inActiveLb.font = kFontChildSection;
//            inActiveLb.textColor = KColorSubTitleTxt;
//            inActiveLb.tag = kCellContentBaseTag + 5;
//            inActiveLb.textAlignment = NSTextAlignmentRight;
//            inActiveLb.text = @"未激活";
//            [cell.contentView addSubview:inActiveLb];
//        }
//        
//        UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentBaseTag];
//        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 1];
//        UIView *lineView = [cell.contentView viewWithTag:kCellContentBaseTag + 2];
//        UILabel *phoneLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 3];
//        UIImageView *iconBgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentBaseTag+4];
//        UILabel *inActiveLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 5];
//
//        
//        NSArray *arr = _listArr[indexPath.section];
//        TXUser *user = arr[indexPath.row];
//        if (!indexPath.row) {
//            iconImgView.hidden = YES;
//            phoneLb.hidden = YES;
//            titleLb.text = [NSString stringWithFormat:@"   %@",user.realName];
//            titleLb.backgroundColor = kColorSection;
//            titleLb.frame = CGRectMake(0, 0, kScreenWidth, KSECTIONHEIGHT);
//            titleLb.font = kFontTiny;
//            titleLb.textColor = kColorGray1;
//            [iconImgView setHidden:YES];
//            [iconBgView setHidden:YES];
//            cell.contentView.backgroundColor = kColorSection;
//            [inActiveLb setHidden:YES];
//        }else{
//            cell.contentView.backgroundColor = kColorWhite;
//            titleLb.font = kFontTitle;
//            titleLb.backgroundColor = kColorClear;
//            titleLb.textColor = KColorTitleTxt;
//            [iconImgView setHidden:NO];
//            [iconBgView setHidden:NO];
//            titleLb.text = user.nickname;
//            phoneLb.text = user.mobilePhoneNumber;
//            iconImgView.hidden = NO;
//            phoneLb.hidden = NO;
//            titleLb.frame = CGRectMake(iconImgView.maxX + 5, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT);
//            NSString *urlStr = [user.avatarUrl getFormatPhotoUrl:40 hight:40];
//            [iconImgView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
//            
//            [titleLb sizeToFit];
//            [phoneLb sizeToFit];
//            titleLb.frame = CGRectMake(iconImgView.maxX + 5, iconImgView.minY+1, titleLb.width_, titleLb.height_);
//            phoneLb.frame = CGRectMake(titleLb.minX, iconImgView.maxY - phoneLb.height_-1, phoneLb.width_, phoneLb.height_);
//            [inActiveLb setHidden:user.activated];
//        }
//
//        CGFloat cellHight = KCELLHIGHT;
//        if (!indexPath.row)
//        {
//            cellHight = KSECTIONHEIGHT;
//        }
//        
//        if (indexPath.row == arr.count - 1) {
//            lineView.frame = CGRectMake(0, cellHight - kLineHeight, kScreenWidth, kLineHeight);
//        }else{
//            lineView.frame = CGRectMake(10, cellHight - kLineHeight, kScreenWidth - 10, kLineHeight);
//        }
//        [cell.contentView setBackgroundColor:kColorWhite];
        UITableViewCell *cell = nil;
//        NSArray *BabyInfoList = (NSArray *)[_babyList objectAtIndex:indexPath.section];
        NSArray *arr = _listArr[indexPath.section];
        if(indexPath.row == 0)//孩子信息
        {
            TXUser *babyUser = [arr objectAtIndex:indexPath.row];
            if([arr count] == 1)//没有绑定家长
            {
                static NSString *babyInfoCellIdentifier1 = @"babyInfoCellIdentifier1";
                BabyInfoNoParentTableViewCell *babyInfoCell = [tableView dequeueReusableCellWithIdentifier:babyInfoCellIdentifier1];
                if(babyInfoCell == nil)
                {
                    babyInfoCell = [[BabyInfoNoParentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:babyInfoCellIdentifier1];
                    
                }
                babyInfoCell.babyNameLabel.text =babyUser.nickname;
                babyInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell = babyInfoCell;
            }
            else
            {
                static NSString *babyInfoCellIdentifier2 = @"babyInfoCellIdentifier2";
                BabyInfoNormalTableViewCell *babyInfoCell = [tableView dequeueReusableCellWithIdentifier:babyInfoCellIdentifier2];
                if(babyInfoCell == nil)
                {
                    babyInfoCell = [[BabyInfoNormalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:babyInfoCellIdentifier2];
                }
                babyInfoCell.babyNameLabel.text =babyUser.nickname;
                babyInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell = babyInfoCell;
            }
        }
        else
        {
            TXUser *parentUser = [arr objectAtIndex:indexPath.row];
            static NSString *parentInfoCellIdentifier = @"parentInfoCellIdentifier";
            ParnentInfoTableViewCell *parentInfoCell = [tableView dequeueReusableCellWithIdentifier:parentInfoCellIdentifier];
            if(parentInfoCell == nil)
            {
                parentInfoCell = [[ParnentInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:parentInfoCellIdentifier];
            }
            [parentInfoCell.headerImgView TX_setImageWithURL:[NSURL URLWithString:[parentUser.avatarUrl getFormatPhotoUrl:40 hight:40]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            parentInfoCell.parentNameLabel.text = parentUser.nickname;
            if(parentUser.activated)
            {
                parentInfoCell.parentStatusValue = ParentStatus_Actived;
            }
            else
            {
                if(parentUser.mobilePhoneNumber == nil || [parentUser.mobilePhoneNumber length] == 0)
                {
                    parentInfoCell.parentStatusValue = ParentStatus_NoCallNumber;
                }
                else  if(![self isInvitedByUserId:parentUser.userId])
                {
                    parentInfoCell.parentStatusValue = ParentStatus_InActived;
                }
                else
                {
                    parentInfoCell.parentStatusValue = ParentStatus_Invited;
                }
            }
            @weakify(self);
            NSString *mobile = parentUser.mobilePhoneNumber;
            [parentInfoCell.callBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                @strongify(self);
                if(mobile != nil && [mobile length] > 0)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",mobile]]];
                }
                else
                {
                    [self showFailedHudWithTitle:@"该用户暂未绑定手机号"];
                }
            }];
            
            [parentInfoCell.inviteBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                @strongify(self);
                [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
                [[TXChatClient sharedInstance].userManager inviteUser:parentUser.userId onCompleted:^(NSError *error) {
                    [TXProgressHUD hideHUDForView:self.view animated:YES];
                    if(error)
                    {
                        [self showFailedHudWithError:error];
                    }
                    else
                    {
                        [self showSuccessHudWithTitle:@"邀请成功"];
                        @synchronized(_invtedList)
                        {
                            [_invtedList addObject:@(parentUser.userId)];
                            parentInfoCell.parentStatusValue = ParentStatus_Invited;
                        }
                    }
                }];
            }];
            cell = parentInfoCell;
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int64_t userId = 0;
    if (_type == ContactType_Teachers) {
        TXUser *user = _listArr[indexPath.row];
        userId = user.userId;
    }else if (indexPath.row){
        _bgImgView.minY = self.customNavigationView.maxY - _bgImgView.height_;
        NSArray *arr = _listArr[indexPath.section];
        TXUser *user = arr[indexPath.row];
        userId = user.userId;
    }else{
        return;
    }
    ParentsDetailViewController *chatVc = [[ParentsDetailViewController alloc] initWithIdentity:userId];
    [self.navigationController pushViewController:chatVc animated:YES];
}


#pragma  mark-- private
-(BOOL)isInvitedByUserId:(int64_t)userId
{
    if([_invtedList containsObject:@(userId)])
    {
        return YES;
    }
    return NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        self.isScrolling = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.isScrolling = NO;
}

@end
