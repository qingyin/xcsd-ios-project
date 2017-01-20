//
//  AddShutUpViewController.m
//  ChildHoodStemp
//
//  Created by steven_l on 15/2/27.
//
//

#import "AddShutUpViewController.h"
//#import "UIUtil.h"
#import "MicroDef.h"
//#import "CHSNavigationBar.h"
//#import "CHMemoryManager.h"
#import "CHTapGesture.h"
#import "CHSelectChildCell.h"
//#import "ChildHoodMemory.h"


static int kBaseSelectTag = 100;
@interface AddShutUpViewController ()

@property (nonatomic, strong) NSMutableArray *selectDataArr;
@property (nonatomic, strong) UIScrollView *bgScrollView;
@end

@implementation AddShutUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initDefaultDatas];
    }
    return self;
}
- (void)dealloc
{
    self.listDataArr = nil;
    self.selectDataArr = nil;
    self.bgScrollView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavViews];
    [self initSubViews];
    // Do any additional setup after loading the view.
}


- (void)initDefaultDatas
{
    self.selectDataArr = [NSMutableArray array];
    
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
//    [self.navigationItem setNewTitle:@"选择班级成员"];
//    
//    [self.navigationItem setRightItemWithTarget:self action:@selector(operateDone) image:@"sendgroup_normal.png" selectedImageName:@"sendgroup_selected.png" text:@"完成"];
//    self.navigationItem.rightBarButtonItem.customView.hidden = YES;
}

- (void)initSubViews
{
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, HARDWARE_SCREEN_WIDTH, HARDWARE_SCREEN_HEIGHT - 64)];
    _bgScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_bgScrollView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //将已经禁言的人从列表中去除掉
        NSMutableArray *tempArr = [NSMutableArray arrayWithArray:_listDataArr];
//        for(ChildHoodMemory *memory in _hasBanArr)
        for(int i = 0; i < 5; i++)
        {
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.memoryId == %d",memory.memoryId]];
//            NSArray *filterArr = [_listDataArr filteredArrayUsingPredicate:predicate];
//            if ([filterArr count])
//            {
//                [tempArr removeObjectsInArray:filterArr];
//            }
        }
        self.listDataArr = [NSMutableArray arrayWithArray:tempArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshSubViews];
        });
    });
}

- (void)refreshSubViews
{
    CGFloat left = HARDWARE_SCREEN_WIDTH > 375?Contact_EdgeSpaceToLeft_h:Contact_EdgeSpaceToLeft;
    int colums = HARDWARE_SCREEN_WIDTH > 375?5:4;
    
  

    NSInteger lines = ([_listDataArr count]%colums >0) ? ([_listDataArr count]/colums + 1) : [_listDataArr count]/colums;
    for (int i=0 ;i < _listDataArr.count;i++) {
//        ChildHoodMemory* ele = (ChildHoodMemory*)[_listDataArr objectAtIndex:i];
        CHTapGesture* tap = [[CHTapGesture alloc] initWithTarget:self
                                                          action:@selector(selectItemTapAction:)
                                                             tag:i+100];
        [tap.userInfo setObject:@"0" forKey:@"IsSelect"];
        SelectItem* item = [[SelectItem alloc] initWithCenter:CGPointMake(                                                                          4+ left+ Contact_MemberWidth*(i%colums)+Contact_MemberWidth/2,(i/colums)*Contact_MemberHeight+Contact_MemberHeight/2)
                                                         name:@"名字"
                                                  portraitURI:@"first_selected"
                                                       action:tap];
        [item setTag:i+kBaseSelectTag];
        
        [_bgScrollView addSubview:item];
    }
    
    CGFloat viewHeight = Contact_EdgeSpaceToTop;// VerSpace;
    viewHeight += (lines*(Contact_MemberHeight));
    
    _bgScrollView.contentSize = CGSizeMake(HARDWARE_SCREEN_WIDTH, viewHeight);

}
#pragma mark - 点按操作
- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)operateDone
{
    _block(_selectDataArr);
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)selectItemTapAction:(CHTapGesture*)item
{
    SelectItem* ele = (SelectItem*)[_bgScrollView viewWithTag:item.tag];
//    ChildHoodMemory* memory = (ChildHoodMemory*)[_listDataArr objectAtIndex:item.tag - kBaseSelectTag];

    if (ele.isSelect) {
        [ele deSelectItem];
//        [_selectDataArr removeObject:memory];
    }else
    {
        [ele setSelectItem];
//        [_selectDataArr addObject:memory];
    }
    

//    ISTThemeButton *btn = (ISTThemeButton *)self.navigationItem.rightBarButtonItem.customView;
//    NSString *rightTitle = nil;
//    if (_selectDataArr.count) {
//        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
//        rightTitle = [NSString stringWithFormat:@"完成(%lu)",(unsigned long)_selectDataArr.count];
//    }
//    else
//    {
//        self.navigationItem.rightBarButtonItem.customView.hidden = YES;
//        rightTitle = [NSString stringWithFormat:@"完成"];
//    }
//    
//    CGSize size;
//    if (IsIOS7) {
//       size = [rightTitle sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}];
//    }
//    else
//    {
//        size = [rightTitle sizeWithFont:btn.titleLabel.font];
//    }
//    CGRect frame = btn.frame;
//    frame.size.width = size.width;
//    btn.frame = frame;
//    [btn setTitle:rightTitle forState:UIControlStateNormal];
//    [btn setTitle:rightTitle forState:UIControlStateSelected];
//    [btn setTitle:rightTitle forState:UIControlStateHighlighted];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
