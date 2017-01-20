//
//  NSString+ParentType.m
//  TXChat
//
//  Created by Cloud on 15/6/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NSString+ParentType.h"

@implementation NSString (ParentType)

+ (NSString *)getParentTypeStr:(TXPBParentType)type{
    switch (type) {
        case TXPBParentTypeFather:
            return @"爸爸";
        case TXPBParentTypeMother:
            return @"妈妈";
        case TXPBParentTypeFathersfather:
            return @"爷爷";
        case TXPBParentTypeFathersmother:
            return @"奶奶";
        case TXPBParentTypeMothersfather:
            return @"姥爷";
        case TXPBParentTypeMothersmother:
            return @"姥姥";
        case TXPBParentTypeOtherparenttype:
            return @"亲属";
        default:
            break;
    }
}

+ (NSString *)getSexTypeStr:(TXPBSexType)type{
    switch (type) {
        case  TXPBSexTypeMale:
            return @"男";
            break;
        case TXPBSexTypeFemale:
            return @"女";
        default:
            return @"未选择";
            break;
    }
}

@end
