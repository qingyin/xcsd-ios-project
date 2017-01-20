//
//  GuardianDetailViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "GuardianDetailViewController.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
#import "NSDate+TuXing.h"
#import "UIButton+EMWebCache.h"
#import <UIImageView+Utils.h>
#import "TXPhotoBrowserViewController.h"

typedef enum : NSUInteger {
    RequestType_None = 0,
    RequestType_Header,
    RequestType_Footer,
} RequestType;

#define kCellContentViewPortrait            123131          //头像
#define kCellContentViewBaseTag             1000
#define kCellContentViewTime                1001            //时间
#define kCellContentViewWeek                1002            //星期
#define kCellContentViewHour                1003            //具体时间
#define kCellContentViewSwipe               1004            //刷卡人
#define kCellContentViewCode                1005            //卡号
#define kCellContentViewClass               1006            //班级


@interface GuardianDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isSetupRefresh;
}

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) UITableView *listTabelView;
@property (nonatomic, assign) RequestType type;

@end

@implementation GuardianDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"云卫士刷卡";
    [self createCustomNavBar];
    [self.btnRight setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    
    _listTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_ - 10) style:UITableViewStylePlain];
    _listTabelView.backgroundColor = kColorBackground;
    _listTabelView.delegate = self;
    _listTabelView.dataSource = self;
    _listTabelView.showsHorizontalScrollIndicator = NO;
    _listTabelView.showsVerticalScrollIndicator = YES;
    _listTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTabelView];
    
    [self addEmptyDataImage:NO showMessage:@"没有刷卡信息"];
    [self setupRefresh];
    
    [self getCheckins];

}

//集成刷新控件
- (void)setupRefresh
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    _listTabelView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _listTabelView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];}];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self isClearCheckIns];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)isClearCheckIns
{
    WEAKSELF
    [self showHighlightedSheetWithTitle:nil normalItems:nil highlightedItems:@[@"清空"] otherItems:nil clickHandler:^(NSInteger index) {
        if (index == 0) {
            [weakSelf clearCheckIns];
        }
    } completion:nil];
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"清空" otherButtonTitles:nil, nil];
//    [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//        if (!buttonIndex) {
//            [weakSelf clearCheckIns];
//        }
//    }];
}

//清空 刷卡
-(void)clearCheckIns
{
    int64_t checkInId = 0;
    if(_listArr && [_listArr count] > 0)
    {
        TXCheckIn *checkIn = (TXCheckIn *)_listArr.firstObject;
        if(checkIn)
        {
            checkInId = checkIn.checkInId;
        }
    }
    else
    {
        return ;
    }
    if(checkInId <= 0)
    {
        return;
    }
    WEAKSELF
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] clearCheckIn:checkInId onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(error)
        {
            [weakSelf showFailedHudWithError:error];
        }
        else
        {
            [weakSelf updateEmptyDataImageStatus:YES];
            _listArr = [NSMutableArray arrayWithCapacity:5];
            [_listTabelView reloadData];
        }
    }];
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


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    self.type = RequestType_Header;
    [self getNewCheckins];
}

- (void)footerRereshing{
    self.type = RequestType_Footer;
    [self getNewCheckins];
}

#pragma mark - 数据请求
//获取刷卡数据
-(void)getNewCheckins
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    TXCheckIn *checkIn = nil;
    if (_type == RequestType_Footer) {
        checkIn = [_listArr lastObject];
        if (!checkIn) {
            [_listTabelView.footer endRefreshing];
            return;
        }
    }
    [[TXChatClient sharedInstance] fetchCheckIns:_type == RequestType_Header?LLONG_MAX:checkIn.checkInId onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
        if (error) {
            [tmpObject showFailedHudWithError:error];
            [tmpObject.listTabelView.header endRefreshing];
            [tmpObject.listTabelView.footer endRefreshing];
            tmpObject.listTabelView.footer.hidden = YES;
            [tmpObject.listTabelView.footer noticeNoMoreData];
        }else{
            if (tmpObject.type == RequestType_Header) {
                tmpObject.listArr = [NSMutableArray arrayWithArray:txCheckIns];
                if (!txCheckIns || !txCheckIns.count) {
                    [tmpObject updateEmptyDataImageStatus:YES];
                }else{
                    [tmpObject updateEmptyDataImageStatus:NO];
                }
            }else{
                [tmpObject updateEmptyDataImageStatus:NO];
                [tmpObject.listArr addObjectsFromArray:txCheckIns];
            }
            [tmpObject.listTabelView reloadData];
            [tmpObject.listTabelView.header endRefreshing];
            [tmpObject.listTabelView.footer endRefreshing];
            if (!hasMore) {
                tmpObject.listTabelView.footer.hidden = YES;
                [tmpObject.listTabelView.footer noticeNoMoreData];
            }else{
                tmpObject.listTabelView.footer.hidden = NO;
                [tmpObject.listTabelView.footer resetNoMoreData];
            }
            if (!tmpObject.listArr.count) {
                [tmpObject updateEmptyDataImageStatus:YES];
            }else{
                [tmpObject updateEmptyDataImageStatus:NO];
            }
        }

        
    }];
}

//从数据库获取数据
- (void)getCheckins{
    NSError *error = nil;
    _listArr = [NSMutableArray arrayWithArray:[[TXChatClient sharedInstance] getCheckIns:LLONG_MAX count:20 error:&error]];
    if (_listArr.count < 20) {
        _listTabelView.footer.hidden = YES;
        [_listTabelView.footer noticeNoMoreData];
    }
    [_listTabelView reloadData];
    // Do any additional setup after loading the view.
    //刷卡
    NSDictionary *dict = [self countValueForType:TXClientCountType_Checkin];
    NSInteger countValue = [dict[TXClientCountNewValueKey] integerValue];
    if (countValue > 0 || [_listArr count] == 0) {
        self.type = RequestType_Header;
        [_listTabelView.header beginRefreshing];
    }
    [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_CHECK_IN];
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArr.count + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == _listArr.count) {
        if (_listArr.count * 142 < _listTabelView.height_) {
            return _listTabelView.height_ - _listArr.count * 142;
        }
        return 0;
    }
    return 121;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat height = section == _listArr.count?0:12.f;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, height)];
    view.backgroundColor = kColorBackground;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == _listArr.count) {
        return 0.f;
    }
    return 12.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == _listArr.count) {
        static NSString *Identifier = @"CellIdentifier1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = kColorClear;
            cell.backgroundColor = kColorClear;
        }
        return cell;
    }
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
        
        UIButton *portraitImgView = [UIButton buttonWithType:UIButtonTypeCustom];
        portraitImgView.frame = CGRectMake(15, 10, 90, 68);
        portraitImgView.tag = kCellContentViewPortrait;
        [cell.contentView addSubview:portraitImgView];
        
        for (int i = 0; i < 6; ++i) {
            UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            label.font = kFontSmall;
            label.textAlignment= NSTextAlignmentLeft;
            label.tag = kCellContentViewBaseTag + 1 + i;
            [cell.contentView addSubview:label];
        }
    }
    
    if(indexPath.section >= [_listArr count])
    {
        return cell;
    }
    
    TXCheckIn *checkin = _listArr[indexPath.section];
    
    //头像
    UIButton *portraitImgView = (UIButton *)[cell.contentView viewWithTag:kCellContentViewPortrait];
    UIImage *image = [UIImage imageNamed:@"checkinDefaultImage"];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [paths[0] stringByAppendingPathComponent:@"circle_defult_90x68.png"];
//    
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
//    if (!image) {
//        image = [UIImage imageNamed:@"circle_portrait"];
//        UIImage *colorImg = [UIImageView createImageWithColor:RGBCOLOR(200, 200, 200)];
//        image = [UIImageView originImage:image scaleToSize:CGSizeMake(70, 70)];
//        image = [UIImageView addImage:image toImage:colorImg andSize:CGSizeMake(90, 68)];
//        
//        [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
//    }
    if (checkin.attaches.count) {
        [portraitImgView TX_setImageWithURL:[NSURL URLWithString:[checkin.attaches[0] getFormatPhotoUrl:90 hight:68]] forState:UIControlStateNormal placeholderImage:image];
        
        [portraitImgView handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
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
                str = [self getWeekDay:date];
                break;
            case kCellContentViewHour:
                str = [NSDate detailTimeForGuradianStyle:[NSString stringWithFormat:@"%@",@(checkin.checkInTime/1000)]];
                break;
            case kCellContentViewSwipe:
                str = checkin.parentName;
                break;
            default:
                break;
        }
        label.text = str;
        label.frame = CGRectMake(12 + portraitImgView.maxX, Y, bgView.width_ - 24 - portraitImgView.width_, height);
        Y = label.maxY;
        label.textColor = [date isToday]?kColorWhite:kColorGray;
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
    
    
    UIImage* stretchableImage = [[date isToday]?[UIImage imageNamed:@"guardian_today"]:[UIImage imageNamed:@"guardian_other"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 0, 68) resizingMode:UIImageResizingModeStretch];
    bgView.image = stretchableImage;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (NSString *)getWeekDay:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = nil;
    NSInteger unitFlags =NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit |NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];
    
    switch (comps.weekday) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
