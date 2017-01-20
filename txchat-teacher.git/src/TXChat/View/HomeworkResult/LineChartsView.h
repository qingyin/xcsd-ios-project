//
//  LineChartsView.h
//  ChartsTest
//
//  Created by gaoju on 16/7/11.
//  Copyright © 2016年 Shlvit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineChartsView : UIView

- (void)setRowDataSource:(NSArray<NSString *> *)rowArr;

- (void)setColDataSource:(NSArray<NSString *> *)colArr;

- (void)setAllPoints:(NSArray *)points;

@property (nonatomic, assign) NSInteger length;

@property (nonatomic, assign) NSInteger colSize;

@end
