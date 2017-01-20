//
//  ReaderCodeViewController.m
//  TXChat
//
//  Created by Cloud on 15/8/17.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ReaderCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZBarReaderView.h"
#import <objc/runtime.h>

@interface ReaderCodeViewController ()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
<AVCaptureMetadataOutputObjectsDelegate>
#else
<ZBarReaderViewDelegate>
#endif
{
    UIImageView *_lineImgView;
    UIImageView *_bgView;
    NSTimer *_timer;
    int num;
    BOOL upOrdown;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
@property (nonatomic, strong) AVCaptureSession *session;
#else
#endif

@end

@implementation ReaderCodeViewController

- (void)viewDidLoad{
    self.titleStr = @"扫一扫";
    [super viewDidLoad];
    [self createCustomNavBar];
    
    [self initView];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initView{
    
    CGFloat width = kScreenWidth - 20;
    _bgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, width, width)];
    _bgView.centerY = (self.customNavigationView.maxY + (self.view.height_ - self.customNavigationView.maxY)/2);
    _bgView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:_bgView];
    
    _lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, _bgView.minY + 10, width - 80, 2)];
    _lineImgView.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:_lineImgView];
    
    upOrdown = NO;
    num =0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    [self setupCamera];

}

- (void)animation1{
    CGFloat width = kScreenWidth - 20;
    CGFloat Y = _bgView.minY + 10;
    if (upOrdown == NO) {
        num ++;
        _lineImgView.frame = CGRectMake(50, Y+2*num, width - 80, 2);
        if (2*num + Y >= (_bgView.maxY - 10)) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _lineImgView.frame = CGRectMake(50, Y+2*num, width - 80, 2);
        if (num <= 10) {
            upOrdown = NO;
        }
    }

}

- (void)setupCamera
{
    CGFloat width = kScreenWidth - 20;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    // Device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // Output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest : CGRectMake ((_bgView.minY)/ kScreenHeight ,10/kScreenWidth , width / kScreenHeight , width / kScreenWidth )];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:input])
    {
        [_session addInput:input];
    }
    
    if ([_session canAddOutput:output])
    {
        [_session addOutput:output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    AVCaptureVideoPreviewLayer *preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame =CGRectMake(0,self.customNavigationView.maxY,kScreenWidth,self.view.height_ - self.customNavigationView.maxY);
    [self.view.layer insertSublayer:preview atIndex:0];
    
    // Start
    [_session startRunning];
#else
    ZBarReaderView *readerView = [[ZBarReaderView alloc] init];
    readerView.readerDelegate = self;
    readerView.frame = CGRectMake(0,self.customNavigationView.maxY,kScreenWidth,self.view.height_ - self.customNavigationView.maxY);
    readerView.torchMode = 0;
    [self.view insertSubview:readerView belowSubview:_bgView];
    readerView.tracksSymbols = NO;
    readerView.scanCrop = CGRectMake((_bgView.minY - self.customNavigationView.maxY)/readerView.height_, 10/readerView.width_,width/readerView.height_, width/readerView.width_);
    
    unsigned int count = 0;
    Ivar *members = class_copyIvarList([ZBarReaderView class], &count);
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        const char *memberName = ivar_getName(var);
        NSString *tmpStr = [[NSString alloc] initWithUTF8String:memberName];
        if ([tmpStr isEqualToString:@"cropLayer"]) {
            CALayer *cropLayer = object_getIvar(readerView, var);
            cropLayer.borderColor = [UIColor clearColor].CGColor;
            break;
        }
    }

    [readerView start];
    #endif
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    if ([stringValue hasPrefix:@"check_in://"]) {
        [_session stopRunning];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:stringValue delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
        
        [_timer invalidate];
    }
}
#else
- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    BOOL isFound = NO;
    for (ZBarSymbol *symbol in symbols) {
        if ([symbols.data hasPrefix:@"check_in://"]) {
            isFound = YES;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:symbols.data delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alertView show];
            [_timer invalidate];
        }
        
        break;
    }
    if (isFound) {
        [readerView stop];
    }
    
}
#endif

-(void)dealloc{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
}

@end
