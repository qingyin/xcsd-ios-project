//
//  NSURL+ZXURL.h
//  ZXTools
//
//  Created by zhangxi on 13-6-21.
//  Copyright (c) 2013年 张玺. All rights reserved.
//

/*
demo

    NSURL *url = [NSURL URLWithString:@"http://zhangxi.me/?name=cc&birth=6.12"];
    
    NSLog(@"%@",[url parameters]);
    NSLog(@"%@",[url parameterForKey:@"name"]);    //cc
    NSLog(@"%@",[url parameterForKey:@"sex"]);     //(null)
    NSLog(@"%@",[url parameterForKey:@"birth"]);   //6.12

*/


#import <Foundation/Foundation.h>

@interface NSURL (ZXURL)


-(NSString *)parameterForKey:(NSString *)key;
-(NSDictionary  *)parameters;

@end
