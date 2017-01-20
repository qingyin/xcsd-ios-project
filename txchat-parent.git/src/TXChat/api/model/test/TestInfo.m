

#import "TestInfo.h"
#import "XCSDTestInfo.h"

@implementation TestInfo
@synthesize description=_description;

-(NSString*)description
{
    return _description;
}
-(void)setDescription:(NSString *)description
{
    _description = description;
}

- (XCSDTestInfo *)changeIntoXCSDTestInfo{
    
    XCSDTestInfo *xcsdtestInfo = [[XCSDTestInfo alloc] init];
    xcsdtestInfo.testId = _id;
    xcsdtestInfo.testDescription = _description;
    xcsdtestInfo.name = _name;
    xcsdtestInfo.associateTag = _associateTag;
    xcsdtestInfo.animalPic = _animalPic;
    xcsdtestInfo.status = _status;
    xcsdtestInfo.colorValue = _colorValue;
    
    return xcsdtestInfo;
}

+ (instancetype)fromXCSDTestInfo:(XCSDTestInfo *)xcsdTestInfo{
    
    TestInfo *testInfo = TestInfo.new;
    testInfo.id = xcsdTestInfo.testId;
    testInfo.description = xcsdTestInfo.testDescription;
    testInfo.name = xcsdTestInfo.name;
    testInfo.associateTag = xcsdTestInfo.associateTag;
    testInfo.animalPic = xcsdTestInfo.animalPic;
    testInfo.status = xcsdTestInfo.status;
    testInfo.colorValue = xcsdTestInfo.colorValue;
    return testInfo;
}
@end
