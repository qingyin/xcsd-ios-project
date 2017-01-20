//
//  XCSDAbilityEvaluation.h
//  Pods
//
//  Created by gaoju on 16/7/20.
//
//

#import <TXChatSDK/TXChatSDK.h>
#import "XCSDLearningAbility.pb.h"

@interface XCSDAbilityEvaluation<NSCoding> : TXEntityBase

@property (readonly, strong) NSArray * details;
@property (readonly) Float64 avgAbilityLevel;
@property (readonly) Float64 avgAbilityPercentage;
@property (readonly) SInt32 abilityQuotient;
@property (readonly) SInt32 maxAbilityQuotient;
@property (readonly, strong) NSArray * abilityChart;

//- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBAbilityEvaluationResponse *)evaluation;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end

@interface XCSDAbilityEvaluationPoint<NSCoding> : TXEntityBase

@property (nonatomic, assign) SInt32 number;

@property (nonatomic, assign) SInt32 score;

//- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBAbilityEvaluationResponsePoint *)evaluation;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end
