/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "MessageReadManager.h"
#import "UIImageView+EMWebCache.h"
#import "EMCDDeviceManager.h"

static MessageReadManager *detailInstance = nil;

@interface MessageReadManager()

@property (strong, nonatomic) UIWindow *keyWindow;

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) UINavigationController *photoNavigationController;

@property (strong, nonatomic) UIAlertView *textAlertView;

@end

@implementation MessageReadManager

+ (id)defaultManager
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            detailInstance = [[self alloc] init];
        });
    }
    
    return detailInstance;
}

#pragma mark - getter

- (UIWindow *)keyWindow
{
    if(_keyWindow == nil)
    {
        _keyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    
    return _keyWindow;
}

- (NSMutableArray *)photos
{
    if (_photos == nil) {
        _photos = [[NSMutableArray alloc] init];
    }
    
    return _photos;
}

- (MWPhotoBrowser *)photoBrowser
{
    if (_photoBrowser == nil) {
        _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        _photoBrowser.displayActionButton = YES;
        _photoBrowser.displayNavArrows = YES;
        _photoBrowser.displaySelectionButtons = NO;
        _photoBrowser.alwaysShowControls = NO;
//        _photoBrowser.wantsFullScreenLayout = YES;
        _photoBrowser.zoomPhotosToFill = YES;
        _photoBrowser.enableGrid = NO;
        _photoBrowser.startOnGrid = NO;
        [_photoBrowser setCurrentPhotoIndex:0];
    }
    
    return _photoBrowser;
}

- (UINavigationController *)photoNavigationController
{
    if (_photoNavigationController == nil) {
        _photoNavigationController = [[UINavigationController alloc] initWithRootViewController:self.photoBrowser];
        _photoNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    [self.photoBrowser reloadData];
    return _photoNavigationController;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [self.photos count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.photos.count)
    {
        return [self.photos objectAtIndex:index];
    }
    
    return nil;
}


#pragma mark - private


#pragma mark - public

- (void)showBrowserWithImages:(NSArray *)imageArray
{
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            MWPhoto *photo = nil;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [MWPhoto photoWithImage:object];
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                photo = [MWPhoto photoWithURL:object];
            }
            else if ([object isKindOfClass:[NSString class]])
            {
                
            }
            if(photo)
            {
                [photoArray addObject:photo];
            }
        }
        
        self.photos = photoArray;
    }
    
    UIViewController *rootController = [self.keyWindow rootViewController];
    [rootController presentViewController:self.photoNavigationController animated:YES completion:nil];
}

- (BOOL)prepareMessageAudioModel:(id<TXMessageModelData>)messageModel
                      updateViewCompletion:(void (^)(id<TXMessageModelData> prevAudioModel, id<TXMessageModelData> currentAudioModel))updateCompletion
{
    BOOL isPrepare = NO;
    
    if ([messageModel messageMediaType] == TXBubbleMessageMediaTypeVoice) {
        id<TXMessageModelData> prevAudioModel = self.audioMessageModel;
        id<TXMessageModelData> currentAudioModel = messageModel;
        self.audioMessageModel = messageModel;
        
        BOOL isPlaying = [messageModel isVoicePlaying];
        if (isPlaying) {
            [messageModel setIsVoicePlaying:NO];
            self.audioMessageModel = nil;
            currentAudioModel = nil;
            [[EMCDDeviceManager sharedInstance] stopPlaying];
        }
        else {
            [messageModel setIsVoicePlaying:YES];
            [prevAudioModel setIsVoicePlaying:NO];
            isPrepare = YES;
            
            if (![messageModel isVoicePlayed]) {
                [messageModel setIsVoicePlayed:YES];
//                [[NSNotificationCenter defaultCenter] postNotificationName:EMMessageVoiceHasPlayedNotification object:nil userInfo:@{@"msg":messageModel}];
                EMMessage *chatMessage = messageModel.message;
                if (chatMessage.ext) {
                    NSMutableDictionary *dict = [chatMessage.ext mutableCopy];
                    if (![[dict objectForKey:@"isPlayed"] boolValue]) {
                        [dict setObject:@YES forKey:@"isPlayed"];
                        chatMessage.ext = dict;
                        [chatMessage updateMessageExtToDB];
                    }
                }
            }
        }
        
        if (updateCompletion) {
            updateCompletion(prevAudioModel, currentAudioModel);
        }

    }
    
    return isPrepare;
}

- (id<TXMessageModelData>)stopMessageAudioModel
{
    id<TXMessageModelData> model = nil;
    if ([self.audioMessageModel messageMediaType] == TXBubbleMessageMediaTypeVoice) {
        if ([self.audioMessageModel isVoicePlaying]) {
            model = self.audioMessageModel;
        }
        [self.audioMessageModel setIsVoicePlaying:NO];
        self.audioMessageModel = nil;
    }
    
    return model;
}


@end
