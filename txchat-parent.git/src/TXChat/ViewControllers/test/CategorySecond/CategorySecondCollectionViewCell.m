

#import "CategorySecondCollectionViewCell.h"

#import "UIColor+Hex.h"

@implementation CategorySecondCollectionViewCell


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


-(void)setData:(CategorySecondInfo *)data schoolAge:(SchoolAgeInfo *)schoolAge
{
    self.titleLabel.text = data.name;
    
    self.backgroundColor = [UIColor colorFromHexRGB:data.colorValue default:[UIColor whiteColor]];//[CategoryFirstCollectionViewCell getColor:data.color];
   
    
    self.ageLabel.text = schoolAge.name;

    if(data.status==1){
        //已完成
        self.statusImageView.hidden=NO;
    }else{
        self.statusImageView.hidden=YES;
    }
}


@end
