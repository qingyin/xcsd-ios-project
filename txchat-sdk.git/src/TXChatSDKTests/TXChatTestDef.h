//
// Created by lingqingwan on 6/9/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#define WAIT(code_block) \
    __block BOOL done;\
    code_block;\
    while (!done) {\
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];\
    }

#define WAIT_START \
    __block BOOL done;
#define WAIT_UNTIL_DONE \
    while (!done) {\
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];\
    }
#define WAIT_DONE done=TRUE