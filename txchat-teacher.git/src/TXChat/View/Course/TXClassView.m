//
//  TXClassView.m
//  TXChatParent
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXClassView.h"
#import "CoursesTitleCell.h"
#import "CoursesDecripCell.h"
#import "CoursesTeacherCell.h"
#import "AssessCell.h"
#import "assessHeaderView.h"
#import "EditDetailViewController.h"
#import "STPopup.h"
#import "ContentsCell.h"
#import "BroadcastInfoViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "BroadcastVideoItem.h"


@implementation TXClassView

//初始化控件
- (void)initHeaderView
{
    self.descrip = [UIButton buttonWithType:UIButtonTypeCustom];
    self.contents = [UIButton buttonWithType:UIButtonTypeCustom];
    self.assessment = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.descrip.frame = CGRectMake(0, 0, self.frame.size.width/3, 40);
    self.descrip.tag = 100;
    self.descrip.titleLabel.font = kFontSubTitle;
    self.contents.frame = CGRectMake(self.frame.size.width/3, 1, self.frame.size.width/3, 40);
    self.contents.titleLabel.font = kFontSubTitle;
    self.contents.tag = 200;
    self.assessment.frame = CGRectMake(self.frame.size.width/3*2, 1, self.frame.size.width/3, 40);
    self.assessment.tag = 300;
    self.assessment.titleLabel.font = kFontSubTitle;
    
    [self.descrip setTitle:@"简介" forState:UIControlStateNormal];
    [self.contents setTitle:@"目录" forState:UIControlStateNormal];
    [self.assessment setTitle:@"评论" forState:UIControlStateNormal];
    
    [self.contents setTitleColor:KColorSelect forState:UIControlStateNormal];
    [self.descrip setTitleColor:kColorBtn forState:UIControlStateNormal];
    [self.assessment setTitleColor:kColorBtn forState:UIControlStateNormal];
    
    [self.descrip addTarget:self action:@selector(clickBtu:) forControlEvents:UIControlEventTouchUpInside];
    [self.contents addTarget:self action:@selector(clickBtu:) forControlEvents:UIControlEventTouchUpInside];
    [self.assessment addTarget:self action:@selector(clickBtu:) forControlEvents:UIControlEventTouchUpInside];
    
    //分割线
    UIView *footerLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.descrip.frame.size.height-0.5, self.frame.size.width*3, 0.5)];
    footerLine.backgroundColor = kColorLine;
    
    self.markView = [[UIView alloc]initWithFrame:CGRectMake(self.descrip.center.x-25*1.5/2, self.descrip.frame.size.height-2, 25*1.5, 2)];
    self.markView.backgroundColor = KColorSelect;
    
    [self addSubview:self.descrip];
    [self addSubview:self.contents];
    [self addSubview:self.assessment];
    [self addSubview:footerLine];
    [self addSubview:self.markView];
    
    [self initContentView];
}

- (void)initContentView
{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, self.frame.size.width, self.frame.size.height-40)];
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width*3, self.frame.size.height-40);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = kColorWhite;
    self.scrollView.delegate = self;
    
    self.descripTB = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-40) style:UITableViewStyleGrouped];
    self.descripTB.tag = 1000;
    self.descripTB.backgroundColor = kColorWhite;
    self.descripTB.delegate = self;
    self.descripTB.dataSource = self;
    self.descripTB.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentsTB = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height-40) style:UITableViewStyleGrouped];
    self.contentsTB.tag = 2000;
    self.contentsTB.backgroundColor = kColorWhite;
    self.contentsTB.delegate = self;
    self.contentsTB.dataSource = self;
    self.contentsTB.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.assessmentTB = [[UITableView alloc]initWithFrame:CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height-40) style:UITableViewStyleGrouped];
    self.assessmentTB.tag = 3000;
    self.assessmentTB.backgroundColor = kColorWhite;
    self.assessmentTB.delegate = self;
    self.assessmentTB.dataSource = self;
    self.assessmentTB.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.descripTB];
    [self.scrollView addSubview:self.contentsTB];
    [self.scrollView addSubview:self.assessmentTB];
    //添加观察者
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
    
    [self loadCellWithXIB];
}

- (void)loadCellWithXIB
{
    [self.descripTB registerClass:[CoursesTitleCell class] forCellReuseIdentifier:@"CoursesTitleCell"];
    [self.descripTB registerClass:[CoursesDecripCell class] forCellReuseIdentifier:@"CoursesDecripCell"];
    [self.descripTB registerClass:[CoursesTeacherCell class] forCellReuseIdentifier:@"CoursesTeacherCell"];
    [self.contentsTB registerClass:[ContentsCell class] forCellReuseIdentifier:@"contentsCell"];
    [self.assessmentTB registerClass:[AssessCell class] forCellReuseIdentifier:@"assessCell"];
}



//点击 简介  目录  评价
- (void)clickBtu:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentOffset = CGPointMake(0, 0);
            }];
            [self scrollViewDidEndDecelerating:self.scrollView];
        }
            break;
        case 200:
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
            }];
            [self scrollViewDidEndDecelerating:self.scrollView];
        }
            break;
        case 300:
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentOffset = CGPointMake(self.frame.size.width*2, 0);
            }];
            [self scrollViewDidEndDecelerating:self.scrollView];
        }
            break;
        default:
            break;
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGPoint point = CGPointFromString([NSString stringWithFormat:@"%@",change[@"new"]]);
    self.markView.frame = CGRectMake(point.x*self.descrip.frame.size.width/self.frame.size.width+self.descrip.center.x-25*1.5/2, self.descrip.frame.size.height-2, 25*1.5, 2);
}
#pragma mark -- UIScrolleViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x == 0) {
        [self.descrip setTitleColor:KColorSelect forState:UIControlStateNormal];
        [self.contents setTitleColor:kColorBtn forState:UIControlStateNormal];
        [self.assessment setTitleColor:kColorBtn forState:UIControlStateNormal];
    }else if (self.scrollView.contentOffset.x == kScreenWidth){
        [self.descrip setTitleColor:kColorBtn forState:UIControlStateNormal];
        [self.contents setTitleColor:KColorSelect forState:UIControlStateNormal];
        [self.assessment setTitleColor:kColorBtn forState:UIControlStateNormal];
    }else{
        [self.descrip setTitleColor:kColorBtn forState:UIControlStateNormal];
        [self.contents setTitleColor:kColorBtn forState:UIControlStateNormal];
        [self.assessment setTitleColor:KColorSelect forState:UIControlStateNormal];
    }
}

#pragma mark --tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1000) {
        return 3;
    }else if (tableView.tag == 2000){
        return self.contentsArr.count;
    }else{
        return self.assessmentArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag) {
        case 1000:
        {
            if (indexPath.row == 0) {
                CoursesTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoursesTitleCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setDateWithCourse:self.course];
                return cell;
            }else if (indexPath.row == 1){
                CoursesDecripCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoursesDecripCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setDateWithCourse:self.course andBool:self.isReload];
                [cell.MoreBtn addTarget:self action:@selector(clickMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }else{
                CoursesTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoursesTeacherCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setDateWithCourse:self.course];
                return cell;
            }
        }
            break;
        case 2000:
        {
            ContentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentsCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setDateWithItem:self.contentsArr[indexPath.row] andIndex:indexPath.row];
//            cell.lineView.hidden = (indexPath.row + 1 == self.contentsArr.count) ? YES : NO;
            return cell;
        }
            break;
        case 3000:
        {
            AssessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"assessCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell bindDateWithCourseComment:self.assessmentArr[indexPath.row]];
//            cell.lineView.hidden = (indexPath.row + 1 == self.assessmentArr.count) ? YES : NO;
            return cell;
        }
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2000) {
        
        [self tableView:tableView didDeselectRowAtIndexPath:self.path];
        //向服务器提交点击数
        BroadcastVideoItem *item = self.contentsArr[indexPath.row];
        [self addCountClickVideoByIndex:item.uid];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        BroadcastInfoViewController *vc = (BroadcastInfoViewController *)[self findViewController:self];
        [vc updateVideoAlbumData];
        [vc onMediaChangeWithIndex:indexPath.row];
        [self changeTextColorFor:tableView andIndexpth:indexPath];
        self.path = indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 2000) {
        ContentsCell *cell = (ContentsCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.titleLable.textColor = KColorTitleTxt;
        cell.lable1.textColor = KColorTitleTxt;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000) {
        if (indexPath.row == 0) {
            return [tableView fd_heightForCellWithIdentifier:@"CoursesTitleCell" cacheByIndexPath:indexPath configuration:^(CoursesTitleCell *cell) {
                [cell setDateWithCourse:self.course];
            }];
        }else if (indexPath.row == 1){
            return [tableView fd_heightForCellWithIdentifier:@"CoursesDecripCell" cacheByIndexPath:indexPath configuration:^(CoursesDecripCell *cell) {
                [cell setDateWithCourse:self.course andBool:self.isReload];
            }];
        }else{
            return [tableView fd_heightForCellWithIdentifier:@"CoursesTeacherCell" cacheByIndexPath:indexPath configuration:^(CoursesTeacherCell *cell) {
                [cell setDateWithCourse:self.course];
            }];
        }
    }else if (tableView.tag == 2000){
        return [tableView fd_heightForCellWithIdentifier:@"contentsCell" cacheByIndexPath:indexPath configuration:^(ContentsCell *cell) {
            [cell setDateWithItem:self.contentsArr[indexPath.row]andIndex:indexPath.row];
        }];
    }else{
        return [tableView fd_heightForCellWithIdentifier:@"assessCell" cacheByIndexPath:indexPath configuration:^(AssessCell *cell) {
            [cell bindDateWithCourseComment:self.assessmentArr[indexPath.row]];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 3000) {
        return 40+18+9+18+20+20;
    }else if (tableView.tag == 2000){
        if (self.contentsArr.count == 0) {
            return 0.001;
        }else{
            return 12;
        }
    }else{
        return 0.001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 3000) {
        assessHeaderView *headerView = [[NSBundle mainBundle]loadNibNamed:@"assessHeaderView" owner:nil options:nil][0];
        headerView.frame = CGRectMake(0, 0, kScreenWidth, 40+18+9+18+20+20);
        [headerView.editBtn addTarget:self action:@selector(clickEdit:) forControlEvents:UIControlEventTouchUpInside];
//        BroadcastInfoViewController *vc = (BroadcastInfoViewController *)[self findViewController:self];
        [headerView bindDateWithCourse:self.course andStarNum:self.starNum];
        return headerView;
    }else if (tableView.tag == 2000){
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
        headerView.backgroundColor = [UIColor whiteColor];
        return headerView;
    }else{
        return nil;
    }
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

//点击评价  编辑
- (void)clickEdit:(UIButton *)sender
{
    //暂停视频
    BroadcastInfoViewController *infoVC = (BroadcastInfoViewController *)[self findViewController:self];
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    
    if (player.playbackStatus == AUMediaPlaybackStatusPaused) {
        infoVC.hasPase = YES;
    }
    if (infoVC.resourceList.count>0 && infoVC.videoView.lable.hidden && self.starNum == 0 && player.playbackStatus == AUMediaPlaybackStatusPlaying) {
        [infoVC onPlayPauseButtonTapped];
    }
    //
    EditDetailViewController *editDetailVC = [[EditDetailViewController alloc]initWithLeave:nil];
    editDetailVC.course = self.course;
    __weak typeof(self) tmpObj = self;
    editDetailVC.editBtn = ^(BOOL isEnable,NSInteger num){
        if (isEnable) {
            tmpObj.starNum = num;
            //刷新评价列表
            [infoVC getDateAssessWithMaxid:LONG_MAX andIsUpRefresh:NO];
            //刷新简介列表
            [infoVC getDateDescrip];
        }
    };
    
    if (self.starNum == 0) {
        STPopupController *popVC = [[STPopupController alloc]initWithRootViewController:editDetailVC];
        popVC.cornerRadius = 4;
        popVC.navigationBarHidden = YES;
        popVC.transitionStyle = STPopupTransitionStyleFade;
        infoVC.hasEdit = YES;
        [popVC presentInViewController:[self findViewController:self]];
    }else{
        [infoVC showFailedHudWithTitle:@"你已评价过此课程"];
    }
}
//点击简介  更多
- (void)clickMoreBtn:(UIButton *)sender
{
    if (!self.isReload) {
        self.isReload = YES;
    }else{
        self.isReload = NO;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.descripTB reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
}
//移除观察者
- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)changeTextColorFor:(UITableView *)tableView andIndexpth:(NSIndexPath *)indexPath
{
    ContentsCell *cell = (ContentsCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.titleLable.textColor = KColorSelect;
    cell.lable1.textColor = KColorSelect;
}
//点击视频次数
- (void)addCountClickVideoByIndex:(NSString *)index
{
    [[TXChatClient sharedInstance].courseManager addPlayCourseLesson:[index integerValue] onCompleted:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

@end
