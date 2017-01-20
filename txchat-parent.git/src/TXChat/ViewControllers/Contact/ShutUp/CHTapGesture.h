//
//  CHTapGesture.h
//  ChildHoodStemp
//
//  Created by zhuxuehang on 13-10-28.
//
//

#import <Foundation/Foundation.h>

@interface CHTapGesture : UITapGestureRecognizer
{
    NSMutableDictionary *_userInfo;
    NSInteger _tag;
}
@property (nonatomic,retain) NSMutableDictionary* userInfo;
@property (nonatomic,assign) NSInteger tag;
-(id)initWithTarget:(id)target action:(SEL)action userInfo:(NSDictionary*)userinfo;
-(id)initWithTarget:(id)target action:(SEL)action tag:(NSInteger)tag;
@end
