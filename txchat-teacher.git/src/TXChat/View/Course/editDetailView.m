//
//  editDetailView.m
//  TXChatParent
//
//  Created by frank on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "editDetailView.h"
#import "EditDetailViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopup.h"


@implementation editDetailView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *rightSwipe = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapStar:)];
    [self.swipView addGestureRecognizer:rightSwipe];
    self.starNum = 5;
}

- (void)tapStar:(UITapGestureRecognizer *)sender
{
    CGPoint tragedPoint = [sender locationInView:self.swipView];
    [self changeStar:tragedPoint];
}
//评价星数
- (IBAction)clickStarBtn:(UIButton *)sender {
    
    switch (sender.tag) {
        case 1:
            //显示1颗星
            [sender setBackgroundImage:[UIImage imageNamed:@"xl-star_10"] forState:UIControlStateNormal];
            for (int i = 2; i<=5; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_12"] forState:UIControlStateNormal];
            }
            self.starNum = 1;
            self.levelLable.text = @"较差";
            break;
        case 2:
            //显示2颗星
            for (int i = 1; i<=2; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_10"] forState:UIControlStateNormal];
            }
            for (int i = 3; i<=5; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_12"] forState:UIControlStateNormal];
            }
            self.starNum = 2;
            self.levelLable.text = @"一般";
            break;
        case 3:
            //显示3颗星
            for (int i = 1; i<=3; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_10"] forState:UIControlStateNormal];
            }
            for (int i = 4; i<=5; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_12"] forState:UIControlStateNormal];
            }
            self.starNum = 3;
            self.levelLable.text = @"良好";
            break;
        case 4:
            //显示4颗星
            for (int i = 1; i<=4; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_10"] forState:UIControlStateNormal];
            }
            for (int i = 5; i<=5; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_12"] forState:UIControlStateNormal];
            }
            self.starNum = 4;
            self.levelLable.text = @"推荐";
            break;
        case 5:
            //显示5颗星
            for (int i = 1; i<=5; i++) {
                UIButton *btn = (UIButton *)[self viewWithTag:i];
                [btn setBackgroundImage:[UIImage imageNamed:@"xl-star_10"] forState:UIControlStateNormal];
            }
            self.starNum = 5;
            self.levelLable.text = @"极佳";
            break;
        default:
            break;
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint tragedPoint = [touch locationInView:self.swipView];
    [self changeStar:tragedPoint];
}

- (void)changeStar:(CGPoint)point
{
    if (CGRectContainsPoint(self.button1.frame, point)){
        [self clickStarBtn:self.button1];
        NSLog(@"1");
        self.starNum = 1;
    }
    if(CGRectContainsPoint(self.button2.frame, point)){
        [self clickStarBtn:self.button2];
        NSLog(@"2");
        self.starNum = 2;
    }
    if (CGRectContainsPoint(self.button3.frame, point)){
        [self clickStarBtn:self.button3];
        NSLog(@"3");
        self.starNum = 3;
    }
    if (CGRectContainsPoint(self.button4.frame, point)){
        [self clickStarBtn:self.button4];
        NSLog(@"4");
        self.starNum = 4;
    }
    if (CGRectContainsPoint(self.button5.frame, point)){
        [self clickStarBtn:self.button5];
        NSLog(@"5");
        self.starNum = 5;
    }
}

//点击提交
- (IBAction)clickCommitBtn:(UIButton *)sender {
    //提交成功之后编辑界面消失，同时不可再编辑
    EditDetailViewController *editDetailVC = (EditDetailViewController *)[self findViewController:self];
    
    [[TXChatClient sharedInstance].courseManager postCourseCourseId:editDetailVC.course.id andScoreId:self.starNum andContent:self.textView.text onCompleted:^(NSError *error) {
        if (error) {
            [editDetailVC showFailedHudWithError:error];
        }else{
            [editDetailVC.popupController dismiss];
            editDetailVC.editBtn(YES,self.starNum);
        }
    }];
    
    [[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeLessonScore bid:[NSString stringWithFormat:@"%lld", editDetailVC.course.id] userId:[TXApplicationManager sharedInstance].currentUser.id extendedInfo:[NSString stringWithFormat:@"{\"score\" : %ld}", self.starNum]];
}

//获取视图所在的控制器
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target = sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

@end
