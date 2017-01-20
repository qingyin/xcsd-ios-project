//
//  GroupDetailHeader.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    GROUPDETAILHEADER_GROUP,
    GROUPDETAILHEADER_BABY,
}GROUPDETAILHEADER;


@interface GroupDetailHeader : UIView
@property(nonatomic, strong)IBOutlet UIImageView *bkImage;
@property(nonatomic, strong)IBOutlet UIImageView *headerImage;
@property(nonatomic, strong)IBOutlet UIView *headerBK;

-(void)setViewModel:(GROUPDETAILHEADER)model;


@end
