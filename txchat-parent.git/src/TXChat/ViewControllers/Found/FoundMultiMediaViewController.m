//
//  FoundMultiMediaViewController.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/19.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "FoundMultiMediaViewController.h"
#import "MediaPlayViewController.h"
#import "TXMediaItem.h"
#import "MediaAlbumCollectionViewCell.h"
#import <TXChatSDK/TXTrackManager.h>
#import <TXChatSDK/TXAlbum.h>

static NSString *const kCollectionViewCellIndentify = @"cvCellIndentify";

@interface FoundMultiMediaViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>
{
    UICollectionView *_listView;
}
@property (nonatomic,strong) NSMutableArray *mediaList;
@property (nonatomic,strong) NSMutableArray *albumList;
@end

@implementation FoundMultiMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"多媒体";
    [self createCustomNavBar];
//    [self setupMediaListData];
    [self setupMediaAlbumListView];
    [self fetchMediaAlbumList];
}
#pragma mark - UI视图创建
- (void)setupMediaAlbumListView
{
//    _mediaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.height_) style:UITableViewStylePlain];
//    _mediaTableView.backgroundColor = [UIColor clearColor];
//    _mediaTableView.delegate = self;
//    _mediaTableView.dataSource = self;
//    [self.view addSubview:_mediaTableView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _listView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, self.customNavigationView.maxY + 10, kScreenWidth - 20, self.view.height_ - self.customNavigationView.maxY - 20) collectionViewLayout:flowLayout];
    _listView.backgroundColor = [UIColor clearColor];
    _listView.showsVerticalScrollIndicator = NO;
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.delegate = self;
    _listView.dataSource = self;
    //注册cell类创建
    [_listView registerClass:[MediaAlbumCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellIndentify];
    
    [self.view addSubview:_listView];

}
#pragma mark - 数据处理
- (void)setupMediaListData
{
    self.mediaList = [NSMutableArray array];
    self.mediaList = [NSMutableArray arrayWithArray:[self mockMedia]];
}
- (NSArray *)mockMedia {
    
    TXMediaAudioItem *audio1 = [[TXMediaAudioItem alloc] init];
    audio1.author = @"Author";
    audio1.title = @"Track 1";
    audio1.uid = @"00000000001";
    audio1.remotePath = @"http://www.tonycuffe.com/mp3/tail%20toddle.mp3";
    //    audio1.remotePath = @"http://s.tx2010.com/11C95CAC-79E9-47D4-8D35-62F0C379D77B.m4a";
    
    TXMediaAudioItem *audio2 = [[TXMediaAudioItem alloc] init];
    audio2.author = @"Author";
    audio2.title = @"Track 2";
    audio2.uid = @"00000000002";
    audio2.remotePath = @"http://www.tonycuffe.com/mp3/cairnomount_lo.mp3";
    //    audio2.remotePath = @"http://s.tx2010.com/11C95CAC-79E9-47D4-8D35-62F0C379D77B.m4a";
    
    TXMediaAudioItem *audio3 = [[TXMediaAudioItem alloc] init];
    audio3.author = @"Author";
    audio3.title = @"Track 3";
    audio3.uid = @"00000000003";
    audio3.remotePath = @"http://www.tonycuffe.com/mp3/pipers%20hut.mp3";
    //    audio3.remotePath = @"http://s.tx2010.com/11C95CAC-79E9-47D4-8D35-62F0C379D77B.m4a";
    
    TXMediaVideoItem *video = [[TXMediaVideoItem alloc] init];
    video.author = @"Video author";
    video.title = @"Video";
    video.uid = @"00000000004";
    //    video.remotePath = @"http://qn.vc/files/data/1541/2%20Many%20Girls%20-%20Fazilpuria,%20Badshah%20[mobmp4.com].mp4";
    video.remotePath = @"http://v.iseeyoo.cn/video/2010/10/25/2a9f0f4e-e035-11df-9117-001e0bbb2442_001.mp4";

    //第一个专辑
    TXMediaCollection *collection1 = [[TXMediaCollection alloc] init];
    collection1.mediaItems = @[audio1, audio2, audio3];
    collection1.author = @"Author1";
    collection1.title = @"Album1";
    //第二个专辑
    TXMediaCollection *collection2 = [[TXMediaCollection alloc] init];
    collection2.mediaItems = @[audio1, audio2];
    collection2.author = @"Author2";
    collection2.title = @"Album2";
    //第三个专辑
    TXMediaCollection *collection3 = [[TXMediaCollection alloc] init];
    collection3.mediaItems = @[audio1, audio2, audio3];
    collection3.author = @"Author3";
    collection3.title = @"Album3";
    //第四个专辑
    TXMediaCollection *collection4 = [[TXMediaCollection alloc] init];
    collection4.mediaItems = @[video, video, video];
    collection4.author = @"Video4";
    collection4.title = @"Video4";

    return @[collection1, collection2, collection3, collection4];
}
#pragma mark - 按钮点击方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mediaList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
    }
    TXMediaItem *item = (TXMediaItem *)_mediaList[indexPath.row];
    cell.textLabel.text = item.title;
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转进入播放器界面
    MediaPlayViewController *playVc = [[MediaPlayViewController alloc] init];
//    playVc.mediaItem = (TXMediaItem *)_mediaList[indexPath.row];
    playVc.collection = [_mediaList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:playVc animated:YES];
}
#pragma mark - 网络请求
- (void)fetchMediaAlbumList
{
    NSArray *arr = [[TXChatClient sharedInstance].trackManager queryAlbums:LLONG_MAX count:20];
    self.albumList = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(TXAlbum *obj, NSUInteger idx, BOOL *stop) {
        TXMediaCollection *collection = [[TXMediaCollection alloc] init];
        collection.uid = [NSString stringWithFormat:@"%@",@(obj.id)];
        collection.author = obj.coverUrl;
        collection.title = obj.name;
        [_albumList addObject:collection];
    }];
    [_listView reloadData];
}
#pragma mark - UICollectionView delegate and dataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _albumList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaAlbumCollectionViewCell *cell = (MediaAlbumCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIndentify forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    TXMediaCollection *album = _albumList[indexPath.row];
    [cell setupCellWithThumbnailName:album.author title:album.title];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (kScreenWidth - 26) / 3;
    float resizeWidth = floorf(width);
    return CGSizeMake(resizeWidth, resizeWidth + 25);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TXMediaCollection *album = _albumList[indexPath.row];
    //跳转进入播放器界面
    MediaPlayViewController *playVc = [[MediaPlayViewController alloc] init];
    //    playVc.mediaItem = (TXMediaItem *)_mediaList[indexPath.row];
    playVc.collection = album;
    [self.navigationController pushViewController:playVc animated:YES];
}
@end
