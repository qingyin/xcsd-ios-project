//
//  TXAsynRun.h
//  TXChat
//
//  Created by 陈爱彬 on 15/7/12.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#ifndef TXAsynRun_h
#define TXAsynRun_h

typedef void(^TXBlockRun)(void);

//void TXAsyncRun(TXBlockRun run);
//
//void TXAsyncRunInMain(TXBlockRun run);



#import <Foundation/Foundation.h>
#import "TXAsynRun.h"

static void TXAsyncRun(TXBlockRun run) {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
		run();
	});
}

static void TXAsyncRunInMain(TXBlockRun run) {
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		run();
	});
}

#endif