//
//  ShutUpItemView.h
//  ChildHoodStemp
//
//  Created by steven_l on 15/2/13.
//
//

#import <UIKit/UIKit.h>
#import "MutiltimediaView.h"


typedef void(^DeleteShutItemBlock)(int  index);

@interface ShutUpItemView : UIView

@property (nonatomic, copy) DeleteShutItemBlock block;
@property (nonatomic,assign) int index;


-(id)initWithName:(NSString*)name portraitURI:(NSString*)uri withIndex:(int)index;

-(void)beginWobble;
-(void)endWobble;



@end
