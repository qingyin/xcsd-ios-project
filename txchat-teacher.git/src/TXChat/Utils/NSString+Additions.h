//
//  NSString+Additions.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/9.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

//获取需要绘制出文本的size
- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)font1 lineSpace:(float)lineSpace;
- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)font1 lineSpace:(float)lineSpace;
//获取需要绘制出文本的行数
- (NSInteger)numberOfLinesWithConstrainedToWidth:(CGFloat)width fromFont:(UIFont *)font1 lineSpace:(float)lineSpace;

@end
