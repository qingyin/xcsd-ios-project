//
//  EditGuardianViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "EditGuardianViewController.h"

#define KTextFiledTagBase 0x1000
#define KEditButtonTagBase 0x5000
#define KCardCellTagBase 0x8000
#define KCELLHight      51.0f
#define KCellCount   3
#define KCardNumberLen 8
#define KHEADERVIEWHIGHT 80.0f

//cell的高度
#define KCELLHIGHT 50

@interface EditGuardianViewController ()<UITextFieldDelegate, UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIButton *_sureBtn;
    UIScrollView *_scrollView;
    UIView *_contentView;//滚动条内的view;
    UITableView *_tableView;
    NSMutableArray *_cardList;
    UITextField *_inputTextField;
    UIView *_bottomView;
    UIView *_headView;
    UILabel *_inputPromptLabel;
}

@property (nonatomic, strong) UIButton *btnCloseKeyboard;   // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度
@property (nonatomic, strong) UITextField *codeTextField;

@end

@implementation EditGuardianViewController

- (id)initWithDetailDic:(NSMutableArray *)detailDic{
    self = [super init];
    if (self) {
        _detailDic = detailDic;
        // 键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        _cardList = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"云卫士卡号";
    [self createCustomNavBar];
    [self createCardListByDic:_detailDic];
    [self initView];
    // Do any additional setup after loading the view.
    [self makeUpdateConstraints];
    [_tableView reloadData];
}

-(void)createCardListByDic:(NSArray *)dic
{
    for(NSDictionary *dicIndex in dic)
    {
        NSString * codeStr = dicIndex[@"code"];
        if(codeStr != nil && [codeStr length] == KCardNumberLen)
        {
            [_cardList addObject:codeStr];
        }
    }
}


- (void)initView{

    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    _contentView = contentView;
    _contentView.userInteractionEnabled = YES;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    
    UIView *headerView = [[UIView alloc] init];
    _headView = headerView;
    [contentView addSubview:headerView];
    
    UILabel *inputCardPromptLabel = [[UILabel alloc] init];
    inputCardPromptLabel.text = @"请输入卡号";
    inputCardPromptLabel.font = kFontSubTitle;
    inputCardPromptLabel.textColor = kColorGray1;
    [headerView addSubview:inputCardPromptLabel];
    _inputPromptLabel = inputCardPromptLabel;
    [inputCardPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(kEdgeInsetsLeft));
        make.top.mas_equalTo(@(kEdgeInsetsLeft));
        make.right.mas_equalTo(@(kEdgeInsetsLeft));
        make.height.mas_equalTo(@(32));
    }];

    UIView *inputHeadView = [[UIView alloc] init];
    inputHeadView.backgroundColor = kColorWhite;
    [headerView addSubview:inputHeadView];
    UITextField *codeTextField = [[UITextField alloc] init];
    codeTextField.placeholder = [NSString stringWithFormat:@"请输入%@位云卫士卡号", @(KCardNumberLen)];
    codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [codeTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [codeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [codeTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    codeTextField.font = kFontSmall;
    codeTextField.delegate = self;
    codeTextField.backgroundColor = [UIColor clearColor];
    codeTextField.textColor = KColorSubTitleTxt;
    [inputHeadView addSubview:codeTextField];
    [codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _inputTextField = codeTextField;

    
    UIButton *bindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bindBtn.titleLabel.font = kFontTitle;
    bindBtn.layer.masksToBounds = YES;
    bindBtn.tag =KEditButtonTagBase + 0;
    bindBtn.layer.borderColor = KColorAppMain.CGColor;
    bindBtn.layer.borderWidth = 0.5f;
    bindBtn.layer.cornerRadius = 5.0f;
    [bindBtn setTitle:@"绑定" forState:UIControlStateNormal];
    [bindBtn setTitleColor:KColorAppMain forState:UIControlStateNormal];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    [bindBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [tmpObject bind:sender];
    }];
    [inputHeadView addSubview:bindBtn];
    
    [codeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(inputHeadView).with.offset(kEdgeInsetsLeft);
        make.height.mas_equalTo(@(44));
        make.right.mas_equalTo(bindBtn.mas_left).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(inputHeadView);
    }];
    
    [bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(codeTextField.mas_centerY);
        make.right.mas_equalTo(@(-kEdgeInsetsLeft));
        make.left.mas_equalTo(codeTextField.mas_right).with.offset(kEdgeInsetsLeft);
        make.size.mas_equalTo(CGSizeMake(60, 32));
    }];
    
    [inputHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.top.mas_equalTo(inputCardPromptLabel.mas_bottom);
        make.right.mas_equalTo(@(0));
        make.height.mas_equalTo(@(50));
    }];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentView);
        make.right.mas_equalTo(@(0));
        make.left.mas_equalTo(@(0));
        make.height.mas_equalTo(@(KHEADERVIEWHIGHT));
    }];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    [contentView addSubview:bottomView];
    
    UILabel *bindCardPromptLabel = [[UILabel alloc] init];
    bindCardPromptLabel.text = @"已绑定卡";
    bindCardPromptLabel.font = kFontSubTitle;
    bindCardPromptLabel.textColor = kColorGray1;
    [bottomView addSubview:bindCardPromptLabel];
    [bindCardPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(kEdgeInsetsLeft));
        make.top.mas_equalTo(bottomView.mas_top).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(@(-kEdgeInsetsLeft));
        make.height.mas_equalTo(@(32));
    }];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    _tableView.scrollEnabled = NO;
    [bottomView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bindCardPromptLabel.mas_bottom).with.offset(0);
        make.left.mas_equalTo(@(0));
        make.right.mas_equalTo(@(0));
        make.height.mas_equalTo([_cardList count] *(KCELLHIGHT +10));
    }];
    
    UILabel *bottomCardPromptLabel = [[UILabel alloc] init];
    bottomCardPromptLabel.text = @"如需修改卡号请解绑后再绑定";
    bottomCardPromptLabel.font = kFontSubTitle;
    bottomCardPromptLabel.textColor = kColorGray1;
    bottomCardPromptLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:bottomCardPromptLabel];
    [bottomCardPromptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(kEdgeInsetsLeft));
        make.top.mas_equalTo(_tableView.mas_bottom).with.offset(0);
        make.right.mas_equalTo(@(-kEdgeInsetsLeft));
        make.height.mas_equalTo(@(32));
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_contentView.mas_top).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(@(0));
        make.left.mas_equalTo(@(0));
        make.bottom.mas_equalTo(_tableView.mas_bottom);
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomView.mas_bottom);
    }];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}



-(void)bind:(id)sender
{
    [self onBind:_inputTextField.text];
}

-(void)unbind:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger tagIncrement = btn.tag - KCardCellTagBase;
    UILabel *cardLabel = (UILabel *)[btn.superview viewWithTag:tagIncrement-1+KCardCellTagBase];
    if(!cardLabel)
    {
        return ;
    }
    [self onLossBtn:cardLabel.text];

}


-(void)onBind:(NSString *)cardNumber
{
    if([cardNumber length] != KCardNumberLen)
    {
        [self showFailedHudWithTitle:[NSString stringWithFormat:@"请输入正确卡号(%@位)", @(KCardNumberLen)]];
        return;
    }
    if([self isCardExist:cardNumber])
    {
        [self showFailedHudWithTitle:[NSString stringWithFormat:@"此卡已绑定"]];
        return;
    }
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    //    NSNumber *parentId = _detailDic[@"parentId"];
    int64_t parentId = [self getParentId];
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] bindCard:cardNumber userId:parentId onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"绑定", nil] counter:1];
            [tmpObject showFailedHudWithError:error];
        }else {
            [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"绑定", nil] counter:1];
            _inputTextField.text = @"";
            [_inputTextField resignFirstResponder];
            @synchronized(_cardList)
            {
                [_cardList addObject:cardNumber];
            }
            TXAsyncRunInMain(^{
                [tmpObject makeUpdateConstraints];
                [tmpObject.view  layoutIfNeeded];;
                [_tableView reloadData];
            });
        }
    }];
}

-(BOOL)isCardExist:(NSString *)cardNumber
{
    __block BOOL ret = NO;
    [_cardList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *card = (NSString *)obj;
        if([card isEqualToString:cardNumber])
        {
            ret = YES;
            *stop = YES;
        }
    }];
    
    return ret;
}

-(void)makeUpdateConstraints
{
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        if([_cardList count] > 0)
        {
            make.height.mas_equalTo([_cardList count] *(KCELLHIGHT ) + ([_cardList count] -1)*kEdgeInsetsLeft);
        }
        else
        {
            make.height.mas_equalTo([_cardList count] *(KCELLHIGHT +kEdgeInsetsLeft));
        }

    }];
    if([_cardList count] == KCellCount)
    {
        [_bottomView setHidden:NO];
        [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_contentView.mas_top).with.offset(0);
        }];
        [_headView setHidden:YES];
    }
    else
    {
        if([_cardList count] == 0)
        {
            [_bottomView setHidden:YES];
            [_headView setHidden:NO];
            [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(_contentView.mas_top).with.offset(KHEADERVIEWHIGHT+kEdgeInsetsLeft);
            }];
        }
        else
        {
            [_bottomView setHidden:NO];
            [_headView setHidden:NO];
            [_bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(_contentView.mas_top).with.offset(KHEADERVIEWHIGHT+kEdgeInsetsLeft);
            }];
        }
    }
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_bottomView.mas_bottom);
    }];
    [_contentView updateConstraints];
}


- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnRight setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    self.btnRight.hidden = YES;
}

- (void)onLossBtn:(NSString *)cardNumber
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    int64_t parentId = [self getParentId];
    [self showAlertViewWithMessage:@"您确定要解绑吗?" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
        [[TXChatClient sharedInstance] reportLossCard:cardNumber userId:parentId onCompleted:^(NSError *error) {
            if (error) {
                [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"解绑", nil] counter:1];
                [tmpObject showFailedHudWithError:error];
            }else {
                [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"解绑", nil] counter:1];
                @synchronized(_cardList)
                {
                    [_cardList  removeObject:cardNumber];
                }
                TXAsyncRunInMain(^{
                    [tmpObject makeUpdateConstraints];
                    [tmpObject.view  layoutIfNeeded];
                    [_tableView reloadData];
                });
            }
        }];
    }], nil];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 限制输入字数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![unicodeStr isEqualToString:string]) {
        return NO;
    }
    if (textField.text.length > KCardNumberLen) {
        return NO;
    }
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.markedTextRange == nil && textField.text.length > KCardNumberLen) {
        textField.text = [textField.text substringToIndex:KCardNumberLen];
    }
    
}

-(NSString *)getCodeStrByInc:(NSInteger)inc
{
    if(inc >= [_detailDic count])
    {
        return @"";
    }
    NSDictionary *dic = [_detailDic objectAtIndex:inc];
    return dic[@"code"];
}

-(int64_t)getParentId
{
    if( [_detailDic count] > 0)
    {
        return 0;
    }
    NSDictionary *dic = [_detailDic objectAtIndex:0];
    NSNumber *parentId = dic[@"parentId"];
    return parentId.longLongValue;
}

-(NSString *)getName
{
    if( [_detailDic count] <= 0)
    {
        return @"";
    }
    NSDictionary *dic = [_detailDic objectAtIndex:0];
    return dic[@"name"];
}


#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 过滤重复
    if (_keyboardHeight == keyboardHeight)
        return;
    _keyboardHeight = keyboardHeight;
    
    UIView *vFirstResponder = [self.view subviewWithFirstResponder];
    if (vFirstResponder) {
        [UIView animateWithDuration:animateSpeed animations:^{
            _btnCloseKeyboard.maxY = self.view.height_ - keyboardHeight + 5;
            _btnCloseKeyboard.alpha = 1;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (_keyboardHeight == 0)
        return;
    
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    _keyboardHeight = 0;
    
    [UIView animateWithDuration:animateSpeed animations:^{
        _btnCloseKeyboard.maxY = self.view.height_;
        _btnCloseKeyboard.alpha = 0;
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [_inputTextField resignFirstResponder];
}

#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_cardList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MedicineTableViewCell";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = kColorWhite;
        cell.backgroundColor = kColorWhite;
        
        UIImageView *portraitImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (KCELLHIGHT-30)/2, 30, 30)];
        portraitImgView.tag =  KCardCellTagBase+1;
        portraitImgView.image = [UIImage imageNamed:@"mine_guardian"];
        [cell.contentView addSubview:portraitImgView];
        
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        titleLb.frame = CGRectMake(50, (KCELLHIGHT-44)/2, 200, 44);
        titleLb.font = kFontMiddle;
        titleLb.textColor = kColorBlack;
        titleLb.tag = KCardCellTagBase+2;
        titleLb.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:titleLb];
        
        UIButton *unbindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        unbindBtn.frame = CGRectMake(kScreenWidth-70, (KCELLHIGHT-32)/2, 60, 32);
        unbindBtn.titleLabel.font = kFontTitle;
        unbindBtn.backgroundColor = kColorClear;
//        [unbindBtn setBackgroundImage:[UIImage imageNamed:@"card_bind"] forState:UIControlStateNormal];
        unbindBtn.tag =KCardCellTagBase + 3;
        unbindBtn.layer.masksToBounds = YES;
        unbindBtn.layer.borderColor = KColorTitleTxt.CGColor;
        unbindBtn.layer.borderWidth = 0.5f;
        unbindBtn.layer.cornerRadius = 5.0f;
        [unbindBtn setTitle:@"解绑" forState:UIControlStateNormal];
        [unbindBtn setTitleColor:KColorTitleTxt forState:UIControlStateNormal];
        [cell.contentView addSubview:unbindBtn];
        
    }
    
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:KCardCellTagBase+2];
    UIButton *unbindBtn = (UIButton *)[cell.contentView viewWithTag:KCardCellTagBase+3];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    [unbindBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [tmpObject unbind:sender];
    }];
    
    if(indexPath.row >= [_cardList count])
    {
        return cell;
    }
    NSString *cardStr = _cardList[indexPath.section];
    titleLb.text = cardStr;
    
    return cell;
}


#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}




- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 10;
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
    
}

@end
