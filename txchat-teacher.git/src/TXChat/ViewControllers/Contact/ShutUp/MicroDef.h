//
//  MicroDef.h
//  wanzhaoIM
//
//  Created by liuyuantao on 15/4/7.
//  Copyright (c) 2015年 liuyuantao. All rights reserved.
//

#ifndef wanzhaoIM_MicroDef_h
#define wanzhaoIM_MicroDef_h

#define HARDWARE_SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
#define HARDWARE_SCREEN_HEIGHT  ([UIScreen mainScreen].bounds.size.height)
#define CommonColor             [UIColor whiteColor]           //界面背景颜色
#define Contact_EdgeSpaceToTop      30
#define Contact_LabelHight          20
#define Contact_LabelWidth          60
#define Contact_BtnHorizontalSpace  5
#define Contact_BtnVerticalSpace    5
#define Contact_BtnEdge             70
#define Contact_LabelNameHeight     20
#define Contact_MemberWidth         (Contact_BtnEdge+2*Contact_BtnHorizontalSpace)
#define Contact_MemberHeight        (Contact_BtnEdge+Contact_LabelNameHeight+Contact_BtnVerticalSpace)
#define Contact_EdgeSpaceToLeft     (HARDWARE_SCREEN_WIDTH - 4*Contact_MemberWidth)/2
#define Contact_EdgeSpaceToLeft_h   (HARDWARE_SCREEN_WIDTH - 5*Contact_MemberWidth)/2

#define ContentLightGrayColor   [UIColor lightGrayColor]        //界面所用小字号所用字体颜色
#define ContentDarkGrayColor    [UIColor grayColor]             //界面所用中字号所用字体颜色
//#define SpecialGrayColor        [UIUtil colorWithHexString:@"#595757" withAlpha:1]      //界面所用大字号所用字体颜色
#define SpecialGrayColor                RGBCOLOR(0x59, 0x57, 0x57)      //界面所用大字号所用字体颜色

#define SpecialFont             [UIFont systemFontOfSize:16]    //界面所用大字号
#define ContentLightFont        [UIFont systemFontOfSize:12]    //界面所用小字号
#define ContentDarkFont         [UIFont systemFontOfSize:14]    //界面所用中字号

typedef enum {
    SNSPMaterialTypeKMessage = 1,
    SNSPMaterialTypeKImage = 2,
    SNSPMaterialTypeKAudio = 3,
    SNSPMaterialTypeKVideo = 4,
    SNSPMaterialTypeKEmotion = 5,
    SNSPMaterialTypeKImageMessage = 100,
} SNSPMaterialType;

#endif
