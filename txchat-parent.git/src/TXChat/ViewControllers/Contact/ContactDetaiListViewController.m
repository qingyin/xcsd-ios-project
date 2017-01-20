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

#define KCELLHIGHT          60.f
#define KSECTIONHEIGHT 20.f
#define kCellContentBaseTag             1231231

@interface ContactDetaiListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView *_topListView;
    UIImageView *_bgImgView;
    UIButton *_selectedBtn;
    UIView *_coverView;
}

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *listArr;
@property (nonatomic, strong) NSArray *groupList;


@end

@implementation ContactDetaiListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createCustomNavBar];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    [_listTableView setDelegate:self];
    [_listTableView setDataSource:self];
    [_listTableView setShowsVerticalScrollIndicator:YES];
    [_listTableView setBackgroundColor:self.view.backgroundColor];
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
    _coverView = [[UIView alloc] initWithFrame:_listTableView.frame];
    _coverView.backgroundColor = kColorBlack;
    _coverView.alpha = 0.0f;
    [self.view addSubview:_coverView];
    
    if ([self.titleStr isEqualToString:@"幼儿园通讯录"]) {
        self.type = ContactType_Teachers;
        self.listArr =[[TXContactManager shareInstance] getTeachersList];
    }else{
        self.type = ContactType_Parents;
        
        self.groupList = [[TXContactManager shareInstance] getParentsGroupList];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"name == %@",@"通讯录全部"];
        NSArray *arr = [_groupList filteredArrayUsingPredicate:pre];
        if (arr.count) {
            NSDictionary *dic = arr[0];
            self.listArr = [[TXContactManager shareInstance] getParentListByArray:dic[@"type"]];
        }
        
        if (_groupList.count == 2) {
            //只有一个组不显示筛选框
            NSDictionary *dic = _groupList[1];
            self.titleStr = dic[@"name"];
            self.titleLb.text = self.titleStr;
            return;
        }
        
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedBtn.adjustsImageWhenHighlighted = NO;
        _selectedBtn.frame = self.titleLb.frame;
        [_selectedBtn setTitleColor:kColorNavigationTitle forState:UIControlStateNormal];
        _selectedBtn.width_ = self.titleLb.width_ + 20;
        [_selectedBtn setImage:[UIImage imageNamed:@"selected_arrow"] forState:UIControlStateNormal];
        _selectedBtn.titleLabel.font = kFontMiddle;
        [_selectedBtn setTitle:@"家长通讯录" forState:UIControlStateNormal];
        [_selectedBtn layoutIfNeeded];
        [_selectedBtn addTarget:self action:@selector(onSelectedBtn) forControlEvents:UIControlEventTouchUpInside];
        _selectedBtn.center = self.titleLb.center;
        [_selectedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
        [_selectedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _selectedBtn.titleLabel.bounds.size.width, 0, -_selectedBtn.titleLabel.bounds.size.width)];
        [self.customNavigationView addSubview:_selectedBtn];
        self.titleLb.hidden = YES;
        [self.customNavigationView bringSubviewToFront:self.btnLeft];

        
        [self.view bringSubviewToFront:self.customNavigationView];
        [self createTopListView];
    }

}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 *  点击顶部选择按钮
 */
- (void)onSelectedBtn{
    if (_topListView.minY < self.customNavigationView.maxY) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _bgImgView.minY = self.customNavigationView.maxY;
            _coverView.alpha = 0.8;
        } completion:nil];
    }else{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _bgImgView.minY = self.customNavigationView.maxY - _topListView.height_;
            _coverView.alpha = 0;
        } completion:nil];
    }
}


/**
 *  创建顶部选择视图
 */
- (void)createTopListView{
    
    _bgImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bgImgView.userInteractionEnabled = YES;
    _bgImgView.layer.cornerRadius = 3.f;
    _bgImgView.layer.masksToBounds = YES;
    _bgImgView.clipsToBounds = YES;
    [self.view insertSubview:_bgImgView belowSubview:self.customNavigationView];
    
    _topListView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _topListView.clipsToBounds = YES;
    [_bgImgView addSubview:_topListView];
    
    __block CGFloat width = 0;
    __block UIButton *tmpBtn = nil;
    NSMutableArray *arr = [NSMutableArray array];
    [_groupList enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        NSString *name = dic[@"name"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = kFontMiddle;
        [btn setTitleColor:kColorBlack forState:UIControlStateNormal];
        [btn setTitleColor:kColorWhite forState:UIControlStateSelected];
        [btn setTitle:name forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImageView createImageWithColor:kColorOrange] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImageView createImageWithColor:kColorWhite] forState:UIControlStateNormal];
        [_topListView addSubview:btn];
        if (idx == 0) {
            btn.selected = YES;
        }
        [btn sizeToFit];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(_topListView.mas_width);
            if (!tmpBtn) {
                make.top.mas_equalTo(8);
            }else{
                make.top.mas_equalTo(tmpBtn.mas_bottom);
            }
            make.height.mas_equalTo(40);
        }];
        tmpBtn = btn;
        width = btn.width_ + 100;
        [arr addObject:btn];
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(UIButton *sender) {
            sender.selected = YES;
            [arr enumerateObjectsUsingBlock:^(UIButton *tmpBtn, NSUInteger idx, BOOL *stop) {
                if (![tmpBtn isEqual:sender]) {
                    tmpBtn.selected = NO;
                }
            }];
            NSString *name = dic[@"name"];
            BOOL isReload = NO;
            if ([name isEqualToString:@"通讯录全部"]) {
                if (![_selectedBtn.titleLabel.text isEqualToString:@"家长通讯录"]) {
                    isReload = YES;
                }
                [_selectedBtn setTitle:@"家长通讯录" forState:UIControlStateNormal];
            }else{
                if (![_selectedBtn.titleLabel.text isEqualToString:name]) {
                    isReload = YES;
                }
                [_selectedBtn setTitle:name forState:UIControlStateNormal];
            }
            if (isReload) {
                self.listArr = [[TXContactManager shareInstance] getParentListByArray:dic[@"type"]];
                [_listTableView reloadData];

            }
            [_selectedBtn layoutIfNeeded];
            [_selectedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
            [_selectedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _selectedBtn.titleLabel.bounds.size.width, 0, -_selectedBtn.titleLabel.bounds.size.width)];

            [self onSelectedBtn];
        }];
    }];
    
    if (_groupList.count > 8) {
        _bgImgView.frame = CGRectMake((kScreenWidth - width), self.customNavigationView.maxY - 40 * 8 - 8, width, 40 * _groupList.count + 8);
        _topListView.contentSize = CGSizeMake(width, 40 * _groupList.count + 8);
    }else{
        _bgImgView.frame = CGRectMake((kScreenWidth - width), self.customNavigationView.maxY - 40 * _groupList.count - 8, width, 40 * _groupList.count + 8);
    }
    _bgImgView.centerX = kScreenWidth/2;
    _topListView.frame = _bgImgView.bounds;
    
    UIImage* stretchableImage = [[UIImage imageNamed:@"dh_zk_bj"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 38, 20, 5) resizingMode:UIImageResizingModeStretch];
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, _topListView.width_/2 + 25, _topListView.height_/2);
    CGSize size = CGSizeMake(_topListView.width_/2 + 25, _topListView.height_/2);
    
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [stretchableImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    maskLayer.contents = (id)[scaledImage CGImage];

    UIImage *stretchableImage1 = [scaledImage resizableImageWithCapInsets:UIEdgeInsetsMake(11, 5, 10, size.width - 5) resizingMode:UIImageResizingModeStretch];

//    stretchableImage = [stretchableImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 37, 10, 0) resizingMode:UIImageResizingModeStretch];
    _bgImgView.image = stretchableImage1;
    
    
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _type == ContactType_Teachers?1:_listArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_type == ContactType_Teachers) {
        return _listArr.count;
    }else{
        NSArray *arr = _listArr[section];
        return arr.count;
    }
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
            return KSECTIONHEIGHT;
        }
        return KCELLHIGHT;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_type == ContactType_Teachers) {
        static NSString *Identifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
            iconImgView.tag = kCellContentBaseTag;
            [cell.contentView addSubview:iconImgView];
            
            UIImageView *iconBgView = [[UIImageView alloc] initWithFrame:iconImgView.frame];
            iconBgView.image = [UIImage imageNamed:@"conversation_mask"];
            [cell.contentView addSubview:iconBgView];
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + kEdgeInsetsLeft, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT)];
            titleLb.font = kFontTitle;
            titleLb.textColor = KColorTitleTxt;
            titleLb.tag = kCellContentBaseTag + 1;
            titleLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:titleLb];
            
            UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
            lineView.frame = CGRectMake(10, KCELLHIGHT - kLineHeight, kScreenWidth - 20, kLineHeight);
            lineView.tag = kCellContentBaseTag + 2;
            [cell.contentView addSubview:lineView];
            
            UILabel *phoneLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + kEdgeInsetsLeft, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT)];
            phoneLb.font = kFontSubTitle;
            phoneLb.textColor = KColorSubTitleTxt;
            phoneLb.tag = kCellContentBaseTag + 3;
            phoneLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:phoneLb];
        }
        
        UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentBaseTag];
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 1];
        UIView *lineView = [cell.contentView viewWithTag:kCellContentBaseTag + 2];
        UILabel *phoneLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 3];

        
        TXUser *user = _listArr[indexPath.row];
        titleLb.text = user.nickname;
        phoneLb.text = user.mobilePhoneNumber;
        [titleLb sizeToFit];
        [phoneLb sizeToFit];
        titleLb.frame = CGRectMake(iconImgView.maxX + 5, iconImgView.minY+1, titleLb.width_, titleLb.height_);
        phoneLb.frame = CGRectMake(titleLb.minX, iconImgView.maxY - phoneLb.height_-1, phoneLb.width_, phoneLb.height_);
        NSString *urlStr = [NSString stringWithFormat:@"%@?imageView2/1/format/jpg/w/80/h/80",user.avatarUrl];
        [iconImgView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        lineView.hidden = indexPath.row == _listArr.count - 1?YES:NO;
        [cell.contentView setBackgroundColor:kColorWhite];
        return cell;
    }else{
        static NSString *Identifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
            iconImgView.tag = kCellContentBaseTag;
            [cell.contentView addSubview:iconImgView];
            
            UIImageView *iconBgView = [[UIImageView alloc] initWithFrame:iconImgView.frame];
            iconBgView.image = [UIImage imageNamed:@"conversation_mask"];
            iconBgView.tag = kCellContentBaseTag+4;
            [cell.contentView addSubview:iconBgView];
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            titleLb.font = kFontTitle;
            titleLb.textColor = KColorSubTitleTxt;
            titleLb.tag = kCellContentBaseTag + 1;
            titleLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:titleLb];
            
            UILabel *phoneLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + 5, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT)];
            phoneLb.font = kFontSubTitle;
            phoneLb.textColor = KColorSubTitleTxt;
            phoneLb.tag = kCellContentBaseTag + 3;
            phoneLb.textAlignment = NSTextAlignmentLeft;
            [cell.contentView addSubview:phoneLb];
            
            UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
            lineView.frame = CGRectMake(10, KCELLHIGHT - kLineHeight, kScreenWidth - 20, kLineHeight);
            lineView.tag = kCellContentBaseTag + 2;
            [cell.contentView addSubview:lineView];
        }
        
        UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentBaseTag];
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 1];
        UIView *lineView = [cell.contentView viewWithTag:kCellContentBaseTag + 2];
        UILabel *phoneLb = (UILabel *)[cell.contentView viewWithTag:kCellContentBaseTag + 3];
        UIImageView *iconBgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentBaseTag+4];

        
        NSArray *arr = _listArr[indexPath.section];
        TXUser *user = arr[indexPath.row];
        if (!indexPath.row) {
            iconImgView.hidden = YES;
            phoneLb.hidden = YES;
            titleLb.text = [NSString stringWithFormat:@"   %@",user.realName];
            titleLb.backgroundColor = kColorSection;
            titleLb.frame = CGRectMake(0, 0, kScreenWidth, KSECTIONHEIGHT);
            titleLb.font = kFontTiny;
            titleLb.textColor = kColorGray1;
            [iconImgView setHidden:YES];
            [iconBgView setHidden:YES];
            cell.contentView.backgroundColor = kColorSection;
        }else{
            cell.contentView.backgroundColor = kColorWhite;
            titleLb.font = kFontTitle;
            titleLb.backgroundColor = kColorClear;
            titleLb.textColor = KColorTitleTxt;
            [iconImgView setHidden:NO];
            [iconBgView setHidden:NO];
            titleLb.text = user.nickname;
            phoneLb.text = user.mobilePhoneNumber;
            iconImgView.hidden = NO;
            phoneLb.hidden = NO;
            titleLb.frame = CGRectMake(iconImgView.maxX + 5, 0, kScreenWidth - iconImgView.maxX - 10, KCELLHIGHT);
            NSString *urlStr = [NSString stringWithFormat:@"%@?imageView2/1/format/jpg/w/80/h/80", user.avatarUrl];
            [iconImgView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            
            [titleLb sizeToFit];
            [phoneLb sizeToFit];
            titleLb.frame = CGRectMake(iconImgView.maxX + 5, iconImgView.minY+1, titleLb.width_, titleLb.height_);
            phoneLb.frame = CGRectMake(titleLb.minX, iconImgView.maxY - phoneLb.height_-1, phoneLb.width_, phoneLb.height_);

        }
        CGFloat cellHight = KCELLHIGHT;
        if (!indexPath.row)
        {
            cellHight = KSECTIONHEIGHT;
        }
        
        if (indexPath.row == arr.count - 1) {
            lineView.frame = CGRectMake(0, cellHight - kLineHeight, kScreenWidth, kLineHeight);
        }else{
            lineView.frame = CGRectMake(10, cellHight - kLineHeight, kScreenWidth - 20, kLineHeight);
        }
        [cell.contentView setBackgroundColor:kColorWhite];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int64_t userId = 0;
    if (_type == ContactType_Teachers) {
        TXUser *user = _listArr[indexPath.row];
        userId = user.userId;
    }else if (indexPath.row){
        _topListView.minY = self.customNavigationView.maxY - _topListView.height_;
        NSArray *arr = _listArr[indexPath.section];
        TXUser *user = arr[indexPath.row];
        userId = user.userId;
    }else{
        return;
    }
    ParentsDetailViewController *chatVc = [[ParentsDetailViewController alloc] initWithIdentity:userId];
    [self.navigationController pushViewController:chatVc animated:YES];
}


@end
