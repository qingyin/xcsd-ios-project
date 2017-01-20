//
//  AlbumPickerController.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"

@interface ELCAlbumPickerController ()

@property (nonatomic, strong) ALAssetsLibrary *library;

@end

@implementation ELCAlbumPickerController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationItem setTitle:@"Loading..."];
    [self.navigationItem setTitle:@"照片"];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.parent action:@selector(cancelImagePicker)];
    [self.navigationItem setRightBarButtonItem:cancelButton];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.assetGroups = tempArray;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    self.library = assetLibrary;
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       // Group enumerator Block
                       void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                       {
                           if (group == nil) {
                               return;
                           }
                           
                           // added fix for camera albums order
                           NSString *sGroupPropertyName = (NSString *)[group valueForProperty:ALAssetsGroupPropertyName];
                           NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                           
                           if (([[sGroupPropertyName lowercaseString] isEqualToString:@"camera roll"] || [sGroupPropertyName isEqualToString:@"相机胶卷"]) && nType == ALAssetsGroupSavedPhotos) {
                               [self.assetGroups insertObject:group atIndex:0];
                           }
                           else {
                               [self.assetGroups addObject:group];
                           }
                           
                           // Reload albums
                           [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:YES];
                       };
                       
                       // Group Enumerator Failure Block
                       void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                           //[error localizedDescription]
                           if ([self.delegate respondsToSelector:@selector(ELCAlbumPickerControllerSelectingDisabled:)]) {
                               [self.delegate ELCAlbumPickerControllerSelectingDisabled:self];
                           }
                           
                           UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                           bgView.backgroundColor = kColorWhite;
                           [self.view addSubview:bgView];
                           
                           UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
                           label.textAlignment = NSTextAlignmentCenter;
                           label.numberOfLines = 0;
                           label.textColor = kColorBlack;
                           label.font = kFontLarge_1;
                           [self.view addSubview:label];
                           NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                           NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
                           NSString *str = [NSString stringWithFormat:@"没有权限访问您的相册\n\n请到“设置-隐私照片”里\n把”%@“的开关打开即可",app_Name];
                           NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
                           [attributedString addAttribute:NSFontAttributeName value:kFontSuper range:[str rangeOfString:@"没有权限访问您的相册"]];
                           label.attributedText = attributedString;
                           [label sizeToFit];
                           label.frame = CGRectMake(0, 0, label.width_, label.height_);
                           label.center = CGPointMake(kScreenWidth/2, (self.view.height_ - 64)/2);
                           
                           UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                           settingBtn.frame = CGRectMake(0, 0, 140, 40);
                           settingBtn.backgroundColor = kColorBlue;
                           settingBtn.layer.cornerRadius = 5;
                           settingBtn.layer.masksToBounds = YES;
                           [settingBtn setTitle:@"去设置" forState:UIControlStateNormal];
                           [settingBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
                           settingBtn.titleLabel.font = kFontLarge_1;
                           [self.view addSubview:settingBtn];
                           
                           settingBtn.center = CGPointMake(kScreenWidth/2, label.centerY + 5 + 20 + label.height_/2);
                           [settingBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
                           }];

                           
//                           UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"用户拒绝访问相册" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
//                           [alert show];
                           
                           //NSLog(@"A problem occured %@", [error description]);
                       };
                       
                       // Enumerate Albums
                       [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                                   usingBlock:assetGroupEnumerator
                                                 failureBlock:assetGroupEnumberatorFailure];
                   });
    
    if ([self.delegate respondsToSelector:@selector(ELCAlbumPickerControllerDidSelectingAlbumn:)]) {
        [self.delegate ELCAlbumPickerControllerDidSelectingAlbumn:self];
    }
}

- (void)reloadTableView
{
    [self.tableView reloadData];
    //[self.navigationItem setTitle:@"照片"];
}

- (void)selectedAssets:(NSArray*)assets
{
    [_parent selectedAssets:assets];
}

- (BOOL)selectedNumber:(NSInteger)number
{
    return [_parent selectedNumber:number];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.assetGroups count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get count
    ALAssetsGroup *g = (ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row];
    [g setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSInteger gCount = [g numberOfAssets];
    
    NSString *groupName = [g valueForProperty:ALAssetsGroupPropertyName];
    if ([[groupName lowercaseString] isEqualToString:@"camera roll"])
        groupName = @"相机胶卷";
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", groupName, (long)gCount];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup*)[self.assetGroups objectAtIndex:indexPath.row] posterImage]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ELCAssetTablePicker *picker = [[ELCAssetTablePicker alloc] initWithNibName: nil bundle: nil];
    picker.singleSelection = self.singleSelection;
    picker.parent = self;
    
    picker.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
    [picker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    if ([self.delegate respondsToSelector:@selector(ELCAlbumPickerController:didSelectAlbumn:)]) {
        [self.delegate ELCAlbumPickerController:self didSelectAlbumn:picker.assetGroup];
    }
    [self.navigationController pushViewController:picker animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 57;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

//- (void)viewDidUnload {
//    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
//    // For example: self.myOutlet = nil;
//}

- (void)dealloc 
{	
}

@end

