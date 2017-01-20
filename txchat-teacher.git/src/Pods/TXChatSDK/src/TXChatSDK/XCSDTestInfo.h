//
//  XCSDTestInfo.h
//  Pods
//
//  Created by gaoju on 16/8/30.
//
//

#import "TXEntityBase.h"

@interface XCSDTestInfo : TXEntityBase


@property (nonatomic, copy) NSString* testId;
@property (nonatomic, copy) NSString* name;

@property (nonatomic, copy) NSString* associateTag;

@property (nonatomic, copy) NSString* animalPic;
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, copy) NSString* colorValue;
@property (nonatomic, copy) NSString* testDescription;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)set;

@end
