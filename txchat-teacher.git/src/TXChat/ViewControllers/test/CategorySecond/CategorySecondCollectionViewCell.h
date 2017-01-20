

#import <UIKit/UIKit.h>
#import "CategorySecondInfo.h"
#import "SchoolAgeInfo.h"
#import "BaseCollectionViewCell.h"
@interface CategorySecondCollectionViewCell : BaseCollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

-(void)setData:(CategorySecondInfo*)data schoolAge:(SchoolAgeInfo*)schoolAge;
@end
