

#import "CategoryFirstCollectionViewCell.h"
//#import "UIImageView+WebCache.h"
#import "UIColor+Hex.h"

@implementation CategoryFirstCollectionViewCell



-(void)awakeFromNib
{
    //圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
 
    //旋转
    self.ageLabel.layer.transform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
//    self.ageLabel.layer.transform = CATransform3DTranslate(self.ageLabel.layer.transform, 25, -15, 0);
    self.ageLabel.layer.shouldRasterize = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)setData:(CategoryFirstInfo *)data schoolAge:(SchoolAgeInfo *)schoolAge
{
    self.titleLabel.text = data.name;
    
    self.backgroundColor = [UIColor colorFromHexRGB:data.colorValue default:[UIColor whiteColor]]; //[CategoryFirstCollectionViewCell getColor:data.color];
//    self.animalImageView.image = [CategoryFirstCollectionViewCell getAnimalImg:data.type];
    [self.animalImageView sd_setImageWithURL:[NSURL URLWithString:data.animalPic]];
    
    
    self.ageLabel.text = schoolAge.name;
}

// #58d68d
// #2b7fb8
// #f1c40e
// #e84e40
// #3898db
// #9a59b5
// #e67f23
//88,214,141
//43,127,184
//241,196,14
//232,78,64
//56,152,219
//154,89,181
//230,127,35
//+(UIColor*)getColor:(NSInteger) color
//{
//    switch (color) {
//		case 1:
//			return [UIColor colorWithRed:88/255.0 green:214/255.0 blue:141/255.0 alpha:1];
//            
//		case 2:
//			return [UIColor colorWithRed:43/255.0 green:127/255.0 blue:184/255.0 alpha:1];
//            
//		case 3:
//			return [UIColor colorWithRed:241/255.0 green:196/255.0 blue:14/255.0 alpha:1];
//            
//		case 4:
//			return [UIColor colorWithRed:232/255.0 green:78/255.0 blue:64/255.0 alpha:1];
//            
//		case 5:
//			return [UIColor colorWithRed:56/255.0 green:152/255.0 blue:219/255.0 alpha:1];
//            
//		case 6:
//			return [UIColor colorWithRed:154/255.0 green:89/255.0 blue:181/255.0 alpha:1];
//            
//		case 7:
//			return [UIColor colorWithRed:230/255.0 green:127/255.0 blue:35/255.0 alpha:1];
//            
//            
//		default:
//			break;
//    }
//    return [UIColor colorWithRed:88/255.0 green:214/255.0 blue:141/255.0 alpha:1];
//}




//+(UIImage*)getAnimalImg:(NSInteger) type
//{
//    NSString* result = @"cat.png";
//    switch (type) {
//		case 1:
//			result = @"cat.png";
//			break;
//		case 2:
//			result = @"dog.png";
//			break;
//		case 3:
//			result = @"dolphin.png";
//			break;
//		case 4:
//			result = @"rabbit.png";
//			break;
//		case 5:
//			result = @"monkey.png";
//			break;
//		case 6:
//			result = @"sheep.png";
//			break;
//		case 7:
//			result = @"tiger.png";
//			break;
//		case 8:
//			result = @"snake.png";
//			break;
//		default:
//			break;
//    }
//    return [UIImage imageNamed:result];
//}
@end
