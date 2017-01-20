//
//  DebugViewController.m
//  TXChat
//
//  Created by lyt on 15/7/16.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "DebugViewController.h"
#import "TXEaseMobHelper.h"
#import "XGPush.h"
#import "NSObject+EXTParams.h"

static NSString *const kServerModeTitle = @"title";
static NSString *const kServerModeValue = @"value";

@interface DebugViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate>


@property (nonatomic,strong) NSMutableArray *serverModeArray;
@property (nonatomic,copy) NSString *serverMode;
@property (nonatomic,copy) NSString *easemobAppKey;
@end

@implementation DebugViewController

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
    self.titleStr = @"本界面内部调试用";
    [self createCustomNavBar];
    [self commonSetup];
    [self setupServerModeView];
    
}
- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - 数据源处理
- (void)commonSetup
{
    //读取默认值
    NSString *modeKey;
    NSString *serverModeUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverMode"];
    if (!serverModeUrl || ![serverModeUrl length]) {
        modeKey = @"publicFormal";
    }else{
        modeKey = serverModeUrl;
    }
    self.serverMode = modeKey;
    NSString *customRequestHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"customServerHost"];
    NSString *customRequestPort = [[NSUserDefaults standardUserDefaults] objectForKey:@"customServerPort"];
    NSString *customEMAppKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"customServerEMAppKey"];
    _easemobAppKey = customEMAppKey ?: @"";
    //设置环境
    self.serverModeArray = [NSMutableArray array];
    NSArray *defaultModes = @[@{kServerModeTitle:@"正式环境",kServerModeValue:@"publicFormal"},
                              @{kServerModeTitle:@"测试环境",kServerModeValue:@"publicTest"},
                              @{kServerModeTitle:@"开发环境",kServerModeValue:@"privateDev"},
                              @{kServerModeTitle:@"自定义环境",kServerModeValue:@"customServerMode"}];
    [self.serverModeArray addObject:defaultModes];
    NSArray *customMode = @[@{kServerModeTitle:@"Host地址",kServerModeValue: customRequestHost ?: @""},
                            @{kServerModeTitle:@"Port",kServerModeValue:customRequestPort ?: @""},
							@{kServerModeTitle:@"环信AppKey1",kServerModeValue:KHuanXin_AppKey_Dev},
							@{kServerModeTitle:@"环信AppKey2",kServerModeValue:KHuanXin_AppKey_Test},
							@{kServerModeTitle:@"环信AppKey3",kServerModeValue:KHuanXin_AppKey_Dis}];
    [self.serverModeArray addObject:customMode];
}
- (void)setServerMode:(NSString *)serverMode
{
    _serverMode = serverMode;
    [[NSUserDefaults standardUserDefaults] setObject:serverMode forKey:@"serverMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)setEasemobAppKey:(NSString *)easemobAppKey
{
    _easemobAppKey = easemobAppKey;
    [[NSUserDefaults standardUserDefaults] setObject:easemobAppKey forKey:@"customServerEMAppKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - UI视图创建
- (void)setupServerModeView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_serverModeArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = _serverModeArray[section];
    return [list count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        //添加输入框
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, CGRectGetWidth(self.view.frame) - 110, 40)];
        textField.backgroundColor = [UIColor clearColor];
        textField.delegate = self;
        textField.textColor = KColorTitleTxt;
        textField.font = kFontMiddle;
        textField.returnKeyType = UIReturnKeyDone;
        textField.tag = 100;
        [cell.contentView addSubview:textField];
        //添加通知监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveTextChangedNotification:) name:UITextFieldTextDidChangeNotification object:textField];
    }
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:100];
    NSDictionary *dict = _serverModeArray[indexPath.section][indexPath.row];
    cell.textLabel.text = dict[kServerModeTitle];
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        textField.hidden = YES;
        //选择环境
        NSString *mode = dict[kServerModeValue];
        if ([self.serverMode isEqualToString:mode]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{
        //自定义环境
        BOOL isCustomServerMode = NO;
        if ([self.serverMode isEqualToString:@"customServerMode"]) {
            //当前选择的是自定义环境,显示Host和Port值
            isCustomServerMode = YES;
        }
        if (indexPath.row >= 2) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            textField.hidden = YES;
            NSString *value = dict[kServerModeValue];
            cell.detailTextLabel.text = value;
            if ([self.easemobAppKey isEqualToString:value] && isCustomServerMode) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            textField.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [textField setTXExtParams:indexPath forKey:@"indexPath"];
            if (isCustomServerMode) {
                NSString *hostValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"customServerHost"];
                NSString *portValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"customServerPort"];
                if (indexPath.row == 0) {
                    textField.text = hostValue;
                }else if (indexPath.row == 1) {
                    textField.text = portValue;
                }
            }else{
                textField.text = @"";
            }
        }
    }
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    headerView.backgroundColor = [UIColor clearColor];
    //添加文字
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    modeLabel.backgroundColor = [UIColor clearColor];
    modeLabel.textColor = KColorTitleTxt;
    modeLabel.font = [UIFont systemFontOfSize:15];
    if (section == 0) {
        modeLabel.text = @"    选择环境";
    }else if (section == 1) {
        modeLabel.text = @"    自定义环境";
    }
    [headerView addSubview:modeLabel];
    //添加分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, CGRectGetWidth(self.view.frame), kLineHeight)];
    lineView.backgroundColor = kColorLine;
    [headerView addSubview:lineView];
    
    return headerView;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSDictionary *dict = _serverModeArray[indexPath.section][indexPath.row];
        self.serverMode = dict[kServerModeValue];
        //刷新视图
        [tableView reloadData];
    }else if (indexPath.section == 1) {
        if (indexPath.row >= 2) {
            NSDictionary *dict = _serverModeArray[indexPath.section][indexPath.row];
            self.easemobAppKey = dict[kServerModeValue];
            //刷新视图
            [tableView reloadData];
        }
    }
}
#pragma mark - 字体变更通知
- (void)onReceiveTextChangedNotification:(NSNotification *)notification
{
    UITextField *textField = (UITextField *)notification.object;
    NSIndexPath *indexPath = [textField extParamForKey:@"indexPath"];
    if (indexPath) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            //host
            [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:@"customServerHost"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else if (indexPath.section == 1 && indexPath.row == 1) {
            //port
            [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:@"customServerPort"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}
#pragma mark - UITextFieldDelegate methods
//结束编辑
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    NSIndexPath *indexPath = [textField extParamForKey:@"indexPath"];
//    if (indexPath) {
//        if (indexPath.section == 1 && indexPath.row == 0) {
//            //host
//            [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:@"customServerHost"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }else if (indexPath.section == 1 && indexPath.row == 1) {
//            //port
//            [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:@"customServerPort"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
//}
@end
