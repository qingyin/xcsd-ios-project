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
#import "SDiPhoneVersion.h"
#import <TXChatClient.h>
#import "CheckInListViewController.h"
#import "NSString+CheckIn.h"

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
    dispatch_queue_t _sessionQueue;
    BOOL _isConfirmed;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
@property (nonatomic, strong) AVCaptureSession *session;
#else
@property (nonatomic, strong)ZBarReaderView *zBarReaderView;
#endif

@end

@implementation ReaderCodeViewController

-(id)init
{
    self = [super init];
    if(self)
    {
        _sessionQueue = dispatch_queue_create("com.txchat.CheckIn.session", DISPATCH_QUEUE_SERIAL );
        _isConfirmed = NO;
    }
    return self;
}


- (void)viewDidLoad{
    self.titleStr = @"扫一扫";
    [super viewDidLoad];
    [self setupDarkModeNavigationBar];
    [self.btnRight setTitle:@"扫描记录" forState:UIControlStateNormal];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    if(![_session isRunning])
    {
        [_session startRunning];
    }
#else
    [_zBarReaderView start];
#endif
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        if([_session isRunning])
        {
            [_session stopRunning];
        }
#else
        [_zBarReaderView stop];
#endif
        
        CheckInListViewController *checkListVC = [[CheckInListViewController alloc] init];
        [self.navigationController pushViewController:checkListVC animated:YES];
    }        
}

- (void)initView{
    
    CGFloat width = kScreenWidth - 2*70;
    _bgView = [[UIImageView alloc]initWithFrame:CGRectMake(70, 0, width, width)];
    _bgView.centerY = (self.customNavigationView.maxY + (self.view.height_ - 2*self.customNavigationView.maxY)/2);
    _bgView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:_bgView];
    
    _lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(80, _bgView.minY + 10, width - 20, 2)];
    _lineImgView.image = [UIImage imageNamed:@"code_line"];
    [self.view addSubview:_lineImgView];
    

    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5].CGColor;
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, nil, CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_- self.customNavigationView.maxY));
    CGPathAddRect(maskPath, nil, _bgView.frame);
    layer.path = maskPath;
    CGPathRelease(maskPath);
    layer.fillRule = kCAFillRuleEvenOdd;
    [self.view.layer addSublayer:layer];
    
    CATextLayer *textLayer1 = [CATextLayer layer];
    textLayer1.frame = CGRectMake(10, _bgView.maxY +52, kScreenWidth-2*10, 32);
    [self.view.layer addSublayer:textLayer1];
    textLayer1.foregroundColor = kColorWhite.CGColor;
    textLayer1.alignmentMode = kCAAlignmentCenter;
    textLayer1.wrapped = YES;
    CFStringRef fontName = (__bridge CFStringRef)kFontNormal.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer1.font = fontRef;
    textLayer1.fontSize = kFontNormal.pointSize;
    textLayer1.contentsScale = [UIScreen mainScreen].scale;
    NSString *text1 = @"将家长的二维码放入框内";
    textLayer1.string = text1;
    
    CATextLayer *textLayer2 = [CATextLayer layer];
    textLayer2.frame = CGRectMake(10, _bgView.maxY +52+32 +6, kScreenWidth-2*10, 32);
    [self.view.layer addSublayer:textLayer2];
    textLayer2.foregroundColor = kColorWhite.CGColor;
    textLayer2.alignmentMode = kCAAlignmentCenter;
    textLayer2.wrapped = YES;
    textLayer2.font = fontRef;
    CGFontRelease(fontRef);
    textLayer2.fontSize = kFontNormal.pointSize;
    textLayer2.contentsScale = [UIScreen mainScreen].scale;
    NSString *text2 = @"即可完成签到";
    textLayer2.string = text2;
    
    upOrdown = NO;
    num =0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
//    self.view.backgroundColor = [UIColor clearColor];
    if(![[SDiPhoneVersion deviceName] isEqualToString:@"Simulator"])
    {
        [self setupCamera];
    }
}

- (void)animation1{
    CGFloat width = kScreenWidth - 2*70;
    CGFloat Y = _bgView.minY + 10;
    num ++;
    _lineImgView.frame = CGRectMake(80, Y+2*num, width - 20, 2);
    if (2*num + Y >= (_bgView.maxY - 10)) {
        num = 0;
    }
}

- (void)setupCamera
{
    CGFloat width = kScreenWidth - 2*70;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    // Device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // Output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest : CGRectMake ((_bgView.minY)/ kScreenHeight ,70/kScreenWidth , width / kScreenHeight , width / kScreenWidth )];
    
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
    _zBarReaderView = readerView;
    readerView.readerDelegate = self;
    readerView.frame = CGRectMake(0,self.customNavigationView.maxY,kScreenWidth,self.view.height_ - self.customNavigationView.maxY);
    readerView.torchMode = 0;
    [self.view insertSubview:readerView belowSubview:_bgView];
    readerView.tracksSymbols = NO;
    readerView.scanCrop = CGRectMake((_bgView.minY - self.customNavigationView.maxY)/readerView.height_, 70/readerView.width_,width/readerView.height_, width/readerView.width_);
    
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

//开始
- (void)startRunning
{
    if (_session.isRunning) {
        return;
    }
    dispatch_sync( _sessionQueue, ^{
        [_session startRunning];
    });
}
//停止
- (void)stopRunning
{
    if (!_session.isRunning) {
        return;
    }
    dispatch_sync( _sessionQueue, ^{
        // the captureSessionDidStopRunning method will stop recording if necessary as well, but we do it here so that the last video and audio samples are better aligned
        //        [self stopRecording]; // does nothing if we aren't currently recording
        [_session stopRunning];
    });
}
- (void)stopRunningWithFinishBlock:(void(^)())block
{
    if (!_session.isRunning) {
        return;
    }
    dispatch_sync( _sessionQueue, ^{
        // the captureSessionDidStopRunning method will stop recording if necessary as well, but we do it here so that the last video and audio samples are better aligned
        //        [self stopRecording]; // does nothing if we aren't currently recording
        [_session stopRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
}

//wjyteacher://check_in_with_user_id
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
    DDLogDebug(@"_isConfirmed:%@", @(_isConfirmed));
    if ([stringValue hasPrefix:@"wjyteacher://"] && [NSString isCardInfo:stringValue] && !_isConfirmed)
    {
        @synchronized(@"isConfirmed") {
            _isConfirmed = YES;
        }
        __weak __typeof(&*self) weakSelf=self;  //by sck
        [self stopRunningWithFinishBlock:^{
            NSString *userId = [NSString getUserIdByUrl:stringValue];
            NSString *userName = [NSString getUserNameByUrl:stringValue];
            NSString *cardNumber = [NSString getUserCardNumberByUrl:stringValue];
            DDLogDebug(@"cardNumber:%@", cardNumber);
            NSString *showTitle = @"";
            if([userName length] > 0 )
            {
                showTitle = [NSString stringWithFormat:@"%@签到成功",userName];
            }
            else if([cardNumber length] > 0)
            {
                showTitle = [NSString stringWithFormat:@"%@签到成功",cardNumber];
            }
            ButtonItem *cancel = [ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:^{
                [_session startRunning];
                _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:weakSelf selector:@selector(animation1) userInfo:nil repeats:YES];
                @synchronized(@"isConfirmed") {
                    _isConfirmed = NO;
                }
            } ];
            ButtonItem *confirm = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                [[TXChatClient sharedInstance].checkInManager addQrCheckInItem:[userId longLongValue] targetUserName:userName targetUserType:@"" targetCardNumber:cardNumber];
                _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:weakSelf selector:@selector(animation1) userInfo:nil repeats:YES];
                [_session startRunning];
                @synchronized(@"isConfirmed") {
                    _isConfirmed = NO;
                }
            } ];
            [weakSelf showAlertViewWithMessage:showTitle andButtonItems:cancel, confirm,nil];
            
            [_timer invalidate];
            _timer = nil;
        }];
    }
}
#else
- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    BOOL isFound = NO;
    for (ZBarSymbol *symbol in symbols) {
        if ([symbols.data hasPrefix:@"wjyteacher://"] && [NSString isCardInfo:symbols.data])
        {
            isFound = YES;
            NSString *userId = [NSString getUserIdByUrl:symbols.data];
            NSString *userName = [NSString getUserNameByUrl:symbols.data];
            NSString *cardNumber = [NSString getUserCardNumberByUrl:symbols.data];
            NSString *showTitle = @"";
            if([userName length] > 0)
            {
                showTitle = [NSString stringWithFormat:@"%@签到成功",userName];
            }
            else if([cardNumber length] > 0)
            {
                showTitle = [NSString stringWithFormat:@"%@签到成功",cardNumber];
            }
            
            ButtonItem *cancel = [ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:^{
                [readerView start];
                _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
            } ];
            ButtonItem *confirm = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
            [[TXChatClient sharedInstance].checkInManager addQrCheckInItem:[userId longLongValue] targetUserName:userName targetUserType:@"" targetCardNumber:cardNumber];
                _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
                [readerView start];
            } ];
            [self showAlertViewWithMessage:showTitle andButtonItems:cancel, confirm,nil];
            [_timer invalidate];
            _timer = nil;
        }
        break;
    }
    if (isFound) {
        [readerView stop];
    }
    
}
#endif



-(void)dealloc{

}

@end
