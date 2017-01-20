//
//  TXGreetingCell.h
//  TXChatParent
//
//  Created by gaoju on 12/28/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXGreetingCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) void(^startBlock)();

@end
