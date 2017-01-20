//
//  ShutUpOperateViewController.h
//  ChildHoodStemp
//
//  Created by steven_l on 15/2/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ShutUpOperateViewController : BaseViewController

@property (nonatomic, copy) NSString *leftTitle;
@property (nonatomic, assign) int32_t deptId;
@property (nonatomic, strong) NSArray *listMemberArr;

- (void)onGetShutUpListArr:(NSArray *)listArr;

@end
