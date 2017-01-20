//
//  CirclePhotosViewController.m
//  TXChatParent
//
//  Created by Cloud on 15/9/23.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "CirclePhotosViewController.h"
#import "MJRefresh.h"
#import "NSDate+TuXing.h"
#import "CirclePhotoCollectionViewCell.h"
#import "TXPhotoBrowserViewController.h"
#import "TXDepartmentPhoto+Circle.h"
#import "DropdownView.h"

static NSString *const CollectionViewCellIndentify = @"collectionViewCellIndentify";

typedef enum : NSUInteger {
    PhotosRequestType_None = 0,
    PhotosRequestType_Header,
    PhotosRequestType_Footer,
} PhotosRequestType;

@interface CirclePhotosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIButton *_selectedBtn;
    UIImageView *_arrowImgView;
    NSInteger _selectedIndex;
}

@property (nonatomic, strong) DropdownView *dropdownView;
@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, assign) PhotosRequestType type;
@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) UICollectionView *listView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *photoArr;
@property (nonatomic, strong) NSMutableArray *tmpListArr;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger totalCount;

@end

@implementation CirclePhotosViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    TXUser *user = [TXChatClient sharedInstance].applicationManager.currentUser;
    self.titleStr = [NSString stringWithFormat:@"%@相册",user.className];
    [super viewDidLoad];
    self.view.backgroundColor = kColorWhite;
    [self createCustomNavBar];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.headerReferenceSize = CGSizeMake(kScreenWidth, 30);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _listView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.maxY) collectionViewLayout:flowLayout];
    _listView.showsVerticalScrollIndicator = NO;
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.delegate = self;
    _listView.backgroundColor = kColorWhite;
    _listView.dataSource = self;
    //注册cell类创建
    [_listView registerClass:[CirclePhotoCollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIndentify];
    [_listView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];

    [self.view addSubview:_listView];
    
    [self setupRefresh];
  
    self.groupList = [NSMutableArray array];
    [_groupList addObjectsFromArray:[[TXChatClient sharedInstance] getAllDepartments:nil]];
    if (!_groupList.count) {
        return;
    }
    
    //获取历史数据
    [self getPhotos];
    self.type = PhotosRequestType_Header;
    [_listView.header beginRefreshing];
    

    if (_departmentId != -1) {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"departmentId == %d",_departmentId];
        NSArray *arr = [_groupList filteredArrayUsingPredicate:pre];
        TXDepartment *department = arr[0];
        _selectedIndex = [_groupList indexOfObject:department];
        self.titleStr = department.name;
        self.titleLb.text = self.titleStr;
    }
    else if(_groupList.count == 1) {
        TXDepartment *department = _groupList[0];
        //只有一个组不显示筛选框
        self.titleStr = department.name;
        self.titleLb.text = self.titleStr;
        return;
    }else{
        TXDepartment *department = _groupList[0];
        self.titleLb.font = kFontMiddle;
        self.titleLb.text = department.name;
    }
    
    _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedBtn.adjustsImageWhenHighlighted = NO;
    _selectedBtn.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, self.customNavigationView.width_, kNavigationHeight);
    [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavigationView insertSubview:_selectedBtn belowSubview:self.btnRight];
//    TXDepartment *department = _groupList[0];
//    self.titleLb.font = kFontMiddle;
//    self.titleLb.text = department.name;
//    self.titleLb.height_ -= 10;
    
    NSMutableArray *titlesArr = [NSMutableArray array];
    [_groupList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (idx == 0) {
//            [titlesArr addObject:obj];
//        }else{
            TXDepartment *depart = obj;
            [titlesArr addObject:depart.name];
//        }
    }];
    
    _dropdownView = [[DropdownView alloc] init];
    if (_selectedIndex != 0) {
        _dropdownView.selectedIndex = _selectedIndex;
    }
    @weakify(self);
    [_dropdownView showInView:self.view andListArr:titlesArr andDropdownBlock:^(int index) {
        @strongify(self);
        if(index == -1)
        {
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
            return;
        }
        else
        {
            _selectedIndex = index;
//            if (index == 0) {
//                self.titleStr = @"全部";
//                self.departmentId = -1;
//            }else{
                TXDepartment *depart = self.groupList[index];
                self.titleStr = depart.name;
                self.departmentId = depart.departmentId;
//            }
            _selectedIndex = index;
            self.titleLb.text = self.titleStr;
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
            TXAsyncRun(^{
                TXAsyncRunInMain(^{
                    self.type = PhotosRequestType_Header;
                    [self.listView.header beginRefreshing];
                    [TXProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
            
        }
    }];
    
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [self.customNavigationView addSubview:_arrowImgView];
    
    [self.customNavigationView bringSubviewToFront:self.btnLeft];
    [self.view bringSubviewToFront:self.customNavigationView];
    

    // Do any additional setup after loading the view.
}

#pragma mark - DROPDOWN VIEW
- (void)showDropDownView
{
    [_dropdownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
}

//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader =[MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    _listView.header = gifHeader;
    _listView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
}

- (void)headerRereshing{
    if (!_groupList.count) {
        [_listView.header endRefreshing];
        return;
    }
    self.type = PhotosRequestType_Header;
    [self fetchPhotos];
}

- (void)footerRereshing{
    if (!_groupList.count) {
        [_listView.footer endRefreshing];
        return;
    }
    self.type = PhotosRequestType_Footer;
    [self fetchPhotos];
}


- (void)createCustomNavBar{
    [super createCustomNavBar];
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

//获取历史图片
- (void)getPhotos{
    TXDepartment *department = _groupList[_selectedIndex];
    self.listArr = [NSMutableArray arrayWithArray:[[TXChatClient sharedInstance].departmentPhotoManager queryDepartmentPhotos:department.departmentId maxDepartmentPhotoId:LLONG_MAX count:20 error:nil]];
    [_listView reloadData];
}

//获取相册网络数据
- (void)fetchPhotos{
    __weak typeof(self)tmpObject = self;
    TXDepartmentPhoto *photo = nil;
    if (_type == PhotosRequestType_Footer) {
        photo = [_listArr lastObject];
        if (!photo) {
            [_listView.footer endRefreshing];
            return;
        }
    }
    TXDepartment *department = _groupList[_selectedIndex];

    [[TXChatClient sharedInstance].departmentPhotoManager fetchDepartmentPhotos:department.departmentId maxDepartmentPhotoId:_type == PhotosRequestType_Header?LLONG_MAX:photo.departmentPhotoId onCompleted:^(NSError *error, NSArray *txDepartmentPhotos,int64_t totalCount, BOOL hasMore) {
        if (error) {
            [tmpObject.listView.header endRefreshing];
            [tmpObject.listView.footer endRefreshing];
            tmpObject.listView.footer.hidden = YES;
            [tmpObject.listView.footer noticeNoMoreData];
            [tmpObject showFailedHudWithError:error];
        }else{
            tmpObject.tmpListArr = [NSMutableArray arrayWithArray:txDepartmentPhotos];
            tmpObject.hasMore = hasMore;
            tmpObject.totalCount = (NSInteger)(totalCount);
            if (!txDepartmentPhotos.count) {
                [tmpObject.listView.header endRefreshing];
                [tmpObject.listView.footer endRefreshing];
            }
            if (!tmpObject.isScrolling) {
                if (tmpObject.type == PhotosRequestType_Header) {
                    tmpObject.listArr = [NSMutableArray arrayWithArray:tmpObject.tmpListArr];
                    [tmpObject manageData:_listArr];
                }else if (tmpObject.type == PhotosRequestType_Footer){
                    [tmpObject.listArr addObjectsFromArray:tmpObject.tmpListArr];
                    [tmpObject manageData:_listArr];
                }
                tmpObject.type = PhotosRequestType_None;
                [tmpObject reloadData];
            }

        }
    }];
}

- (void)manageData:(NSArray *)arr{
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:arr];
    self.dataArr = [NSMutableArray array];
    self.photoArr = [NSMutableArray array];
    int currentIndex = 0;
    while ([tmpArr count]) {
        TXDepartmentPhoto *photo = [tmpArr objectAtIndex:0];
        
        NSString *createOn = [NSDate timeForShortStyle:[NSString stringWithFormat:@"%@", @(photo.createdOn/1000)]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date=[formatter dateFromString:createOn];
        NSTimeInterval timeStamp = [date timeIntervalSince1970];
        NSTimeInterval endTimeStamp = timeStamp + (60 * 60 * 24);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BETWEEN {%llf,%llf}",@"createdOn",timeStamp * 1000,endTimeStamp * 1000];
        NSArray *arr1 = [tmpArr filteredArrayUsingPredicate:predicate];
        NSMutableArray *newFeedArr = [NSMutableArray array];
        for (TXDepartmentPhoto *tmpFeed in arr1) {
            tmpFeed.index = @(currentIndex);
            currentIndex++;
            [newFeedArr addObject:tmpFeed];
            [_photoArr addObject:tmpFeed];
        }
        [_dataArr addObject:newFeedArr];
        [tmpArr removeObjectsInArray:arr1];
    }
}

- (void)showPhotoView:(NSArray *)arr andIndex:(NSInteger)index
{
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    browerVc.preVC = self;
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:arr];
    if(_hasMore)
    {
        [tmpArr addObject:@"end"];
    }
    browerVc.hasMore = _hasMore;
    browerVc.totalCount = _totalCount;
    TXDepartment *department = _groupList[_selectedIndex];
    browerVc.departmentId = department.departmentId;
    [browerVc showBrowserWithImages:tmpArr currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}

#pragma mark - UICollectionView delegate and dataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataArr.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *arr = _dataArr[section];
    return arr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CirclePhotoCollectionViewCell *cell = (CirclePhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIndentify forIndexPath:indexPath];
    NSArray *arr = _dataArr[indexPath.section];
    TXDepartmentPhoto *photo = arr[indexPath.row];
    [cell setupCellWithThumbnailName:photo.fileUrl];
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout
- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        NSArray *arr = _dataArr[indexPath.section];
        TXDepartmentPhoto *photo = arr[indexPath.row];
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        [reusableview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectMake(12.5, 0, kScreenWidth - 25, 30)];
        label.font = kFontMiddle_b;
        label.textColor = NSTextAlignmentLeft;
        label.textColor = KColorTitleTxt;
        NSString *createOn = [NSDate timeForShortStyle:[NSString stringWithFormat:@"%@", @(photo.createdOn/1000)]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date=[formatter dateFromString:createOn];
        NSString *destDateString = [formatter stringFromDate:date];
        label.text = destDateString;
        [reusableview addSubview:label];
        
    }
    reusableview.backgroundColor = [UIColor clearColor];
    
    return reusableview;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (kScreenWidth - 25 - 6) / 3;
    float resizeWidth = floorf(width);
    return CGSizeMake(resizeWidth, resizeWidth);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 12.5, 0, 12.5);
}

//选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = _dataArr[indexPath.section];
    TXDepartmentPhoto *photo = arr[indexPath.row];
    [self showPhotoView:_photoArr andIndex:photo.index.intValue];
}

#pragma mark - UIScrollView Delegate
- (void)reloadData{
    [_listView reloadData];
    [_listView.header endRefreshing];
    [_listView.footer endRefreshing];
    self.tmpListArr = [NSMutableArray array];
    if (!_hasMore) {
        _listView.footer.hidden = YES;
        [_listView.footer noticeNoMoreData];
    }else{
        _listView.footer.hidden = NO;
        [_listView.footer resetNoMoreData];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        self.isScrolling = NO;
        if (_type == PhotosRequestType_Header && _tmpListArr.count) {
            self.type = PhotosRequestType_None;
            self.listArr = [NSMutableArray arrayWithArray:_tmpListArr];
            [self manageData:_listArr];
            [self reloadData];
        }else if (_type == PhotosRequestType_Footer && _tmpListArr.count){
            self.type = PhotosRequestType_None;
            [_listArr addObjectsFromArray:_tmpListArr];
            [self manageData:_listArr];
            [self reloadData];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.isScrolling = NO;
    if (_type == PhotosRequestType_Header && _tmpListArr.count) {
        self.listArr = [NSMutableArray arrayWithArray:_tmpListArr];
        [self manageData:_listArr];
        [self reloadData];
    }else if (_type == PhotosRequestType_Footer && _tmpListArr.count){
        [_listArr addObjectsFromArray:_tmpListArr];
        [self manageData:_listArr];
        [self reloadData];
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
