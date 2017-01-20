//
//  EventViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/10/31.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "EventViewController.h"
#import "XCSDDataProto.pb.h"

@interface EventViewController ()


@end

@implementation EventViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.bid.length > 0) {
        
        if (self.isMessage) {
            [[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeChannelIn bid:self.bid userId:[TXApplicationManager sharedInstance].currentUser.userId extendedInfo:@"{\"type\" : \"message\"}"];
        }else {
            [self reportEvent:XCSDPBEventTypeChannelIn bid:self.bid];
        }
    }
}


- (void)dealloc {
    
    if (self.bid.length > 0) {
        
        if (self.isMessage) {
            [[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeChannelOut bid:self.bid userId:[TXApplicationManager sharedInstance].currentUser.userId extendedInfo:@"{\"type\" : \"message\"}"];
        }else {
            [self reportEvent:XCSDPBEventTypeChannelOut bid:self.bid];
        }
    }
}

@end
