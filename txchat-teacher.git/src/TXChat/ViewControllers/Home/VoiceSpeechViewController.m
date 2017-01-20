//
//  VoiceSpeechViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/2.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "VoiceSpeechViewController.h"
#import <FLAnimatedImageView.h>
#import <FLAnimatedImage.h>
#import <SDiPhoneVersion.h>
#import "TXSystemManager.h"
#import <MJRefresh.h>
#import "UIButton+EMWebCache.h"
#import <UIImageView+Utils.h>
#import "NSDate+TuXing.h"
#import <NSDate+DateTools.h>
#import <AVFoundation/AVFoundation.h>
#import "TXPhotoBrowserViewController.h"
#import <BlockUI.h>
#import <extobjc.h>

const CGFloat voiceBarHight = 70.0f;
const CGFloat cellHight = 133.0f;
#define kCellContentViewPortrait            123131          //头像
#define kCellContentViewBaseTag             1000
#define kCellContentViewTime                1001            //时间
#define kCellContentViewWeek                1002            //星期
#define kCellContentViewHour                1003            //具体时间
#define kCellContentViewSwipe               1004            //刷卡人
#define kCellContentViewIdentity            1005            //身份
#define kCellContentViewCode                1005            //卡号
#define kCellContentViewClass               1006            //班级


#define KSoundPlayCompleted             @"soundPlayCompleted"

@interface VoiceSpeechViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    FLAnimatedImageView *_animatedImageView;
    UITableView *_tableView;
    NSMutableArray *_listArray;
    int64_t _maxCheckId;
}
@property (nonatomic,strong) FLAnimatedImage *animatedImage;
@property (nonatomic, strong) AVSpeechSynthesizer * speechSynthesizer;
@property (nonatomic, assign) BOOL voiceSpeakChoice;
@property (nonatomic, assign)SystemSoundID lastSoundID;
@end

@implementation VoiceSpeechViewController


-(id)init
{
    self = [super init];
    if(self)
    {
        _listArray = [NSMutableArray arrayWithCapacity:1];
        _voiceSpeakChoice = FALSE;
        if(!_speechSynthesizer)
        {
            _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
            
        }
        _maxCheckId = 0;
        _lastSoundID = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"语音播报";
    [self createCustomNavBar];
    [self createTableView];
    [self createVoiceSpeechView];
    [self setupRefresh];
    [_tableView.header beginRefreshing];
    [self registerNotification];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

-(void)dealloc
{
    [self unregisterNotification];
}

#pragma mark - UI视图创建

-(void)createTableView
{
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = cellHight;
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).with.offset(self.customNavigationView.maxY);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).with.offset(-voiceBarHight);
    }];

}

- (void)createVoiceSpeechView
{
    UIView *voiceBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height_ - voiceBarHight, self.view.width_, voiceBarHight)];
    voiceBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:voiceBgView];
    //添加分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, voiceBgView.width_, 1)];
    lineView.backgroundColor = kColorLine;
    [voiceBgView addSubview:lineView];
    //添加Gif视图
    _animatedImageView = [[FLAnimatedImageView alloc] init];
    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        _animatedImageView.frame = CGRectMake(0, 0, 356, 48);
    }else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        _animatedImageView.frame = CGRectMake(0, 0, 384, 52);
    }else{
        _animatedImageView.frame = CGRectMake(0, 0, 310, 42);
    }
    _animatedImageView.center = CGPointMake(voiceBgView.centerX, 35);
//    _animatedImageView.contentMode = UIViewContentModeScaleAspectFill;
    _animatedImageView.clipsToBounds = YES;
    [voiceBgView addSubview:_animatedImageView];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"voiceSpeech" withExtension:@"gif"];
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"voiceSpeech" ofType:@"gif"];
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:dataPath]];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    self.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    //添加按钮
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.frame = CGRectMake(0, 0, 36, 66);
    voiceBtn.center = CGPointMake(voiceBgView.centerX, 35);
    voiceBtn.adjustsImageWhenHighlighted = NO;
    [voiceBtn setImage:[UIImage imageNamed:@"voiceOff"] forState:UIControlStateNormal];
    [voiceBtn setImage:[UIImage imageNamed:@"voiceOn"] forState:UIControlStateSelected];
    [voiceBtn addTarget:self action:@selector(onVoiceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [voiceBgView addSubview:voiceBtn];
    @weakify(self);
    //判断是否已开启语音
    if ([TXSystemManager sharedManager].isCheckInVoiceSpeaking) {
        @strongify(self);
        [self onVoiceButtonTapped:voiceBtn];
    }
}
#pragma mark - 按钮点击方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)onVoiceButtonTapped:(UIButton *)btn
{
    [btn setSelected:!btn.isSelected];
    if(btn.isSelected)
    {
//        [self speakVoice:@"开启语音播报 "];
        [self playNewMessageSound:@"start"];
    }
    else
    {
//        [self speakVoice:@"关闭语音播报 "];
        [self playNewMessageSound:@"off"];
    }
    
    _animatedImageView.animatedImage = btn.isSelected ? self.animatedImage : nil;
    //设置全局标示符
    _voiceSpeakChoice = btn.isSelected;
    [self updateMaxId];

}




#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = kColorClear;
        cell.backgroundColor = kColorClear;
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, tableView.width_ - 16, 121)];
        bgView.userInteractionEnabled = YES;
        bgView.tag = kCellContentViewBaseTag;
        [cell.contentView addSubview:bgView];
        
        UIButton *portraitImgView = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 90, 68)];
        portraitImgView.tag = kCellContentViewPortrait;
        [cell.contentView addSubview:portraitImgView];
        
        for (int i = 0; i < 7; ++i) {
            UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            label.font = kFontSmall;
            label.textAlignment= NSTextAlignmentLeft;
            label.tag = kCellContentViewBaseTag + 1 + i;
            [cell.contentView addSubview:label];
        }
    }
    
    if(indexPath.row >= [_listArray count])
    {
        return cell;
    }
    
    TXCheckIn *checkin = _listArray[indexPath.row];
    
    //头像
    UIButton *portraitImgView = (UIButton *)[cell.contentView viewWithTag:kCellContentViewPortrait];
    UIImage *image = [UIImage imageNamed:@"checkinDefaultImage"];
    @weakify(self);
    if (checkin.attaches.count) {
        [portraitImgView TX_setImageWithURL:[NSURL URLWithString:[checkin.attaches[0] getFormatPhotoUrl:90 hight:68]] forState:UIControlStateNormal placeholderImage:image];
        [portraitImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            @strongify(self);
            [self showPhotoView:@[checkin.attaches[0]] andIndex:0];
        }];
    }else{
        [portraitImgView setImage:image forState:UIControlStateNormal];
    }
    
    
    UIImageView *bgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:checkin.checkInTime/1000];
    CGFloat height = 68/4;
    CGFloat Y = portraitImgView.minY;
    for (int i = 0; i < 4; ++i) {
        int tag = kCellContentViewBaseTag + 1 + i;
        UILabel *label = (UILabel *)[cell.contentView viewWithTag: tag];
        NSString *str = nil;
        switch (tag) {
            case kCellContentViewTime:
                str = [NSDate timeForGuradianStyle:[NSString stringWithFormat:@"%@",@(checkin.checkInTime/1000)]];
                break;
            case kCellContentViewWeek:
                str = [self weekDayToString:[date weekday]];
                break;
            case kCellContentViewHour:
                str = [NSDate detailTimeForGuradianStyle:[NSString stringWithFormat:@"%@",@(checkin.checkInTime/1000)]];
                break;
            case kCellContentViewSwipe:
                str = checkin.username;
                break;
            default:
                break;
        }
        label.text = str;
        label.frame = CGRectMake(12 + portraitImgView.maxX, Y, bgView.width_ - 24 - portraitImgView.width_, height);
        Y = label.maxY;
        label.textColor = [self isNewCheckIn:checkin.checkInId]?kColorWhite:kColorGray;
    }
    
    for (int i = 4; i < 6; ++i) {
        int tag = kCellContentViewBaseTag + 1 + i;
        UILabel *label = (UILabel *)[cell.contentView viewWithTag: tag];
        label.textColor = kColorGray;
        NSString *str = nil;
        switch (tag) {
            case kCellContentViewCode:
                str = [NSString stringWithFormat:@"卡号：%@",checkin.cardCode];
                break;
            case kCellContentViewClass:
                str = [NSString stringWithFormat:@"班级：%@",checkin.className];
                break;
            default:
                break;
        }
        if(!str )
        {
            continue;
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedString addAttribute:NSForegroundColorAttributeName value:kColorGray2 range:NSMakeRange(0, 3)];
        label.attributedText = attributedString;
        [label sizeToFit];
        CGFloat offsetY = 30;
        if ([date isToday]) {
            offsetY = 34;
        }
        if (i == 4) {
            label.frame = CGRectMake(portraitImgView.minX, bgView.height_ - offsetY, label.width_, 30);
        }else{
            label.frame = CGRectMake(bgView.width_ - 12 - label.width_, bgView.height_ - offsetY, label.width_, 30);
        }
    }
    
    
    UIImage* stretchableImage = [[self isNewCheckIn:checkin.checkInId]?[UIImage imageNamed:@"guardian_new"]:[UIImage imageNamed:@"guardian_other"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 0, 68) resizingMode:UIImageResizingModeStretch];
    bgView.image = stretchableImage;
    
    
    return cell;
}

#pragma mark-  UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat height = 12.f;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, height)];
    view.backgroundColor = kColorBackground;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.f;
}


//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    _tableView.footer.backgroundColor = [UIColor clearColor];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    
}


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
	__weak __typeof(&*self) weakSelf=self;  //by sck
	dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchCheckInRereshing];
    });
}
- (void)footerRereshing{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf LoadLastPages];
    });
}


- (void)LoadLastPages
{
    TXCheckIn *checkin = (TXCheckIn *)_listArray.lastObject;
    if(!_listArray || !_listArray.count || !checkin)
    {
        [_tableView.footer endRefreshing];
        return ;
    }
    @weakify(self);
    [[TXChatClient sharedInstance].checkInManager fetchAttendance:checkin.checkInId onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
        @strongify(self);
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            NSMutableArray *newList = [NSMutableArray arrayWithArray:_listArray];
            [newList addObjectsFromArray:txCheckIns];
            @synchronized(_listArray)
            {
                _listArray = newList;
            }
            [_tableView.footer setHidden:!hasMore];
            
        }
        [_tableView.footer endRefreshing];
        [_tableView reloadData];
    }];
    

}



-(void)updateCheckInAfterFooterReresh:(NSArray *)medicines
{
    @synchronized(_listArray)
    {

    }
    [_tableView reloadData];
    
}


- (void)fetchCheckInRereshing{
    [self updateMaxId];
    @weakify(self);
    [[TXChatClient sharedInstance].checkInManager fetchAttendance:LLONG_MAX onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
        @strongify(self);
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            @synchronized(_listArray)
            {
                _listArray = [NSMutableArray arrayWithArray:txCheckIns];
            }
            [_tableView.footer setHidden:!hasMore];
        }
        [_tableView.header endRefreshing];
        [_tableView reloadData];
    }];
    
    
}

- (void)updateCheckInAfterHeaderRefresh:(NSArray *)medicines
{
    [_tableView reloadData];
}

#pragma mark-  private
- (NSString *)weekDayToString:(NSInteger)weekDay{
    switch (weekDay) {
        case 1:
            return @"星期日";
            break;
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
        default:
            break;
    }
    return nil;
}

//新语音通知
-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RcvNewCheckIn:) name:ReceiveNewCheckinVoiceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(soundPlayComplted:) name:KSoundPlayCompleted object:nil];
}



-(void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReceiveNewCheckinVoiceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KSoundPlayCompleted object:nil];
}


-(void)RcvNewCheckIn:(NSNotification *)notification
{
    if(!_tableView.header.isRefreshing && !_tableView.header.isRefreshing)
    {
        [_tableView.header beginRefreshing];
    }
    if(_voiceSpeakChoice && !_lastSoundID)
    {
//        [self speakVoice:@"有小朋友刷卡啦"];
        _lastSoundID = [self playNewMessageSound:@"new_msg"];
    }
}


-(void)soundPlayComplted:(NSNotification *)notification
{
    NSNumber *soundId = (NSNumber *)notification.object;
    if(soundId.unsignedIntegerValue == _lastSoundID)
    {
        _lastSoundID = 0;
    }

}


//speak

-(void)speakVoice:(NSString *)speakStr
{
    if(!_speechSynthesizer)
    {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];

    }
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:speakStr];
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voice;
    utterance.volume = 1.0f;
    utterance.rate = 0.55f;
    [_speechSynthesizer speakUtterance:utterance];

}


/**
 *  全屏展示图片
 *
 *  @param arr   图片Arr
 *  @param index 显示第几张
 */
- (void)showPhotoView:(NSArray *)arr andIndex:(int)index
{
    //    NSMutableArray *tmpArr = [NSMutableArray array];
    //    [arr enumerateObjectsUsingBlock:^(NSString *fileurl, NSUInteger idx, BOOL *stop) {
    //        [tmpArr addObject:fileurl];
    //    }];
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:arr currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}

/**
 *  判断 是不是 新啦刷卡消息
 *
 *  @param checkInId 当前checkin id
 *
 *  @return 是不是新拉消息
 */
-(BOOL)isNewCheckIn:(int64_t)checkInId
{
    
    if(_voiceSpeakChoice && checkInId > _maxCheckId)
    {
        return YES;
    }
    return NO;
}
/**
 *  更新 maxId
 */
-(void)updateMaxId
{
    if(_voiceSpeakChoice)
    {
        if(_listArray && _listArray.count)
        {
            TXCheckIn *checkIn = (TXCheckIn *)_listArray.firstObject;
            _maxCheckId = checkIn.checkInId;
        }
        else
        {
            _maxCheckId = 0;
        }
    }
    else
    {
        _maxCheckId = 0;
    }
}


// 播放接收到新消息时的声音
- (SystemSoundID)playNewMessageSound:(NSString *)soundName
{
    if(!soundName || soundName.length <= 0)
    {
        return 0;
    }
    // 要播放的音频文件地址
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mp3"];
    // 创建系统声音，同时返回一个ID
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:audioPath]), &soundID);
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(soundID,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          SystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(soundID);
    
    return soundID;
}
/**
 *  系统铃声播放完成后的回调
 */
void SystemSoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
    AudioServicesDisposeSystemSoundID(sound_id);
    [[NSNotificationCenter defaultCenter] postNotificationName:KSoundPlayCompleted object:@(sound_id)];
}


@end
