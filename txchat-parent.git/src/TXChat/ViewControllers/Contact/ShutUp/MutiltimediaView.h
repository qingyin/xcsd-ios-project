//
//  MutiltimediaView.h
//  ChildHoodStemp
//
//  Created by xuzuotao on 13-10-6.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    CHSVoiceTypeSended = 0,
    CHSVoiceTypeReceived,
    CHSVoiceNoticeTypeReceived
} CHSVoiceType;

@class SNSPMultimedia;
@interface MutiltimediaView : UIView
{
    CHSVoiceType   _voiceType;
    BOOL           _isFromChat;
    NSString       *_fileUri;
    NSIndexPath    *_indexPath;
}
@property (nonatomic, assign) int64_t voiceMsgDBID;
@property (nonatomic, assign) int64_t voiceMsgID;//同步服务器id
@property (nonatomic, copy) NSString *fileUri;
@property (nonatomic, assign) BOOL  isFromChat;
@property (nonatomic, assign) BOOL  showProgress;;

@property (nonatomic, assign) CHSVoiceType voiceType;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign)BOOL isAutoPlayOrShow;//是否允许自动播放或者显示图片

-(void)setMultimediaFileUri:(NSString*)fileUri type:(int32_t)type;

-(void)setImage:(UIImage*)image;

-(NSString*)localFileName:(BOOL)md5Flag;

-(void)setImgVoiceOrigin;

-(BOOL)adjustFileExist;


-(void)showImageInfullScreen:(UIImage*)image;
-(void)showImage2XInfullScreen:(UIImage*)image;


@end
