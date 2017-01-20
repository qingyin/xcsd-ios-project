//
//  SignInAnimation.h
//  TXChatTeacher
//
//  Created by lyt on 15/10/19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignInAnimation : NSObject
+ (instancetype)sharedManager;
-(void)showSignInAnimation:(NSInteger)weiDouNumber;
@end
