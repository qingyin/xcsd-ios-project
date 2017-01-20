

#import <Foundation/Foundation.h>

#include <openssl/rsa.h>

@interface MyRSA : NSObject

+ (NSString *)setPublicKey:(NSString *)data Mod:(NSString*)mod Exp:(NSString*)exp;


@end
