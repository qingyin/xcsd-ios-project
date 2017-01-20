//
//  UnifyHomeworkLevelController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/6/28.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "UnifyHomeworkLevelController.h"
#import "UnifyHomeworkSelectCell.h"

#define kBTN_HEIGHT 40
#define kCAN_SELECTCOUNT 5

@interface UnifyHomeworkLevelController ()<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *_tableView;
    UIButton *_confirmBtn;
}

@property (nonatomic, strong) NSMutableArray *selectedLevels;
@property (nonatomic, assign) NSInteger levels;
@property (nonatomic, assign) NSInteger remainingHomework;

@end

@implementation UnifyHomeworkLevelController

static NSString *ID = @"UnifyHomeworkLevelController";

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    self.titleStr = @"关卡选择";
    
    [self setupUI];
    
//    [self setupConfirmBtn];
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
    
    [self.btnRight setTitle:@"确认" forState:UIControlStateNormal];
}

- (void)setupUI{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, kScreenWidth, kScreenHeight - navHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 44;
}

- (void)setLevels:(NSInteger)levels AndSelectdLevels:(NSString *)selectedLevels remainingHomework:(NSInteger)remainingHomework{
    
    self.remainingHomework = remainingHomework;
    
    self.levels = levels;
    
    self.selectedLevels = [NSMutableArray arrayWithArray:[selectedLevels componentsSeparatedByString:@","]];
}

- (NSMutableArray *)selectedLevels{
    if (_selectedLevels == nil) {
        _selectedLevels = [NSMutableArray arrayWithCapacity:5];
    }
    return _selectedLevels;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
        if (self.selectedLevels.count <= 0) {
            self.getSelectedLevels(@"");
            return ;
        }
        
        [self.selectedLevels sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
            return str1.integerValue > str2.integerValue ? NSOrderedDescending : NSOrderedAscending;
        }];
        
        self.getSelectedLevels([self.selectedLevels.copy componentsJoinedByString:@","]);
    }
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.levels / 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return section == self.levels / 10 ? (self.levels % 10) : 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UnifyHomeworkSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UnifyHomeworkSelectCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    NSInteger number = indexPath.section * 10 + indexPath.row;
    
    cell.levelLbl.text = [NSString stringWithFormat:@"第%ld关",number + 1];

    if ([self.selectedLevels containsObject:[NSString stringWithFormat:@"%ld",number + 1]]) {
        cell.seletBtn.selected = YES;
    }else{
        cell.seletBtn.selected = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UnifyHomeworkSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL selectedOrNot = cell.seletBtn.isSelected;
    NSString *number = [NSString stringWithFormat:@"%ld",indexPath.section * 10 + indexPath.row + 1];

    if (selectedOrNot) {
        [self.selectedLevels removeObject:number];
        cell.seletBtn.selected = NO;
        return;
    }
    
    if (self.selectedLevels.count >= self.remainingHomework) {
        [self showFailedHudWithTitle:@"自主作业每天布置不能超过5关哦!"];
        return;
    }
    
    if ([self.selectedLevels containsObject:number]) {  return;   }
    [self.selectedLevels addObject:number];
    cell.seletBtn.selected = YES;
}

@end
