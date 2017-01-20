//
//  MutiltimediaView.m
//  ChildHoodStemp
//
//  Created by xuzuotao on 13-10-6.
//
//

#import "MutiltimediaView.h"
//#import "Snsp.pb.h"
//#import "ChildHoodConsts.h"
//#import "ChildHoodUser.h"
//#import "UIUtil.h"
//#import "CHPostService.h"
//#import "CHPostManager.h"
//#import "ChildHoodService.h"
//#import "CHResourceService.h"
//#import "CHSAudioPlayer.h"
//#import "ChildHoodService.h"
#import <AVFoundation/AVFoundation.h>
#import "MicroDef.h"
//#import "CHMessageManager.h"
//#import "ChildHoodMessage.h"
//#import "CHBubbleMessageCell.h"
#define BUBBLEVIEW_MAX_WIDTH HARDWARE_SCREEN_WIDTH - 150
#define BUBBLEVIEW_PIC_SIZE 85
@interface MutiltimediaView()<AVAudioPlayerDelegate>
{
    SNSPMaterialType _type;
    BOOL _audioIsExist;
    UILabel *_processLal;
}

@property(nonatomic,retain)UILabel *processLal;

-(void)onResourceDownloaded:(NSNotification*)notification;

-(void)showImageData;

- (void)scanImgMethod:(id)sender;

-(void)showImage:(UIImage*)image;

-(void)handlAudio;

-(void)handlImage;


@end


@implementation MutiltimediaView
@synthesize voiceType = _voiceType;
@synthesize fileUri = _fileUri;
@synthesize processLal = _processLal;

- (void)scanImgMethod:(id)sender
{
  //  [[NSNotificationCenter defaultCenter] postNotificationName:GetImgMemory object:sender];
}

-(void)dealloc
{
    NSLog(@"MutiltimediaView dealloc!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

-(void)showImageInChat:(UIImage *) image
{
        for (UIView *aView in [self subviews]) {
            [aView removeFromSuperview];
        }
        UIImageView* view = [[UIImageView alloc]init];
        [view setUserInteractionEnabled:YES];
        [self addSubview:view];

    CGSize sizeImage = image.size;
   
    
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat flag = sizeImage.width/sizeImage.height;
    if (flag>1) {
        width = BUBBLEVIEW_PIC_SIZE/sizeImage.height*sizeImage.width;
        height = BUBBLEVIEW_PIC_SIZE;
    }
    else if (flag<1) {
        width = BUBBLEVIEW_PIC_SIZE;
        height = BUBBLEVIEW_PIC_SIZE/image.size.width*image.size.height;
    }
    else if (flag==1) {
        width = BUBBLEVIEW_PIC_SIZE;
        height = BUBBLEVIEW_PIC_SIZE;
    }

    view.image = [self scaleToSize:image size:CGSizeMake(width, height)];
    view.frame = CGRectMake(0, 0, width, height);
    view.tag = self.tag;
    view.center = CGPointMake(BUBBLEVIEW_PIC_SIZE/2, BUBBLEVIEW_PIC_SIZE/2);
    self.processLal.frame = CGRectMake((width - 40)/2, (height - 20)/2, 40, 20);
    [self addSubview:self.processLal];
    [self bringSubviewToFront:self.processLal];
   // [view setNeedsDisplay];
}

-(void)showImage:(UIImage*)image
{
   
        for (UIView *aView in [self subviews]) {
            [aView removeFromSuperview];
        }
       // UIImageView* view = [[UIImageView alloc]init];
        //[view setUserInteractionEnabled:YES];

    CGRect rect = self.frame;
    CGSize sizeImage = image.size;
    UIImageView* view = [[UIImageView alloc]initWithImage:image];
    [view setUserInteractionEnabled:YES];

    
    
    //如果 长和宽都大于边界重新计算大小
    if(sizeImage.width > rect.size.width && sizeImage.height > rect.size.height)
    {
        if(sizeImage.width/sizeImage.height > rect.size.width/rect.size.height)
        {
            
            CGFloat width = rect.size.width;
            CGFloat height = rect.size.width*sizeImage.height/sizeImage.width;
            view.frame = CGRectMake(0,
                                    (rect.size.height - height)/2,
                                    width, height);
            
            
        }else{
            CGFloat height = rect.size.height;
            CGFloat width =  rect.size.height*sizeImage.width/sizeImage.height;
            view.frame = CGRectMake((rect.size.width - width)/2,
                                    0,
                                    width, height);
            
        }
    }else if(sizeImage.width > rect.size.width){
        //如果 宽大于边界重新计算大小
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.width*sizeImage.height/sizeImage.width;
        view.frame = CGRectMake(0,
                                (rect.size.height - height)/2,
                                width, height);
        
        
        
    }else if(sizeImage.height > rect.size.height){
        //如果 长大于边界重新计算大小
        CGFloat height = rect.size.height;
        CGFloat width =  rect.size.height*sizeImage.width/sizeImage.height;
        view.frame = CGRectMake((rect.size.width - width)/2,
                                0,
                                width, height);
        
    }else{
        //如果长和宽都小于或者等于边界，剧中显示
//        view.frame = CGRectMake((rect.size.width - sizeImage.width)/2,
//                                (rect.size.height - sizeImage.height)/2,
//                                sizeImage.width, sizeImage.height);
        if (sizeImage.height/rect.size.height>sizeImage.width/rect.size.width) {
            view.frame = CGRectMake((rect.size.width - sizeImage.width*rect.size.height/sizeImage.height)/2,
                                    0,
                                    sizeImage.width*rect.size.height/sizeImage.height, rect.size.height);
            
        }else{
            view.frame = CGRectMake(0,
                                    (rect.size.height - sizeImage.height*rect.size.width/sizeImage.width)/2,
                                    rect.size.width, sizeImage.height*rect.size.width/sizeImage.width);
            
            
        }
      //  view.center=self.center;
        
        
    }
    
    view.tag = self.tag;
    /*  UITapGestureRecognizer *scanImg     = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImgMethod:)] autorelease];
     
     [view addGestureRecognizer:scanImg];
     */
    //image.size =
    [self addSubview:view];
    [self addSubview:self.processLal];
    self.processLal.frame = CGRectMake(0, 0, 40, 20);
    
    self.processLal.center = self.center;
    self.processLal.text = @"0%";
    self.processLal.textColor = [UIColor whiteColor];
    self.processLal.backgroundColor = [UIColor clearColor];
    self.processLal.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
    self.processLal.layer.cornerRadius = 5.0f;

    [self bringSubviewToFront:self.processLal];

    if([view respondsToSelector:@selector(setNeedsDisplay)])
    {
        [view setNeedsDisplay];
    }
}

-(void)setImage:(UIImage*)image
{
  
    [self showImage:image];

}

-(void)setVoiceType:(CHSVoiceType)voiceType
{
    _voiceType = voiceType;
    UIImageView *img_voice = (UIImageView *)[self viewWithTag:123647];
    if (img_voice) {
        [img_voice removeFromSuperview];
        img_voice = nil;
    }
    img_voice = [[UIImageView alloc] init];
    if (voiceType == CHSVoiceTypeSended) {
        //img_voice.frame = CGRectMake(self.frame.size.width - 40, (self.frame.size.height-24)/2, 24, 30);
        img_voice.image = [UIImage imageNamed:@"audio_play_right_animate_03.png"];
        
        CGSize size = img_voice.image.size;
        img_voice.frame = CGRectMake(self.frame.size.width - 20 - size.width, (self.frame.size.height-size.height)/2, size.width, size.height);
        
        img_voice.animationImages=[NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"audio_play_right_animate_01.png"],
                                 [UIImage imageNamed:@"audio_play_right_animate_02.png"],
                                 [UIImage imageNamed:@"audio_play_right_animate_03.png"],nil ];
    }
    else if (voiceType == CHSVoiceTypeReceived) {
        img_voice.image = [UIImage imageNamed:@"audio_play_left_animate_03.png"];

        CGSize size = img_voice.image.size;
        img_voice.frame = CGRectMake(20, (self.frame.size.height-size.height)/2, size.width, size.height);
        
        img_voice.animationImages=[NSArray arrayWithObjects:
                                   [UIImage imageNamed:@"audio_play_left_animate_01.png"],
                                   [UIImage imageNamed:@"audio_play_left_animate_02.png"],
                                   [UIImage imageNamed:@"audio_play_left_animate_03.png"],nil ];
    } else if (voiceType == CHSVoiceNoticeTypeReceived) {
        img_voice.image = [UIImage imageNamed:@"audio_play_left_animate_03.png"];

        CGSize size = img_voice.image.size;
        img_voice.frame = CGRectMake(20, (self.frame.size.height-size.height)/2, size.width, size.height);
        img_voice.animationImages=[NSArray arrayWithObjects:
                                   [UIImage imageNamed:@"audio_play_left_animate_01.png"],
                                   [UIImage imageNamed:@"audio_play_left_animate_02.png"],
                                   [UIImage imageNamed:@"audio_play_left_animate_03.png"],nil ];
    }

    
    
    img_voice.tag = 123647;
    img_voice.animationDuration = 0.9f;
    img_voice.animationRepeatCount = NSIntegerMax;
    img_voice.userInteractionEnabled = NO;
    [self addSubview:img_voice];

}

-(void)setImgVoiceOrigin
{
    UIImageView *img_voice = (UIImageView *)[self viewWithTag:123647];
    if (_voiceType == CHSVoiceTypeSended) {
        
        CGSize size = img_voice.image.size;
        
        img_voice.frame = CGRectMake(self.frame.size.width - 20 - size.width, (self.frame.size.height-size.height)/2, size.width, size.height);
    }
    else
    {
        CGSize size = img_voice.image.size;
        
        img_voice.frame = CGRectMake(20, (self.frame.size.height-size.height)/2, size.width, size.height);
    }
}

-(void)showImageData
{
    
//    NSData* data = [NSData dataWithContentsOfFile:[self localFileName:NO]];
//    if(data == nil) data = [NSData dataWithContentsOfFile:[self localFileName:YES]];
//
//    UIImage* image = nil;
//    if((data))image = [UIImage imageWithData:data];
    UIImage *image = [self getImage];
    if(image == nil)
    {
        for (UIView *aView in [self subviews]) {
            [aView removeFromSuperview];
        }
       
        if(self.showProgress){
            CGRect ff = self.frame;
            
            self.processLal.frame = CGRectMake((ff.size.width - 40)/2, (ff.size.height - 20)/2, 40, 20);

            self.processLal.hidden = NO;
            self.processLal.text = @"0%";
            self.processLal.textColor = [UIColor whiteColor];
            self.processLal.backgroundColor = [UIColor clearColor];
            self.processLal.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
            self.processLal.layer.cornerRadius = 5.0f;
            [self addSubview:self.processLal];
            [self bringSubviewToFront:self.processLal];
        }
        else{
           
            UIImage*    image1 = [UIImage imageNamed:@"headnotfound"];
//            NSAssert(image1 != nil, @" headnotfound");
            if(image1 != nil)
            {
                if(_isFromChat){
                    [self showImageInChat:image1];
                }else{
                    [self showImage:image1];
                }
            }

        }

//        [[CHResourceService defaultResourceService] downloadFileUri:_fileUri type:_type];
    }
    else
    {
//        UIActivityIndicatorView *view = (UIActivityIndicatorView *)[self viewWithTag:434240];
//        if (view) {
//            [view removeFromSuperview];
//            view = nil;
//        }
        if (_isFromChat) {
//            if (_delegate && [_delegate respondsToSelector:@selector(imageResourceDownloaded:withImageSize:)])
//            {
//                CGSize newSize = [self showImageInChat:image];
//                [_delegate imageResourceDownloaded:self withImageSize:newSize];
//            }
            [self showImageInChat:image];
        }
        else
        {
            [self showImage:image];
        }
    }
}


-(void)showImageInfullScreen:(UIImage*)image
{
    for (UIView *aView in [self subviews]) {
        [aView removeFromSuperview];
    }
    CGRect rect = self.frame;
    UIImageView* view = [[UIImageView alloc]initWithImage:image];
    CGSize size = image.size
    ;
    rect.size.height = size.height;
    rect.size.width = size.width;
    view.clipsToBounds = YES;
    [view setUserInteractionEnabled:YES];
    
    view.frame = rect;

    self.processLal.frame = CGRectMake((rect.size.width - 40)/2, (rect.size.height - 20)/2, 40, 20);

    
    view.tag = self.tag;

    [self addSubview:view];
    
    UILabel *lal = [[UILabel alloc] initWithFrame:self.frame];
    lal.text = @"";
    lal.font = [UIFont systemFontOfSize:12];
    lal.textAlignment = NSTextAlignmentCenter;
    lal.textColor = [UIColor whiteColor];
    lal.backgroundColor = [UIColor clearColor];
    lal.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
    lal.layer.cornerRadius = 5.0f;
    [self addSubview:lal];
    [self bringSubviewToFront:lal];
    lal.hidden = YES;
    self.processLal = lal;
    [view setNeedsDisplay];


}
-(void)showImage2XInfullScreen:(UIImage*)image{
    for (UIView *aView in [self subviews]) {
        [aView removeFromSuperview];
    }
    CGRect rect = self.frame;
    UIImageView* view = [[UIImageView alloc]initWithImage:image];
    CGSize size = image.size
    ;
    rect.size.height = size.height*2;
    rect.size.width = size.width*2;
    view.clipsToBounds = YES;
    [view setUserInteractionEnabled:YES];
    
    view.frame = rect;
    view.center = self.center;
    
    
    view.tag = self.tag;
    
    [self addSubview:view];
    [view setNeedsDisplay];
}

-(NSString*)localFileName:(BOOL)md5Flag
{
    if(md5Flag){
//        NSString* md5 = nil;
        if(_fileUri != nil )
        {
//            md5 = [UIUtil md5:_fileUri];
        }
//        return [NSString stringWithFormat:@"%@%@", [ChildHoodService defaultService].childHoodUser.resourcePath, md5];
    }
//    return [NSString stringWithFormat:@"%@%@", [ChildHoodService defaultService].childHoodUser.resourcePath, _fileUri];
    return _fileUri;
 }



- (id)initWithFrame:(CGRect)frame
{
    _fileUri = nil;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isFromChat = NO;
        UILabel *lal = [[UILabel alloc] initWithFrame:self.frame];
        lal.text = @"";
        lal.font = [UIFont systemFontOfSize:12];
        lal.textAlignment = NSTextAlignmentCenter;
        lal.textColor = [UIColor whiteColor];

        CGRect ff = self.frame;
        self.processLal.frame = CGRectMake((ff.size.width - 40)/2, (ff.size.height - 20)/2, 40, 20);

        
        lal.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6];
        [self addSubview:lal];
        [self bringSubviewToFront:lal];
        lal.hidden = YES;
        self.processLal = lal;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResourceUploaded:) name:@"NOTIFY_UPLOAD_PRCESS" object:nil];
        self.isAutoPlayOrShow = YES;
        self.voiceMsgID = 0;
    }
    return self;
}

-(void)onResourceUploaded:(NSNotification *)notification{
//    ChildHoodMessage *amessage =notification.object;
//    
//    NSRange range = [_fileUri rangeOfString:amessage.fileUri];
//    NSLog(@"%@ ::: %@", amessage.fileUri,_fileUri);
//    
//    if (range.location < 1000 ) {
//        if(amessage.messageStatus == kMessageSending){
//            NSLog(@"hhhhh:%d",amessage.progressReport);
//                _processLal.text = [NSString stringWithFormat:@"%d%%",amessage.progressReport];
//            
//                _processLal.hidden = NO;
//                [self addSubview:_processLal];
//                [self bringSubviewToFront:_processLal];
//          
//
//        }else if(amessage.messageStatus == kMessageOK){
//            NSLog(@"hhhhh:%d",amessage.progressReport);
//            
//                _processLal.hidden = YES;
//           
//        }
//        
//        
//        
//    }else{
//    //    _processLal.hidden = YES;
//    }
}


-(void)onResourceDownloaded:(NSNotification*)notification
{
    [self performSelectorOnMainThread:@selector(updateNotification:) withObject:notification waitUntilDone:YES];
//    [self performSelectorInBackground:@selector(updateNotification:) withObject:notification];
//    __unsafe_unretained MutiltimediaView *block = self;
//    __unsafe_unretained NSNotification *no = notification;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [block updateNotification:notification];
//    });
//    CHSProcessReport *processReport =notification.object;
//    NSString* fileUri = processReport.fileUri;
//    NSLog(@"------------->fileUri:%@||pos:%lld||total:%lld",fileUri,processReport.pos,processReport.total);
//    
//    if (_type == SNSPMaterialTypeKAudio){
//        return;
//    }
//    if (!_showProgress&&processReport.pos!=processReport.total) {
//        return;
//    }
//    if([fileUri isEqualToString:_fileUri])
//    {
//        _processLal.text = [NSString stringWithFormat:@"%d%%",(int)(processReport.pos*100.0/processReport.total)];
//        //_processLal.textColor = [UIColor redColor];
//        
//        _processLal.hidden = NO;
//
//        
//        _processLal.font = [UIFont systemFontOfSize:12];
//        _processLal.textAlignment = UITextAlignmentCenter;
//        _processLal.textColor = [UIColor whiteColor];
//
//        
//        CGRect ff = self.frame;
//        self.processLal.frame = CGRectMake((ff.size.width - 40)/2, (ff.size.height - 20)/2, 40, 20);
//
//        
//        _processLal.backgroundColor = [UIColor clearColor];
//        _processLal.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
//        //_processLal.frame = CGRectMake(0, 0, 50, 20);
//        [_processLal.layer setCornerRadius:5.];
//        [self addSubview:_processLal];
//        [self bringSubviewToFront:_processLal];
//        if(_type == SNSPMaterialTypeKImageMessage || _type == SNSPMaterialTypeKImage){
//            if(_type == SNSPMaterialTypeKAudio){
//                NSLog(@"音频下载完毕:%@",_fileUri);
//                _audioIsExist = YES;
//            }
//        }
//        if(processReport.pos==processReport.total){
//            
//            
//            [[NSNotificationCenter defaultCenter ] removeObserver:self name:NOTIFY_MSG_RESOURCE object:nil];
//            _processLal.hidden =YES;
//
//         
//            NSLog(@"图片资源下载完毕:%@",_fileUri);
//            NSData* data = [NSData dataWithContentsOfFile:[self localFileName:NO]];
//            if(data == nil)data = [NSData dataWithContentsOfFile:[self localFileName:YES]];
//            UIImage* image = [UIImage imageWithData:data];
//            if(image == nil){
//                image = [UIImage imageNamed:@"headnotfound"];
//            }
//            if(_isFromChat){
//                [self showImageInChat:image];
//            }else{
//                [self showImage:image];
//            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideFileUriImg" object:nil];
//        
//        }else{
//            BOOL ss = self.processLal.hidden;
//            NSLog(@"音频下载完毕:%@",_fileUri);
//
//        }
//        
//    }
    
}



-(void)updateNotification:(NSNotification*)notification
{
//    @synchronized(@"updateNotification")
//    {
//        CHSProcessReport *processReport =notification.object;
//        NSString* fileUri = processReport.fileUri;
////        NSLog(@"------------->fileUri:%@||pos:%lld||total:%lld",fileUri,processReport.pos,processReport.total);
//        
//        if (_type == SNSPMaterialTypeKAudio && [fileUri isEqualToString:_fileUri]){
//            if(processReport.pos==processReport.total)
//            {
//                [self handlAudio];
//                CGFloat times = [self voiceTimeForRowAtIndexPath];
//                CHBubbleMessageCell *cell = [self getCell];
//                if(cell != nil)
//                {
//                    [cell updateVoice:times];
//                }
//                
//                [[NSNotificationCenter defaultCenter ] removeObserver:self name:NOTIFY_MSG_RESOURCE object:nil];
//                
//            }
//            return;
//        }
//        if (!_showProgress&&processReport.pos!=processReport.total) {
//            return;
//        }
//        if([fileUri isEqualToString:_fileUri])
//        {
//            _processLal.text = [NSString stringWithFormat:@"%d%%",(int)(processReport.pos*100.0/processReport.total)];
//            //_processLal.textColor = [UIColor redColor];
//            
//            _processLal.hidden = NO;
//            
//            
//            _processLal.font = [UIFont systemFontOfSize:12];
//            _processLal.textAlignment = UITextAlignmentCenter;
//            _processLal.textColor = [UIColor whiteColor];
//            
//            
//            CGRect ff = self.frame;
//            self.processLal.frame = CGRectMake((ff.size.width - 40)/2, (ff.size.height - 20)/2, 40, 20);
//            
//            
//            _processLal.backgroundColor = [UIColor clearColor];
//            _processLal.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
//            //_processLal.frame = CGRectMake(0, 0, 50, 20);
//            [_processLal.layer setCornerRadius:5.];
//            [self addSubview:_processLal];
//            [self bringSubviewToFront:_processLal];
//            if(_type == SNSPMaterialTypeKImageMessage || _type == SNSPMaterialTypeKImage){
//                if(_type == SNSPMaterialTypeKAudio){
//                    NSLog(@"音频下载完毕:%@",_fileUri);
//                    _audioIsExist = YES;
//                }
//            }
//            if(processReport.pos==processReport.total)
//            {
//                
//                
//                [[NSNotificationCenter defaultCenter ] removeObserver:self name:NOTIFY_MSG_RESOURCE object:nil];
//                _processLal.hidden =YES;
//                
//                
//                NSLog(@"图片资源下载完毕:%@",_fileUri);
////                NSData* data = [NSData dataWithContentsOfFile:[self localFileName:NO]];
////                if(data == nil)data = [NSData dataWithContentsOfFile:[self localFileName:YES]];
////                UIImage* image = [UIImage imageWithData:data];
//                UIImage *image = [self getImage];
//                if(image == nil){
//                    image = [UIImage imageNamed:@"headnotfound"];
//                }
//                if(_isFromChat){
//                    [self showImageInChat:image];
//                }else{
//                    [self showImage:image];
//                }
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"HideFileUriImg" object:nil];
//                
//            }else{
//                BOOL ss = self.processLal.hidden;
//                NSLog(@"音频下载完毕:%@",_fileUri);
//                
//            }
//            
//        }
//    }

}

//-(CHBubbleMessageCell *)getCell
//{
//    int i = 0;
//    CHBubbleMessageCell *cell = nil;
//    UIView *superView = self.superview;
//    while (superView) {
//        if([superView isKindOfClass:[CHBubbleMessageCell class]])
//        {
//            cell = (CHBubbleMessageCell *)superView;
//            break;
//        }
//        i ++;
//        superView = superView.superview;
//        if(i > 6)
//        {
//            break;
//        }
//    }
//    return cell;
//}


-(void)handlImage
{
    UIImage* image = [UIImage imageNamed:_fileUri];//加载本地资源
    if(image)
    {
        [self showImage:image];
    }
    else
    {
        [self showImageData];
    }
}

-(void)handlImageWithType:(int32_t)type1{
    UIImage* image = [UIImage imageNamed:_fileUri];//加载本地资源
    if(image)
    {
        [self showImage:image type:type1];
    }
    else
    {
        [self showImageDataWithType:type1];
    }
}

-(void)showImage:(UIImage *)image type:(int32_t)type1
{
    if(image == nil)
    {
        return;
    }
    if (type1==SNSPMaterialTypeKImageMessage) {
        for (UIView *aView in [self subviews]) {
            [aView removeFromSuperview];
        }
        // UIImageView* view = [[UIImageView alloc]init];
        //[view setUserInteractionEnabled:YES];
        
        CGRect rect = self.frame;
        CGSize sizeImage = image.size;
        UIImageView* view = [[UIImageView alloc]initWithImage:image];
        [view setUserInteractionEnabled:YES];
        
        
        
        //如果 长和宽都大于边界重新计算大小
        if(sizeImage.width > rect.size.width && sizeImage.height > rect.size.height)
        {
            if(sizeImage.width/sizeImage.height > rect.size.width/rect.size.height)
            {
                
                CGFloat width = rect.size.width;
                CGFloat height = rect.size.width*sizeImage.height/sizeImage.width;
                view.frame = CGRectMake(0,
                                        (rect.size.height - height)/2,
                                        width, height);
                
                
            }else{
                CGFloat height = rect.size.height;
                CGFloat width =  rect.size.height*sizeImage.width/sizeImage.height;
                view.frame = CGRectMake((rect.size.width - width)/2,
                                        0,
                                        width, height);
                
            }
        }else if(sizeImage.width > rect.size.width){
            //如果 宽大于边界重新计算大小
            CGFloat width = rect.size.width;
            CGFloat height = rect.size.width*sizeImage.height/sizeImage.width;
            view.frame = CGRectMake(0,
                                    (rect.size.height - height)/2,
                                    width, height);
            
            
            
        }else if(sizeImage.height > rect.size.height){
            //如果 长大于边界重新计算大小
            CGFloat height = rect.size.height;
            CGFloat width =  rect.size.height*sizeImage.width/sizeImage.height;
            view.frame = CGRectMake((rect.size.width - width)/2,
                                    0,
                                    width, height);
            
        }else{
            //如果长和宽都小于或者等于边界，剧中显示
            //        view.frame = CGRectMake((rect.size.width - sizeImage.width)/2,
            //                                (rect.size.height - sizeImage.height)/2,
            //                                sizeImage.width, sizeImage.height);
            
            
            if (sizeImage.height/rect.size.height>sizeImage.width/rect.size.width) {
                view.frame = CGRectMake((rect.size.width - sizeImage.width*rect.size.height/sizeImage.height)/2,
                                        0,
                                        sizeImage.width*rect.size.height/sizeImage.height, rect.size.height);
                
            }else{
                view.frame = CGRectMake(0,
                                        (rect.size.height - sizeImage.height*rect.size.width/sizeImage.width)/2,
                                        rect.size.width, sizeImage.height*rect.size.width/sizeImage.width);
            }
        }
        
        view.tag = self.tag;
        
        /*  UITapGestureRecognizer *scanImg     = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImgMethod:)] autorelease];
         
         [view addGestureRecognizer:scanImg];
         */
        //image.size =
        [self addSubview:view];
        [self addSubview:self.processLal];
        CGRect ff = self.frame;
        self.processLal.frame = CGRectMake((ff.size.width - 40)/2, (ff.size.height - 20)/2, 40, 20);
        
        self.processLal.text = @"0%";
        self.processLal.textColor = [UIColor whiteColor];
        self.processLal.backgroundColor = [UIColor clearColor];
        self.processLal.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
        self.processLal.layer.cornerRadius = 5.0f;
        
        [self bringSubviewToFront:self.processLal];
        
        [view setNeedsDisplay];

    }
}

-(UIImage *)getImage
{
    
//    NSData* data = [NSData dataWithContentsOfFile:[self localFileName:NO]];
//    if(data == nil) data = [NSData dataWithContentsOfFile:[self localFileName:YES]];
    NSString *filePath = nil;
    NSString *filePath1 = [self localFileName:NO];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath1])
    {
        filePath = filePath1;
        NSLog(@" fileexist 1 __line:%d", __LINE__);
    }
    else
    {
        NSString *filePath2 = [self localFileName:YES];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath2])
        {
            filePath = filePath2;
            NSLog(@" fileexist 2 __line:%d", __LINE__);
        }
    }
    
    if(filePath != nil)
    {
        UIImage *image =  [UIImage imageWithContentsOfFile:filePath];
//        UIImage *image =  [UIImage imageNamed:filePath];
//        NSLog(@"filePath:%@ image:%d", filePath, image);
        return image;
    }
    return nil;
}

-(void)showImageDataWithType:(int32_t)type1{
    if (type1==SNSPMaterialTypeKImageMessage) {
//        NSData* data = [NSData dataWithContentsOfFile:[self localFileName:NO]];
//        if(data == nil) data = [NSData dataWithContentsOfFile:[self localFileName:YES]];
        
        UIImage *showImage =  [self getImage];
//        if(data == nil || [data length] ==0)
        if(showImage == nil)
        {
            for (UIView *aView in [self subviews]) {
                [aView removeFromSuperview];
            }
            
            if(self.showProgress){
                CGRect ff = self.frame;
                self.processLal.frame = CGRectMake((ff.size.width - 40)/2, (ff.size.height - 20)/2, 40, 20);
                self.processLal.hidden = NO;
                self.processLal.text = @"0%";
                self.processLal.textColor = [UIColor whiteColor];
                self.processLal.backgroundColor = [UIColor clearColor];
                self.processLal.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
                self.processLal.layer.cornerRadius = 5.0f;
                [self addSubview:self.processLal];
                [self bringSubviewToFront:self.processLal];
            }
            else{
                
                UIImage*    image = [UIImage imageNamed:@"headnotfound"];
                
                if(_isFromChat){
                    [self showImageInChat:image];
                }else{
                    [self showImage:image type:_type];
                }
                
            }
            
//            [[CHResourceService defaultResourceService] downloadFileUri:_fileUri type:_type];
        }
        else
        {
//            UIImage* image = [UIImage imageWithData:data];
            UIImage *image = showImage;
            if (_isFromChat) {
                [self showImageInChat:image];
            }
            else
            {
                [self showImage:image type:_type];
            }
        }

    }
}


-(void)handlAudio
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:[self localFileName:NO]];
    if(!isExist){
        isExist= [fileManager fileExistsAtPath:[self localFileName:YES]];
    }
    _audioIsExist = isExist;
    if (!isExist) {
        NSLog(@"语音文件不存在，准备下载");
//        [[CHResourceService defaultResourceService] downloadFileUri:_fileUri type:_type];
    }
}

-(CGFloat)voiceTimeForRowAtIndexPath
{
    NSData *data = [NSData dataWithContentsOfFile:[self localFileName:NO]];
    if(data== nil){
        data = [NSData dataWithContentsOfFile:[self localFileName:YES]];
        
    }
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    CGFloat time = player.duration;
    return time;
}


-(BOOL)adjustFileExist
{
    NSData* data = [NSData dataWithContentsOfFile:[self localFileName:NO]];
    if(data == nil) data = [NSData dataWithContentsOfFile:[self localFileName:YES]];

    if(data == nil)return NO;
    return YES;
}


-(void)setMultimediaFileUri:(NSString*)fileUri type:(int32_t)type
{
    if(fileUri == nil){
     
        for (UIView *aView in [self subviews]) {
            [aView removeFromSuperview];
        }

        return;
    }
    self.fileUri = [NSString stringWithFormat:@"%@",fileUri];
    _type = type;
    
//    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(onResourceDownloaded:) name:NOTIFY_MSG_RESOURCE object:nil];

    if(_type == SNSPMaterialTypeKImage)//可以对SNSPMaterialTypeKImageMessage做进一步区分
    {
        [self handlImage];
    }else if(_type == SNSPMaterialTypeKImageMessage){
        [self handlImageWithType:SNSPMaterialTypeKImageMessage];
    }
    else if (_type == SNSPMaterialTypeKAudio)
    {
        [self handlAudio];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoiceAnimation) name:@"STOPVOICEANIMATION" object:nil];
        if(self.isAutoPlayOrShow)
        {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVoice)];
            [tapGesture setNumberOfTapsRequired:1];
            [tapGesture setNumberOfTouchesRequired:1];
            [self addGestureRecognizer:tapGesture];
        }
    }
    
}

-(void) stopVoiceAnimation
{
    UIImageView *view = (UIImageView *)[self viewWithTag:123647];
    if (view) {
        if ([view isAnimating]) {
            [view stopAnimating];
        }
    }
}

-(void) playVoice
{
//    if (_audioIsExist) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"STOPVOICEANIMATION" object:nil];
//        NSString *voiceFilePath = [self localFileName:NO];
//        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:voiceFilePath];
//        if(!isExist)voiceFilePath = [self localFileName:YES];
//
//        
//        CHSAudioPlayer *player = [CHSAudioPlayer sharedInstance];
//        BOOL flag = [player playSoundWithURL:voiceFilePath];
//        if (flag) {
//            [CHMessageManager updateIsPlayByMsgDBId:_voiceMsgDBID isPlay:YES];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOVEREDPOT_NOTICE" object:_indexPath];
//            if(self.voiceMsgID != 0)
//            {
//                NSNumber *number = [NSNumber numberWithLongLong:self.voiceMsgID];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"PLAYVOICE_NOTICE" object:number];
//            }
//            UIImageView *view = (UIImageView *)[self viewWithTag:123647];
//            if (view) {
//                [view startAnimating];
//            }
//            player.audioPlayer.delegate = self;
//        }
//    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
//    [[CHSAudioPlayer sharedInstance] handleNotification:NO];
//    UIImageView *view = (UIImageView *)[self viewWithTag:123647];
//    if (view)
//    {
//        if ([view isAnimating]) {
//            [view stopAnimating];
//        }
//    }
}

-(void) changeImage
{
    if (_voiceType == CHSVoiceTypeSended) {
        
    }
    else if (_voiceType == CHSVoiceTypeReceived) {

    }
}

@end
