//
//  UploadImageStatus.h
//  TXChat
//
//  Created by lyt on 15-7-1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    UPLOADIMAGE_STATUS_NORMAL = 0,//正常
    UPLOADIMAGE_STATUS_UPLOADING = 1,//上传中
    UPLOADIMAGE_STATUS_FAILED = 2,//失败
}UPLOADIMAGE_STATUS_T;
@interface UploadImageStatus : NSObject
@property(nonatomic, strong)UIImage *uploadImage;
@property(nonatomic, assign)UPLOADIMAGE_STATUS_T uploadStatus;
@property(nonatomic, strong)NSUUID *uuidKey;//全局唯一key
@property(nonatomic, strong)NSString *serverFileKey;//服务器文件名
@property(nonatomic, copy)NSString *serverFileUrl;//服务器url
@property(nonatomic, assign)CGFloat process;
//视频URL
@property (nonatomic,strong) NSURL *videoURL;

@end
