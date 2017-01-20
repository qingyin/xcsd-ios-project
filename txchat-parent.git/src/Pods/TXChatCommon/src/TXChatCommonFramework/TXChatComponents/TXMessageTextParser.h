//
//  TXMessageTextParser.h
//  TXChatCommonFramework
//
//  Created by 陈爱彬 on 15/12/21.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYText.h>

@interface TXMessageTextParser : NSObject
<YYTextParser>

@property (nonatomic,strong) UIColor *highlightColor;

@end
