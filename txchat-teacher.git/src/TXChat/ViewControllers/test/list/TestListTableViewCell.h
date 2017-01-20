

#import <UIKit/UIKit.h>

#import "TestInfo.h"

/** 亲子任务item */
@interface TestListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *borderView;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet UIImageView *animalImageView;

@property (weak, nonatomic) IBOutlet UIView *finishView;



-(void)setData:(TestInfo*)data;

@end
