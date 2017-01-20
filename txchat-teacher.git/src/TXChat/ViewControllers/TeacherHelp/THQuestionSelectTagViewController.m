//
//  THQuestionSelectTagViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THQuestionSelectTagViewController.h"
#import "THAskQuestionViewController.h"

@interface THQuestionSelectTagViewController ()
<UITableViewDelegate,
UITableViewDataSource>
{
    NSInteger _selectedIndex;
}
@property (nonatomic,strong) UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic,strong) UITableView *tagsTableView;
@property (nonatomic,strong) NSMutableArray *tagsList;

@end

@implementation THQuestionSelectTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _selectedIndex = -1;
    [self createCustomNavBar];
    [self setupTagsTableView];
    if (!_tagsArray) {
        [self fetchQuestionTagsList];
    }else{
        self.tagsList = [NSMutableArray arrayWithArray:_tagsArray];
        [_tagsTableView reloadData];
    }
}
#pragma mark - UI视图创建
- (void)createCustomNavBar
{
    self.titleStr = @"选择分类";
    [super createCustomNavBar];
//    [self.btnRight setTitle:@"完成" forState:UIControlStateNormal];
}
- (void)setupTagsTableView
{
    self.tagsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY) style:UITableViewStylePlain];
    self.tagsTableView.backgroundColor = [UIColor clearColor];
    self.tagsTableView.delegate = self;
    self.tagsTableView.dataSource = self;
    self.tagsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tagsTableView];

}
- (UIActivityIndicatorView *)loadingIndicatorView
{
    if (!_loadingIndicatorView) {
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingIndicatorView;
}
#pragma mark - 按钮点击响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
//    else{
//        if (_selectedIndex == -1) {
//            //弹出未选择分类Tip
//            [self showFailedHudWithTitle:@"请选择分类"];
//        }else{
//            //跳转到提问界面
//            TXPBTag *currentTag = _tagsList[_selectedIndex];
//            if (self.tagBlock) {
//                self.tagBlock(currentTag);
//                [self.navigationController popViewControllerAnimated:YES];
//            }else{
//                THAskQuestionViewController *askVc = [[THAskQuestionViewController alloc] init];
//                askVc.tag = currentTag;
//                askVc.backVc = _backVc;
//                if (_tagsArray) {
//                    askVc.forbiddenChangeTag = YES;
//                }
//                [self.navigationController pushViewController:askVc animated:YES];
//            }
//        }
//    }
}
#pragma mark - 数据获取
- (void)fetchQuestionTagsList
{
    //添加请求loading视图
    self.loadingIndicatorView.center = CGPointMake(self.tagsTableView.centerX, self.tagsTableView.height_ / 2);
    [self.loadingIndicatorView startAnimating];
    [self.tagsTableView addSubview:self.loadingIndicatorView];
    //处理数据
    self.tagsList = [NSMutableArray array];
    [[TXChatClient sharedInstance].txJsbMansger fetchTagsWithTagType:1 onCompleted:^(NSError *error, NSArray *tags) {
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            [self.tagsList addObjectsFromArray:tags];
            [self.tagsList enumerateObjectsUsingBlock:^(TXPBTag *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.id == _currentTag.id) {
                    _selectedIndex = idx;
                    *stop = YES;
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭请求效果
                [self.loadingIndicatorView removeFromSuperview];
                self.loadingIndicatorView = nil;
                [_tagsTableView reloadData];
            });
        }
    }];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tagsList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = nil;
        //更改标题label样式
        UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, tableView.width_ - 30, 44)];
        tagLabel.backgroundColor = [UIColor clearColor];
        tagLabel.font = [UIFont systemFontOfSize:14];
        tagLabel.textColor = KColorTitleTxt;
        tagLabel.tag = 100;
        [cell.contentView addSubview:tagLabel];
        //添加分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.width_, kLineHeight)];
        lineView.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
        lineView.tag = 110;
        [cell.contentView addSubview:lineView];
    }
    TXPBTag *tag = _tagsList[indexPath.row];
    UILabel *tagLabel = [cell.contentView viewWithTag:100];
    tagLabel.text = tag.name;
    if (indexPath.row == _selectedIndex) {
        tagLabel.textColor = RGBCOLOR(0xFF, 0x93, 0x3d);
    }else{
        tagLabel.textColor = KColorTitleTxt;
    }
    UIView *lineView = [cell.contentView viewWithTag:110];
    if (indexPath.row == [_tagsList count] - 1) {
        lineView.hidden = YES;
    }else{
        lineView.hidden = NO;
    }
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    [tableView reloadData];
    //跳转到提问界面
    TXPBTag *currentTag = _tagsList[_selectedIndex];
    if (self.tagBlock) {
        self.tagBlock(currentTag);
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        THAskQuestionViewController *askVc = [[THAskQuestionViewController alloc] init];
        askVc.tag = currentTag;
        askVc.backVc = _backVc;
        if (_tagsArray) {
            askVc.forbiddenChangeTag = YES;
        }
        [self.navigationController pushViewController:askVc animated:YES];
    }
}
@end
