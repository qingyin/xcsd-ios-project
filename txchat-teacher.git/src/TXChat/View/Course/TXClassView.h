//
//  TXClassView.h
//  TXChatParent
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXClassView : UIView <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIButton *descrip;
@property (nonatomic,strong) UIButton *contents;
@property (nonatomic,strong) UIButton *assessment;
@property (nonatomic,strong) UIView *markView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UITableView *descripTB;
@property (nonatomic,strong) UITableView *contentsTB;
@property (nonatomic,strong) UITableView *assessmentTB;
@property (nonatomic) BOOL isReload;//简介 yes展开；no收起
@property (nonatomic) NSInteger starNum;//用户评价的星数
@property (nonatomic,strong) NSIndexPath *path;//记录上次点击的单元格的path
//数据源
@property (nonatomic,strong) NSArray *contentsArr;
@property (nonatomic,strong) NSMutableArray *assessmentArr;
@property (nonatomic,strong) TXPBCourse *course;

- (void)initHeaderView;
- (void)changeTextColorFor:(UITableView *)tableView andIndexpth:(NSIndexPath *)indexPath;


@end
