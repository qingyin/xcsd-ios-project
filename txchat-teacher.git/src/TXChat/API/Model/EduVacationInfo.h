//
//  EduVacationInfo.h
//  EduiPhone
//
//  Created by mac on 15-4-17.
//  Copyright (c) 2015年 ctrip. All rights reserved.
//

#import "BaseJSONModel.h"
#import "VacationInfo.h"

@protocol EduVacationInfo
@end

@interface EduVacationInfo : BaseJSONModel

@property NSString* id;
@property NSString* pic;

@property NSString* sharePic;
@property NSString* introduction;

@property NSString* title;
@property NSString* content;

@property NSString* eleArticleId;
@property NSString* eleArticleIntroduction;
@property NSString* eleArticlePic;
@property NSString* eleArticleTitle;

@property NSArray<VacationInfo>* vacations;

@end
