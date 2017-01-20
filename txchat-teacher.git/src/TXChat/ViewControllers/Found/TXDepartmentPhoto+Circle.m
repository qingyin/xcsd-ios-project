//
//  TXDepartmentPhoto+Circle.m
//  TXChatParent
//
//  Created by Cloud on 15/10/19.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXDepartmentPhoto+Circle.h"

static void *Index = (void *)@"Index";

@implementation TXDepartmentPhoto (Circle)

- (NSNumber *)index{
    return objc_getAssociatedObject(self, Index);
}

- (void)setIndex:(NSNumber *)index{
    objc_setAssociatedObject(self, Index, index, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
