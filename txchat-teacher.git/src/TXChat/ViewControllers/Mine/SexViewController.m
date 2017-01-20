//
//  SexViewController.m
//  TXChat
//
//  Created by lyt on 15/7/15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SexViewController.h"
//cell的高度
#define KCELLHIGHT 50
@interface SexViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSString *_defaultSex;//默认选中 sex;
    SexSelectedCompleted _onCompleted;
}
@end

@implementation SexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _onCompleted = nil;
    }
    return self;
}
//初始化 默认性别 和 选中后处理
-(id)initWithDefaultSex:(NSString *)defaultSex onCompleted:(SexSelectedCompleted)onComplted
{
    self = [super init];
    if(self)
    {
        _defaultSex = defaultSex;
        _onCompleted = onComplted;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"性别";
    [self createCustomNavBar];
    [self.btnLeft setTitle:@"返回" forState:UIControlStateNormal];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).with.offset(self.customNavigationView.maxY);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SexTableViewCell";
    //    DLog(@"section:%d, rows:%d", indexPath.section, indexPath.row);
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        titleLb.font = kFontMiddle;
        titleLb.textColor = kColorBlack;
        titleLb.tag = 100;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectMake(kEdgeInsetsLeft, KCELLHIGHT - kLineHeight, self.view.width_ - kEdgeInsetsLeft, kLineHeight)];
        lineView.tag = 10000;
        [cell.contentView addSubview:lineView];
    }
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:100];

    UIView *lineView = [cell.contentView viewWithTag:10000];
    if(indexPath.row == 0)
    {
        [titleLb setText:@"男"];
        [lineView setHidden:NO];
    }
    else
    {
        [titleLb setText:@"女"];
        [lineView setHidden:YES];
    }
    [titleLb sizeToFit];
    titleLb.frame = CGRectMake(kEdgeInsetsLeft, 0, titleLb.width_, KCELLHIGHT);
    if([titleLb.text isEqualToString:_defaultSex])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell.contentView setBackgroundColor:kColorWhite];
    return cell;
}

#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedSex = @"女";
    if(indexPath.row == 0)
    {
        selectedSex = @"男";
    }
    _onCompleted(selectedSex);
    [self.navigationController popViewControllerAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}





@end
