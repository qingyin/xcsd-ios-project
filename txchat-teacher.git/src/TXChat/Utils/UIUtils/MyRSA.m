

#import "MyRSA.h"



@implementation MyRSA

+ (NSString *)setPublicKey:(NSString *)data Mod:(NSString*)modulus Exp:(NSString*)exponent
{
    //    const char *key = [sp UTF8String];
    const char *mod = [modulus UTF8String];
    const char *exp = [exponent UTF8String];
    const char *input = [data UTF8String];
    
    RSA * pubkey = RSA_new();
    
    BIGNUM * bnmod = BN_new();
    BIGNUM * bnexp = BN_new();
    
    BN_hex2bn(&bnmod, mod);
    NSLog(@"十进制mod：%s", BN_bn2dec(bnmod));
    BN_hex2bn(&bnexp, exp);
    NSLog(@"十进制exp：%s", BN_bn2dec(bnexp));
    
    
    
    pubkey->n = bnmod;
    pubkey->e = bnexp;
    
    int nLen = RSA_size(pubkey);
    
    char *crip = (char*)malloc(nLen); // (char *)malloc(sizeof(char*)*nLen+1);//malloc(nLen-RSA_PKCS1_PADDING_SIZE) ;
    bzero(crip, nLen);
    
    
    int ret = RSA_public_encrypt(nLen,  (const unsigned char *)input, (unsigned char *)crip, pubkey, RSA_NO_PADDING);
    NSLog(@"ret : %d",ret);
    
//    char* resultChar;
    if (ret <= 0)
    {
        NSLog(@"erro encrypt");
    
        
    }
    else
    {
        
        NSLog(@"SUC encrypt");
        
//        BIGNUM *rs;
//        rs = BN_new();
//        
//        BN_bin2bn((unsigned char *)crip, ret, rs);
//        resultChar = BN_bn2hex(rs);
//        NSLog(@"Encrypt OK, sp=%s",resultChar);//转为16进
        
        

    }
    
     NSData *resData = [NSData dataWithBytes:crip length:ret];
    
    free(crip);
    RSA_free(pubkey);
    
//    return [[NSString alloc]initWithData:resData encoding:NSUTF8StringEncoding];
   
    return [self hex:resData useLower:NO];
//    return [NSString stringWithCString:resultChar encoding:NSUTF8StringEncoding];
}

+ (NSString *)hex: (NSData *)data useLower: (bool)isOutputLower
{
    static const char HexEncodeCharsLower[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
    static const char HexEncodeChars[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    char *resultData;
    // malloc result data
    resultData = malloc([data length] * 2 +1);
    // convert imgData(NSData) to char[]
    unsigned char *sourceData = ((unsigned char *)[data bytes]);
    uint length = [data length];
    
    if (isOutputLower) {
        for (uint index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeCharsLower[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeCharsLower[(sourceData[index] % 0x10)];
        }
    }
    else {
        for (uint index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeChars[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeChars[(sourceData[index] % 0x10)];
        }
    }
    resultData[[data length] * 2] = 0;
    
    // convert result(char[]) to NSString
    NSString *result = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    sourceData = nil;
    free(resultData);
    
    return result;
}

@end
