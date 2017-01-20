//
//  LeaveViewController.m
//  TXChatParent
//
//  Created by lyt on 15/11/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "LeaveViewController.h"
#import <UIImageView+Utils.h>
#import "CHSCharacterCountTextView.h"
#import <extobjc.h>
#import <NSDate+DateTools.h>
#import "NSDate+TuXing.h"
#import "CalendarHomeViewController.h"
#import "LeaveListViewController.h"

#define    KMaxLeaveNumber 200
#define KVIEWMARGIN (15.0f)

#define KLeaveTypeTag 0x1000
#define KLeaveDateTag 0x1000+1

@interface LeaveViewController ()<UITabBarDelegate, CHSCharacterCountTextViewDelegate>
{
    CHSCharacterCountTextView *_textView;//请假说明
    NSMutableArray *_selectedDate;
    UILabel *_selectedDateLabel;
    UILabel *_selectedCountLabel;
    UIView *_tabSelectedBtmView;
    NSMutableArray *_holidays;
    TXPBLeaveType _leaveType;
    UILabel *_leaveTypeContentLabel;
}
@end

@implementation LeaveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedDate = [NSMutableArray arrayWithCapacity:1];
        _holidays = [NSMutableArray arrayWithCapacity:1];
        _leaveType = TXPBLeaveTypeUnp;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"请假";
    [self createCustomNavBar];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnRight setTitle:@"请假记录" forState:UIControlStateNormal];
    [self setupViews];
    [_selectedDate addObject:[NSDate date]];
    [self updateViews];
    [self requestHolidays];
}


-(void)setupViews
{
    UIView *leaveView = [[UIView alloc] init];
    leaveView.backgroundColor = kColorWhite;
    [self.view addSubview:leaveView];
    CGFloat margin = KVIEWMARGIN;
    
    UIView *leaveTypeBg = [[UIView alloc] init];
    leaveTypeBg.tag = KLeaveTypeTag;
    //添加点击事件
    UITapGestureRecognizer* leaveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveViewTapEvent:)];
    leaveTap.numberOfTapsRequired = 1;
    leaveTap.numberOfTouchesRequired = 1;
    leaveTap.cancelsTouchesInView = NO;
    leaveTypeBg.userInteractionEnabled = YES;
    [leaveTypeBg addGestureRecognizer:leaveTap];
    [leaveView addSubview:leaveTypeBg];
    
    UIImageView *leaveTypeImgView = [[UIImageView alloc] init];
    UIImage *leaveTypeImg = [UIImage imageNamed:@"attendance_leaveType"];
    [leaveTypeImgView setImage:leaveTypeImg];
    [leaveTypeBg addSubview:leaveTypeImgView];
    [leaveTypeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(leaveTypeBg);
        make.size.mas_equalTo(leaveTypeImg.size);
    }];

    UILabel *leaveTypeTitle = [[UILabel alloc] init];
    leaveTypeTitle.text = @"请假类型";
    leaveTypeTitle.font = kFontSubTitle;
    leaveTypeTitle.textColor = KColorSubTitleTxt;
    [leaveTypeBg addSubview:leaveTypeTitle];
    [leaveTypeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leaveTypeImgView.mas_right).with.offset(14);
        make.centerY.mas_equalTo(leaveTypeBg);
    }];
    
    UILabel *leaveTypeContent = [[UILabel alloc] init];
    _leaveTypeContentLabel = leaveTypeContent;
    leaveTypeContent.text = (_leaveType == TXPBLeaveTypeSck)?@"病假":@"事假";
    leaveTypeContent.font = kFontSubTitle;
    leaveTypeContent.textColor = KColorSubTitleTxt;
    leaveTypeContent.textAlignment = NSTextAlignmentRight;
    [leaveTypeBg addSubview:leaveTypeContent];

    
    UIImageView *leaveTypeRightArrow = [[UIImageView alloc] init];
    UIImage *leaveTypeRightArrowImg = [UIImage imageNamed:@"attendance_rightNormal"];
    [leaveTypeRightArrow setImage:leaveTypeRightArrowImg];
    [leaveTypeBg addSubview:leaveTypeRightArrow];
    
    [leaveTypeContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(leaveTypeRightArrow.mas_left).with.offset(-15);
        make.centerY.mas_equalTo(leaveTypeBg);
        make.width.mas_equalTo(160);
    }];
    
    [leaveTypeRightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(leaveTypeBg);
    }];
    
    
    UIView *beginLine = [[UIView alloc] init];
    beginLine.backgroundColor = kColorLine;
    [leaveView addSubview:beginLine];
    [beginLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(leaveView);
        make.left.mas_equalTo(@(margin));
        make.right.mas_equalTo(leaveView);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(leaveTypeBg.mas_bottom);
    }];
    
    [leaveTypeBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(leaveView);
        make.height.mas_equalTo(50);
    }];
    
    UIView *requestTime = [[UIView alloc] init];
    requestTime.tag = KLeaveDateTag;
    requestTime.backgroundColor = [UIColor clearColor];
    [leaveView addSubview:requestTime];
    //添加点击事件
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveViewTapEvent:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;
    requestTime.userInteractionEnabled = YES;
    [requestTime addGestureRecognizer:tap];
    

    UIImageView *timeImgView = [[UIImageView alloc] init];
    UIImage *timeImage = [UIImage imageNamed:@"attendance_dateIcon"];
    [timeImgView setImage:timeImage];
    [requestTime addSubview:timeImgView];
    [timeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(margin));
        make.size.mas_equalTo(timeImage.size);
        make.centerY.mas_equalTo(requestTime);
    }];
    
    UILabel *requestTimeTitle = [[UILabel alloc] init];
    requestTimeTitle.text = @"请假时间";
    requestTimeTitle.font = kFontSubTitle;
    requestTimeTitle.textColor = KColorSubTitleTxt;
    [requestTime addSubview:requestTimeTitle];
    [requestTimeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeImgView.mas_right).with.offset(14);
        make.centerY.mas_equalTo(requestTime);
    }];
    
    UILabel *requestTimeContent = [[UILabel alloc] init];
    _selectedDateLabel = requestTimeContent;
    requestTimeContent.text = @"";
    requestTimeContent.font = kFontSubTitle;
    requestTimeContent.textColor = KColorSubTitleTxt;
    requestTimeContent.textAlignment = NSTextAlignmentRight;
    [requestTime addSubview:requestTimeContent];

    
    UIImageView *leaveTimeRightArrow = [[UIImageView alloc] init];
    UIImage *leaveTimeRightArrowImg = [UIImage imageNamed:@"attendance_rightNormal"];
    [leaveTimeRightArrow setImage:leaveTimeRightArrowImg];
    [requestTime addSubview:leaveTimeRightArrow];
    [leaveTimeRightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(requestTime);
    }];
    [requestTimeContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(leaveTypeRightArrow.mas_left).with.offset(-15);
        make.centerY.mas_equalTo(requestTime);
        make.width.mas_equalTo(160);
    }];
    
    
    UIView *midLine2 = [[UIView alloc] init];
    midLine2.backgroundColor = kColorLine;
    [requestTime addSubview:midLine2];
    [midLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(margin));
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(kLineHeight);
        make.bottom.mas_equalTo(requestTime);
    }];
    
    [requestTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(leaveView);
        make.height.mas_equalTo(51);
        make.top.mas_equalTo(beginLine.mas_bottom);
    }];
    
    UIView *requestCount = [[UIView alloc] init];
    requestCount.backgroundColor = kColorClear;
    [leaveView addSubview:requestCount];
    
    UIImageView *requestCountImageView = [[UIImageView alloc] init];
    UIImage *requestCountImage = [UIImage imageNamed:@"attendance_dateNumber"];
    [requestCountImageView setImage:requestCountImage];
    [requestCount addSubview:requestCountImageView];
    [requestCountImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(margin));
        make.size.mas_equalTo(requestCountImage.size);
        make.centerY.mas_equalTo(requestCount);
    }];
    
    UILabel *requestCountTitle = [[UILabel alloc] init];
    requestCountTitle.text = @"请假天数";
    requestCountTitle.font = kFontSubTitle;
    requestCountTitle.textColor = KColorSubTitleTxt;
    [requestCount addSubview:requestCountTitle];
    [requestCountTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(requestCountImageView.mas_right).with.offset(14);
        make.centerY.mas_equalTo(requestCount);
    }];
    
    UILabel *requestCountContent = [[UILabel alloc] init];
    _selectedCountLabel = requestCountContent;
    requestCountContent.text = @"7";
    requestCountContent.font = kFontSubTitle;
    requestCountContent.textColor = KColorSubTitleTxt;
    requestCountContent.textAlignment = NSTextAlignmentRight;
    [requestCount addSubview:requestCountContent];
    [requestCountContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-(30+leaveTimeRightArrowImg.size.width));
        make.centerY.mas_equalTo(requestCount);
        make.width.mas_equalTo(160);
    }];
    
    [requestCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(leaveView);
        make.height.mas_equalTo(51);
        make.top.mas_equalTo(requestTime.mas_bottom);
    }];
    
    UIView *midLine1 = [[UIView alloc] init];
    midLine1.backgroundColor = kColorLine;
    [leaveView addSubview:midLine1];
    [midLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(margin));
        make.right.mas_equalTo(leaveView);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(requestCount.mas_bottom).with.offset(-kLineHeight);
    }];
    
    
    _textView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:KMaxLeaveNumber placeHoder:@"输入请假原因...(非必填)"];
    _textView.layer.borderColor = [UIColor clearColor].CGColor;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.userInteractionEnabled = YES;
    _textView.delegate = self;
    [leaveView addSubview:_textView];
    

    
    UIView *endLine = [[UIView alloc] init];
    endLine.backgroundColor = kColorLine;
    [leaveView addSubview:endLine];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leaveView).with.offset(KVIEWMARGIN-5);
        make.top.mas_equalTo(midLine1.mas_bottom).with.offset(kLineHeight);
        make.right.mas_equalTo(leaveView).with.offset(-kEdgeInsetsLeft+5);
        make.height.mas_equalTo(@(150));
//        make.bottom.mas_equalTo(endLine.mas_top);
        
    }];
    [endLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(kLineHeight);
        make.bottom.mas_equalTo(_textView.mas_bottom).with.offset(kLineHeight);
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
    [self.view addSubview:leaveBtn];
    [leaveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).with.offset(-20);
        make.left.mas_equalTo(self.view.mas_left).with.offset(20);
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-30);
        make.height.mas_equalTo(40);
    }];
    [leaveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).with.offset(self.customNavigationView.maxY+10);
        make.right.and.left.mas_equalTo(self.view);
//        make.bottom.mas_equalTo(leaveBtn.mas_top).with.offset(-30);
        make.bottom.mas_equalTo(endLine.mas_bottom);
    }];
    
    
    @weakify(self);
    [leaveBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        [self requestForLeave];
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)updateViews
{
    _selectedCountLabel.text = [NSString stringWithFormat:@"%@天", @(_selectedDate.count)];
    NSMutableString *showDateStr = [NSMutableString stringWithCapacity:1];
    if(_selectedDate.count)
    {
        if(_selectedDate.count == 1)
        {
            NSDate *date = (NSDate *)_selectedDate.firstObject;
            [showDateStr appendFormat:@"%02ld-%02ld", (long)date.month, (long)date.day];
        }
        else if(_selectedDate.count >= 2)
        {
            NSDate *beginDate = (NSDate *)_selectedDate.firstObject;
            NSDate *endDate = (NSDate *)_selectedDate.lastObject;
            [showDateStr appendFormat:@"%02ld-%02ld 到 %02ld-%02ld", (long)beginDate.month, (long)beginDate.day, (long)endDate.month, (long)endDate.day];
        }
    }
    
    _leaveTypeContentLabel.text = (_leaveType == TXPBLeaveTypeSck)?@"病假":@"事假";
    _selectedDateLabel.text = showDateStr;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self showLeaveListVC:@(NO)];
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


#pragma mark - CHSCharacterCountTextViewDelegate
-(void)characterCountTextViewIsShowPlaceholder:(BOOL)isShowPlaceholder
{
//    if([_textView.getContent trim].length == 0)
//    {
//        _isInputMedicineContent = NO;
//    }
//    else
//    {
//        _isInputMedicineContent = !isShowPlaceholder;
//    }
    [self updateRightBtnStatus];
}

-(void)updateRightBtnStatus
{
}

#pragma mark-- private
-(void)requestForLeave
{
    @weakify(self);
    NSDate *currentDate = _selectedDate.firstObject;
    NSDate *endDate = _selectedDate.lastObject;
    TXUser *current = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSString *leaveReason = @"";
    NSString *tmpStr = [_textView.getContent trim];
    if([tmpStr length] > 0)
    {
        leaveReason = tmpStr;
    }
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance].checkInManager applyLeave:leaveReason beginDate:[currentDate dateToLongLong] endDate:[endDate dateToLongLong]leaveType:_leaveType userId:current.childUserId onCompleted:^(NSError *error) {
        @strongify(self);
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            [self showSuccessHudWithTitle:@"请假成功"];
            [self performSelector:@selector(showLeaveListVC:) withObject:@(YES) afterDelay:0.3f];
        }
    }];
}


-(void)selectLeaveDate
{
    CalendarHomeViewController *avc = [[CalendarHomeViewController alloc] init];
    avc.titleStr = @"请假时间";
    avc.holidays = _holidays;
    [avc setAirPlaneToDay:365 ToDateforString:nil];
    @weakify(self);
    avc.calendarblock = ^(NSArray *selectedArr){
        @strongify(self);
        NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:1];
        if(selectedArr && [selectedArr count])
        {
            [selectedArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CalendarDayModel *dayModel = (CalendarDayModel *)obj;
                [tmp addObject:dayModel.date];
            }];
        }
        @synchronized(_selectedDate)
        {
            _selectedDate = tmp;
        }
        [self updateViews];
    };
    [self.navigationController pushViewController:avc animated:YES];
}

-(void)leaveViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    if(!recognizer)
    {
        return ;
    }
    //去除键盘
    [_textView resignFirstResponder];
    if(recognizer.view.tag == KLeaveDateTag)
    {
        [self selectLeaveDate];
    }
    else if(recognizer.view.tag == KLeaveTypeTag)
    {
        @weakify(self);
        [self showNormalSheetWithTitle:nil items:@[@"事假", @"病假"] clickHandler:^(NSInteger index) {
            @strongify(self)
            if(index == 0)
            {
                _leaveType = TXPBLeaveTypeUnp;
            }
            else if(index == 1)
            {
                _leaveType = TXPBLeaveTypeSck;
            }
            [self updateViews];
        } completion:nil];
    }
}


-(void)showLeaveListVC:(NSNumber *)isRequestSuccess
{
    LeaveListViewController *leaveList = [[LeaveListViewController alloc] initWithLeaveResult:[isRequestSuccess boolValue]];
    [self.navigationController pushViewController:leaveList animated:YES];
    
}

-(void)requestHolidays
{
    NSDate *today = [NSDate date];
    [[TXChatClient sharedInstance].checkInManager fetchRestDaysWithYear:today.year onCompleted:^(NSError *error, NSArray *restDays) {
        if(error)
        {
        
        }
        else
        {
            @synchronized(_holidays)
            {
                [_holidays addObjectsFromArray:restDays];
            }
        }
    }];

    [[TXChatClient sharedInstance].checkInManager fetchRestDaysWithYear:today.year+1 onCompleted:^(NSError *error, NSArray *restDays) {
        if(error)
        {
            
        }
        else
        {
            @synchronized(_holidays)
            {
                [_holidays addObjectsFromArray:restDays];
            }
        }
    }];

}

#pragma mark--  hide keyboard
- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    //去除键盘
    [_textView resignFirstResponder];
}




@end
