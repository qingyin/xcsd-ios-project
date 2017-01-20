//
//  LeaveDetailViewController.m
//  TXChatTeacher
//
//  Created by Cloud on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "LeaveDetailViewController.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "UIViewController+STPopup.h"
#import "STPopup.h"
#import "PlaceholderTextView.h"
#import "TXPBLeave+Util.h"
#import "LeavesListViewController.h"

@interface LeaveDetailViewController ()
{
    UIScrollView *_scrollView;
    PlaceholderTextView *_inputField;
}

@end

@implementation LeaveDetailViewController

- (id)initWithLeave:(TXPBLeave *)leave{
    self = [super init];
    if (self) {
        _leave = leave;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapBackgroundView) name:@"TapBackgroundView" object:nil];
        
        UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20 * kScale, 20 * kScale, 50, 50)];
        photoImgView.layer.cornerRadius = 8.0f/2.0f;
        photoImgView.layer.masksToBounds = YES;
        [self.view addSubview:photoImgView];
        [photoImgView TX_setImageWithURL:[NSURL URLWithString:_leave.userAvatar] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        
        UILabel *nameLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        nameLb.font = kFontMiddle_b;
        nameLb.textColor = kColorBlack;
        nameLb.text = _leave.applyUserName;
        [nameLb sizeToFit];
        [self.view addSubview:nameLb];
        nameLb.frame = CGRectMake(photoImgView.maxX + 9 * kScale, photoImgView.minY + 3 * kScale, nameLb.width_, nameLb.height_);
        
        UILabel *timeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        timeLb.font = kFontSmall;
        timeLb.textColor = kColorGray;
        timeLb.text = [NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(_leave.createdOn/1000)]];
        [timeLb sizeToFit];
        [self.view addSubview:timeLb];
        timeLb.frame = CGRectMake(nameLb.minX, photoImgView.maxY - 3 * kScale - timeLb.height_, timeLb.width_, timeLb.height_);
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_scrollView];
        
        UILabel *reasonTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        reasonTitleLb.font = kFontMiddle;
        reasonTitleLb.textColor = kColorBlack;
        reasonTitleLb.text = @"原因:";
        [reasonTitleLb sizeToFit];
        [_scrollView addSubview:reasonTitleLb];
        reasonTitleLb.frame = CGRectMake(0, 31 * kScale, reasonTitleLb.width_, reasonTitleLb.height_);
        reasonTitleLb.centerX = photoImgView.centerX;
        
        UILabel *reasonLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        reasonLb.font = kFontMiddle;
        reasonLb.numberOfLines = 0;
        reasonLb.textColor = kColorGray;
        reasonLb.text = _leave.reason;
        [_scrollView addSubview:reasonLb];
        CGSize reasonSize = [reasonLb sizeThatFits:CGSizeMake(kScreenWidth - 175 * kScale, MAXFLOAT)];
        reasonLb.frame = CGRectMake(reasonTitleLb.maxX + 20 * kScale, reasonTitleLb.minY, kScreenWidth - 175 * kScale, reasonSize.height);
        
        UILabel *numTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        numTitleLb.font = reasonTitleLb.font;
        numTitleLb.textColor = reasonTitleLb.textColor;
        numTitleLb.text = @"天数:";
        [_scrollView addSubview:numTitleLb];
        numTitleLb.frame = CGRectMake(reasonTitleLb.minX, MAX(reasonTitleLb.maxY, reasonLb.maxY) + 15 * kScale, reasonTitleLb.width_, reasonTitleLb.height_);
        
        UILabel *numLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        numLb.font = reasonLb.font;
        numLb.textColor = reasonLb.textColor;
        numLb.text = [NSString stringWithFormat:@"%0.1f天",_leave.days];
        [_scrollView addSubview:numLb];
        [numLb sizeToFit];
        numLb.frame = CGRectMake(reasonTitleLb.maxX + 20 * kScale, numTitleLb.minY, numLb.width_, numLb.height_);
        
        UILabel *dateTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        dateTitleLb.font = reasonTitleLb.font;
        dateTitleLb.textColor = reasonTitleLb.textColor;
        dateTitleLb.text = @"日期:";
        [_scrollView addSubview:dateTitleLb];
        dateTitleLb.frame = CGRectMake(reasonTitleLb.minX, numLb.maxY + 15 * kScale, reasonTitleLb.width_, reasonTitleLb.height_);
        
        UILabel *dateLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        dateLb.font = reasonLb.font;
        dateLb.numberOfLines = 0;
        dateLb.textColor = reasonLb.textColor;
        NSMutableString *datesStr = [NSMutableString stringWithCapacity:1];
        for(NSInteger i = 0; i < leave.dates.count; i++)
        {
            NSNumber *currentDateValue = (NSNumber *)(leave.dates[i]);
            NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:currentDateValue.longLongValue/1000];
            [datesStr appendFormat:@"%@月%@日",@(currentDate.month), @(currentDate.day)];
            if(i != leave.dates.count-1)
            {
                [datesStr appendFormat:@","];
            }
        }
        dateLb.text = [NSString stringWithFormat:@"%@",datesStr];
        [_scrollView addSubview:dateLb];
        [dateLb sizeToFit];
        CGSize dateLbSize = [dateLb sizeThatFits:CGSizeMake(kScreenWidth - 175 * kScale, MAXFLOAT)];
        dateLb.frame = CGRectMake(reasonLb.minX, dateTitleLb.minY, dateLbSize.width, dateLbSize.height);
        
        UILabel *statusTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        statusTitleLb.font = reasonTitleLb.font;
        statusTitleLb.textColor = reasonTitleLb.textColor;
        statusTitleLb.text = @"状态:";
        [_scrollView addSubview:statusTitleLb];
        statusTitleLb.frame = CGRectMake(reasonTitleLb.minX, dateLb.maxY + 15 * kScale, reasonTitleLb.width_, reasonTitleLb.height_);
        
        UILabel *statusLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        statusLb.font = reasonLb.font;
        statusLb.textColor = reasonLb.textColor;
        statusLb.text = [_leave.isCompleted boolValue]?@"已处理":@"待处理";
        [_scrollView addSubview:statusLb];
        [statusLb sizeToFit];
        statusLb.frame = CGRectMake(reasonLb.minX, statusTitleLb.minY, statusLb.width_, statusLb.height_);
        
        CGFloat Y = statusLb.maxY;
        if (_leave.reply.length) {
            UILabel *replyTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            replyTitleLb.font = reasonTitleLb.font;
            replyTitleLb.textColor = reasonTitleLb.textColor;
            replyTitleLb.text = @"备注:";
            [_scrollView addSubview:replyTitleLb];
            replyTitleLb.frame = CGRectMake(reasonTitleLb.minX, statusLb.maxY + 15 * kScale, statusTitleLb.width_, statusTitleLb.height_);
            
            UILabel *replyLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            replyLb.font = reasonLb.font;
            replyLb.numberOfLines = 0;
            replyLb.textColor = reasonLb.textColor;
            replyLb.text = _leave.reply;
            [_scrollView addSubview:replyLb];
            CGSize replySize = [replyLb sizeThatFits:CGSizeMake(kScreenWidth - 175 * kScale, MAXFLOAT)];
            replyLb.frame = CGRectMake(reasonLb.minX, replyTitleLb.minY, replySize.width, replySize.height);
            
            Y = replyLb.maxY;
        }

        __weak typeof(self)tmpObject = self;
        if (![_leave.isCompleted boolValue]) {
            UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(10 * kScale, Y + 16 * kScale, kScreenWidth - 80 * kScale, 60 * kScale)];
            inputView.layer.cornerRadius = 6.f;
            inputView.layer.masksToBounds = YES;
            inputView.backgroundColor = kColorBackground;
            inputView.layer.borderColor = kColorLine.CGColor;
            inputView.layer.borderWidth = kLineHeight;
            [_scrollView addSubview:inputView];
            
            PlaceholderTextView *textField = [[PlaceholderTextView alloc] initWithFrame:CGRectMake(8 * kScale, 8 * kScale, inputView.width_ - 16 * kScale, inputView.height_ - 16 * kScale)];
            _inputField = textField;
            textField.placeholderFont = kFontMiddle;
            textField.placeholder = @"审批意见（可不填）";
            textField.backgroundColor = kColorClear;
            textField.font = kFontMiddle;
            textField.textColor = kColorGray;
            [inputView addSubview:textField];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 5.f;
            btn.backgroundColor = KColorAppMain;
            btn.frame = CGRectMake(inputView.minX, inputView.maxY + 20 * kScale, inputView.width_, 40);
            btn.titleLabel.font = kFontMiddle;
            [btn setTitle:@"确认" forState:UIControlStateNormal];
            [_scrollView addSubview:btn];
            [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [tmpObject approveLeave:textField.text];
            }];
            
            if (btn.maxY + 30 * kScale + photoImgView.maxY > (kScreenHeight * 4/5)) {
                _scrollView.frame = CGRectMake(0, photoImgView.maxY, kScreenWidth - 60 * kScale, (kScreenHeight * 4/5) - photoImgView.maxY);
                _scrollView.contentSize = CGSizeMake(kScreenWidth - 60 * kScale, btn.maxY + 30 * kScale + photoImgView.maxY);
            }else{
                _scrollView.frame = CGRectMake(0, photoImgView.maxY, kScreenWidth - 60 * kScale, btn.maxY + 30 * kScale + photoImgView.maxY);
            }

            
        }else{
            if (Y + 30 * kScale + photoImgView.maxY > (kScreenHeight * 4/5)) {
                _scrollView.frame = CGRectMake(0, photoImgView.maxY, kScreenWidth - 60 * kScale, (kScreenHeight * 4/5) - photoImgView.maxY);
                _scrollView.contentSize = CGSizeMake(kScreenWidth - 60 * kScale, Y + 30 * kScale + photoImgView.maxY);
            }else{
                _scrollView.frame = CGRectMake(0, photoImgView.maxY, kScreenWidth - 60 * kScale, Y + 30 * kScale + photoImgView.maxY);
            }

        }
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(_scrollView.width_ - 48, 0, 48, 48);
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [closeBtn setImage:[UIImage imageNamed:@"gbicon"] forState:UIControlStateNormal];
        [self.view addSubview:closeBtn];
        [closeBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            [tmpObject.popupController dismiss];
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
        [tapGesture setNumberOfTapsRequired:1];
        [_scrollView addGestureRecognizer:tapGesture];
        self.contentSizeInPopup = CGSizeMake(kScreenWidth - 60 * kScale, _scrollView.height_);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)approveLeave:(NSString *)reason{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance].checkInManager approveLeave:_leave.id reply:reason onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }else{
            tmpObject.leave.isCompleted = [NSNumber numberWithBool:YES];
            [tmpObject.listVC.listTableView reloadData];
            [tmpObject.popupController dismiss];
        }
    }];
}


- (void)onTapBackgroundView{
    if ([_inputField isFirstResponder]) {
        [_inputField resignFirstResponder];
    }else{
        [self.popupController dismiss];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    //去除键盘
    [_inputField resignFirstResponder];
}

@end
