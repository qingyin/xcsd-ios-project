//
//  NSString+ParentType.h
//  TXChat
//
//  Created by Cloud on 15/6/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ParentType)

+ (NSString *)getParentTypeStr:(TXPBParentType)type;
+ (NSString *)getSexTypeStr:(TXPBSexType)type;

@end
