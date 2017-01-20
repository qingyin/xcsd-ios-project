//
//  CircleUploadView.m
//  TXChat
//
//  Created by Cloud on 15/7/6.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleUploadView.h"

@implementation CircleUploadView

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshProgress:) name:@"refreshProgress" object:nil];
        self.clipsToBounds = YES;
        [self initView];
    }
    return self;
}

- (void)refreshProgress:(NSNotification *)notification{
    NSDictionary *dic = notification.object;
    NSString *key = dic[@"key"];
    NSNumber *progress = dic[@"progress"];
    if ([key isEqualToString:_uuidKey]) {
        _vProgress.progress = progress.floatValue;
    }
}

- (void)initView{
    _uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _uploadBtn.imageView.clipsToBounds = YES;
    _uploadBtn.frame = CGRectMake(0, 0, 94, 94);
    [self addSubview:_uploadBtn];
    
    _vProgress = [[DAProgressOverlayView alloc] initWithFrame:_uploadBtn.bounds];
    _vProgress.userInteractionEnabled = NO;
    _vProgress.progress = 0.1;
    [self addSubview:_vProgress];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
