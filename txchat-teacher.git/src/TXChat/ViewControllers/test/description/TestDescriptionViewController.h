

#import "BaseViewController.h"
#import "ChildInfo.h"
#import "CategorySecondInfo.h"
@class TestInfo;

@interface TestDescriptionViewController : BaseViewController


@property ChildInfo* childInfo;
//@property CategorySecondInfo *categorySecondInfo;
@property NSString* testID;

@property (nonatomic, strong) TestInfo *testInfo;

- (IBAction)startAction:(id)sender;

@end
