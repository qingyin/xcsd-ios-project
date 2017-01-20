//
//  TXReportManager.m
//  TXChatParent
//
//  Created by lyt on 15/12/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXReportManager.h"
#import <ZipArchive.h>
#import "AppDelegate.h"
#import "BaseViewController.h"

@implementation TXReportManager

//单例
+ (instancetype)shareInstance
{
    static TXReportManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}


-(BOOL)updateLoggs:(BaseViewController *)showInVC complete:(UpdateLoggsCallBack)complete
{
    
    NSMutableArray *fileLoggers = [NSMutableArray arrayWithCapacity:5];
    [fileLoggers addObjectsFromArray:[self getEaseLogs]];
    [fileLoggers addObjectsFromArray:[self getWJYLoggs]];
    [fileLoggers addObjectsFromArray:[self getEaseDb]];
    [fileLoggers addObjectsFromArray:[self getWJYDB]];
    //    DLog(@"fileLoggers:%@", fileLoggers );
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    
    NSString *sZipPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/wjy_%lld.zip", currentUser.userId]];
    
    BOOL bRet = [zip CreateZipFile2:sZipPath];
    if(!bRet)
    {
        return NO;
    }
    int i = 0;
    if([fileLoggers count] > 0)
    {
        for(NSString *file in fileLoggers)
        {
            [zip addFileToZip:file newname:[NSString stringWithFormat:@"%d_%@",i, [file lastPathComponent]]];
            i++;
        }
    }
    
    [zip CloseZipFile2];
    NSUUID *uuidkey = [NSUUID UUID];
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    [TXProgressHUD showHUDAddedTo:appdelegate.window withMessage:@"正在上传日志信息"];
//    __weak typeof(showInVC) weakSelf = showInVC;
    @weakify(self)
    [[TXChatClient sharedInstance] uploadData:[NSData dataWithContentsOfMappedFile:sZipPath] uuidKey:uuidkey fileExtension:@"zip" cancellationSignal:^BOOL{
        return NO;
    } progressHandler:^(NSString *key, float percent) {
        
    } onCompleted:^(NSError *error, NSString *serverFileKey, NSString *serverFileUrl) {
        DDLogDebug(@"error:%@, serverFileKey:%@, serverFileUrl:%@", error, serverFileKey, serverFileUrl);
        @strongify(self);
        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        [TXProgressHUD hideHUDForView:appdelegate.window animated:YES];
        [self delTmpZipFile];
        NSString *alertMsg = nil;
        if(error)
        {
            alertMsg = @"上传日志信息失败";
        }
        else
        {
            alertMsg = @"上传日志信息成功";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [showInVC showFailedHudWithTitle:alertMsg];
        });
        [[TXChatClient sharedInstance] log:serverFileUrl onCompleted:^(NSError *error) {
            DDLogDebug(@"error:%@", error);
            if(complete)
            {
                complete(error, serverFileUrl);
            }
        }];
    }];
    return YES;
}

-(void)delTmpZipFile
{
    
    
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    
    NSString *sZipPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/wjy_%lld.zip", currentUser.userId]];
    [[NSFileManager defaultManager] removeItemAtPath:sZipPath error:nil];
}

//获取微家园日志文件列表
-(NSArray *)getWJYLoggs
{
    
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/sdkLogs/"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath])
    {
        return nil;
    }
    NSMutableArray *fileLoggs = [NSMutableArray arrayWithCapacity:5];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath: logPath ];
    for(NSString *file in files)
    {
        [fileLoggs addObject:[NSString stringWithFormat:@"%@/%@", logPath, file]];
    }
    return fileLoggs;
}

-(NSArray *)getEaseLogs
{
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/EaseMobLog/"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath])
    {
        return nil;
    }
    NSMutableArray *fileLoggs = [NSMutableArray arrayWithCapacity:5];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath: logPath ];
    for(NSString *file in files)
    {
        [fileLoggs addObject:[NSString stringWithFormat:@"%@/%@", logPath, file]];
    }
    return fileLoggs;
}

//获取环信数据库
-(NSArray *)getEaseDb
{
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/easemobDB/"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath])
    {
        return nil;
    }
    NSMutableArray *fileLoggs = [NSMutableArray arrayWithCapacity:5];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath: logPath ];
    for(NSString *file in files)
    {
        [fileLoggs addObject:[NSString stringWithFormat:@"%@/%@", logPath, file]];
    }
    return fileLoggs;
    
}

//获取微家园数据库
-(NSArray *)getWJYDB
{
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath])
    {
        return nil;
    }
    NSMutableArray *fileLoggs = [NSMutableArray arrayWithCapacity:5];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath: logPath ];
    for(NSString *file in files)
    {
        if([file hasSuffix:@".sqlite"] || [file hasSuffix:@".plist"])
        {
            [fileLoggs addObject:[NSString stringWithFormat:@"%@/%@", logPath, file]];
        }
    }
    return fileLoggs;
}



@end
