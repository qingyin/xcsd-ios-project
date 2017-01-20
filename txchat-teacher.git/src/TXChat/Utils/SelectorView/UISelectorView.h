//
//  UISelectorView.h
//  GasHome
//
//  Created by Alan on 13-6-25.
//  Copyright (c) 2013年 AutoHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UISelectorViewDelegate;

@interface UISelectorView : UIView <UITableViewDataSource, UITableViewDelegate>{
    BOOL isBuildFinish;
}

@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat marginWidth;
@property (nonatomic, strong) UIColor *colorStateNormal;
@property (nonatomic, strong) UIColor *colorStateSelected;
@property (nonatomic, strong) UIColor *colorSelector;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, readonly) NSMutableArray *selectedIndexPaths;
@property (nonatomic, weak) id <UISelectorViewDelegate> delegate;

- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;

@end

@protocol UISelectorViewDelegate <NSObject>
@optional

- (void)selectorView:(UISelectorView *)selectorView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end


