 

#import "BaseViewController.h"
#import "TestInfo.h"
#import "ChildInfo.h"
#import "CategorySecondInfo.h"
@interface TestSubjectViewController : BaseViewController

//@property CategorySecondInfo* categorySecondInfo;

@property ChildInfo *childInfo;
@property TestInfo *testInfo;

- (IBAction)previousAction:(id)sender;
- (IBAction)nextAction:(id)sender;




@end
