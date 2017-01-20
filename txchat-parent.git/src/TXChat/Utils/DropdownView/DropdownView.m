//
//  DropdownView.m
//  TXChatTeacher
//
//  Created by Cloud on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "DropdownView.h"
#import "LMDropdownView.h"

@interface DropdownView ()<LMDropdownViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *listArr;
@property (nonatomic, strong) UIView *preView;
@property (nonatomic, strong) LMDropdownView *dropdownView;
@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, assign) BOOL isReload;


@end

@implementation DropdownView

- (void)showInView:(UIView *)view
        andListArr:(NSArray *)arr
  andDropdownBlock:(DropdownBlock)block{
    self.listArr = arr;
    self.preView = view;
    _block = block;
}

#pragma mark - DROPDOWN VIEW
- (void)showDropDownView:(CGFloat)originY
{
    // Init dropdown view
    if (!self.dropdownView) {
        self.dropdownView = [LMDropdownView dropdownView];
        self.dropdownView.delegate = self;
        
        // Customize Dropdown style
        self.dropdownView.closedScale = 1;
        self.dropdownView.blurRadius = 5;
        self.dropdownView.blackMaskAlpha = 0.5;
        self.dropdownView.animationDuration = 0.5;
        self.dropdownView.animationBounceHeight = 0;
        //        self.dropdownView.contentBackgroundColor = [UIColor colorWithRed:40.0/255 green:196.0/255 blue:80.0/255 alpha:1];
    }
    
    if (!_menuTableView) {
        if (_listArr.count > 8) {
            _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40 * kScale1 * 8) style:UITableViewStylePlain];
        }else{
            _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40 * kScale1 * _listArr.count) style:UITableViewStylePlain];
        }
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
    }
    
    // Show/hide dropdown view
    if ([self.dropdownView isOpen]) {
        [self.dropdownView hide];
    }
    else {
        [_menuTableView reloadData];
        [self.dropdownView showInView:_preView withContentView:_menuTableView atOrigin:CGPointMake(0, originY)];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ceilf(40 * kScale1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *userProfiles = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    static NSString *Identifier = @"customCellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, tableView.width_, ceilf(40 * kScale1))];
        titleLb.font = kFontMiddle;
        titleLb.textAlignment = NSTextAlignmentCenter;
        titleLb.tag = 100;
        [cell.contentView addSubview:titleLb];
        
        [cell.contentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, ceilf(40 * kScale1) - kLineHeight, kScreenWidth, kLineHeight)]];
    }
    
    NSString *name = _listArr[indexPath.row];
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:100];
    titleLb.text = name;
    
    if (_selectedIndex == indexPath.row) {
        titleLb.backgroundColor = KColorAppMain;
        titleLb.textColor = kColorWhite;
    }else{
        titleLb.backgroundColor = kColorWhite;
        titleLb.textColor = kColorBlack;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.row;
    self.isReload = YES;
    [self.dropdownView hide];
    return;
}

- (void)dropdownViewDidHide:(LMDropdownView *)dropdownView{
    if (_isReload) {
        _isReload = NO;
        _block(_selectedIndex);
    }else{
        _block(-1);
    }
}



@end
