//
//  TXMessage.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXMessage.h"
#import "NSDate+TuXing.h"
#import "UILabel+ContentSize.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "TXContactManager.h"


#define IMAGE_MAX_SIZE 120 //　图片最大显示大小
#define TEXT_MAX_MARGIN 120 //　文字最大显示大小
static NSDictionary *_msgAttributeDict;


@implementation TXMessage

- (instancetype)initBubbleMessageWithEMMessage:(EMMessage *)msg
                                   isGroupChat:(BOOL)isGroup
{
    self = [super init];
    if (self) {
        _message = msg;
        //设置行高矫正
        _textFixedLineHeight = 19;
        //消息id
        self.messageId = _message.messageId;
        //时间
//        NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)msg.timestamp];
//        self.time = [createDate formattedTime];
        //发送者的名字
        if (isGroup) {
            self.userId = msg.groupSenderName;
        }else{
            self.userId = msg.from;
        }
        //获取ext的用户信息
        NSDictionary *extDict = _message.ext;
        NSString *extUserName = extDict[@"name"];
        if (extUserName && [extUserName length]) {
            self.senderName = extDict[@"name"];
        }
        //获取用户头像和名称
        if (self.userId && [self.userId length]) {
            NSDictionary *userDict = [[TXContactManager shareInstance] getUserByUserID:[self.userId longLongValue] isGroup:NO complete:nil];
            if (userDict) {
                NSString *headerImgString = userDict[@"headerImg"];
                NSString *sendNameString = userDict[@"name"];
                if (headerImgString && [headerImgString length]) {
                    self.avatarUrlString = headerImgString;
                }
                if (sendNameString && [sendNameString length]) {
                    self.senderName = sendNameString;
                }
            }else {
                
                self.isService = [msg.from isEqualToString:KTXCustomerChatter];
                if (self.isService) {
                    
                    NSString *disPlayName = msg.ext[@"weichat"][@"agent"][@"userNickname"];
                    
                    self.senderName = disPlayName != NULL ? disPlayName : @"乐学堂客服";
                    if ([self.senderName hasPrefix:@"乐学堂"]) {
                        NSString *avatar = [NSString stringWithFormat:@"http://kefu.easemob.com/ossimages/%@", [msg.ext[@"weichat"][@"agent"][@"avatar"] substringFromIndex:2]];
                        self.avatarUrlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)avatar, (CFStringRef)@"!NULL,'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
                    }
                }
            }
        }
        //本地默认图片
        self.avatarImage = [UIImage imageNamed:@"userDefaultIcon"];
        //聊天内容
        if (msg.messageBodies && [msg.messageBodies count] > 0) {
            EMTextMessageBody *body = msg.messageBodies[0];
            if (body.messageBodyType == eMessageBodyType_Text) {
//                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
//                                            convertToSystemEmoticons:body.text];
                self.text = body.text;
                //替换掉\r字符串
                self.text = [self.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                //消息内容类型
                self.messageMediaType = TXBubbleMessageMediaTypeText;
                self.isShare = NO;
                
//                if ([self.text containsString:@"{\"url\""] && [self.text containsString:@"}"]) {
//                    self.isShare = YES;
//                    
//                    NSRange range = [self.text rangeOfString:@"-"];
//                    NSString *jsonTxt = [self.text substringFromIndex:range.location + 1];
//                    
//                    NSData *jsonData = [jsonTxt dataUsingEncoding:NSUTF8StringEncoding];
//                    
//                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
//                    self.shareUrl = dict[@"url"];
//                    self.shareTitle = dict[@"articleTitle"];
//                    self.shareImageUrl = dict[@"coverImageUrl"];
//                }
                
                
                if (msg.ext[@"url"]) {
                    
                    self.isShare = YES;
                    self.shareUrl = msg.ext[@"url"];
                    self.shareTitle = msg.ext[@"articleTitle"];
                    self.shareImageUrl = msg.ext[@"coverImageUrl"];
                }
            }else if (body.messageBodyType == eMessageBodyType_Image) {
                //图片
//                NSLog(@"这是图片");
                //消息内容类型
                self.messageMediaType = TXBubbleMessageMediaTypePhoto;
                //图片信息
                EMImageMessageBody *imgMessageBody = (EMImageMessageBody*)body;
                self.imageSize = imgMessageBody.size;
//                if (imgMessageBody.thumbnailSize.width >= 120) {
//                    CGFloat aThumbHeight = imgMessageBody.thumbnailSize.height / imgMessageBody.thumbnailSize.width * 120;
//                    self.thumbnailImageSize = CGSizeMake(120, aThumbHeight);
//                }else{
//                    self.thumbnailImageSize = imgMessageBody.thumbnailSize;
//                }
                if (imgMessageBody.thumbnailSize.width == 0) {
                    self.thumbnailImageSize = CGSizeZero;
                }else{
                    CGFloat thumbHeight = imgMessageBody.thumbnailSize.height / imgMessageBody.thumbnailSize.width * 120;
                    self.thumbnailImageSize = CGSizeMake(120, thumbHeight);
                }
                
                self.imageLocalPath = imgMessageBody.localPath;
                self.thumbnailImageLocalPath = imgMessageBody.thumbnailLocalPath;
                self.imageRemoteURL = imgMessageBody.remotePath;
            }else if (body.messageBodyType == eMessageBodyType_Voice) {
                //消息内容类型
                self.messageMediaType = TXBubbleMessageMediaTypeVoice;
                //语音
                self.voiceTime = ((EMVoiceMessageBody *)body).duration;
                CGFloat growLength;
                if (self.voiceTime >= 60) {
                    growLength = kMessageVoiceBubbleMaxWidth - kMessageVoiceBubbleMinWidth;
                }else{
                    growLength = (kMessageVoiceBubbleMaxWidth - kMessageVoiceBubbleMinWidth) * _voiceTime / 60;

                }
                self.voiceBubbleLength = kMessageVoiceBubbleMinWidth + growLength;
                
                self.chatVoice = (EMChatVoice *)((EMVoiceMessageBody *)body).chatObject;
                if (msg.ext) {
                    NSDictionary *dict = msg.ext;
                    self.isVoicePlayed = [[dict objectForKey:@"isPlayed"] boolValue];
                }else {
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@NO,@"isPlayed", nil];
                    msg.ext = dict;
                    [msg updateMessageExtToDB];
                }
                // 本地音频路径
                self.voicelocalPath = ((EMVoiceMessageBody *)body).localPath;
                self.voiceRemotePath = ((EMVoiceMessageBody *)body).remotePath;
            }else if (body.messageBodyType == eMessageBodyType_Video) {
                //视频内容类型
                self.messageMediaType = TXBubbleMessageMediaTypeVideo;
                EMVideoMessageBody *videoMessageBody = (EMVideoMessageBody*)body;
                self.videoSize = videoMessageBody.size;
                if (videoMessageBody.size.width == 0) {
                    self.videoThumbSize = CGSizeZero;
                }else{
                    CGFloat thumbHeight = videoMessageBody.size.height / videoMessageBody.size.width * 120;
                    self.videoThumbSize = CGSizeMake(120, thumbHeight);
                }
                self.videoLocalThumbnailImageURL = videoMessageBody.thumbnailLocalPath;
                self.videoRemoteThumbnailImageURL = videoMessageBody.thumbnailRemotePath;
                self.videoLocalPath = videoMessageBody.localPath;
                self.videoRemoteURL = videoMessageBody.remotePath;
            }
            //计算高度
            [self calculateRowHeight];
        }
        //设置是否是群聊
        _isGroupChat = isGroup;
        //发送状态
        _status = _message.deliveryState;
    }
    return self;
}
- (NSString *)messageId
{
    return _message.messageId;
}
- (BOOL)isVoiceRead
{
    return _message.isReadAcked;
}
+ (NSDictionary *)messageTextAttributes
{
    if (!_msgAttributeDict) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;
        _msgAttributeDict = @{NSFontAttributeName:kMessageTextFont,
                              NSParagraphStyleAttributeName:paragraphStyle,
                              };
    }
    return _msgAttributeDict;
}
//计算高度
- (void)calculateRowHeight
{
    if (_messageMediaType == TXBubbleMessageMediaTypeText) {
        
        if (self.isShare) {
//            _rowHeight = 120 + 40 + 4;
            
            
            CGFloat max_width = [UIScreen mainScreen].bounds.size.width - kMessageBubbleWidthMargin - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) * 2 - kMessageTextWidthMargin;
            
            CGFloat image_height = 150 / ([UIScreen mainScreen].bounds.size.width - 30) * max_width;
            
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName,nil];
            CGSize textSize = [self.shareTitle boundingRectWithSize:CGSizeMake(max_width - 10.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
            
            _rowHeight = textSize.height + image_height + 22 + 7 + 30;
            
            return;
        }
        //文本内容
        CGFloat avatarWidth = kMessageAvatarWidth + kMessageViewMargin * 2;
        CGFloat max_width = [UIScreen mainScreen].bounds.size.width - kMessageBubbleWidthMargin - (kMessageAvatarWidth + kMessageAvatarAndBubbleMargin + kMessageCellSpace) * 2 - kMessageTextWidthMargin;
        //        CGSize labelSize = [UILabel contentSizeForLabelWithText:self.text maxWidth:max_width font:kMessageTextFont];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:self.text attributes:[[self class] messageTextAttributes]];
//        //矫正行高，如emoji高度比普通文本高度高
//        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
//        modifier.fixedLineHeight = _textFixedLineHeight;
//        YYTextContainer *container = [YYTextContainer new];
//        container.size = CGSizeMake(max_width, CGFLOAT_MAX);
//        container.linePositionModifier = modifier;
//        self.textLayout = [YYTextLayout layoutWithContainer:container text:text];
//        CGSize size = [self.textLayout textBoundingSize];
        self.textLayout = [YYTextLayout layoutWithContainerSize:CGSizeMake(max_width, CGFLOAT_MAX) text:text];
        CGSize size = [self.textLayout textBoundingSize];
        size.height += (kMessageBubbleTopMarigin + kMessageBubbleBottomMargin);
        if (size.height < kMessageBubbleMinHeight) {
            self.textSize = CGSizeMake(size.width, kMessageBubbleMinHeight);
        }else{
            self.textSize = size;
        }
        _rowHeight = size.height > kMessageAvatarWidth ? (size.height + kMessageViewMargin * 2) : avatarWidth;
    }else if (_messageMediaType == TXBubbleMessageMediaTypePhoto) {
        //图片内容
        CGFloat avatarWidth = kMessageAvatarWidth + kMessageViewMargin * 2;
        CGSize imageResize = [self imageSizeThatFits:_thumbnailImageSize];
        _rowHeight = (imageResize.height + kMessageViewMargin * 2) > avatarWidth ? (imageResize.height + kMessageViewMargin * 2) : avatarWidth;
    }else if (_messageMediaType == TXBubbleMessageMediaTypeEmotion) {
        //表情内容
        _rowHeight = kMessageAvatarWidth + kMessageViewMargin * 2;
    }else if (_messageMediaType == TXBubbleMessageMediaTypeVoice) {
        //语音内容
        _rowHeight = kMessageAvatarWidth + kMessageViewMargin * 2;
    }else if (_messageMediaType == TXBubbleMessageMediaTypeVideo) {
        //视频
        CGFloat avatarWidth = kMessageAvatarWidth + kMessageViewMargin * 2;
        CGSize imageResize = [self imageSizeThatFits:_videoThumbSize];
        _rowHeight = (imageResize.height + kMessageViewMargin * 2) > avatarWidth ? (imageResize.height + kMessageViewMargin * 2) : avatarWidth;
    }
    _rowHeight += 4;
}
- (void)setBubbleMessageType:(TXBubbleMessageType)bubbleMessageType
{
    _bubbleMessageType = bubbleMessageType;
    //如果是群聊且是别人发送的内容，更新新的高度
    if (_isGroupChat && _bubbleMessageType == TXBubbleMessageTypeIncoming) {
        _rowHeight += kMessageSendNameHeight;
    }
}
//图片重适配尺寸
- (CGSize)imageSizeThatFits:(CGSize)size
{
    CGSize retSize = size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = IMAGE_MAX_SIZE;
        retSize.height = IMAGE_MAX_SIZE;
    }
    if (retSize.width >= IMAGE_MAX_SIZE) {
        //缩减到max_size的大小
        retSize.width = IMAGE_MAX_SIZE;
        retSize.height = IMAGE_MAX_SIZE / retSize.width  *  retSize.height;
        return retSize;
    }
    //原尺寸
    return retSize;
}

- (void)setIsTimeMessage:(BOOL)isTimeMessage
{
    _isTimeMessage = isTimeMessage;
    if (_isTimeMessage) {
        _rowHeight = 30;
    }
}
- (void)setIsTipMessage:(BOOL)isTipMessage
{
    _isTipMessage = isTipMessage;
    if (_isTipMessage) {
        _rowHeight = 60;
    }
}

@end
