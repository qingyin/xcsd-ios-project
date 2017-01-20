//
//  AddShutUpViewController.h
//  ChildHoodStemp
//
//  Created by steven_l on 15/2/27.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^AddShutUpFinishBlock)(NSArray *arr);
@interface AddShutUpViewController : BaseViewController

@property (nonatomic, assign) int32_t deptId;
@property (nonatomic, copy) AddShutUpFinishBlock block;
@property (nonatomic, strong) NSArray *listDataArr;
@property (nonatomic, strong) NSArray *hasBanArr;


@end
