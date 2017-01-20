//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "EMSDWebImageDecoder.h"
#import "EMSDWebImageManager.h"
#import "EMSDWebImageOperation.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MessageProgressObj.h"
#import "CommonUtils.h"

@interface MWPhoto () {
    
    BOOL _loadingInProgress;
    id <EMSDWebImageOperation> _webImageOperation;
    
}

- (void)imageLoadingComplete;

@end

@implementation MWPhoto

@synthesize underlyingImage = _underlyingImage; // synth property from protocol

#pragma mark - Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
    return [[MWPhoto alloc] initWithImage:image];
}

// Deprecated
+ (MWPhoto *)photoWithFilePath:(NSString *)path {
    return [MWPhoto photoWithURL:[NSURL fileURLWithPath:path]];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
    return [[MWPhoto alloc] initWithURL:url];
}

+ (MWPhoto *)photoWithCustomPhoto:(EMMessage *)customPhoto
{
    return [[MWPhoto alloc] initWithCustomPhoto:customPhoto];
}
#pragma mark - Init

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        _image = image;
    }
    return self;
}

// Deprecated
- (id)initWithFilePath:(NSString *)path {
    if ((self = [super init])) {
        _photoURL = [NSURL fileURLWithPath:path];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        _photoURL = [url copy];
    }
    return self;
}
- (id)initWithCustomPhoto:(EMMessage *)customPhoto
{
    if ((self = [super init])) {
        _customPhoto = customPhoto;
    }
    return self;
}
#pragma mark - MWPhoto Protocol Methods
//重新加载图片
- (void)reloadURLImage
{
    if (!_photoURL) {
//        DDLogDebug(@"重新加载图片失败，因为没有PhotoUrl");
        return;
    }
    EMSDWebImageManager *manager = [EMSDWebImageManager sharedManager];
    if ([manager cachedImageExistsForURL:_photoURL]) {
        NSString *key = [manager cacheKeyForURL:_photoURL];
        EMSDImageCache *cache = [EMSDImageCache sharedImageCache];
        [cache removeImageForKey:key fromDisk:YES withCompletion:^{
//            DDLogDebug(@"重新加载----删除图片成功:%@",_photoURL);
            self.underlyingImage = nil;
            _loadingInProgress = NO;
            //重新加载
            [self loadUnderlyingImageAndNotify];
        }];
    }
}

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self imageLoadingComplete];
            });
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self imageLoadingComplete];
        });
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
        // Check what type of url it is
        if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
            
            // Load from asset library async
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    @try {
                        ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                        [assetslibrary assetForURL:self->_photoURL
                                       resultBlock:^(ALAsset *asset){
                                           ALAssetRepresentation *rep = [asset defaultRepresentation];
                                           CGImageRef iref = [rep fullScreenImage];
                                           if (iref) {
                                               self.underlyingImage = [UIImage imageWithCGImage:iref];
                                           }
                                           [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                                       }
                                      failureBlock:^(NSError *error) {
                                          self.underlyingImage = nil;
                                          MWLog(@"Photo from asset library error: %@",error);
                                          [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                                      }];
                    } @catch (NSException *e) {
                        MWLog(@"Photo from asset library error: %@", e);
                        [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                    }
                }
            });
            
        } else if ([_photoURL isFileReferenceURL]) {
            
            // Load from local file async
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    @try {
                        self.underlyingImage = [UIImage imageWithContentsOfFile:self->_photoURL.path];
                        if (!self->_underlyingImage) {
                            MWLog(@"Error loading photo from path: %@", _photoURL.path);
                        }
                    } @finally {
                        [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                    }
                }
            });
            
        } else {
//            //先添加图片加载效果
//            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [NSNumber numberWithFloat:0.01], @"progress",
//                                  self, @"photo", nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
            // Load async from web (using SDWebImage)
            @try {
                EMSDWebImageManager *manager = [EMSDWebImageManager sharedManager];
//                WEAKSELF
                // by mey
                __weak __typeof(&*self) weakSelf=self;
                _webImageOperation = [manager downloadImageWithURL:_photoURL
                                                           options:0
                                                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                              if (expectedSize > 0) {
                                                                  float progress = receivedSize / (float)expectedSize;
                                                                  NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        [NSNumber numberWithFloat:progress], @"progress",
                                                                                        self, @"photo", nil];
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
                                                              }
                                                          }
                                                         completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                                             if (error) {
//                                                                 DDLogDebug(@"图片加载SDWebImage failed to download image: %@", error);
//                                                             }
                                                             __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                             if (strongSelf) {
                                                                 if (finished) {
                                                                     strongSelf->_webImageOperation = nil;
                                                                     strongSelf->_loadingInProgress = NO;
                                                                 }
                                                                 strongSelf.underlyingImage = image;
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [strongSelf imageLoadingComplete];
                                                                 });
                                                             }
                                                         }];
            } @catch (NSException *e) {
                MWLog(@"Photo from web: %@", e);
                _webImageOperation = nil;
                [self imageLoadingComplete];
            }
            
        }
        
    }else if (_customPhoto) {
        // Check what type of url it is
//        //先post图片加载通知
//        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [NSNumber numberWithFloat:0.01], @"progress",
//                              self, @"photo", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
        //加载图片
        EMMessage *_message = (EMMessage *)_customPhoto;
        @try {
            id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
            id<IEMMessageBody> messageBody = [[_message messageBodies] firstObject];
            EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
            
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed) {
                NSString *localPath = [imageBody localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    if (image)
                    {
                        self.underlyingImage = image;
                        [self imageLoadingComplete];
                    }
                }
            }else{
                MessageProgressObj *obj = [[MessageProgressObj alloc] initWithProgressBlock:^(float progress) {
                    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithFloat:progress], @"progress",
                                          self, @"photo", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
                }];
                [chatManager asyncFetchMessage:_message progress:obj completion:^(EMMessage *aMessage, EMError *error) {
                    if (!error) {
                        [self resetWebImageOperation];
                        
                        NSString *localPath = [imageBody localPath];
                        if (localPath && localPath.length > 0) {
                            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                            if (image) {
                                self.underlyingImage = image;
                            }
                        }
                        [self imageLoadingComplete];
                        //发送列表刷新通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:EMMessageImageLoadSuccessNotification object:_message userInfo:nil];
                    }
                    
                } onQueue:nil];
            }
        } @catch (NSException *e) {
            //        MWLog(@"Photo from message: %@", e);
            [self resetWebImageOperation];
            [self imageLoadingComplete];
        }
    } else {
        
        // Failed - no source
        @throw [NSException exceptionWithName:@"NO object to show!" reason:nil userInfo:nil];
        
    }
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    self.underlyingImage = nil;
}

- (void)resetWebImageOperation
{
    _webImageOperation = nil;
}
- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    //    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelAnyLoading {
    if (_webImageOperation) {
        [_webImageOperation cancel];
        _loadingInProgress = NO;
    }
}

@end
