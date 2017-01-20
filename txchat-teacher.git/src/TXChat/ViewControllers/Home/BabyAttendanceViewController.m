//
//  BabyAttendanceViewController.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BabyAttendanceViewController.h"
#import <UIImageView+Utils.h>
#import "UIImage+Rotate.h"
#import "AttendanceUICollectionViewCell.h"
#import "UIImageView+EMWebCache.h"
#import <NSString+Photo.h>
#import "NSDate+TuXing.h"
#import <NSDate+DateTools.h>
#import "DropdownView.h"
#import "LeavesListViewController.h"
#import <UIImageView+TXSDImage.h>

CGFloat tabbarHight = 40.0f;

@interface BabyAttendanceViewController ()<UITabBarDelegate,UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger _selectedAttendanceIndex;//tab栏 选中按钮顺序
    UITabBarItem *_leftItem;
    UITabBarItem *_middleItem;
    UITabBarItem *_rightItem;
    UITabBar *_tabbar;
    UILabel *_showMonthLabel;//显示当前日期控件
    UIView  *_tabSelectedBtmView; //tab栏 下面 选中标签
    UICollectionView *_collectionView;
    NSMutableArray *_presentArray;//出勤
    NSMutableArray *_absentArray;//缺席
    NSMutableArray *_leaveArray;//请假
    NSMutableArray *_selectedItems; //选中用户
    NSDate *_currentDate;//当前显示日期
    UIView *_coverView;
    UIImageView *_arrowImgView;
    NSInteger _selectedIndex;
    UIImageView *_bgImgView; //
    UIView *_btmView; //底部 请假和补签 区域
    UIButton *_rightDayBtn; //下一天按钮
    DropdownView *_dropDownView;
    UIButton *_selectedBtn;
    BOOL _isHoliday;
}
@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, assign) int64_t departmentId;
@end

@implementation BabyAttendanceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _presentArray = [NSMutableArray arrayWithCapacity:1];
        _absentArray = [NSMutableArray arrayWithCapacity:1];
        _leaveArray = [NSMutableArray arrayWithCapacity:1];
        _selectedItems = [NSMutableArray arrayWithCapacity:1];
        _currentDate = [NSDate date];
        _isHoliday = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    [self.btnRight setTitle:@"孩子请假" forState:UIControlStateNormal];
    [self setupTabViews];
    [self setupViews];
    [self updateDataFromServer:_currentDate];
    [self updateMonthBtns];
    [self updateViews];
    self.view.backgroundColor = kColorWhite;
}


-(void)setupViews
{
    @weakify(self);
    
    //创建 月份选择view
    UIView *monthSelectedView = [[UIView alloc] init];
    monthSelectedView.backgroundColor = RGBCOLOR(0xee, 0xee, 0xee);

    [self.view addSubview:monthSelectedView];
    
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"attendance_leftNormal"] forState:UIControlStateNormal];
    [monthSelectedView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.and.bottom.mas_equalTo(monthSelectedView);
        make.width.mas_equalTo(40);
    }];
    [leftBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        _currentDate = [_currentDate dateBySubtractingDays:1];
        [self updateDataFromServer:_currentDate];
        [self clearSelectedUsers];
        [self updateMonthBtns];
        
    }];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightDayBtn = rightBtn;
    [rightBtn setImage:[UIImage imageNamed:@"attendance_rightNormal"] forState:UIControlStateNormal];
    [monthSelectedView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.and.bottom.mas_equalTo(monthSelectedView);
        make.width.mas_equalTo(40);
    }];
    [rightBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        _currentDate = [_currentDate dateByAddingDays:1];
        [self updateDataFromServer:_currentDate];
        [self clearSelectedUsers];
        [self updateMonthBtns];
    }];
    
    UIView *monthTabView = [[UIView alloc] init];
    //添加点击事件
    UITapGestureRecognizer* monthViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(monthViewTapEvent:)];
    monthViewTap.numberOfTapsRequired = 1;
    monthViewTap.numberOfTouchesRequired = 1;
    monthViewTap.cancelsTouchesInView = NO;
    monthSelectedView.userInteractionEnabled = YES;
    monthTabView.userInteractionEnabled = YES;
    [monthTabView addGestureRecognizer:monthViewTap];
    [monthSelectedView addSubview:monthTabView];
    [monthTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(monthSelectedView);
        make.left.mas_equalTo(leftBtn.mas_right);
        make.right.mas_equalTo(rightBtn.mas_left);
        make.centerY.mas_equalTo(monthSelectedView);
    }];
    
    UILabel *monthLabel = [[UILabel alloc] init];
    monthLabel.textColor = KColorSubTitleTxt;
    monthLabel.font = kFontLarge;
    monthLabel.text = @"";
    _showMonthLabel = monthLabel;
    [monthSelectedView addSubview:monthLabel];
    [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(monthSelectedView);
        make.centerX.mas_equalTo(monthSelectedView);
    }];
    [monthSelectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).with.offset(self.customNavigationView.maxY);
        make.height.mas_equalTo(34);
    }];
    
    [_tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(monthSelectedView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, tabbarHight));
        make.right.and.left.mas_equalTo(self.view);
    }];
    UIView *beginLine = [[UIView alloc] init];
    beginLine.backgroundColor = kColorLine;
    [self.view addSubview:beginLine];
    [beginLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(_tabbar.mas_bottom);
    }];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setBackgroundColor:kColorClear];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.allowsSelection = YES;
    [_collectionView registerClass:[AttendanceUICollectionViewCell class] forCellWithReuseIdentifier:@"GradientCell"];
    [self.view addSubview:_collectionView];
  
    
    UIView *btmView = [[UIView alloc] init];
    btmView.backgroundColor = kColorClear;
    _btmView = btmView;
    [self.view addSubview:btmView];
    
    
    UIView *endLine = [[UIView alloc] init];
    endLine.backgroundColor = kColorLine;
    [btmView addSubview:endLine];
    [endLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(btmView);
        make.right.mas_equalTo(btmView);
        make.height.mas_equalTo(kLineHeight);
        make.bottom.mas_equalTo(btmView).with.offset(-50.0f);
    }];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).with.offset(8);
        make.right.mas_equalTo(self.view).with.offset(-8);
        make.top.mas_equalTo(beginLine.mas_bottom);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    //创建请假view
    UIButton *leaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leaveBtn.tintColor = kColorWhite;
    leaveBtn.titleLabel.font = kFontSuper;
    [leaveBtn setTitle:@"请假" forState:UIControlStateNormal];
    leaveBtn.layer.cornerRadius = 4.0f/2;
    leaveBtn.layer.masksToBounds = YES;
    [leaveBtn setBackgroundImage:[UIImageView createImageWithColor:KColorAppMain] forState:UIControlStateNormal];
    [leaveBtn setBackgroundImage:[UIImageView createImageWithColor:KColorAppMainP] forState:UIControlStateHighlighted|UIControlStateSelected];
    [btmView addSubview:leaveBtn];

    [leaveBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        if(_selectedItems.count)
        {
            [self askForLeave:_selectedItems];
        }
        else
        {
            [self showFailedHudWithTitle:@"未选中任何用户"];
        }
    }];
    
    
    //创建补签view
    UIButton *manualSignInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    manualSignInBtn.tintColor = kColorWhite;
    manualSignInBtn.titleLabel.font = kFontSuper;
    [manualSignInBtn setTitle:@"补签" forState:UIControlStateNormal];
    manualSignInBtn.layer.cornerRadius = 4.0f/2;
    manualSignInBtn.layer.masksToBounds = YES;
    [manualSignInBtn setBackgroundImage:[UIImageView createImageWithColor:RGBCOLOR(0x56, 0xc8, 0xfd)] forState:UIControlStateNormal];
    [manualSignInBtn setBackgroundImage:[UIImageView createImageWithColor:RGBCOLOR(0x39, 0xbc, 0xf9)] forState:UIControlStateHighlighted|UIControlStateSelected];
    [btmView addSubview:manualSignInBtn];
   
    

    [manualSignInBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        if(_selectedItems.count)
        {
            [self askForPresent:_selectedItems];
        }
        else
        {
            [self showFailedHudWithTitle:@"未选中任何用户"];
        }
    }];
    
    [leaveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(manualSignInBtn.mas_left).with.offset(-10);
        make.left.mas_equalTo(btmView.mas_left).with.offset(10);
        make.bottom.mas_equalTo(btmView.mas_bottom).with.offset(-10);
        make.width.mas_equalTo(manualSignInBtn);
        make.height.mas_equalTo(32);
    }];
    
    [manualSignInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(btmView.mas_right).with.offset(-10);
        make.left.mas_equalTo(leaveBtn.mas_right).with.offset(10);
        make.bottom.mas_equalTo(btmView.mas_bottom).with.offset(-10);
        make.width.mas_equalTo(leaveBtn);
        make.height.mas_equalTo(32);
    }];
    
    [btmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(51.0f);
    }];
    [btmView setHidden:YES];
    
    
    
    

    self.groupList = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *departments = [[TXChatClient sharedInstance] getAllDepartments:nil];
    NSMutableArray *showTitles= [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *index in departments)
    {
        if(![index.name isEqualToString:@"老师"])
        {
            [self.groupList addObject:index];
            [showTitles addObject:index.name];
        }
    }
    
    if(self.groupList.count > 0)
    {
        TXDepartment *depart = self.groupList[0];
        self.departmentId = depart.departmentId;
        //只有一个组不显示筛选框
        self.titleStr = depart.name;
        self.titleLb.text = self.titleStr;
        if (_groupList.count == 1) {
            return;
        }
    }
    
    _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedBtn.adjustsImageWhenHighlighted = NO;
    _selectedBtn.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, self.customNavigationView.width_, kNavigationHeight);
    [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavigationView addSubview:_selectedBtn];
    [self.customNavigationView bringSubviewToFront:self.btnLeft];
    [self.customNavigationView bringSubviewToFront:self.btnRight];
    DropdownView *dropDwon = [[DropdownView alloc] init];
    _dropDownView = dropDwon;
    [dropDwon showInView:self.view andListArr:showTitles andDropdownBlock:^(int index) {
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
            TXDepartment *depart = self.groupList[index];
            NSLog(@"name:%@", depart.name);
            self.titleStr = depart.name;
            self.titleLb.text = self.titleStr;
            self.departmentId = depart.departmentId;
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
        }
        [self updateDataFromServer:_currentDate];
    }];

    _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [self.customNavigationView addSubview:_arrowImgView];
}

- (void)showDropDownView
{
    [_dropDownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];

}


-(void)setupTabViews
{
    UIColor *selectedColor = RGBCOLOR(0x56, 0xc8, 0xfd);
    
    UITabBar *tabbar = [[UITabBar alloc] init];
    UITabBarItem *leftItem = nil;
    if(IOS7_OR_LATER)
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"已到" image:nil selectedImage:nil];
    }
    else
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"已到" image:nil tag:0];
    }
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      KColorSubTitleTxt, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateNormal];
    
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      selectedColor, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [leftItem setTitlePositionAdjustment:UIOffsetMake(0, -8)];
    _leftItem = leftItem;
    
    
    UITabBarItem *middleItem = nil;
    if(IOS7_OR_LATER)
    {
        middleItem = [[UITabBarItem alloc] initWithTitle:@"未到" image:nil selectedImage:nil];
    }
    else
    {
        middleItem = [[UITabBarItem alloc] initWithTitle:@"未到" image:nil tag:0];
    }
    
    [middleItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      KColorSubTitleTxt, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateNormal];
    
    
    [middleItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      selectedColor, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [middleItem setTitlePositionAdjustment:UIOffsetMake(0, -8)];
    _middleItem = middleItem;
    
    UITabBarItem *rightItem = nil;
    if(IOS7_OR_LATER)
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"请假" image:nil selectedImage:nil];
    }
    else
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"病假" image:nil tag:0];
    }
    
    
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       KColorSubTitleTxt, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateNormal];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       selectedColor, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [rightItem setTitlePositionAdjustment:UIOffsetMake(0, -8)];
    _rightItem = rightItem;
    NSArray *tabBarItemArray = [[NSArray alloc] initWithObjects: leftItem, _middleItem,rightItem,nil];
    [tabbar setItems: tabBarItemArray];
    [tabbar setBackgroundImage:[UIImageView createImageWithColor:kColorWhite]];
    [[UITabBar appearance] setShadowImage:[UIImageView createImageWithColor:kColorWhite]];
    tabbar.delegate = self;
    [self.view addSubview:tabbar];
    _tabbar = tabbar;
    [tabbar setSelectedItem:_leftItem];
    
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = RGBCOLOR(0x5c, 0xc8, 0xfd);
    _tabSelectedBtmView = selectedView;
    [tabbar addSubview:selectedView];
    CGFloat centerY = kScreenWidth/3.0f;
    [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 2));
        make.bottom.mas_equalTo(tabbar.mas_bottom);
        make.left.mas_equalTo(tabbar.mas_left).with.offset(0 + (centerY-100)/2);
    }];
}
-(void)updateMonthBtns
{
    NSDate *today = [NSDate date];
    if(_currentDate.year == today.year
       && _currentDate.month >= today.month
       && _currentDate.day >= today.day)
    {
        [_rightDayBtn setEnabled:NO];
        [_rightDayBtn setImage:[UIImage imageNamed:@"attendance_rightDisable"] forState:UIControlStateNormal];
    }
    else
    {
        [_rightDayBtn setImage:[UIImage imageNamed:@"attendance_rightNormal"] forState:UIControlStateNormal];
        [_rightDayBtn setEnabled:YES];
    }
}
-(void)updateViews
{
    if(_isHoliday)
    {
        _showMonthLabel.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld(节假日)", (long)_currentDate.year, (long)_currentDate.month,(long)_currentDate.day];
    }
    else
    {
        _showMonthLabel.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld", (long)_currentDate.year, (long)_currentDate.month,(long)_currentDate.day];
    }
    _leftItem.title = [NSString stringWithFormat:@"已到(%ld)", (unsigned long)[_presentArray count]];
    _middleItem.title = [NSString stringWithFormat:@"未到(%ld)", (unsigned long)[_absentArray count]];
    _rightItem.title = [NSString stringWithFormat:@"请假(%ld)", (unsigned long)[_leaveArray count]];
    [_tabbar layoutIfNeeded];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark-  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item // called when a new view is selected by the user (but not programatically)
{
    if(item == _leftItem)
    {
        if(_selectedAttendanceIndex != 0)
        {
            _selectedAttendanceIndex = 0;
            [self updateSelectedBtmView:_selectedAttendanceIndex];
            [_collectionView reloadData];
        }
    }
    else if (item == _rightItem)
    {
        if(_selectedAttendanceIndex != 2)
        {
            _selectedAttendanceIndex = 2;
            [self updateSelectedBtmView:_selectedAttendanceIndex];
            [_collectionView reloadData];
        }
    }
    else  if (item == _middleItem)
    {
        if(_selectedAttendanceIndex != 1)
        {
            _selectedAttendanceIndex = 1;
            [self updateSelectedBtmView:_selectedAttendanceIndex];
            [_collectionView reloadData];
        }
    }
}

-(void)updateSelectedBtmView:(NSInteger)index
{
    CGFloat centerY = kScreenWidth/3.0f;
    [_tabSelectedBtmView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_tabbar.mas_left).with.offset(centerY*index + (centerY-100)/2);
    }];

    if(index != 1)
    {
        [_btmView setHidden:YES];
        [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.mas_bottom);
        }];
    }
    else
    {
        [_btmView setHidden:NO];
        [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-51);
        }];
    }
    [UIView animateWithDuration:0.3f animations:^{
        [_tabSelectedBtmView layoutIfNeeded];

    }];
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_btmView layoutIfNeeded];
        [_collectionView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];

}


#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self getShowDataArray] count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"GradientCell";
    AttendanceUICollectionViewCell * cell = (AttendanceUICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *dataArray = [self getShowDataArray];
    if(indexPath.row >= [dataArray count])
    {
        return cell;
    }
    TXPBUser *user = [dataArray objectAtIndex:indexPath.row];
    [cell.headerImage TX_setImageWithURL:[NSURL URLWithString:[user.avatar getFormatPhotoUrl:50.0f hight:50.0f]] placeholderImage:[UIImage imageNamed:@"attendance_defaultHeader"]];
    [cell.nameLabel setText:user.nickname];
    [cell updateSelectedStatus:[self isSelected:user.userId]];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(65, 97);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 4, 0, 4.5);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TXPBUser *user = [self getShowDataArray][indexPath.row];
    if(_selectedAttendanceIndex == 1)
    {
        if([self isSelected:user.userId])
        {
            @synchronized(_selectedItems)
            {
                [_selectedItems removeObject:@(user.userId)];
            }
        }
        else
        {
            @synchronized(_selectedItems)
            {
                [_selectedItems addObject:@(user.userId)];
            }
        }
        [_collectionView reloadData];
    }
}


#pragma  mark-- private


-(NSMutableArray *)getShowDataArray
{
    if(_selectedAttendanceIndex == 0)
    {
        return _presentArray;
    }
    else if(_selectedAttendanceIndex == 1)
    {
        return _absentArray;
    }
    return _leaveArray;
}

-(BOOL)isSelected:(int64_t)userId
{
    __block BOOL isSelected = NO;
    [_selectedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *selectedUserId = (NSNumber *)obj;
        if(selectedUserId.longLongValue == userId)
        {
            isSelected = YES;
            *stop = YES;
        }
    }];
    return isSelected;
}


-(void)updateDataFromServer:(NSDate *)currentDate
{
    @weakify(self);
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance].checkInManager fetchDepartmentAttendance:self.departmentId date:[_currentDate dateToLongLong] onCompleted:^(NSError *error, NSArray *presentUsers, NSArray *absenceUsers, NSArray *leaveUsers, BOOL isRestDay) {
        _isHoliday = isRestDay;
        @strongify(self);
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            @synchronized(_presentArray)
            {
                _presentArray = [NSMutableArray arrayWithArray:presentUsers];
            }
            @synchronized(_absentArray)
            {
                _absentArray = [NSMutableArray arrayWithArray:absenceUsers];
            }
            @synchronized(_leaveArray)
            {
                _leaveArray = [NSMutableArray arrayWithArray:leaveUsers];
            }
            [self updateViews];
            [_collectionView reloadData];
        }
    }];
}



#pragma mark - 按钮点击方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(sender.tag == TopBarButtonRight)
    {
        [self showLeavesList];
    }
}

///**
// *  点击顶部选择按钮
// */
//
//- (void)onTapCover{
//    [self onSelectedBtn];
//}
//- (void)onSelectedBtn{
//    if (_bgImgView.minY < self.customNavigationView.maxY) {
//        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            _bgImgView.minY = self.customNavigationView.maxY;
//            _coverView.alpha = 0.8;
//            _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
//        } completion:nil];
//    }else{
//        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            _bgImgView.minY = self.customNavigationView.maxY - _bgImgView.height_;
//            _coverView.alpha = 0;
//            _arrowImgView.transform = CGAffineTransformMakeRotation(0);
//        } completion:nil];
//    }
//    [_collectionView reloadData];
//}

-(void)askForLeave:(NSArray *)leaveUsers
{
    @weakify(self);
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance].checkInManager updateAttendance:nil absenceUserIds:nil leaveUserIds:leaveUsers date:[_currentDate dateToLongLong] onCompleted:^(NSError *error) {
        @strongify(self);
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            [self updateDataFromServer:_currentDate];
            [self clearSelectedUsers];
        }
    }];
}


-(void)askForPresent:(NSArray *)PresentUsers
{
    @weakify(self);
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance].checkInManager updateAttendance:PresentUsers absenceUserIds:nil leaveUserIds:nil date:[_currentDate dateToLongLong] onCompleted:^(NSError *error) {
        @strongify(self);
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            [self updateDataFromServer:_currentDate];
            [self clearSelectedUsers];
        }
    }];
}



-(void)clearSelectedUsers
{
    @synchronized(_selectedItems)
    {
        _selectedItems = [NSMutableArray arrayWithCapacity:1];
    }
}


-(void)showLeavesList
{
    LeavesListViewController *avc = [[LeavesListViewController alloc] init];
    [self.navigationController pushViewController:avc animated:YES];
}

-(void)monthViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    @weakify(self);
    [self showDatePickerWithCurrentDate:_currentDate minimumDate:[_currentDate dateBySubtractingYears:1] maximumDate:[NSDate date] selectedDate:_currentDate selectedBlock:^(NSDate *selectedDate) {
        @strongify(self);
        _currentDate = selectedDate;
        [self updateDataFromServer:_currentDate];
        [self clearSelectedUsers];
        [self updateMonthBtns];
    }];
    
    
}


@end
