

#import "BaseResponse.h"
#import "PreloginResult.h"

@interface PreloginResponse : BaseResponse

//{  errorCode = 0;
    //                                   message = "<null>";
    //                                   result =     {
    //                                       m = 8785f7837418b4be30d5c08033fc3dce05c2dcfd4f428911ae8985fbe95bf76885be752489694f2cf7ae93a309520d4aaeca29ae5e8b8fab9efe2618cc84aa1d6c5f4ffd8250391c86d85c2601f0d7055e5d541137a783ac15da7ccb21cd8abec7ee5a05b3b6e03d3521cfd7e42b261e49cd14d253af505357802ce865c6a11b;
    //                                       p = 10001;
    //                                       r = 326998;
    //                                       t = 1406798661355;
    //                                   }

@property PreloginResult<Optional>* result;


@end
