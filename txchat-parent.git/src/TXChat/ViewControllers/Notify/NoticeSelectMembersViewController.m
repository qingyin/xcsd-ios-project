//
//  NoticeSelectMembersViewController.m
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoticeSelectMembersViewController.h"
#import "NotifySelectMembersTableViewCell.h"
#define KSECTIONHEIGHT1 10.0f
@interface NoticeSelectMembersViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSInteger _selectedCount ;
    NSArray *_titleArray;
}
@end

@implementation NoticeSelectMembersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedCount = 0;
        _updateMemberSelected = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"乐学堂测试_14班";
    [self createCustomNavBar];
    NSString *selectStr= [NSString stringWithFormat:@"选择(%ld)", (long)_selectedCount];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self createTitles];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    UIView *superview = self.view;
    WEAKSELF
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, 0));
    }];
}
-(void)createTitles
{
    _titleArray = @[@[@"a", @"a1", @"a2"], @[@"b", @"b1", @"b2"], @[@"c", @"c1", @"c2"], @[@"d", @"d1", @"d2"], @[@"e", @"e1", @"e2"], @[@"f", @"f1", @"f2"]];
}



-(void)updateRightTitle:(NSInteger)updateValue
{
    _selectedCount += updateValue;
    NSString *selectStr= [NSString stringWithFormat:@"选择(%ld)", (long)_selectedCount];
    [self.btnRight setTitle:selectStr forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        _updateMemberSelected(_titleArray, @"乐学堂测试_14班");
        [self.navigationController popViewControllerAnimated:YES];
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



#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[_titleArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_titleArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotifySelectMembersTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    NotifySelectMembersTableViewCell *userSelectedCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (userSelectedCell == nil) {
        userSelectedCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifySelectMembersTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    NSString *title = [[_titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [userSelectedCell.userNameLabel setText:title];
    if(indexPath.row == [(NSArray *)[_titleArray objectAtIndex:indexPath.section] count] -1)
    {
        [userSelectedCell.seperatorLine setHidden:YES];
    }
    WEAKSELF
    userSelectedCell.selectedBock = ^(NSString *groupName, BOOL isSelected){
        NSInteger selectecCount = 0;
        if(isSelected)
        {
            selectecCount ++;
        }
        else
        {
            selectecCount--;
        }
        [weakSelf updateRightTitle:selectecCount];
    };
    
    
    cell = userSelectedCell;
    return cell;
}
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    
//    NSMutableArray *sectionIndex = [[NSMutableArray alloc] initWithCapacity:5];
//    for(char c = 'A'; c <= 'Z'; c++ )
//    {
//        [sectionIndex addObject:[NSString stringWithFormat:@"%c",c]];
//    }
//    //    [sectionIndex addObject:[NSString stringWithFormat:@"%c",'#']];
//    
//    return sectionIndex;
//}

#pragma mark-  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    CGFloat height = KSECTIONHEIGHT1;
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
    return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UIView *headerView = nil;
    headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, KSECTIONHEIGHT1);
    headerView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.frame.size.width-15, KSECTIONHEIGHT1)];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [label setTextColor:[UIColor redColor]];
    NSString *title = [[_titleArray objectAtIndex:section] objectAtIndex:0];
    [label setText:title];
    [headerView addSubview:label];
//    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = nil;
    return headerView;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self showTeacherDetailVC];
    
}

@end
