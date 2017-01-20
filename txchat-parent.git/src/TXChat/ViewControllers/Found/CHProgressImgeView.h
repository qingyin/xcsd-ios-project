//
//  CHProgressImgeView.h
//  ChildHoodStemp
//
//  Created by Cloud on 14/12/29.
//
//

#import <UIKit/UIKit.h>

@interface CHProgressImgeView : UIImageView

@property (nonatomic, strong) UILabel *progressLb;

- (void)setProgress:(float)num;

@end
