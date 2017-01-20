//
//  XCSDAbilityEvaluation.m
//  Pods
//
//  Created by gaoju on 16/7/20.
//
//

#import "XCSDAbilityEvaluation.h"

@implementation XCSDAbilityEvaluation

- (instancetype)loadValueFromPbObject:(XCSDPBAbilityEvaluationResponse *)evaluation{
    _details = evaluation.details;
    _avgAbilityLevel = evaluation.avgAbilityLevel;
    _avgAbilityPercentage = evaluation.avgAbilityPercentage;
    _abilityQuotient = evaluation.abilityQuotient;
    _maxAbilityQuotient = evaluation.maxAbilityQuotient;
    
    _abilityChart = evaluation.abilityChart;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:_details forKey:@"details"];
    [aCoder encodeObject:@(_avgAbilityLevel) forKey:@"avgAbilityLevel"];
    [aCoder encodeObject:@(_avgAbilityPercentage) forKey:@"avgAbilityPercentage"];
    [aCoder encodeObject:@(_abilityQuotient) forKey:@"abilityQuotient"];
    [aCoder encodeObject:_abilityChart forKey:@"abilityChart"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    return self;
}

@end

@implementation XCSDAbilityEvaluationPoint

- (instancetype)loadValueFromPbObject:(XCSDPBAbilityEvaluationResponsePoint *)evaluation{
    _number = evaluation.number;
    _score = evaluation.score;
}

@end
