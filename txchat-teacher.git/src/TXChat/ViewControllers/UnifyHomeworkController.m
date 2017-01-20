//
//  UnifyHomeworkController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/6/27.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "UnifyHomeworkController.h"
#import "UnifyHomeworkCell.h"
#import "XCSDGame.pb.h"
#import "UnifyHomeworkLevelController.h"
#import "UIColor+Hex.h"
#import "XCSDDataProto.pb.h"

@interface UnifyHomeworkController ()<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView *_tableView;
    UILabel *_titleLbl;
    UIButton *_confirmBtn;
    NSArray *_gameList;
    NSMutableDictionary *_selectedDict;
}

@end

@implementation UnifyHomeworkController

static NSString *ID = @"UnifyHomeworkController";

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self createCustomNavBar];
    
    self.titleStr = @" 布置自主作业";
    
    [self fetchRemainingHomeworks];
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [self fetchGameLists:^(NSError *error, NSArray *gameLevels) {
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            return ;
        }
        
        _gameList = gameLevels;
        [_tableView reloadData];
    }];
    
    _selectedDict = [NSMutableDictionary dictionary];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupLabel];
    
    [self setupTableView];
}

- (void)fetchGameLists:(void (^)(NSError *error, NSArray *gameLevels)) onCompleted{
    
    XCSDPBGameListRequestBuilder *requestBuilder = [XCSDPBGameListRequest builder];
    
    [[TXHttpClient sharedInstance] sendRequest:@"/game/list" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
        XCSDPBGameListResponse *gameResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(innerError);
        
        TX_PARSE_PB_OBJECT(XCSDPBGameListResponse, gameResponse);
        
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, gameResponse.gameList);
            });
        }
    }];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    
    [self.btnRight setTitle:@"发送" forState:UIControlStateNormal];
}

- (void)setupLabel{
    
    CGFloat navHeight = self.customNavigationView.height_;
    
    _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, navHeight, kScreenWidth, 42)];
    [self.view addSubview:_titleLbl];
    _titleLbl.text = @"自主作业全班内容相同，最多不超过五关";
    _titleLbl.textAlignment = NSTextAlignmentCenter;
    _titleLbl.numberOfLines = 0;
    _titleLbl.textColor = [UIColor colorWithHexRGB:@"919191"];
    _titleLbl.backgroundColor = [UIColor colorWithHexRGB:@"F7F7F7"];
    _titleLbl.font = [UIFont systemFontOfSize:15];
    
    UILabel *levelLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, _titleLbl.maxY, kScreenWidth, 33)];
    [self.view addSubview:levelLbl];
    levelLbl.font = [UIFont boldSystemFontOfSize:15];
    levelLbl.text = @"选择要布置的游戏及相应关卡";
    levelLbl.textColor = RGBCOLOR(72, 72, 72);
}

- (void)setupTableView{
    
    CGFloat labelH = 33.f;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _titleLbl.maxY + 33, kScreenWidth, kScreenHeight - _titleLbl.maxY - labelH) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 65;
}

- (void)setRemainingCount:(NSInteger)remainingCount{
    
    _remainingCount = remainingCount;
    
    NSArray *gameLevels = [self changeSelectedGamesIntoGameList];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger remainCount = _remainingCount - gameLevels.count;
    
    if (remainCount > 0) {
        
        [userDefaults setObject:@(_remainingCount - gameLevels.count) forKey:kLocalRemainingCount];
    }else{
        [userDefaults setObject:@(-1) forKey:kLocalRemainingCount];
    }
}

- (void)fetchRemainingHomeworks{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    _remainingCount = [[user objectForKey:kLocalRemainingCount] integerValue];
    
    // -1代表没有剩余的作业, 0代表本地没有缓存数据,先给一个默认的数据
    if (_remainingCount == 0) {
        _remainingCount = 5;
    }
    
    [[TXChatClient sharedInstance].homeWorkManager HomeworkRemainingCountClassId:self.class_Id onCompleted:^(NSError *error, BOOL customizedStatus, int32_t unifiedCount) {
        
        if (error) {
            return ;
        }
        
        [user setObject:@(_remainingCount) forKey:kLocalRemainingCount];
        _remainingCount = (NSInteger)unifiedCount;
    }];
}

- (NSArray *)changeSelectedGamesIntoGameList{
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    [_selectedDict enumerateKeysAndObjectsUsingBlock:^(NSNumber *idx, NSString *str, BOOL * _Nonnull stop) {
        
        NSArray *array = [str componentsSeparatedByString:@","];
        
        XCSDPBGameListResponseGame *game = _gameList[idx.integerValue];
        
        [array enumerateObjectsUsingBlock:^(NSString *num, NSUInteger idx, BOOL * _Nonnull stop) {
            
            XCSDPBGameLevelBuilder *gameLevelBuilder = [XCSDPBGameLevel builder];
            
            gameLevelBuilder.gameId = game.gameId;
            
            gameLevelBuilder.level = (SInt32)(num.integerValue);
            
            [tmpArr addObject:[gameLevelBuilder build]];
        }];
    }];
    
    return tmpArr.copy;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        NSArray *gameLevels = [self changeSelectedGamesIntoGameList];
        
        if (gameLevels.count == 0  || gameLevels == nil) {
            [self showFailedHudWithTitle:@"请选择游戏关卡"];
            return;
        }
        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    
        [[TXChatClient sharedInstance].homeWorkManager sendUnifiedHomework:self.class_Id gameLevels:gameLevels onCompleted:^(NSError *error) {
            
            [TXProgressHUD hideHUDForView:self.view animated:YES];
            
            if (error) {
                [self showFailedHudWithTitle:@"发送失败"];
            }
            [self showSuccessHudWithTitle:@"发送成功"];
            
            [self reportEvent:XCSDPBEventTypeUnifiedHomework bid:[NSString stringWithFormat:@"%ld",(long)self.class_Id]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:HomeWorkPostNotification object:nil];
            
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _gameList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UnifyHomeworkCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UnifyHomeworkCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    cell.setGame(_gameList[indexPath.row]);
    
    NSString *str = _selectedDict[@(indexPath.row)];
    if (str) {
        cell.setText(str).setCustomBackgroundColor();
    }else{
        cell.setText(@"无").clearCustomBackgroundColor();
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UnifyHomeworkCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL isOld = ![cell.getText() isEqual: @"无"];
    
    XCSDPBGameListResponseGame *game = _gameList[indexPath.row];
    UnifyHomeworkLevelController *levelVC = [[UnifyHomeworkLevelController alloc] init];
    [self.navigationController pushViewController:levelVC animated:YES];
    
    [levelVC setLevels:game.levelCount AndSelectdLevels:_selectedDict[@(indexPath.row)] remainingHomework: _remainingCount - [self getSelectedDictAllCount]];
    
    levelVC.getSelectedLevels = ^(NSString *levels){
      
        if (levels.length == 0) {
            [_selectedDict removeObjectForKey:@(indexPath.row)];
            
            [self exchangeCellWithindexPath:indexPath Index:_selectedDict.allValues.count];
            
            for (NSInteger i = indexPath.row; i < _selectedDict.allValues.count; i++) {
                
                _selectedDict[@(i)] = _selectedDict[@(i + 1)];
                
                if (i == _selectedDict.allValues.count - 1) {
                    [_selectedDict removeObjectForKey:@(i)];
                }
            }
            
            [self reloadSelectedCells];
            
            return ;
        }
        
        if (isOld) {
            _selectedDict[@(indexPath.row)] = levels;
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            return;
        }
        
        [self exchangeCellWithIndexPath:indexPath str:levels];
    };
}

- (void)exchangeCellWithIndexPath:(NSIndexPath *)indexPath str:(NSString *)str{

    NSInteger tmpIdx = 0;
    
    for (NSInteger i = 0; i <= indexPath.row; i++) {
        
        if (!_selectedDict[@(i)]) {
            _selectedDict[@(i)] = str;
            
            tmpIdx = i;
            break;
        }
    }
    [self exchangeCellWithindexPath:indexPath Index:tmpIdx];
}

- (void)exchangeCellWithindexPath:(NSIndexPath *)indexPath Index:(NSInteger)idx {
    
    NSMutableArray *gameList = [NSMutableArray arrayWithArray:_gameList];
    [gameList exchangeObjectAtIndex:idx withObjectAtIndex:indexPath.row];
    _gameList = gameList.copy;
    
    if (idx == 0) {
        [_tableView reloadData];
        return;
    }
    
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0],indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)reloadSelectedCells{
    NSMutableArray *tmpArr = [NSMutableArray array];
    for (NSInteger i = 0; i <= _selectedDict.allValues.count; i++) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:i inSection:0];
        [tmpArr addObject:idx];
    }
    [_tableView reloadRowsAtIndexPaths:tmpArr withRowAnimation:UITableViewRowAnimationFade];
}

- (NSInteger)getSelectedDictAllCount{
    
    NSInteger count = 0;
    
    for (NSString *str in _selectedDict.allValues) {
        count += ((str.length + 1) / 2);
    }
    return count;
}


@end
