
#import <UIKit/UIKit.h>


@interface LabelMarkView : UILabel {
    NSString *backgroundImageName;
    NSString *foregroundImageName;

	double _mark;
}
-(void)setMark:(double)mark;

@property (nonatomic, strong) NSString *backgroundImageName;
@property (nonatomic, strong) NSString *foregroundImageName;

@end
