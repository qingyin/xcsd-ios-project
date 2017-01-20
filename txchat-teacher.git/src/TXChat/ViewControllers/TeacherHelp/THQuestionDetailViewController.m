//
//  THQuestionDetailViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THQuestionDetailViewController.h"
#import "THQuestionView.h"
#import "THQuestionAnswerTableViewCell.h"
#import "TXPhotoBrowserViewController.h"
#import "THAnswerDetailViewController.h"
#import "THAskQuestionViewController.h"
#import <MJRefresh.h>
#import "NSObject+EXTParams.h"
#import "THSpecialistInfoViewController.h"

@interface THQuestionDetailViewController ()
<UITableViewDelegate,
UITableViewDataSource,
THQuestionViewDelegate>
{
    BOOL _isTopRefresh;
    BOOL _hasMore;
}
@property (nonatomic,strong) THQuestionView *descView;
@property (nonatomic,strong) UITableView *answerTableView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) TXPBQuestion *questionIntroduction; //问题介绍
@property (nonatomic,strong) NSMutableArray *specialistAnswers;  //专家回答
@property (nonatomic,strong) NSMutableArray *normalAnswers;      //网友回答
@property (nonatomic,strong) NSMutableArray *answerList;         //所有的回答列表

@end

@implementation THQuestionDetailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorBackground;
    self.titleStr = @"问题详情";
    _isTopRefresh = YES;
    //插入网友回答占位符
    self.answerList = [NSMutableArray arrayWithObject:@[[NSNull null]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveRefreshNewAnswerNotification:) name:TeacherHelpRefreshNewAnswerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveRefreshAnswerIdNotification:) name:TeacherHelpRefreshAnswerListNotification object:nil];
    [self createCustomNavBar];
    [self fetchDescriptionAndAnswersWithMaxId:LLONG_MAX];
}
#pragma mark - UI视图创建
//创建问题介绍视图
- (void)setupQuestionIntroView
{
    self.descView = [[THQuestionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 0)];
    self.descView.backgroundColor = [UIColor clearColor];
    self.descView.clipsToBounds = YES;
    self.descView.delegate = self;
    self.descView.questionDict = _questionIntroduction;
    //重新设置frame
    CGRect descFrame = self.descView.frame;
    descFrame.size.height = self.descView.questionHeight;
    self.descView.frame = descFrame;
    //设置headerview
    self.answerTableView.tableHeaderView = self.descView;
}
//创建回答列表视图
- (void)setupAnswerListView
{
    self.answerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY - 50) style:UITableViewStylePlain];
    self.answerTableView.backgroundColor = [UIColor clearColor];
    self.answerTableView.dataSource = self;
    self.answerTableView.delegate = self;
    self.answerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.answerTableView];
    //设置headerview和footerview
    [self setupQuestionIntroView];
    [self setupWantAnswerView];
    [self setupRefreshView];
}
//创建我要回答按钮视图
- (void)setupWantAnswerView
{
    UIButton *answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    answerButton.backgroundColor = [UIColor whiteColor];
    answerButton.frame = CGRectMake(0, self.answerTableView.maxY, self.view.width_, 50);
    answerButton.titleLabel.font = kFontMiddle;
    [answerButton setImage:[UIImage imageNamed:@"jsb-tw-a"] forState:UIControlStateNormal];
    [answerButton setImage:[UIImage imageNamed:@"jsb-tw-b"] forState:UIControlStateHighlighted];
    [answerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [answerButton setTitleColor:RGBCOLOR(0x7a, 0x8b, 0x9b) forState:UIControlStateNormal];
    [answerButton setTitle:@"我要回答" forState:UIControlStateNormal];
    [answerButton addTarget:self action:@selector(onWantAnswerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:answerButton];
}
- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingView;
}
//集成刷新控件
- (void)setupRefreshView
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    self.answerTableView.header = gifHeader;
    self.answerTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *)self.answerTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}
#pragma mark - 按钮点击响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//我要回答按钮
- (void)onWantAnswerButtonTapped:(UIButton *)btn
{
    THAskQuestionViewController *vc = [[THAskQuestionViewController alloc] init];
    vc.questionId = _pbQuestion.id;
    vc.isAddNewAnswer = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - THQuestionViewDelegate methods
- (void)onQuestionPhotoTapped:(NSInteger)index
{
    NSArray *pics = _questionIntroduction.attaches;
    NSMutableArray *photos = [NSMutableArray array];
    [pics enumerateObjectsUsingBlock:^(TXPBAttach *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.attachType == TXPBAttachTypePic) {
//            [photos addObject:obj.fileurl];
//        }
        [photos addObject:obj.fileurl];
    }];
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:photos currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];

}
#pragma mark - Public
//回复
- (void)replyAnswerWithComment:(TXPBQuestionAnswer *)answer
{
    THAnswerDetailViewController *answerVc = [[THAnswerDetailViewController alloc] init];
    answerVc.questionAnswer = answer;
    answerVc.showReplyViewImmediately = YES;
    [self.navigationController pushViewController:answerVc animated:YES];
}
//删除
- (void)deleteAnswerWithId:(int64_t)answerId
{
    WEAKSELF
    [self showAlertViewWithMessage:@"确认要删除吗?" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
        STRONGSELF
        if (strongSelf) {
            [strongSelf deleteQuestionAnswerWithId:answerId];
        }
    }], nil];
}
//赞
- (void)likeAnswerWithComment:(TXPBQuestionAnswer *)answer
{
    BOOL isLike = NO;
    NSNumber *extLiked = [answer extParamForKey:@"hasThanked"];
    if (extLiked) {
        isLike = [extLiked boolValue];
    }else{
        isLike = answer.hasThanked;
    }
    if (isLike) {
        //已经喜欢过
        [self showFailedHudWithTitle:@"你已对此答案表示感谢"];
    }else{
        [self likeQuestionAnswerWithId:answer.id];
    }
}
//点击头像
- (void)onAvtarTappedWithComment:(TXPBQuestionAnswer *)answer
{
    if (!answer) {
        return;
    }
    if (answer.userType == TXPBUserTypeExpert) {
        //进入专家详情界面
        THSpecialistInfoViewController *infoVc = [[THSpecialistInfoViewController alloc] init];
        infoVc.expertUserId = answer.authorId;
        [self.navigationController pushViewController:infoVc animated:YES];
    }
}
//根据id刷新数据
- (void)refreshAnswerListWithId:(int64_t)answerId
{
    __block BOOL isExpertLike = NO;
    __block NSInteger likeIndex = -1;
    //首先从专家回答中查找
    @synchronized(self.specialistAnswers) {
        [self.specialistAnswers enumerateObjectsUsingBlock:^(TXPBQuestionAnswer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.id == answerId) {
                //喜欢该条回答
                isExpertLike = YES;
                likeIndex = idx;
                *stop = YES;
            }
        }];
    }
    if (likeIndex == -1) {
        //尝试从网友回答中查找
        @synchronized(self.normalAnswers) {
            [self.normalAnswers enumerateObjectsUsingBlock:^(TXPBQuestionAnswer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.id == answerId) {
                    //喜欢该条回答
                    likeIndex = idx;
                    *stop = YES;
                }
            }];
        }
    }
    if (likeIndex != -1) {
        //刷新该列
        NSIndexPath *indexPath;
        if (isExpertLike) {
            indexPath = [NSIndexPath indexPathForRow:likeIndex inSection:0];
        }else{
            if (_specialistAnswers && [_specialistAnswers count]) {
                indexPath = [NSIndexPath indexPathForRow:likeIndex inSection:2];
            }else{
                indexPath = [NSIndexPath indexPathForRow:likeIndex inSection:1];
            }
        }
        if ([[_answerTableView indexPathsForVisibleRows] containsObject:indexPath]) {
            [_answerTableView beginUpdates];
            [_answerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [_answerTableView endUpdates];
        }
    }
}
#pragma mark - NSNotification通知处理
//重新加载最新的答案列表
- (void)onReceiveRefreshNewAnswerNotification:(NSNotification *)notification
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _isTopRefresh = YES;
    [self fetchDescriptionAndAnswersWithMaxId:LLONG_MAX];
    //修改回答数+1
    int64_t replyNumber = 0;
    NSNumber *extNumber = [_questionIntroduction extParamForKey:@"replyNumber"];
    if (extNumber) {
        replyNumber = [extNumber intValue];
    }else{
        replyNumber = _questionIntroduction.replyNum;
    }
    [_questionIntroduction setTXExtParams:@(replyNumber + 1) forKey:@"replyNumber"];
    [_pbQuestion setTXExtParams:@(replyNumber + 1) forKey:@"replyNumber"];
    [_descView setReplyNumber:replyNumber + 1];
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:TeacherHelpQuestionReplysChangedNotification object:nil userInfo:@{@"questionId":@(_pbQuestion.id)}];
}
//刷新某一个答案id的cell
- (void)onReceiveRefreshAnswerIdNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo && [[userInfo allKeys] containsObject:@"answerId"]) {
        int64_t answerId = [userInfo[@"answerId"] longLongValue];
        [self refreshAnswerListWithId:answerId];
    }
}
#pragma mark - 数据获取+处理
//根据问题id获取介绍和回答列表
- (void)fetchDescriptionAndAnswersWithMaxId:(int64_t)maxId
{
    //获取问题详情
    __block BOOL hasError = NO;
    dispatch_group_t fetchGroup = dispatch_group_create();
    if (!_questionIntroduction) {
        //添加记载效果
        [self.view addSubview:self.loadingView];
        self.loadingView.center = self.view.center;
        [self.loadingView startAnimating];
        //请求问题详情
        dispatch_group_enter(fetchGroup);
        [[TXChatClient sharedInstance].txJsbMansger fetchQuestionWithQuestionId:_pbQuestion.id onCompleted:^(NSError *error, TXPBQuestion *question) {
            if (error) {
                hasError = YES;
                [self showFailedHudWithError:error];
            }else{
                self.questionIntroduction = question;
            }
            dispatch_group_leave(fetchGroup);
        }];
    }
    //获取专家答案列表
    dispatch_group_enter(fetchGroup);
    [[TXChatClient sharedInstance].txJsbMansger fetchQuestionAnswersWithQuestionId:_pbQuestion.id authorId:0 userType:0 maxId:maxId onCompleted:^(NSError *error, NSArray *answers, BOOL hasMore, NSArray *expertAnswers, BOOL hasMoreExpertAnswers) {
        if (error) {
            hasError = YES;
            [self showFailedHudWithError:error];
        }else{
            if (expertAnswers && [expertAnswers count]) {
                if (!_specialistAnswers) {
                    self.specialistAnswers = [NSMutableArray arrayWithArray:expertAnswers];
                    [self.answerList insertObject:self.specialistAnswers atIndex:0];
                }else{
                    [self.specialistAnswers removeAllObjects];
                    [self.specialistAnswers addObjectsFromArray:expertAnswers];
                }
            }
            if (_isTopRefresh) {
                if (!_normalAnswers) {
                    self.normalAnswers = [NSMutableArray arrayWithArray:answers];
                    [self.answerList addObject:self.normalAnswers];
                }else{
                    [self.normalAnswers removeAllObjects];
                    [self.normalAnswers addObjectsFromArray:answers];
                }
            }else{
                [self.normalAnswers addObjectsFromArray:answers];
            }
            _hasMore = hasMore;
        }
        dispatch_group_leave(fetchGroup);
    }];
    //刷新列表
    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(), ^{
        //创建视图
        if (_loadingView) {
            [self.loadingView stopAnimating];
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
        }
        if (hasError) {
            //停止刷新
            if (_isTopRefresh) {
                [self.answerTableView.header endRefreshing];
            }else{
                [self.answerTableView.footer endRefreshing];
            }
        }else{
            if (!_answerTableView) {
                [self setupAnswerListView];
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                //停止刷新
                if (_isTopRefresh) {
                    [self.answerTableView.header endRefreshing];
                }else{
                    [self.answerTableView.footer endRefreshing];
                }
                [_answerTableView reloadData];
                [_answerTableView.footer setHidden:!_hasMore];
            }
        }
    });
}
//删除回答
- (void)deleteQuestionAnswerWithId:(int64_t)answerId
{
    //移除自己的回答
    [[TXChatClient sharedInstance].txJsbMansger deleteQuestionAnswerWithAnswerId:answerId onCompleted:^(NSError *error) {
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            __block NSInteger deleteIndex = -1;
            @synchronized(self.normalAnswers) {
                [self.normalAnswers enumerateObjectsUsingBlock:^(TXPBQuestionAnswer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.id == answerId) {
                        //删除该条回答
                        deleteIndex = idx;
                        *stop = YES;
                    }
                }];
            }
            if (deleteIndex != -1) {
                //从tableview中移除
                NSIndexPath *indexPath;
                if (_specialistAnswers && [_specialistAnswers count]) {
                    indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:2];
                }else{
                    indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:1];
                }
                @synchronized(_normalAnswers) {
                    if (deleteIndex < [_normalAnswers count]) {
                        [_normalAnswers removeObjectAtIndex:deleteIndex];
                    }
                }
                if ([[_answerTableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [_answerTableView beginUpdates];
                    [_answerTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    NSInteger tipIndex = 0;
                    if ([_specialistAnswers count] > 0) {
                        tipIndex = 1;
                    }
                    [_answerTableView reloadSections:[NSIndexSet indexSetWithIndex:tipIndex] withRowAnimation:UITableViewRowAnimationNone];
                    [_answerTableView endUpdates];
                }
                //修改回答数+1
                int64_t replyNumber = 0;
                NSNumber *extNumber = [_questionIntroduction extParamForKey:@"replyNumber"];
                if (extNumber) {
                    replyNumber = [extNumber intValue];
                }else{
                    replyNumber = _questionIntroduction.replyNum;
                }
                [_questionIntroduction setTXExtParams:@(replyNumber - 1) forKey:@"replyNumber"];
                [_pbQuestion setTXExtParams:@(replyNumber - 1) forKey:@"replyNumber"];
                [_descView setReplyNumber:replyNumber - 1];
                //发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:TeacherHelpQuestionReplysChangedNotification object:nil userInfo:@{@"questionId":@(_pbQuestion.id)}];
            }
        }
    }];
}
//喜欢回答
- (void)likeQuestionAnswerWithId:(int64_t)answerId
{
    [[TXChatClient sharedInstance].commentManager sendComment:nil commentType:TXPBCommentTypeLike toUserId:_pbQuestion.authorId targetId:answerId targetType:TXPBTargetTypeAnswer onCompleted:^(NSError *error, int64_t commentId) {
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            __block BOOL isExpertLike = NO;
            __block NSInteger likeIndex = -1;
            //首先从专家回答中查找
            @synchronized(self.specialistAnswers) {
                [self.specialistAnswers enumerateObjectsUsingBlock:^(TXPBQuestionAnswer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.id == answerId) {
                        //喜欢该条回答
                        isExpertLike = YES;
                        likeIndex = idx;
                        [obj setTXExtParams:@(YES) forKey:@"hasThanked"];
                        int64_t thankNumber = obj.thankNum;
                        [obj setTXExtParams:@(thankNumber + 1) forKey:@"thankNum"];
                        *stop = YES;
                    }
                }];
            }
            if (likeIndex == -1) {
                //尝试从网友回答中查找
                @synchronized(self.normalAnswers) {
                    [self.normalAnswers enumerateObjectsUsingBlock:^(TXPBQuestionAnswer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.id == answerId) {
                            //喜欢该条回答
                            likeIndex = idx;
                            [obj setTXExtParams:@(YES) forKey:@"hasThanked"];
                            int64_t thankNumber = obj.thankNum;
                            [obj setTXExtParams:@(thankNumber + 1) forKey:@"thankNum"];
                            *stop = YES;
                        }
                    }];
                }
            }
            if (likeIndex != -1) {
                //刷新该列
                NSIndexPath *indexPath;
                if (isExpertLike) {
                    indexPath = [NSIndexPath indexPathForRow:likeIndex inSection:0];
                }else{
                    if (_specialistAnswers && [_specialistAnswers count]) {
                        indexPath = [NSIndexPath indexPathForRow:likeIndex inSection:2];
                    }else{
                        indexPath = [NSIndexPath indexPathForRow:likeIndex inSection:1];
                    }
                }
                if ([[_answerTableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [_answerTableView beginUpdates];
                    [_answerTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [_answerTableView endUpdates];
                }
            }
            
            [self reportEvent:XCSDPBEventTypeLikeAnswer bid:[NSString stringWithFormat:@"%lld",answerId]];
        }
    }];
}
//获取index的answer数据
- (TXPBQuestionAnswer *)answerForQuestionWithIndexPath:(NSIndexPath *)indexPath
{
    TXPBQuestionAnswer *answerDict = self.answerList[indexPath.section][indexPath.row];
    return answerDict;
}
#pragma mark - 上拉刷新下拉刷新
//下拉刷新
- (void)headerRereshing
{
    _isTopRefresh = YES;
    [self fetchDescriptionAndAnswersWithMaxId:LLONG_MAX];
}
//上拉加载
- (void)footerRereshing
{
    _isTopRefresh = NO;
    TXPBQuestionAnswer *lastAnswer = [_normalAnswers lastObject];
    [self fetchDescriptionAndAnswersWithMaxId:lastAnswer.id];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.answerList count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *listArray = self.answerList[section];
    return [listArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listArray = self.answerList[indexPath.section];
    if ([listArray[indexPath.row] isKindOfClass:[NSNull class]]) {
        if (![_specialistAnswers count] && ![_normalAnswers count]) {
            return 60;
        }
        return 39;
    }
    TXPBQuestionAnswer *answerDict = [self answerForQuestionWithIndexPath:indexPath];
    return [THQuestionAnswerTableViewCell heightForCellWithQuestionAnswer:answerDict cellWidth:tableView.width_];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *headerCellIndentify = @"headerCell";
    NSArray *listArray = self.answerList[indexPath.section];
    if ([listArray[indexPath.row] isKindOfClass:[NSNull class]]) {
        //网友回答section
        UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:headerCellIndentify];
        if (!headerCell) {
            headerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellIndentify];
            headerCell.backgroundColor = [UIColor clearColor];
            headerCell.backgroundView = nil;
            headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            //添加header视图
            UIView *answerHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerCell.contentView.width_, 39)];
            answerHeader.backgroundColor = kColorClear;
            answerHeader.tag = 100;
            [headerCell.contentView addSubview:answerHeader];
            UIView *imgView = [[UIView alloc] initWithFrame:CGRectMake(13, 20, 2, 14)];
            imgView.backgroundColor = RGBCOLOR(0xff, 0x93, 0x3d);
            [answerHeader addSubview:imgView];
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 14)];
            tipLabel.backgroundColor = [UIColor clearColor];
            tipLabel.font = [UIFont systemFontOfSize:12];
            tipLabel.textColor = KColorTitleTxt;
            tipLabel.text = @"网友回答";
            [answerHeader addSubview:tipLabel];
            //添加没有回答的视图
            UIView *noAnswerHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerCell.contentView.width_, 60)];
            noAnswerHeader.backgroundColor = kColorClear;
            noAnswerHeader.tag = 150;
            [headerCell.contentView addSubview:noAnswerHeader];
            CGFloat startX = (tableView.width_ - 150) / 2;
            UIImageView *editImgView = [[UIImageView alloc] initWithFrame:CGRectMake(startX, 35, 23, 23)];
            editImgView.image = [UIImage imageNamed:@"noAnswerEditTip"];
            [noAnswerHeader addSubview:editImgView];
            UILabel *noAnswerTip = [[UILabel alloc] initWithFrame:CGRectMake(editImgView.maxX + 5, 35, 150, 23)];
            noAnswerTip.backgroundColor = [UIColor clearColor];
            noAnswerTip.font = [UIFont systemFontOfSize:15];
            noAnswerTip.textColor = RGBCOLOR(0xdd, 0xdd, 0xdd);
            noAnswerTip.text = @"稍后专家会为你解答";
            [noAnswerHeader addSubview:noAnswerTip];
        }
        UIView *normalTipLabel = [headerCell.contentView viewWithTag:100];
        UIView *noAnswerTipLabel = [headerCell.contentView viewWithTag:150];
        if (![_specialistAnswers count] && ![_normalAnswers count]) {
            normalTipLabel.hidden = YES;
            noAnswerTipLabel.hidden = NO;
        }else{
            if (![_normalAnswers count]) {
                normalTipLabel.hidden = YES;
            }else{
                normalTipLabel.hidden = NO;
            }
            noAnswerTipLabel.hidden = YES;
        }
        return headerCell;
    }
    static NSString *cellIndentify = @"cellIndentify";
    THQuestionAnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[THQuestionAnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify cellWidth:tableView.width_];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.detailVc = self;
    }
    TXPBQuestionAnswer *answerDict = [self answerForQuestionWithIndexPath:indexPath];
    cell.questionAnswer = answerDict;
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *listArray = self.answerList[indexPath.section];
    if ([listArray[indexPath.row] isKindOfClass:[NSNull class]]) {
        return;
    }
    //跳转到答案界面
    THAnswerDetailViewController *answerVc = [[THAnswerDetailViewController alloc] init];
    TXPBQuestionAnswer *answerDict = [self answerForQuestionWithIndexPath:indexPath];
    answerVc.questionAnswer = answerDict;
    [self.navigationController pushViewController:answerVc animated:YES];
}
@end
