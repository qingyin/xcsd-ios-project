//
//  HomeWorkType.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/31.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkType.h"

@implementation HomeWorkType
-(instancetype)init{
    self=[super init];
    if (self) {
        self.homeWorkTypeArray =[NSMutableArray array];
        self.homeWorkBriefArray =[NSMutableArray array];
        self.homeWorkTypeArray=@[@"系统定制作业",@"教师自主作业"];
        self.homeWorkBriefArray=@[@"乐学堂会根据学生学能测试和作业成绩定制适合学生水平的作业",@"你可以给学生统一布置相同的作业，来考察学生的成绩水平"];
    }
    return self;
}

@end
