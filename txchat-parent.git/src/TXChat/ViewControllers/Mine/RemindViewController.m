//
//  RemindViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/5.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "RemindViewController.h"
#import "TXSystemManager.h"
#import <TXChatClient.h>
#import "NSDictionary+Utils.h"

static NSInteger const kSwitchTag = 100;
static NSInteger const kNoDisturbButtonTag = 200;

@interface RemindViewController ()
{
    UIScrollView *_listView;
    NSMutableDictionary *_userRemindSetting;
}

@end

@implementation RemindViewController

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

-(id)init
{
    self = [super init];
    if(self)
    {
        _userRemindSetting = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"消息提醒";
    [self createCustomNavBar];
    [self loadUserRemindSetting];
    _listView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_)];
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_listView];
    
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)loadUserRemindSetting
{
    NSError *err = nil;
    NSDictionary *serverProfile = [[TXChatClient sharedInstance] getCurrentUserProfiles:&err];
    [_userRemindSetting setValuesForKeysWithDictionary:serverProfile];
    [self createDefaultValue:_userRemindSetting];
    [TXSystemManager sharedManager].enableGlobalSoundPlay = [[_userRemindSetting objectForKey:KUserSound] boolValue];
    [TXSystemManager sharedManager].enableGlobalVibrationPlay = [[_userRemindSetting objectForKey:KUserVibration] boolValue];
}

-(void)createDefaultValue:(NSMutableDictionary *)currentRemindSetting
{
    if(![currentRemindSetting containsKey:KUserNoDisturb])
    {
        [currentRemindSetting setValue:[NSString stringWithFormat:@"%d", 0] forKey:KUserNoDisturb];
    }
    if(![currentRemindSetting containsKey:KUserVibration])
    {
        [currentRemindSetting setValue:[NSString stringWithFormat:@"%d", 1] forKey:KUserVibration];
    }
    if(![currentRemindSetting containsKey:KUserSound])
    {
        [currentRemindSetting setValue:[NSString stringWithFormat:@"%d", 1] forKey:KUserSound];
    }
}


- (void)initView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _listView.width_, 90)];
    topView.backgroundColor = kColorWhite;
    [_listView addSubview:topView];
    
    [topView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(kEdgeInsetsLeft, topView.height_/2, topView.width_ - 2*kEdgeInsetsLeft, kLineHeight)]];
    
    NSArray *arr = @[@"声音提示",@"震动"];
    __block CGFloat Y = 0;
    __block CGFloat switchMinX = 0;
    [arr enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
        UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectMake(kEdgeInsetsLeft, Y, 200, topView.height_/2)];
        label.font = kFontMiddle;
        label.textColor = kColorBlack;
        label.text = str;
        [topView addSubview:label];
        
        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [aSwitch setOnTintColor:KColorAppMain];
        [aSwitch sizeToFit];
        aSwitch.tag = kSwitchTag + idx;
        aSwitch.frame = CGRectMake(topView.width_ - kEdgeInsetsLeft - aSwitch.width_,label.minY + (label.height_ - aSwitch.height_)/2, 30, 22);
        [topView addSubview:aSwitch];
        if (idx == 0) {
            //声音
            [aSwitch setOn: [[_userRemindSetting objectForKey:KUserSound] boolValue]];
        }else{
            //震动
            [aSwitch setOn:[[_userRemindSetting objectForKey:KUserVibration] boolValue]];
        }
        [aSwitch handleControlEvent:UIControlEventTouchUpInside withBlock:^(UISwitch *sender) {
            NSInteger switchIndex = sender.tag - kSwitchTag;
            //网络更新配置
            if (switchIndex == 0) {
                [[TXChatClient sharedInstance] saveUserProfiles:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", sender.isOn?1:0], KUserSound, nil] onCompleted:^(NSError *error) {
                    DLog(@"error:%@", error);
                    if(!error)
                    {
                        [MobClick event:@"mime_remind" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"修改声音提示", nil] counter:1];
                        [TXSystemManager sharedManager].enableGlobalSoundPlay = sender.isOn;
                    }
                    else
                    {
                        [MobClick event:@"mime_remind" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"修改声音提示", nil] counter:1];
                        [sender setOn:!sender.isOn];
                        [self showFailedHudWithError:error];
                    }
                }];
            }else{
                [[TXChatClient sharedInstance] saveUserProfiles:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", sender.isOn?1:0], KUserVibration, nil] onCompleted:^(NSError *error) {
                    DLog(@"error:%@", error);
                    if(!error)
                    {
                        [MobClick event:@"mime_remind" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"修改震动", nil] counter:1];
                        [TXSystemManager sharedManager].enableGlobalVibrationPlay = sender.isOn;
                    }
                    else
                    {
                        [MobClick event:@"mime_remind" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"修改声音提示", nil] counter:1];
                        [sender setOn:!sender.isOn];
                        [self showFailedHudWithError:error];
                    }
                }];
            }
        }];
        
        switchMinX = aSwitch.minX;
        Y = label.maxY;
    }];
    
    UILabel *tipLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    tipLb.text = @"若乐学堂在运行时,你可以设置是否需要声音或者震动";
    tipLb.numberOfLines = 0;
    tipLb.textColor = kColorLightGray;
    tipLb.font = kFontSmall;
    [_listView addSubview:tipLb];
    CGSize size = [tipLb sizeThatFits:CGSizeMake(self.view.width_ - 50, MAXFLOAT)];
    [tipLb sizeToFit];
    tipLb.frame = CGRectMake(kEdgeInsetsLeft, topView.maxY + 10, self.view.width_ - 2*kEdgeInsetsLeft , size.height);
    
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, tipLb.maxY + 10, _listView.width_, 44 * 4)];
    timeView.backgroundColor = kColorWhite;
    [_listView addSubview:timeView];
    
    UILabel *timeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    timeLb.font = kFontMiddle;
    timeLb.textColor = kColorLightGray;
    timeLb.text = @"消息免打扰时段";
    [timeView addSubview:timeLb];
    [timeLb sizeToFit];
    timeLb.frame = CGRectMake(kEdgeInsetsLeft, 0, timeLb.width_, 44);
    [timeView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(kEdgeInsetsLeft, timeLb.height_ - kLineHeight, timeView.width_ - 2*kEdgeInsetsLeft, kLineHeight)]];
    
    NSArray *timeArr = @[@"全天开启",@"只在夜间开启",@"关闭"];
    __block CGFloat timeY = timeLb.maxY;
    NSMutableArray *btnArr = [NSMutableArray array];
    NSInteger  noDisturbValue = [[_userRemindSetting objectForKey:KUserNoDisturb] integerValue];
    NSInteger selectedIndex = 0;
    if(noDisturbValue == 0)
    {
        selectedIndex = 2;
    }
    else if(noDisturbValue == 1)
    {
        selectedIndex = 0;
    }
    else
    {
        selectedIndex = 1;
    }
    
    [timeArr enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
        UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        label.text = str;
        label.font = kFontMiddle;
        label.textColor = kColorBlack;
        [timeView addSubview:label];
        [label sizeToFit];
        label.frame = CGRectMake(kEdgeInsetsLeft, timeY, label.width_, 44);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, label.minY, topView.width_, label.height_);
        [btn setImage:[UIImage imageNamed:@"btn_mask"] forState:UIControlStateSelected];
        [btn setImage:nil forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, btn.width_ - kEdgeInsetsLeft - 22, 0, kEdgeInsetsLeft);
        btn.tag = kNoDisturbButtonTag + idx;
        [timeView addSubview:btn];
        [btnArr addObject:btn];
        
        if (idx == selectedIndex) {
            btn.selected = YES;
        }
        
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(UIButton *sender) {
            if (!sender.selected) {
                sender.selected = YES;
                [btnArr enumerateObjectsUsingBlock:^(UIButton *tmpBtn, NSUInteger idx, BOOL *stop) {
                    if (![tmpBtn isEqual:sender]) {
                        tmpBtn.selected = NO;
                    }
                }];
            }
            //网络更新配置
            NSInteger noDisturbIndex = (sender.tag - kNoDisturbButtonTag);
            NSInteger noDisturbValue = 0;
            if(noDisturbIndex == 0)
            {
                noDisturbValue = 1;
            }
            else if(noDisturbIndex == 1)
            {
                noDisturbValue = 2;
            }
            
            [[TXChatClient sharedInstance] saveUserProfiles:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)noDisturbValue], KUserNoDisturb, nil] onCompleted:^(NSError *error) {
                DLog(@"error:%@", error);
                if(!error)
                {
                    [MobClick event:@"mime_remind" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"修改免打扰", nil] counter:1];
                    [TXSystemManager sharedManager].globalNoDisturbStatus =  noDisturbValue;
                    [[TXSystemManager sharedManager] updateEaseMobPushNotificationOptions];
                }
                else
                {
                    [MobClick event:@"mime_remind" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"修改免打扰", nil] counter:1];
                    btn.selected = NO;
                    NSInteger  noDisturbValue = [[_userRemindSetting objectForKey:KUserNoDisturb] integerValue];
                    NSInteger selectedIndex = 0;
                    if(noDisturbValue == 0)
                    {
                        selectedIndex = 2;
                    }
                    else if(noDisturbValue == 1)
                    {
                        selectedIndex = 0;
                    }
                    else
                    {
                        selectedIndex = 1;
                    }
                    
                    UIButton *lastBtn = (UIButton *)[timeView viewWithTag:kNoDisturbButtonTag + selectedIndex];
                    lastBtn.selected = YES;
                    
                    [self showFailedHudWithError:error];
                }
            }];
        }];
        
        timeY += 44;
        
        if (idx != timeArr.count - 1) {
            [timeView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(kEdgeInsetsLeft, label.maxY - kLineHeight, timeView.width_ - 2*kEdgeInsetsLeft, kLineHeight)]];
        }
    }];
    UILabel *bottomTipLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    bottomTipLb.text = @"夜间免打扰时间为22:00-08:00";
    bottomTipLb.textColor = kColorLightGray;
    bottomTipLb.font = kFontSmall;
    bottomTipLb.textAlignment = NSTextAlignmentCenter;
    [_listView addSubview:bottomTipLb];
    CGSize bottomSize = [bottomTipLb sizeThatFits:CGSizeMake(self.view.width_ - 2*kEdgeInsetsLeft, MAXFLOAT)];
    [bottomTipLb sizeToFit];
    bottomTipLb.frame = CGRectMake(kEdgeInsetsLeft, timeView.maxY + 10, self.view.width_ - 2*kEdgeInsetsLeft , bottomSize.height);

    _listView.contentSize = CGSizeMake(_listView.width_, bottomTipLb.maxY + 10);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
