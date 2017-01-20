//
//  XCSDTestInfo.m
//  Pods
//
//  Created by gaoju on 16/8/30.
//
//

#import "XCSDTestInfo.h"

@implementation XCSDTestInfo


//@property NSString* description;
//@property NSString* id;
//@property NSString* name;
//
//@property NSString* associateTag;
//
//@property NSString* animalPic;
//@property NSInteger status;
//
//@property NSString* colorValue;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)set{
    
    _testId = [set stringForColumn:@"testId"];
    _testDescription = [set stringForColumn:@"testDescription"];
    _name = [set stringForColumn:@"name"];
    _associateTag = [set stringForColumn:@"associateTag"];
    _animalPic = [set stringForColumn:@"animalPic"];
    _colorValue = [set stringForColumn:@"colorValue"];
    _status = [set intForColumn:@"status"];
    
    return self;
}

@end
