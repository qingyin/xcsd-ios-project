//
//  TXGreetingViewController.m
//  TXChatParent
//
//  Created by gaoju on 12/28/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import "TXGreetingViewController.h"
#import "TXGreetingCell.h"
#import "AppDelegate.h"

@interface TXGreetingViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation TXGreetingViewController

NSString *ID = @"TXGreetingViewController";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)setupUI {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[TXGreetingCell class] forCellWithReuseIdentifier:ID];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TXGreetingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[TXGreetingCell alloc] init];
    }
    cell.index = [self.dataArr[indexPath.item] integerValue];
    
    if (indexPath.item == 3) {
        cell.startBlock = ^() {
            
            AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
            if ([appdelegate isAutoLogin]) {
                [appdelegate createTabBarView];
            }else {
                [appdelegate createLoginView];
            }
            
            [USER_DEFAULT setBool:YES forKey:kFirstLogin];
        };
    }
    
    return cell;
}

- (NSArray *)dataArr {
    if (_dataArr == nil) {
        _dataArr = @[@1, @2, @3, @4];
    }
    return _dataArr;
}

@end
