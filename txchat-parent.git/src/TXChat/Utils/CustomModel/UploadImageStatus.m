//
//  UploadImageStatus.m
//  TXChat
//
//  Created by lyt on 15-7-1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UploadImageStatus.h"

@implementation UploadImageStatus
-(id)init
{
    self =[super init];
    if(self)
    {
        _uploadImage = nil;
        _uploadStatus = UPLOADIMAGE_STATUS_NORMAL;
        _uuidKey = nil;
        _serverFileKey = nil;
        _process = 0.0f;
    }
    return self;
}




@end
