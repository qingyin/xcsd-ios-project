//
//  AlbumPickerController.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ELCAssetSelectionDelegate.h"
#import "ELCAssetTablePicker.h"
@protocol ELCAlbumPickerControllerDelegate;

@interface ELCAlbumPickerController : UITableViewController <ELCAssetSelectionDelegate>

@property (nonatomic, weak) id<ELCAssetSelectionDelegate> parent;
@property (nonatomic, strong) NSMutableArray *assetGroups;
@property (nonatomic, assign) BOOL singleSelection;         //单选
@property (nonatomic, assign) id<ELCAlbumPickerControllerDelegate> delegate;

@end
@protocol ELCAlbumPickerControllerDelegate <NSObject>

@optional
- (void)ELCAlbumPickerController:(ELCAlbumPickerController*)controller didSelectAlbumn:(ALAssetsGroup *)assetsGroup;
- (void)ELCAlbumPickerControllerDidSelectingAlbumn:(ELCAlbumPickerController*)controller;
- (void)ELCAlbumPickerControllerSelectingDisabled:(ELCAlbumPickerController*)controller;

@end
