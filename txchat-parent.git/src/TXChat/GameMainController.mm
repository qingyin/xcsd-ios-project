//
//  GameMainController.m
//  TXChatParent
//
//  Created by yi.meng on 16/7/4.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "GameMainController.h"
#import "CCAppDelegate.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "platform/ios/CCDirectorCaller-ios.h"
#import "cocos2d.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "network/HttpClient.h"
#import "TXSystemManager.h"
#import "GameManager.h"

static cocos2d::Size designResolutionSize = cocos2d::Size(480, 320);
static cocos2d::Size smallResolutionSize = cocos2d::Size(480, 320);
static cocos2d::Size mediumResolutionSize = cocos2d::Size(1024, 768);
static cocos2d::Size largeResolutionSize = cocos2d::Size(2048, 1536);


@interface GameMainController ( ) {
    UIWindow *window;
	CCAppDelegate *app;
}

@property (strong, nonatomic) CCEAGLView *eaglView;

@end
@implementation GameMainController

@synthesize eaglView = _eaglView;

+(BOOL)callNativeUIWithTitle:(NSString *) title andContent:(NSString *)content{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    [alertView show];
    [instace.navigationController popViewControllerAnimated:YES];
    
    BOOL enterGameFlag = [[GameManager getInstance] getEnterGameFlag];
    if (enterGameFlag) {
        
        [[TXChatClient sharedInstance].dataReportManager reportEventBid:XCSDPBEventTypeChannelOut bid:TX_PROFILE_KEY_OPTION_GAME];
    }
    return true;
}

+(void)callNativeGameReport:(NSNumber*)gameId
                  eventType:(NSNumber*)eventType
{
    NSLog(@"callNativeGameReport------gameId=%@ eventType=%@",gameId,eventType);
    BOOL enterGameFlag = [[GameManager getInstance] getEnterGameFlag];
    if (enterGameFlag) {
        int64_t userid = [[GameManager getInstance] getEnterGameUserId];
        NSString* bid = [NSString stringWithFormat:@"%@",gameId];
        
        NSLog(@"callNativeGameReport---string---gameId=%@ eventType=%d userid=%lld",bid,[eventType intValue],userid);
        [[TXChatClient sharedInstance].dataReportManager reportGameData:(XCSDPBEventType)[eventType intValue] bid:bid userId:userid];
    }
}

+(void)callNativeFinishHomeworkReport:(NSString *)memberId
							 andScore:(NSString *)scoreJson
{
	int64_t userid = [[GameManager getInstance] getEnterGameUserId];
	
	NSLog(@"callNativeFinishHomeworkReport------memberId=%@ scoreJson=%@ userid=%lld",memberId,scoreJson,userid);
	[[TXChatClient sharedInstance].dataReportManager reportExtendedInfo:XCSDPBEventTypeFinishHomework bid:memberId userId:userid extendedInfo:scoreJson];
}

+(void)callNativeGameTestReport:(NSString *)testId
{
	NSLog(@"callNativeGameTestReport------testId=%@",testId);
	int64_t userid = [[GameManager getInstance] getEnterGameUserId];	
	[[TXChatClient sharedInstance].dataReportManager reportGameData:XCSDPBEventTypeGameTest bid:testId userId:userid];
}

+(void)callNativeLog:(NSString *)log
{
	NSLog(@"callNativeLog------=%@",log);
}
+(void)callNativeHttpPost:(NSString *)url
					token:(NSString *)token
				 bodyData:(NSString *)bodyData
				  hostUrl:(NSString *)hostUrl
			  callback:(NSString *)callback{
	[[TXHttpClient sharedInstance] sendRequest:url
										 token:token
									  bodyData:[bodyData dataUsingEncoding:NSUTF8StringEncoding]
									   hostUrl:[[TXSystemManager sharedManager] getJSHostUrlString]
								   onCompleted:^(NSError *error, NSData *responseData) {
									   NSError *innerError;
									   
									   TX_GO_TO_COMPLETED_IF_ERROR(error);
									   
								   completed:{
									   TX_POST_NOTIFICATION_IF_ERROR(innerError);
									   dispatch_async(dispatch_get_main_queue(), ^{
										   NSLog(@"\n\n url='%@',\n token='%@',\n bodyData='%@',\n hostUrl='%@'\n realHostUrl='%@',\n\n\n\n",url,token,bodyData,hostUrl,[[TXSystemManager sharedManager] getJSHostUrlString]);
										   NSLog(@"%lu bytes string is '%s'",(unsigned long)[responseData length],[responseData bytes]);
										   DDLogDebug(@"callNativeHttpPost->innerError:%@,%ld",innerError,(long)innerError.code);

										   if (innerError) {
											   instace->app->executeJSFunctionWithParam("{\"result\":400}","httpPostCallBack");
										   }else{
											   NSData * da = [responseData copy];
											   NSString *aString = [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
										       std::string str = std::string([aString UTF8String]);
											   instace->app->executeJSFunctionWithParam(str,"httpPostCallBack");
										   }
									   });
								   }
	}];
}

- (id)init{
    self = [super init];
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
    //disable Gesture
    self.fd_interactivePopDisabled = YES;
	
	
	app = new CCAppDelegate();
    //cocos2d::Application *app = cocos2d::Application::getInstance();
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();
	
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [[UIScreen mainScreen] bounds]
                                         pixelFormat: kEAGLColorFormatRGBA8
                                         depthFormat: GL_DEPTH24_STENCIL8_OES
                                  preserveBackbuffer: NO
                                          sharegroup: nil
                                       multiSampling: NO
                                     numberOfSamples: 0 ];
    
    self.eaglView = eaglView;
    
//    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
//    
//    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
//                                         pixelFormat: kEAGLColorFormatRGBA8
//                                         depthFormat: GL_DEPTH24_STENCIL8_OES
//                                  preserveBackbuffer: NO
//                                          sharegroup: nil
//                                       multiSampling: NO
//                                     numberOfSamples: 0 ];
    
    // Enable or disable multiple touches
    [self.eaglView setMultipleTouchEnabled:NO];
    [self.view insertSubview:self.eaglView atIndex:0];


    
    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView((__bridge void *)self.eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    
//    cocos2d::EventListenerCustom *_listener;
	
    app->setupMainScene();
	
	app->executeJSFunctionWithParam([self.param cStringUsingEncoding:NSASCIIStringEncoding],"EnterCocos");
    instace = self;
    
    
}

- (void)viewDidUnload {
    NSLog(@"GameViewController.viewDidUnload");
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL enterGameFlag = [[GameManager getInstance] getEnterGameFlag];
    if (enterGameFlag) {
        
        [[TXChatClient sharedInstance].dataReportManager reportEventBid:XCSDPBEventTypeChannelIn bid:TX_PROFILE_KEY_OPTION_GAME];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   cocos2d::Director::getInstance()->end();
}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    auto director = cocos2d::Director::getInstance();
    director->stopAnimation();
//    director->getEventDispatcher()->dispatchCustomEvent("game_on_hide");
//    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
//    SimpleAudioEngine::getInstance()->pauseAllEffects();
    
    director->purgeCachedData();
//    cocos2d::Director::getInstance()->pause();
//    cocos2d::Director::getInstance()->end();
    
    
//    [[CCDirectorCaller sharedDirectorCaller] stopMainLoop];
	
	
	
	delete app;
	
	//    director->getScheduler()->unscheduleAll();
	cocos2d::network::HttpClient::destroyInstance();
	
	
	
    
    if (self.eaglView) {
        [self.eaglView removeFromSuperview];
        self.eaglView = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    

}


@end
