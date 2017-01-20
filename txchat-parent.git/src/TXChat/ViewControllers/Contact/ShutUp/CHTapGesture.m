//
//  CHTapGesture.m
//  ChildHoodStemp
//
//  Created by zhuxuehang on 13-10-28.
//
//

#import "CHTapGesture.h"

@implementation CHTapGesture
@synthesize userInfo = _userInfo;
@synthesize tag = _tag;

-(id)initWithTarget:(id)target action:(SEL)action userInfo:(NSDictionary*)userinfo
{
    self = [super initWithTarget:target action:action];
    if (self) {
        _userInfo = [[NSMutableDictionary alloc] initWithDictionary:userinfo];
    }
    return self;
}

-(id)initWithTarget:(id)target action:(SEL)action tag:(NSInteger)tag
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.tag = tag;
        _userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];

    }
    return self;
}

-(id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
//        _userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"CHTapGesture dealloc");
}
@end
