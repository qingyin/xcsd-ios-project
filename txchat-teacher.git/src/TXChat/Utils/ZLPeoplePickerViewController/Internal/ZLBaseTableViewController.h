//
//  ZLBaseTableViewController.h
//  ZLPeoplePickerViewControllerDemo
//
//  Created by Zhixuan Lai on 11/5/14.
//  Copyright (c) 2014 Zhixuan Lai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLTypes.h"
#import "BaseViewController.h"

@class APContact;

static NSString *const kCellIdentifier = @"cellID";

@interface ZLBaseTableViewController : BaseViewController

@property (strong, nonatomic) NSMutableArray *partitionedContacts;
@property (strong, nonatomic) NSMutableSet *selectedPeople;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) ZLContactField filedMask;

- (void)setPartitionedContactsWithContacts:(NSArray *)contacts;
- (void)configureCell:(UITableViewCell *)cell forContact:(APContact *)product;
- (BOOL)shouldEnableCellforContact:(APContact *)contact;
- (APContact *)contactForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
