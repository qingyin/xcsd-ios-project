//
//  Enum+Utils.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

typedef NS_ENUM(NSInteger, HomeListType) {
    HomeListType_Announcement = 0,          //公告
    HomeListType_Activity,                  //活动
    HomeListType_Recipes,                   //食谱
    HomeListType_Medicine,                  //喂药
    HomeListType_Guardian,                  //刷卡
    HomeListType_Notice,                    //通知
    HomeListType_Mail,                      //院长信箱
    HomeListType_Insurance,                 //保险
    HomeListType_Game,                      //游戏 by mey
    HomeListType_HomeWork = 14,                  //作业 by zhang
    HomeListType_Achievement,               //学能成绩 by mey
	HomeListType_StudentSefaty,             //学生安全
	HomeListType_ThemeTest,                 //主题测试 by sck
    HomeListType_Course,                   // 空中课堂

};

typedef NS_ENUM(SInt32, TXHomePostType) {
    TXHomePostType_Activity = 1,           //活动
    TXHomePostType_Announcement = 2,       //公告
    TXHomePostType_Learngarden = 3,        //微学园
    TXHomePostType_Intro = 4,              //介绍
    TXHomePostType_Recipes = 5,            //食谱
    TXHomePostType_ServiceAgreement = 6,   //服务协议
    TXHomePostType_WeiXueYuanPush,         //微学园的push
    TXHomePostType_GardenPost,             //园公众号
    TXHomePostType_HomeWork,      //作业
};

typedef NS_ENUM(NSInteger, FoundType) {
    FoundType_None = 0,
    FoundType_Circle,                      //亲子圈
    FoundType_WeiXueYuan,                  //微学园
    FoundType_Event,                       //活动专区
    FoundType_Shop,                        //积分商城
    FoundType_RecordDraw,                  //抽奖记录
    FoundType_MultiMedia,                  //多媒体
    FoundType_ClassBroadcast,              //微课堂直播
//    by mey
//    FoundType_Game,                       //game
};