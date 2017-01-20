//
//  TXMediaView.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/22.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXMediaView.h"
#import <TXChatCommon/AUMediaPlayer.h>

@implementation TXMediaView

#pragma mark - LifeCycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
//layerClass
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
@end
