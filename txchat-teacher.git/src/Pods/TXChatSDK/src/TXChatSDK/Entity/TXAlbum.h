//
//  TXAlbum.h
//  TXChatSDK
//
//  Created by lingqingwan on 10/22/15.
//  Copyright © 2015 lingiqngwan. All rights reserved.
//

#import "TXEntityBase.h"

@interface TXAlbum : TXEntityBase
/**
 * 名称
 */
@property(nonatomic, strong) NSString *name;
/**
 * 封面
 */
@property(nonatomic, strong) NSString *coverUrl;
@end
