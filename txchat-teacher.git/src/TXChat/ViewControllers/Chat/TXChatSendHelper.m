//
//  TXChatSendHelper.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/8.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatSendHelper.h"
#import "ConvertToCommonEmoticonsHelper.h"

#import "EMCommandMessageBody.h"

@interface TXChatImageOptions : NSObject<IChatImageOptions>

@property (assign, nonatomic) CGFloat compressionQuality;

@end

@implementation TXChatImageOptions

@end

@implementation TXChatSendHelper

+(EMMessage *)sendTextMessageWithString:(NSString *)str
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
                                    ext:(NSDictionary *)ext
{
    //添加表情映射
//    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:str];
    EMChatText *text = [[EMChatText alloc] initWithText:str];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption ext:ext];
    
}

+(EMMessage *)sendImageMessageWithImage:(UIImage *)image
                             toUsername:(NSString *)username
                            isChatGroup:(BOOL)isChatGroup
                      requireEncryption:(BOOL)requireEncryption
                                    ext:(NSDictionary *)ext
{
    EMChatImage *chatImage = [[EMChatImage alloc] initWithUIImage:image displayName:@"image.jpg"];
    id <IChatImageOptions> options = [[TXChatImageOptions alloc] init];
    [options setCompressionQuality:1.0];
    [chatImage setImageOptions:options];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithImage:chatImage thumbnailImage:nil];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption ext:ext];
    
}

//+(EMMessage *)sendImageMessageWithImage:(UIImage *)image
//                             toUsername:(NSString *)username
//                            messageType:(EMMessageType)type
//                      requireEncryption:(BOOL)requireEncryption
//                                    ext:(NSDictionary *)ext
//{
//    EMChatImage *chatImage = [[EMChatImage alloc] initWithUIImage:image displayName:@"image.jpg"];
//    id <IChatImageOptions> options = [[ChatImageOptions alloc] init];
//    [options setCompressionQuality:0.6];
//    [chatImage setImageOptions:options];
//    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithImage:chatImage thumbnailImage:nil];
//    return [self sendMessage:username messageBody:body messageType:type requireEncryption:requireEncryption ext:ext];
//}

+(EMMessage *)sendVoice:(EMChatVoice *)voice
             toUsername:(NSString *)username
            isChatGroup:(BOOL)isChatGroup
      requireEncryption:(BOOL)requireEncryption
                    ext:(NSDictionary *)ext
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption ext:ext];
    
    //    EMMessageType type = isChatGroup ? eMessageTypeGroupChat : eMessageTypeChat;
    //    return [self sendVoice:voice toUsername:username messageType:type requireEncryption:requireEncryption ext:ext];
}

//+(EMMessage *)sendVoice:(EMChatVoice *)voice
//             toUsername:(NSString *)username
//            messageType:(EMMessageType)type
//      requireEncryption:(BOOL)requireEncryption
//                    ext:(NSDictionary *)ext
//{
//    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
//    return [self sendMessage:username messageBody:body messageType:type requireEncryption:requireEncryption ext:ext];
//}

+(EMMessage *)sendVideo:(EMChatVideo *)video
             toUsername:(NSString *)username
            isChatGroup:(BOOL)isChatGroup
      requireEncryption:(BOOL)requireEncryption
                    ext:(NSDictionary *)ext
{
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithChatObject:video];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption ext:ext];
}

//+(EMMessage *)sendVideo:(EMChatVideo *)video
//             toUsername:(NSString *)username
//            messageType:(EMMessageType)type
//      requireEncryption:(BOOL)requireEncryption
//                    ext:(NSDictionary *)ext
//{
//    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithChatObject:video];
//    return [self sendMessage:username messageBody:body messageType:type requireEncryption:requireEncryption ext:ext];
//}

+(EMMessage *)sendLocationLatitude:(double)latitude
                         longitude:(double)longitude
                           address:(NSString *)address
                        toUsername:(NSString *)username
                       isChatGroup:(BOOL)isChatGroup
                 requireEncryption:(BOOL)requireEncryption
                               ext:(NSDictionary *)ext
{
    EMChatLocation *chatLocation = [[EMChatLocation alloc] initWithLatitude:latitude longitude:longitude address:address];
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithChatObject:chatLocation];
    return [self sendMessage:username messageBody:body isChatGroup:isChatGroup requireEncryption:requireEncryption ext:ext];
}

//+(EMMessage *)sendLocationLatitude:(double)latitude
//                         longitude:(double)longitude
//                           address:(NSString *)address
//                        toUsername:(NSString *)username
//                       messageType:(EMMessageType)type
//                 requireEncryption:(BOOL)requireEncryption
//                               ext:(NSDictionary *)ext
//{
//    EMChatLocation *chatLocation = [[EMChatLocation alloc] initWithLatitude:latitude longitude:longitude address:address];
//    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithChatObject:chatLocation];
//    return [self sendMessage:username messageBody:body messageType:type requireEncryption:requireEncryption ext:ext];
//}

//// 发送消息
//+(EMMessage *)sendMessage:(NSString *)username
//              messageBody:(id<IEMMessageBody>)body
//              messageType:(EMMessageType)type
//        requireEncryption:(BOOL)requireEncryption
//                      ext:(NSDictionary *)ext
//{
//    EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:username bodies:[NSArray arrayWithObject:body]];
//    retureMsg.requireEncryption = requireEncryption;
//    retureMsg.messageType = type;
//    retureMsg.ext = ext;
//    EMMessage *message = [[EaseMob sharedInstance].chatManager asyncSendMessage:retureMsg progress:nil];
//
//    return message;
//}

// 发送消息
+(EMMessage *)sendMessage:(NSString *)username
              messageBody:(id<IEMMessageBody>)body
              isChatGroup:(BOOL)isChatGroup
        requireEncryption:(BOOL)requireEncryption
                      ext:(NSDictionary *)ext
{
    EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:username bodies:[NSArray arrayWithObject:body]];
    retureMsg.requireEncryption = requireEncryption;
    if (isChatGroup) {
        retureMsg.messageType = eMessageTypeGroupChat;
    }else{
        retureMsg.messageType = eMessageTypeChat;
    }
//    retureMsg.isGroup = isChatGroup;
    retureMsg.ext = ext;
    EMMessage *message = [[EaseMob sharedInstance].chatManager asyncSendMessage:retureMsg progress:nil];
    
    return message;
}


@end
