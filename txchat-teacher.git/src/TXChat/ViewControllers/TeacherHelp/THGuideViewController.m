//
//  THGuideViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THGuideViewController.h"
#import "THGuideArticlesTableViewController.h"
#import "THQuestionSelectTagViewController.h"

@interface THGuideViewController ()
<TXPagerScrollViewControllerDelegate,
TXPagerScrollViewControllerDataSource>

@property (nonatomic,strong) NSMutableArray *guideCategorys;
@property (nonatomic,strong) NSMutableArray *categoryNames;

@end

@implementation THGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"宝典";
    //设置提问
    [self.btnRight setTitle:@"提问" forState:UIControlStateNormal];
    [self setDataSource:self];
    [self setDelegate:self];
    [self fetchGuideCategoryList];
}
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        THQuestionSelectTagViewController *vc = [[THQuestionSelectTagViewController alloc] init];
        vc.backVc = self.rdv_tabBarController;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - 数据获取
//获取宝典的分类并刷新
- (void)fetchGuideCategoryList
{
    [[TXChatClient sharedInstance].txJsbMansger fetchTagsWithTagType:TXPBTagTypeTagKnowledge onCompleted:^(NSError *error, NSArray *tags) {
        if (error) {
            [self showFailedHudWithError:error];
            [self reloadData];
        }else{
            self.guideCategorys = [NSMutableArray arrayWithArray:tags];
            self.categoryNames = [NSMutableArray array];
            [tags enumerateObjectsUsingBlock:^(TXPBTag *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.categoryNames addObject:obj.name];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                //刷新
                [self reloadData];
            });
        }
    }];
}
#pragma mark - TXPagerScrollViewControllerDataSource methods
- (NSInteger)numberOfViewControllers
{
    return [self.guideCategorys count];
}
- (UIViewController *)viewControllerForIndex:(NSInteger)index
{
    THGuideArticlesTableViewController *articleVc = [[THGuideArticlesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    articleVc.category = self.guideCategorys[index];
    return articleVc;
}
- (NSArray *)titleTabList
{
    return [self.categoryNames copy];
}
- (CGFloat)tabHeight
{
    return 36.f;
}
- (UIColor *)normalTitleColor
{
    return RGBCOLOR(0x44, 0x44, 0x44);
}
- (UIColor *)selectedTitleColor
{
    return RGBCOLOR(0xff, 0x93, 0x3d);
}

#pragma mark - TXPagerScrollViewControllerDelegate methods
- (void)pageScrollViewController:(TXPageScrollViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index
{
//    NSLog(@"Did transition to tab %ld", (long)index);
}

@end
