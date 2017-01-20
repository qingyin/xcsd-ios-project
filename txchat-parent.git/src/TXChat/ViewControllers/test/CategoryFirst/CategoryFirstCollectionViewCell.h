

#import <UIKit/UIKit.h>
#import "CategoryFirstInfo.h"
#import "SchoolAgeInfo.h"
#import "BaseCollectionViewCell.h"
@interface CategoryFirstCollectionViewCell : BaseCollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *animalImageView;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

//+(UIColor*)getColor:(NSInteger) color;
//+(UIImage*)getAnimalImg:(NSInteger) type;

-(void)setData:(CategoryFirstInfo*)data schoolAge:(SchoolAgeInfo*)schoolAge;
@end
