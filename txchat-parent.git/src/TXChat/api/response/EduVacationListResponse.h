//
//  EduVacationListResponse.h
//  EduiPhone
//
//  Created by mac on 15-4-17.
//  Copyright (c) 2015年 ctrip. All rights reserved.
//

#import "BaseResponse.h"
#import "EduVacationInfo.h"

@interface EduVacationListResponse : BaseResponse

@property NSArray<EduVacationInfo>* result;

@end
