//
//  MuteViewController.m
//  TXChat
//
//  Created by lyt on 15/7/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MuteViewController.h"
#import "MuteCollectionViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "MuteSelectMembersViewController.h"
#import "TXUser+Utils.h"
#import "TXEaseMobHelper.h"

#define KSuffix   @"20150807_1130"
#define KADDNEWMUTE @"addNewMute"
#define KDELMUTEUSER @"delMuteUsers"

@interface MuteViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_muteList;
    BOOL _isEdited;
    int64_t _departmentId;
}
@end

@implementation MuteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _muteList = [NSMutableArray arrayWithCapacity:1];
        _isEdited = NO;
    }
    return self;
}

-(id)initWithDepartmentId:(int64_t)departmentId
{
    self = [super init];
    if(self)
    {
        _departmentId = departmentId;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    self.titleStr = @"禁言设置";
    [self createCustomNavBar];
    [self setupViews];
    [self updateMuteData];
}

-(void)setupViews
{
    
    UIView *titleBack = [UIView new];
    [titleBack setBackgroundColor:kColorSection];
    [self.view addSubview:titleBack];
    UILabel *title = [UILabel new];
    [title setFont:kFontSubTitle];
    [title setTextColor:kColorGray1];
    [title setText:@"禁言的家长将不能在该班级群和亲子圈中发消息"];
    [title setBackgroundColor:[UIColor clearColor]];
    [titleBack addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(titleBack).with.insets(UIEdgeInsetsMake(0, kEdgeInsetsLeft, 0, 0));
    }];
    [titleBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.right.mas_equalTo(@(0));
        make.top.mas_equalTo(self.view).with.offset(self.customNavigationView.maxY);
        make.height.mas_equalTo(20);
    }];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.allowsSelection = YES;
    [_collectionView registerClass:[MuteCollectionViewCell class] forCellWithReuseIdentifier:@"GradientCell"];
    [self.view addSubview:_collectionView];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(self.view).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(titleBack.mas_bottom).with.offset(kEdgeInsetsLeft);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    _isEdited = NO;
    [self updateMuteList:nil];
}
-(void)updateMuteData
{
//    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    __weak __typeof(&*self) weakSelf=self;  //by sck
//    [[TXChatClient sharedInstance]  fetchMutedUserIds:_departmentId onCompleted:^(NSError *error, NSArray *childUserIds) {
//        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
//        if(error)
//        {
//            DDLogDebug(@"error:%@",error);
//            [self showFailedHudWithError:error];
//        }
//        else
//        {
//            @synchronized(_muteList)
//            {
//                [_muteList removeAllObjects];
//                [childUserIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    NSNumber *userId = (NSNumber *)obj;
//                    TXUser *user = [[TXChatClient sharedInstance] getUserByUserId:[userId longLongValue] error:nil];
//                    if(user != nil)
//                    {
//                        [_muteList addObject:user];
//                    }
//                }];
//                [weakSelf addOperatorUser];
//            }
//            TXAsyncRunInMain(^{
//                [_collectionView reloadData];
//            });
//        }
//    }];
}

-(void)addOperatorUser
{
    NSUInteger muteCount = [_muteList count];
    TXUser *addUser = [[TXUser alloc] init];
    addUser.nickname = @"";
    addUser.avatarUrl = @"shutUpAdd";
    addUser.realName = [NSString stringWithFormat:@"%@%@",KADDNEWMUTE,KSuffix];
    if(addUser)
    {
        [_muteList addObject:addUser];
    }
    if(muteCount > 0)
    {
        TXUser *delUser = [[TXUser alloc] init];
        delUser.nickname = @"";
        delUser.avatarUrl = @"shutUpDelete";
        delUser.realName = [NSString stringWithFormat:@"%@%@",KDELMUTEUSER,KSuffix];
        if(delUser)
        {
            [_muteList addObject:delUser];
        }
    }
}



-(void)onClickBtn:(UIButton *)sender
{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_muteList count];;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"GradientCell";
    MuteCollectionViewCell * cell = (MuteCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    TXUser *user = [_muteList objectAtIndex:indexPath.row];
    if([user.realName isEqualToString:[NSString stringWithFormat:@"%@%@",KADDNEWMUTE,KSuffix]]
       || [user.realName isEqualToString:[NSString stringWithFormat:@"%@%@",KDELMUTEUSER,KSuffix]])
    {
        [cell.headerImage setImage:[UIImage imageNamed:user.avatarUrl]];
        [cell.nameLabel setText:@""];
        [cell updateDelStatus:NO];
    }
    else
    {
        [cell.headerImage TX_setImageWithURL:[NSURL URLWithString:[user getFormatAvatarUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        [cell.nameLabel setText:user.nickname];
        [cell updateDelStatus:_isEdited];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(67, 67);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 0, 2, 0);
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TXUser *user = [_muteList objectAtIndex:indexPath.row];
    
    if([user.realName isEqualToString:[NSString stringWithFormat:@"%@%@",KADDNEWMUTE,KSuffix]])
    {
        [self showMuteAddVC];
    }
    else if([user.realName isEqualToString:[NSString stringWithFormat:@"%@%@",KDELMUTEUSER,KSuffix]])
    {
        _isEdited = !_isEdited;
        [self updateMuteList:nil];
    }
    else
    {
        if(_isEdited)
        {
            [self unmuteUser:indexPath];
        }
    }
}

-(void)unmuteUser:(NSIndexPath *)indexPath
{
//    TXUser *muteUser = [_muteList objectAtIndex:indexPath.row];
//    int64_t muteUserId = muteUser.userId;
//    __weak __typeof(&*self) weakSelf=self;  //by sck
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    [[TXChatClient sharedInstance] unMute:_departmentId childUserId:muteUserId onCompleted:^(NSError *error) {
//        TXAsyncRunInMain(^{
//            [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
//        });
//       if(error)
//       {
//           [MobClick event:@"mute" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"解禁", nil] counter:1];
//           DDLogDebug(@"error:%@",error);
//           [self showFailedHudWithError:error];
//       }
//       else
//       {
//           [MobClick event:@"mute" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"解禁", nil] counter:1];
//           [[TXEaseMobHelper sharedHelper] sendCMDMessageWithType:TXCMDMessageType_GagUser];
//           TXAsyncRunInMain(^{
//               @synchronized(_muteList)
//               {
//                   [_muteList removeObjectAtIndex:indexPath.row];
//                   if([_muteList count] == 2)
//                   {
//                       [_muteList removeObject:_muteList.lastObject];
//                       _isEdited = NO;
//                   }
//               }
//               [_collectionView reloadData];
//           });
//       }
//    }];
}


-(void)showMuteAddVC
{
    NSMutableArray *selectedUsers = [NSMutableArray arrayWithCapacity:1];
    
    if([_muteList count] > 2)
    {
        NSRange range = {0, [_muteList count]-2};
        [selectedUsers addObjectsFromArray:[_muteList subarrayWithRange:range]];
    }
    
    MuteSelectMembersViewController *muteSelectedVC = [[MuteSelectMembersViewController alloc] initWithDepartmentId:_departmentId selectedUsers:selectedUsers];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    muteSelectedVC.updateMemberSelected = ^(NSArray *userArray, int64_t departmentId)
    {
        if([userArray count] > 0)
        {
            [weakSelf updateMuteList:userArray];
        }
    };
    [self.navigationController pushViewController:muteSelectedVC animated:YES];
}

-(void)updateMuteList:(NSArray *)newMuteUsers
{
    @synchronized(_muteList)
    {
        if([_muteList count] == 1)
        {
            TXUser *delUser = [[TXUser alloc] init];
            delUser.nickname = @"";
            delUser.avatarUrl = @"shutUpDelete";
            delUser.realName = [NSString stringWithFormat:@"%@%@",KDELMUTEUSER,KSuffix];
            if(delUser)
            {
                [_muteList addObject:delUser];
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                               NSMakeRange([_muteList count] -2,[newMuteUsers count])];
        [_muteList insertObjects:newMuteUsers atIndexes:indexes];
    }
    [_collectionView reloadData];
}


//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark  UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return _isEdited;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UICollectionView class]])
    {
        return YES;
    }
    return NO;
}
@end
