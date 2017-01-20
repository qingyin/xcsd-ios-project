//
//  TXChatEaseMobConversation.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatEaseMobConversation.h"
#import <EMConversation.h>
#import <EaseMobSDK/EMMessage.h>
#import <EaseMobSDK/IEMMessageBody.h>
#import <EaseMobSDK/EMTextMessageBody.h>
#import "ConvertToCommonEmoticonsHelper.h"
#import "NSDate+TuXing.h"
#import "TXContactManager.h"
#import "TXSystemManager.h"

@interface TXChatEaseMobConversation()

@property (nonatomic,copy) NSString *groupIdString;
@end

@implementation TXChatEaseMobConversation

- (instancetype)initWithGroupId:(NSString *)groupId
{
    if (!groupId) {
        return nil;
    }
    _groupIdString = groupId;
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:groupId conversationType:eConversationTypeGroupChat];
//    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:groupId isGroup:YES];
    self = [self initWithEMConversation:conversation];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithEMConversation:(EMConversation *)conversation
{
    self = [super init];
    if (self) {
        _emConversation = conversation;
        if (_emConversation.conversationType == eConversationTypeGroupChat) {
            self.avatarImageName = @"classDefaultIcon";
        }else if (_emConversation.conversationType == eConversationTypeChat) {
            self.avatarImageName = @"userDefaultIcon";
        }
//        self.avatarImageName = _emConversation.isGroup ? @"classDefaultIcon" : @"userDefaultIcon";
        if (_groupIdString && [_groupIdString length]) {
            self.detailMsg = @"赶快向全班的家长老师打个招呼吧！";
        }else{
            if (_emConversation.conversationType == eConversationTypeGroupChat) {
                NSString *subTitleString = [self subTitleMessageByConversation:conversation];
                if (subTitleString && [subTitleString length]) {
                    self.detailMsg = subTitleString;
                }else{
                    self.detailMsg = @"赶快向全班的家长老师打个招呼吧！";
                }
            }else{
                self.detailMsg = [self subTitleMessageByConversation:conversation];
            }
        }
        self.time = [self lastMessageTimeByConversation:conversation];
        EMMessage *latestmessage = [conversation latestMessage];
        self.timeStamp = latestmessage.timestamp / 1000;
        /*获取用户头像和名称*/
        NSDictionary *userDict;
        if (_emConversation.conversationType == eConversationTypeGroupChat) {
            userDict = [[TXContactManager shareInstance] getUserByUserID:[_emConversation.chatter longLongValue] isGroup:YES complete:nil];
        }else{
            userDict = [[TXContactManager shareInstance] getUserByUserID:[_emConversation.chatter longLongValue] isGroup:NO complete:nil];
        }
        
        if (userDict) {
            self.avatarRemoteUrlString = userDict[@"headerImg"];
            NSString *conversationName = userDict[@"name"];
            if (conversationName && [conversationName length]) {
                self.displayName = conversationName;
            }else{
                [self handleEmConversationDisplayName];
            }
        }else{
            [self handleEmConversationDisplayName];
            self.isService = [latestmessage.from isEqualToString:KTXCustomerChatter] || [latestmessage.to isEqualToString:KTXCustomerChatter];
            if (self.isService) {
                
                EMMessage *lastOther = [conversation latestMessageFromOthers];
                if (lastOther) {
                    NSString *disPlayName = lastOther.ext[@"weichat"][@"agent"][@"userNickname"];
                    
                    self.displayName = disPlayName != NULL ? disPlayName : @"乐学堂客服";
                    if ([self.displayName hasPrefix:@"乐学堂"]) {
                        NSString *avatar = [NSString stringWithFormat:@"http://kefu.easemob.com/ossimages/%@", [lastOther.ext[@"weichat"][@"agent"][@"avatar"] substringFromIndex:2]];
                        self.avatarRemoteUrlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)avatar, (CFStringRef)@"!NULL,'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
                    }
                    
                }
            }
        }
    }
    return self;
}
//获取环信传递的组名
- (void)handleEmConversationDisplayName
{
    //处理成需要的内容
    if (_emConversation.conversationType == eConversationTypeGroupChat) {
        //群聊
        if (![_emConversation.ext objectForKey:@"groupSubject"] || ![_emConversation.ext objectForKey:@"isPublic"])
        {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:_emConversation.chatter]) {
                    self.displayName = group.groupSubject;
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:_emConversation.ext];
                    [ext setObject:group.groupSubject forKey:@"groupSubject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    _emConversation.ext = ext;
                    break;
                }
            }
        }else{
            self.displayName = [_emConversation.ext objectForKey:@"groupSubject"];
        }
    }else{
        //单聊
        EMMessage *chatterMessage = _emConversation.latestMessageFromOthers;
        NSDictionary *extDict = chatterMessage.ext;
        NSString *extUserName = extDict[@"name"];
        NSString *extAvatarUrlString = extDict[@"avatarUrl"];
        if (extUserName && [extUserName length]) {
            self.displayName = extDict[@"name"];
        }
        if (extAvatarUrlString && [extAvatarUrlString length]) {
            self.avatarRemoteUrlString = extAvatarUrlString;
        }
    }
}
// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@",@(lastMessage.timestamp / 1000)]];
    }
    
    return ret;
}
//是否允许展示未读数
- (BOOL)isEnableUnreadCountDisplay
{
    return YES;
}
//是否允许展示红点
- (BOOL)isEnableShowRedDot
{
    return YES;
}
// 得到未读消息条数
- (NSInteger)unReadCount
{
    NSInteger ret = 0;
    ret = _emConversation.unreadMessagesCount;
    
    return ret;
}
// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
//    if (chatMessage) {
//        lastMessage = chatMessage;
//    }else{
//        lastMessage = [conversation latestMessage];
//    }
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                EMMessage *emMsg = [messageBody message];
                //先获取ext的用户信息
                NSString *userName = @"";
                NSDictionary *extDict = emMsg.ext;
                NSString *extUserName = extDict[@"name"];
                if (extUserName && [extUserName length]) {
                    userName = extDict[@"name"];
                }
                if (emMsg.messageType == eMessageTypeGroupChat) {
                    //读取用户名称
                    NSDictionary *userDict = [[TXContactManager shareInstance] getUserByUserID:[emMsg.groupSenderName longLongValue] isGroup:NO complete:nil];
                    if (userDict) {
                        NSString *nameString = userDict[@"name"];
                        if (nameString && [nameString length]) {
                            userName = nameString;
                        }
                    }
                    if ([userName length]) {
                        ret = [NSString stringWithFormat:@"%@:[图片]",userName];
                    }else{
                        ret = @"[图片]";
                    }

                }else{
                    ret = @"[图片]";
                }
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                EMMessage *emMsg = [messageBody message];
//                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
//                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                NSString *didReceiveText = ((EMTextMessageBody *)messageBody).text;
                
                if ([didReceiveText containsString:@"-{"] && [didReceiveText containsString:@"}"]) {
                    NSRange range = [didReceiveText rangeOfString:@"-"];
                    
                    didReceiveText = [didReceiveText substringToIndex:range.location - 1];
                }
                //先获取ext的用户信息
                NSString *userName = @"";
                NSDictionary *extDict = emMsg.ext;
                NSString *extUserName = extDict[@"name"];
                if (extUserName && [extUserName length]) {
                    userName = extDict[@"name"];
                }
                if (emMsg.messageType == eMessageTypeGroupChat) {
                    //读取用户名称
                    NSDictionary *userDict = [[TXContactManager shareInstance] getUserByUserID:[emMsg.groupSenderName longLongValue] isGroup:NO complete:nil];
                    if (userDict) {
                        NSString *nameString = userDict[@"name"];
                        if (nameString && [nameString length]) {
                            userName = nameString;
                        }
                    }
                    if ([userName length]) {
                        ret = [NSString stringWithFormat:@"%@:%@",userName,didReceiveText];
                    }else{
                        ret = didReceiveText;
                    }
                }else{
                    ret = didReceiveText;
                }
            } break;
            case eMessageBodyType_Voice:{
                EMMessage *emMsg = [messageBody message];
                //先获取ext的用户信息
                NSString *userName = @"";
                NSDictionary *extDict = emMsg.ext;
                NSString *extUserName = extDict[@"name"];
                if (extUserName && [extUserName length]) {
                    userName = extDict[@"name"];
                }
                if (emMsg.messageType == eMessageTypeGroupChat) {
                    //读取用户名称
                    NSDictionary *userDict = [[TXContactManager shareInstance] getUserByUserID:[emMsg.groupSenderName longLongValue] isGroup:NO complete:nil];
                    if (userDict) {
                        NSString *nameString = userDict[@"name"];
                        if (nameString && [nameString length]) {
                            userName = nameString;
                        }
                    }
                    if ([userName length]) {
                        ret = [NSString stringWithFormat:@"%@:[语音]",userName];
                    }else{
                        ret = @"[语音]";
                    }
                }else{
                    ret = @"[语音]";
                }
            } break;
            case eMessageBodyType_Location: {
                ret = @"[位置]";
            } break;
            case eMessageBodyType_Video: {
                EMMessage *emMsg = [messageBody message];
                //先获取ext的用户信息
                NSString *userName = @"";
                NSDictionary *extDict = emMsg.ext;
                NSString *extUserName = extDict[@"name"];
                if (extUserName && [extUserName length]) {
                    userName = extDict[@"name"];
                }
                if (emMsg.messageType == eMessageTypeGroupChat) {
                    //读取用户名称9
                    NSDictionary *userDict = [[TXContactManager shareInstance] getUserByUserID:[emMsg.groupSenderName longLongValue] isGroup:NO complete:nil];
                    if (userDict) {
                        NSString *nameString = userDict[@"name"];
                        if (nameString && [nameString length]) {
                            userName = nameString;
                        }
                    }
                    if ([userName length]) {
                        ret = [NSString stringWithFormat:@"%@:[视频]",userName];
                    }else{
                        ret = @"[视频]";
                    }
                    
                }else{
                    ret = @"[视频]";
                }

            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}
#pragma mark - 获取最后一条聊天消息
//最后一条聊天的消息
+ (EMMessage *)lastChatMessageForConversation:(EMConversation *)conversation
{
    if (!conversation) {
        return nil;
    }
    EMMessage *lastMsg = [conversation latestMessage];
    if (lastMsg) {
        EMMessage *chatMessage = [TXChatEaseMobConversation previousChatMessageWithLastMessage:lastMsg conversation:conversation];
        return chatMessage;
    }
    return nil;
}
+ (EMMessage *)previousChatMessageWithLastMessage:(EMMessage *)msg
                                     conversation:(EMConversation *)conversation
{
    if (msg) {
        NSDictionary *extDict = msg.ext;
        BOOL isRevokeMsg = [[extDict valueForKey:@"isRevokeMsg"] boolValue];
        if (!isRevokeMsg) {
            //非撤回消息
            return msg;
        }else{
            //寻找下一个非撤回消息
            NSArray *list = [conversation loadNumbersOfMessages:1 withMessageId:msg.messageId];
            if (list && [list count] == 1) {
                EMMessage *lastMsg = list[0];
                EMMessage *previousMsg = [self previousChatMessageWithLastMessage:lastMsg conversation:conversation];
                return previousMsg;
            }else{
                return nil;
            }
        }
    }
    return nil;
}
@end
