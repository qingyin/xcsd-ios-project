//
//  ShutUpOperateViewController.m
//  ChildHoodStemp
//
//  Created by steven_l on 15/2/12.
//
//

#import "ShutUpOperateViewController.h"
//#import "UIUtil.h"
#import "MicroDef.h"
//#import "CHSNavigationBar.h"
//#import "CHContactService.h"
//#import "ChildHoodService.h"
#import "ShutUpItemView.h"
//#import "ISTThemeButton.h"
#import "AddShutUpViewController.h"
//#import "ChildHoodMemory.h"
#import "CHTapGesture.h"
#import "NoticeSelectMembersViewController.h"

static float kTopTitleLbHeight = 15.0f;
static float kLeftMargin = 10.0f;
static  float topMargin = 5;
static int numOfCols = 4;
static int kAddBtnTag = 10000;
static int kDeleteBtnTag = 10001;
static int kBackAlertTag = 1000;
static int kDealFinishAlertTag = 1001;
static float kScrollWhiteSpacing = 70;

@interface ShutUpOperateViewController ()<UIAlertViewDelegate>
{
//    CHContactService    *_contactService;
    BOOL _isAddFinish;
    BOOL _isDeleteFinsh;
}

@property (nonatomic, strong) UIScrollView *listScrollView;
@property (nonatomic, strong) NSMutableArray *hasBanViewArr;
@property (nonatomic, strong) NSMutableArray *hasBanDataArr;
@property (nonatomic, strong) NSMutableArray *willAddBanArr;
@property (nonatomic, strong) NSMutableArray *willDeleteBanArr;

@end

@implementation ShutUpOperateViewController

- (void)dealloc
{
    self.leftTitle = nil;
    self.listScrollView = nil;
    self.hasBanViewArr = nil;
    self.hasBanDataArr = nil;
    self.willAddBanArr = nil;
    self.willDeleteBanArr  =nil;
    self.listMemberArr = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDefaultDatas];
    [self initNavViews];
    [self initSubviews];
    // Do any additional setup after loading the view.
}
- (void)initDefaultDatas
{
    self.hasBanDataArr = [NSMutableArray array];
    self.hasBanViewArr = [NSMutableArray array];
    self.willDeleteBanArr = [NSMutableArray array];
    self.willAddBanArr = [NSMutableArray array];
    _isAddFinish = YES;
    _isDeleteFinsh = YES;
}
-(UIView*)getAViewWithSize:(CGSize)si backGroundColor:(UIColor*)color
{
    UIView* vifoot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, si.width, si.height)];
    [vifoot setBackgroundColor:color];
    return vifoot;
}
- (void)initNavViews
{
    UIView* vi = [self getAViewWithSize:CGSizeMake(HARDWARE_SCREEN_WIDTH, 30) backGroundColor:CommonColor];
    [vi setCenter:CGPointMake(HARDWARE_SCREEN_WIDTH/2, -15)];
    [self.view addSubview:vi];
    [self.view setBackgroundColor:CommonColor];
//    [self.navigationItem setHidesBackButton:YES];
//    [self.navigationItem setLeftItemWithTarget:self action:@selector(back:) image:@"back_bar_button.png" selectedImageName:@"back_bar_button_tapped.png" text:nil disabled:nil];
//    [self.navigationItem setNewTitle:_leftTitle];
//    
//    [self.navigationItem setRightItemWithTarget:self action:@selector(operateDone) image:@"sendgroup_normal.png" selectedImageName:nil text:@"完成"];
//    self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    self.titleStr = @"禁言设置";
    [self createCustomNavBar];
    [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnLeft addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)initSubviews
{
    UILabel *topTitleLb = [[UILabel alloc] initWithFrame:CGRectMake(kLeftMargin, 5+self.customNavigationView.maxY, HARDWARE_SCREEN_WIDTH, kTopTitleLbHeight)];
    topTitleLb.font = [UIFont systemFontOfSize:14.f];
    topTitleLb.backgroundColor = [UIColor whiteColor];
    topTitleLb.textColor = SpecialGrayColor;
    topTitleLb.text = @"禁言的家长将不能在班级中发消息";
    [self.view addSubview:topTitleLb];
    
    CHTapGesture* tap = [[CHTapGesture alloc] initWithTarget:self
                                                      action:@selector(endWobble)
                                                         tag:100];
    self.listScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topTitleLb.frame), HARDWARE_SCREEN_WIDTH, HARDWARE_SCREEN_HEIGHT - 64- CGRectGetHeight(topTitleLb.frame))];
    _listScrollView.backgroundColor = CommonColor;
    [_listScrollView addGestureRecognizer:tap];
    [self.view addSubview:_listScrollView];
    
//    [UIUtil addMBProgressViewTitle:@"正在加载" inView:self.view alpha:0.5];
//
//    _contactService = (CHContactService *)[[ChildHoodService defaultService] createContactService:self];
//    [_contactService getShutUpList:_deptId];
}

- (void)onGetShutUpListArr:(NSArray *)listArr
{
    self.hasBanDataArr = [NSMutableArray arrayWithArray:listArr];
    for (int i = 0; i < [_hasBanDataArr count]; i++) {
//        ChildHoodMemory *hood = _hasBanDataArr[i];
//        ShutUpItemView *item = [[ShutUpItemView alloc] initWithName:hood.name portraitURI:hood.profilePictureUri withIndex:i];
        ShutUpItemView *item = [[ShutUpItemView alloc] initWithName:@"名字" portraitURI:@"first_selected" withIndex:i];
        item.frame = CGRectMake(0, 0, Contact_MemberWidth, Contact_MemberHeight);
        item.block = ^(int index)
        {
            [self deleteItem:index];
        };
        [self.hasBanViewArr addObject:item];
    }
//    [UIUtil hideMBProgressViewForView:self.view];
    [self reloadScollSubviews];
}
- (void)reloadScollSubviews
{
    [_listScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    float itemAllWidth = Contact_MemberWidth + (HARDWARE_SCREEN_WIDTH -2*kLeftMargin- 4*Contact_MemberWidth)/(numOfCols -1);
    for (int i = 0; i < [_hasBanViewArr count]; i++) {
        ShutUpItemView *item = _hasBanViewArr[i];
        item.frame = CGRectMake(kLeftMargin+itemAllWidth*(i%numOfCols), topMargin+Contact_MemberHeight*(i/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
        item.index = i;
        [_listScrollView addSubview:item];
    }
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(kLeftMargin+itemAllWidth*(([_hasBanDataArr count])%numOfCols), topMargin+Contact_MemberHeight*([_hasBanDataArr count]/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
    [addBtn addTarget:self action:@selector(addBtnTap:) forControlEvents:UIControlEventTouchUpInside];
//    [addBtn setImageStr:@"shutUpAdd.png" forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"shutUpAdd"] forState:UIControlStateNormal];
    addBtn.tag = kAddBtnTag;
    [_listScrollView addSubview:addBtn];
    
    float contentHeight = CGRectGetMaxY(addBtn.frame);
    //如果服务器上有禁言人的话就有减号
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(kLeftMargin+itemAllWidth*(([_hasBanDataArr count]+1)%numOfCols), topMargin+Contact_MemberHeight*(([_hasBanDataArr count]+1)/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
//    [deleteBtn setImageStr:@"shutUpDelete.png" forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"shutUpDelete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.tag = kDeleteBtnTag;
    [_listScrollView addSubview:deleteBtn];
    if ([self.hasBanViewArr count] )
    {
        contentHeight = CGRectGetMaxY(deleteBtn.frame);
    }
    else
    {
        deleteBtn.hidden = YES;
    }
    _listScrollView.contentSize = CGSizeMake(CGRectGetWidth(_listScrollView.frame), contentHeight+kScrollWhiteSpacing);
}

#pragma mark - 点按操作
- (void)back:(id)sender
{
    if(_willAddBanArr.count >0 || _willDeleteBanArr.count > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认放弃修改？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alert.tag = kBackAlertTag;
        [alert show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)operateDone
{

    [self endWobble];
    
    //做删除 和 增加的操作
    if (_willDeleteBanArr.count || _willAddBanArr.count) {
//        [UIUtil addMBProgressViewTitle:@"正在处理中.." inView:self.view alpha:0.5];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有新的修改" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (_willAddBanArr.count) {
//        NSMutableArray *tempArr = [NSMutableArray array];
//        for(ChildHoodMemory *mem in _willAddBanArr)
//        {
//            [tempArr addObject:[NSNumber numberWithInt:mem.memoryId]];
//        }
        _isAddFinish = NO;
//        [_contactService userShutUpWithDeptId:_deptId withUsers:tempArr];
    }
    if (_willDeleteBanArr.count) {
//        NSMutableArray *tempArr = [NSMutableArray array];
//        for(ChildHoodMemory *mem in _willDeleteBanArr)
//        {
//            [tempArr addObject:[NSNumber numberWithInt:mem.memoryId]];
//        }
        _isDeleteFinsh = NO;
//        [_contactService userReleaseBanWithDeptId:_deptId withUsers:tempArr];
    }
    
}

- (void)deleteBtnTap:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        for (ShutUpItemView *item in _hasBanViewArr) {
            [item beginWobble];
        }
        //如果处于编辑状态 添加按钮是取消的
        UIButton *addBtn = (UIButton *)[_listScrollView viewWithTag:kAddBtnTag];
        addBtn.hidden = YES;
        UIButton *deleteBtn = (UIButton *)[_listScrollView viewWithTag:kDeleteBtnTag];
        deleteBtn.frame = addBtn.frame;

    }
    else
    {
        [self endWobble];
        
    }
}


- (void)addBtnTap:(UIButton *)btn
{
//    AddShutUpViewController *addVC = [[AddShutUpViewController alloc] initWithNibName:nil bundle:nil];
//    addVC.deptId = _deptId;
//    addVC.block = ^(NSArray *arr)
//    {
//        [self addPersons:arr];
//    };
//    addVC.hasBanArr = _hasBanDataArr;
//    addVC.listDataArr = _listMemberArr;
//    [self.navigationController pushViewController:addVC animated:YES];
        NoticeSelectMembersViewController *selectMembers = [[NoticeSelectMembersViewController alloc] init];
//        WEAKSELF
//        selectMembers.updateMemberSelected = ^(NSArray *userArray, NSString *groupName)
//        {
//            [weakSelf updateRightTitle:[userArray count]];
//        };
        [self.navigationController pushViewController:selectMembers animated:YES];
}

- (void)endWobble
{
    UIButton *deleteBtn = (UIButton *)[_listScrollView viewWithTag:kDeleteBtnTag];
    if (deleteBtn.selected) {
        deleteBtn.selected = NO;
        for (ShutUpItemView *item in _hasBanViewArr) {
            [item endWobble];
        }
        UIButton *addBtn = (UIButton *)[_listScrollView viewWithTag:kAddBtnTag];
        addBtn.hidden = NO;
        float itemAllWidth = Contact_MemberWidth + (HARDWARE_SCREEN_WIDTH -2*kLeftMargin- 4*Contact_MemberWidth)/(numOfCols -1);
        deleteBtn.frame = CGRectMake(kLeftMargin+itemAllWidth*(([_hasBanDataArr count]+1)%numOfCols), topMargin+Contact_MemberHeight*(([_hasBanDataArr count]+1)/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
    }
}

#pragma mark - 处理
- (void)deleteItem:(int)index
{
//    ChildHoodMemory *memory = [self.hasBanDataArr objectAtIndex:index];
//    [_hasBanDataArr removeObjectAtIndex:index];
     //如果是新添加的就直接删了即可
//    if ([_willAddBanArr containsObject:memory]) {
//        [_willAddBanArr removeObject:memory];
//    }
//    else
//    {
//        [_willDeleteBanArr addObject:memory];
//    }
    
    ShutUpItemView *view = [self.hasBanViewArr objectAtIndex:index];
    [self.hasBanViewArr removeObjectAtIndex:index];
    [view removeFromSuperview];
       //并且位置动画改变
    [UIView animateWithDuration:0.3 animations:^
     {
         [self removeItemFromScroll:index];
     } completion:^(BOOL finished)
     {
         [self dealTheRightBarItem];
     }];
    
}

- (void)removeItemFromScroll:(int)index
{
    float itemAllWidth = Contact_MemberWidth + (HARDWARE_SCREEN_WIDTH -2*kLeftMargin- 4*Contact_MemberWidth)/(numOfCols -1);
    for (int i = index; i < [_hasBanViewArr count]; i++) {
        ShutUpItemView *item = _hasBanViewArr[i];
        item.frame = CGRectMake(kLeftMargin+itemAllWidth*(i%numOfCols), topMargin+Contact_MemberHeight*(i/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
        item.index = i;
    }
    UIButton *addBtn = (UIButton *)[_listScrollView viewWithTag:kAddBtnTag];
    addBtn.frame = CGRectMake(kLeftMargin+itemAllWidth*(([_hasBanDataArr count])%numOfCols), topMargin+Contact_MemberHeight*([_hasBanDataArr count]/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
    
    float contentHeight = CGRectGetMaxY(addBtn.frame);
    
    UIButton *deleteBtn = (UIButton *)[_listScrollView viewWithTag:kDeleteBtnTag];
    //如果服务器上有禁言人的话就有减号
    if ([self.hasBanViewArr count] )
    {
        deleteBtn.frame = addBtn.frame;
        deleteBtn.hidden = NO;
        contentHeight = CGRectGetMaxY(deleteBtn.frame);
    }
    else
    {
        deleteBtn.hidden = YES;
        deleteBtn.selected = NO;
        addBtn.hidden = NO;
    }
    _listScrollView.contentSize = CGSizeMake(CGRectGetWidth(_listScrollView.frame), contentHeight+kScrollWhiteSpacing);
}

- (void)addPersons:(NSArray *)addArr
{
    if (!addArr.count) {
        return;
    }
//    for (int i = 0; i <addArr.count; i++) {
//        ChildHoodMemory *mem = addArr[i];
//        [self.hasBanDataArr addObject:mem];
//        [_willAddBanArr addObject:mem];
//    }
    for (int i = (int)(_hasBanDataArr.count - addArr.count); i < [_hasBanDataArr count]; i++) {
//        ChildHoodMemory *memory = _hasBanDataArr[i];
//        ShutUpItemView *item = [[ShutUpItemView alloc] initWithName:memory.name portraitURI:memory.profilePictureUri withIndex:i];
        ShutUpItemView *item = [[ShutUpItemView alloc] initWithName:@"name" portraitURI:@"first_selected" withIndex:i];
        item.frame = CGRectMake(0, 0, Contact_MemberWidth, Contact_MemberHeight);
        item.block = ^(int index)
        {
            [self deleteItem:index];
        };
        [self.hasBanViewArr addObject:item];
    }
    
    float itemAllWidth = Contact_MemberWidth + (HARDWARE_SCREEN_WIDTH -2*kLeftMargin- 4*Contact_MemberWidth)/(numOfCols -1);
    for (int i = (int)(_hasBanDataArr.count - addArr.count); i < [_hasBanViewArr count]; i++) {
        ShutUpItemView *item = _hasBanViewArr[i];
        item.frame = CGRectMake(kLeftMargin+itemAllWidth*(i%numOfCols), topMargin+Contact_MemberHeight*(i/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
        item.index = i;
        [_listScrollView addSubview:item];
    }
    UIButton *addBtn = (UIButton *)[_listScrollView viewWithTag:kAddBtnTag];
    addBtn.frame = CGRectMake(kLeftMargin+itemAllWidth*(([_hasBanDataArr count])%numOfCols), topMargin+Contact_MemberHeight*([_hasBanDataArr count]/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
    
    
    float contentHeight = CGRectGetMaxY(addBtn.frame);
    UIButton *deleteBtn = (UIButton *)[_listScrollView viewWithTag:kDeleteBtnTag];
    //如果服务器上有禁言人的话就有减号
    if ([self.hasBanViewArr count] )
    {
        deleteBtn.frame = CGRectMake(kLeftMargin+itemAllWidth*(([_hasBanDataArr count]+1)%numOfCols), topMargin+Contact_MemberHeight*(([_hasBanDataArr count]+1)/numOfCols), Contact_MemberWidth, Contact_MemberHeight);
        deleteBtn.hidden = NO;
        contentHeight = CGRectGetMaxY(deleteBtn.frame);
    }
    else
    {
        deleteBtn.hidden = YES;

    }
    _listScrollView.contentSize = CGSizeMake(CGRectGetWidth(_listScrollView.frame), contentHeight+kScrollWhiteSpacing);
    [self dealTheRightBarItem];
}

- (void)dealTheRightBarItem
{
    if (_willDeleteBanArr.count || _willAddBanArr.count) {
        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.customView.hidden = YES;
    }
}


#pragma mark - 操作完成
- (void)onBannedWithResult:(BOOL)result
{
    _isAddFinish = YES;
    if (result) {
        [_willAddBanArr removeAllObjects];
    }
    [self dealTheWaitting];
}
- (void)onReleaseBannedWithResult:(BOOL)result
{
    _isDeleteFinsh = YES;
    if (result) {
        [_willDeleteBanArr removeAllObjects];
    }
    [self dealTheWaitting];
}

- (void)dealTheWaitting
{
    if (_isDeleteFinsh && _isAddFinish) {
//        [UIUtil hideMBProgressViewForView:self.view];
    }
    else
    {
        return;
    }
    
    NSString *message = nil;
    if (_willDeleteBanArr.count || _willAddBanArr.count) {
        message = @"处理失败";
    }
    else
    {
        message = @"处理完成";
    }

//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//     if (!_willDeleteBanArr.count && !_willAddBanArr.count)
//     {
//         alert.tag = kDealFinishAlertTag;
//     }
//    [alert show];
    dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
             if (!_willDeleteBanArr.count && !_willAddBanArr.count)
             {
                 alert.tag = kDealFinishAlertTag;
             }
            [alert show];
                                  });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - uialert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kBackAlertTag)
    {
        if (buttonIndex == 0)
        {
            
        }
        else if (buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == kDealFinishAlertTag)
    {
        [self.navigationController popViewControllerAnimated:YES];
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

@end
