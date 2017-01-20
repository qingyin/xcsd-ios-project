//
//  ChineseToPinyin.h
//  LianPu
//
//  Created by shawnlee on 10-12-16.
//  Copyright 2010 lianpu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pinyin.h"

@interface ChineseToPinyin : NSObject {

}
char pinyinFirstLetter(unsigned short hanzi);
+ (NSString *) pinyinFromChineseString:(NSString *)string;
+ (char) sortSectionTitle:(NSString *)string; 
@end
