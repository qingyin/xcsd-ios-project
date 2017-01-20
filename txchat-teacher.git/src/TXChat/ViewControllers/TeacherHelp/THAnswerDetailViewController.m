//
//  THAnswerDetailViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/1.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THAnswerDetailViewController.h"
#import "THAnswerView.h"
#import "TXPhotoBrowserViewController.h"
#import "THAnswerCommentTableViewCell.h"
#import "TXMessageInputView.h"
#import "MLEmojiLabel.h"
#import <MJRefresh.h>
#import "NSObject+EXTParams.h"

@interface THAnswerDetailViewController ()
<UITableViewDelegate,
UITableViewDataSource,
THAnswerViewDelegate,
XHMessageInputViewDelegate,
UIGestureRecognizerDelegate>
{
    BOOL _isTopRefresh;
}
@property (nonatomic,strong) THAnswerView *descView;
@property (nonatomic,strong) UITableView *commentTableView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) TXMessageInputView *commentToolView;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,assign) int64_t replyUserId;

@end

@implementation THAnswerDetailViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isTopRefresh = YES;
    [self createCustomNavBar];
    [self setupCommentsListView];
    [self fetchDescriptionAndCommentsWithMaxId:LLONG_MAX];
    if (_showReplyViewImmediately) {
        //显示输入框
        [self onCommentButtonTapped];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //添加输入框组件
    if (![_commentToolView isDescendantOfView:self.view]) {
        [self.view addSubview:_commentToolView];
        [self.view bringSubviewToFront:_commentToolView];
    }
    // 设置关联的scrollView
    self.commentToolView.associatedScrollView = _commentTableView;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除输入框组件
    if ([_commentToolView isDescendantOfView:self.view]) {
        [_commentToolView removeFromSuperview];
    }
}
#pragma mark - UI视图创建
- (void)createCustomNavBar
{
    self.titleStr = _questionAnswer.questionTitle;
    self.umengEventText = @"教师帮问题回答详情界面";
    self.shouldLimitTitleLabelWidth = YES;
    [super createCustomNavBar];
}
//创建答案介绍视图
- (void)setupAnswerIntroView
{
    self.descView = [[THAnswerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 100)];
    self.descView.backgroundColor = [UIColor clearColor];
    self.descView.delegate = self;
    self.descView.answerDict = _questionAnswer;
    //重新设置frame
    CGRect descFrame = self.descView.frame;
    descFrame.size.height = self.descView.answerHeight;
    self.descView.frame = descFrame;
    //设置headerview
    self.commentTableView.tableHeaderView = self.descView;
}
//创建回答列表视图
- (void)setupCommentsListView
{
    self.commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY - 44) style:UITableViewStylePlain];
    self.commentTableView.backgroundColor = [UIColor clearColor];
    self.commentTableView.dataSource = self;
    self.commentTableView.delegate = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.commentTableView];
    //设置headerview和footerview
    [self setupAnswerIntroView];
    [self setupToolView];
    [self setupRefreshView];
    [self setupCommentToolBarView];
    //添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    tapGesture.delegate = self;
    [_commentTableView addGestureRecognizer:tapGesture];

}
//创建回复+赞视图
- (void)setupToolView
{
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.commentTableView.maxY, self.view.width_, 44)];
    toolView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolView];
    //获取最新的赞数量
    int64_t thankNum = 0;
    NSNumber *extNumber = [_questionAnswer extParamForKey:@"thankNum"];
    if (extNumber) {
        thankNum = [extNumber longLongValue];
    }else{
        thankNum = _questionAnswer.thankNum;
    }
    //添加赞
    BOOL isLike = NO;
    NSNumber *extLiked = [_questionAnswer extParamForKey:@"hasThanked"];
    if (extLiked) {
        isLike = [extLiked boolValue];
    }else{
        isLike = _questionAnswer.hasThanked;
    }
    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    likeButton.backgroundColor = [UIColor whiteColor];
    likeButton.frame = CGRectMake(0, 0, toolView.width_ / 2, 44);
    likeButton.titleLabel.font = kFontMiddle;
    [likeButton setTitleColor:RGBCOLOR(0x7a, 0x8b, 0x9b) forState:UIControlStateNormal];
    [likeButton setTitleColor:RGBCOLOR(0xff, 0x93, 0x3d) forState:UIControlStateSelected];
    [likeButton setTitle:[NSString stringWithFormat:@"赞(%@)",@(thankNum)] forState:UIControlStateNormal];
    [likeButton addTarget:self action:@selector(onLikeAnswerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:likeButton];
    if (isLike) {
        [likeButton setSelected:YES];
    }
    //添加回复
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.backgroundColor = [UIColor whiteColor];
    commentButton.frame = CGRectMake(toolView.width_ / 2, 0, toolView.width_ / 2, 44);
    commentButton.titleLabel.font = kFontMiddle;
    [commentButton setTitleColor:RGBCOLOR(0x7a, 0x8b, 0x9b) forState:UIControlStateNormal];
    [commentButton setTitle:@"回复" forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(onCommentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:commentButton];
    //添加竖分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(likeButton.maxX, 7, kLineHeight, 30)];
    lineView.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
    [toolView addSubview:lineView];
    //添加横分割线
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, toolView.width_, kLineHeight)];
    topLineView.backgroundColor = RGBCOLOR(0xdb, 0xdb, 0xdb);
    [toolView addSubview:topLineView];

}
//创建聊天工具栏视图
- (void)setupCommentToolBarView
{
    _commentToolView = [[TXMessageInputView alloc] initWithFrame:CGRectMake(0, self.view.height_, self.view.width_, kChatToolBarHeight)];
    _commentToolView.delegate = self;
    _commentToolView.associatedScrollView = _commentTableView;
    _commentToolView.contentViewController = self;
    _commentToolView.shouldShowInputViewWhenFinished = NO;
    [_commentToolView setupView];
    [self.view addSubview:_commentToolView];
    [self.view bringSubviewToFront:_commentToolView];
}
//加载效果
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
    self.commentTableView.header = gifHeader;
    self.commentTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *)self.commentTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TeacherHelpRefreshAnswerListNotification object:nil userInfo:@{@"answerId":@(_questionAnswer.id)}];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)onLikeAnswerButtonTapped:(UIButton *)btn
{
    BOOL isLike = NO;
    NSNumber *extLiked = [_questionAnswer extParamForKey:@"hasThanked"];
    if (extLiked) {
        isLike = [extLiked boolValue];
    }else{
        isLike = _questionAnswer.hasThanked;
    }
    if (isLike) {
        //已经喜欢过
        [self showFailedHudWithTitle:@"你已对此答案表示感谢"];
    }else{
        //赞
        [[TXChatClient sharedInstance].commentManager sendComment:nil commentType:TXPBCommentTypeLike toUserId:_questionAnswer.authorId targetId:_questionAnswer.id targetType:TXPBTargetTypeAnswer onCompleted:^(NSError *error, int64_t commentId) {
            if (error) {
                [self showFailedHudWithError:error];
            }else{
                [_questionAnswer setTXExtParams:@(YES) forKey:@"hasThanked"];
                int64_t thankNumber = _questionAnswer.thankNum;
                [_questionAnswer setTXExtParams:@(thankNumber + 1) forKey:@"thankNum"];
                [btn setTitle:[NSString stringWithFormat:@"赞(%@)",@(thankNumber + 1)] forState:UIControlStateNormal];
                [btn setSelected:YES];
                
                [self reportEvent:XCSDPBEventTypeLikeAnswer bid:[NSString stringWithFormat:@"%lld",self.questionAnswer.id]];
            }
        }];
    }
}
- (void)onCommentButtonTapped
{
    self.commentToolView.inputTextView.placeHolder = @"";
    self.replyUserId = 0;
    [self.commentToolView.inputTextView becomeFirstResponder];
}
#pragma mark - THQuestionViewDelegate methods
- (void)onAnswerPhotoTapped:(NSInteger)index
{
    NSArray *pics = _questionAnswer.attaches;
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:pics currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
    
}
#pragma mark - Public methods
//回复某人
- (void)replyCommentWithUserName:(NSString *)userName
                          userId:(int64_t)userId
                         comment:(TXComment *)comment
{
    if (userName && [userName length]) {
        TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
        if (currentUser.userId == userId) {
            self.commentToolView.inputTextView.placeHolder = @"回复自己";
        }else{
            self.commentToolView.inputTextView.placeHolder = [NSString stringWithFormat:@"回复%@",userName];
        }
        self.replyUserId = userId;
    }else{
        self.commentToolView.inputTextView.placeHolder = @"";
        self.replyUserId = 0;
    }
    [self.commentToolView.inputTextView becomeFirstResponder];
}
//删除某条评论
- (void)deleteCommentWithId:(int64_t)commentId
{
    WEAKSELF
    [self showAlertViewWithMessage:@"确认要删除吗?" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
        STRONGSELF
        if (strongSelf) {
            [strongSelf deleteAnswerReplyWithId:commentId];
        }
    }], nil];
}
#pragma mark - 数据获取+处理
//根据答案id获取介绍和评论列表
- (void)fetchDescriptionAndCommentsWithMaxId:(int64_t)maxId
{
    if (!_comments) {
        [self.view addSubview:self.loadingView];
        self.loadingView.center = self.view.center;
        [self.loadingView startAnimating];
    }
    [[TXChatClient sharedInstance].commentManager fetchCommentsByTargetId:_questionAnswer.id targetType:TXPBTargetTypeAnswer maxCommentId:maxId includeLikes:NO onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            if (_isTopRefresh) {
                self.comments = [NSMutableArray arrayWithArray:comments];
            }else{
                [self.comments addObjectsFromArray:comments];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_loadingView) {
                [self.loadingView stopAnimating];
                [self.loadingView removeFromSuperview];
                self.loadingView = nil;
            }
            if (_isTopRefresh) {
                [self.commentTableView.header endRefreshing];
            }else{
                [self.commentTableView.footer endRefreshing];
            }
            [_commentTableView reloadData];
            [_commentTableView.footer setHidden:!hasMore];
        });
    }];
}
//发送评论
- (void)sendAnswerComment:(NSString *)comment
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TXChatClient sharedInstance].commentManager sendComment:comment commentType:TXPBCommentTypeReply toUserId:self.replyUserId targetId:_questionAnswer.id targetType:TXPBTargetTypeAnswer onCompleted:^(NSError *error, int64_t commentId) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            [self headerRereshing];
            //修改回复数+1
            int64_t replyNumber = 0;
            NSNumber *extNumber = [_questionAnswer extParamForKey:@"replyNumber"];
            if (extNumber) {
                replyNumber = [extNumber intValue];
            }else{
                replyNumber = _questionAnswer.replyNum;
            }
            [_questionAnswer setTXExtParams:@(replyNumber + 1) forKey:@"replyNumber"];
            
            
            [self reportEvent:XCSDPBEventTypeCommentAnswer bid:[NSString stringWithFormat:@"%lld", self.questionAnswer.id]];
        }
    }];
}
//删除某条回复
- (void)deleteAnswerReplyWithId:(int64_t)commentId
{
    [[TXChatClient sharedInstance].commentManager deleteComment:commentId onCompleted:^(NSError *error) {
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            __block NSInteger deleteIndex = -1;
            @synchronized(self.comments) {
                [self.comments enumerateObjectsUsingBlock:^(TXComment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.commentId == commentId) {
                        //删除该条回答
                        deleteIndex = idx;
                        *stop = YES;
                    }
                }];
            }
            if (deleteIndex != -1) {
                //从tableview中移除
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
                @synchronized(_comments) {
                    if (deleteIndex < [_comments count]) {
                        [_comments removeObjectAtIndex:deleteIndex];
                    }
                }
                if ([[_commentTableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [_commentTableView beginUpdates];
                    [_commentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [_commentTableView endUpdates];
                }
                //修改回复数-1
                int64_t replyNumber = 0;
                NSNumber *extNumber = [_questionAnswer extParamForKey:@"replyNumber"];
                if (extNumber) {
                    replyNumber = [extNumber intValue];
                }else{
                    replyNumber = _questionAnswer.replyNum;
                }
                [_questionAnswer setTXExtParams:@(replyNumber - 1) forKey:@"replyNumber"];
            }
        }
    }];
}
#pragma mark - 上拉刷新下拉刷新
//下拉刷新
- (void)headerRereshing
{
    _isTopRefresh = YES;
    [self fetchDescriptionAndCommentsWithMaxId:LLONG_MAX];
}
//上拉加载
- (void)footerRereshing
{
    _isTopRefresh = NO;
    TXComment *comment = [_comments lastObject];
    [self fetchDescriptionAndCommentsWithMaxId:comment.commentId];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_comments count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXComment *commentDict = _comments[indexPath.row];
    return [THAnswerCommentTableViewCell heightForCellWithAnswerComment:commentDict cellWidth:tableView.width_];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    THAnswerCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[THAnswerCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify cellWidth:tableView.width_];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.answerVc = self;
    }
    TXComment *commentDict = _comments[indexPath.row];
    cell.answerComment = commentDict;
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - 手势代理+响应
- (void)onTapGesture:(UIGestureRecognizer *)gesture{
    [self.commentToolView endEdit];
}
//识别触摸时间，屏蔽点击btn等的事件
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[MLEmojiLabel class]] ||
       [touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    return YES;
}
#pragma mark - TXMessageEmotionViewDelegate methods
//发送表情
- (void)sendEmotionText:(NSString *)text
{
    if (text.length > 0) {
        self.commentToolView.inputTextView.text = @"";
        [self sendAnswerComment:text];
        [self.commentToolView endEdit];
    }
}
//发送文字
- (void)didSendTextAction:(NSString *)text {
    //判断是否是空消息
    NSString *trimString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimString length] == 0) {
        //Alert提醒不能输入空白消息
        [self showFailedHudWithTitle:@"不能发送空白消息"];
    }else{
        //清空已发送文本
        self.commentToolView.inputTextView.text = @"";
        [self sendAnswerComment:text];
        [self.commentToolView endEdit];
    }
}

//底部insets改变
- (void)onBottomInsetsChanged:(CGFloat)bottom
               isShowKeyboard:(BOOL)isShow
{
    [self setTableViewInsetsWithBottomValue:bottom];
    if (isShow)
        [self scrollToBottomAnimated:NO];
}

#pragma mark - Scroll Message TableView Helper Method
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {

}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.bottom = bottom;
    return insets;
}
- (void)scrollToBottomAnimated:(BOOL)animated {

}
#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentToolView associatedScrollViewWillBeginDragging];
}
@end
