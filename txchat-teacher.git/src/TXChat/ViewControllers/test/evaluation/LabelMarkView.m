

#import "LabelMarkView.h"


@implementation LabelMarkView


@synthesize backgroundImageName;
@synthesize foregroundImageName;


- (void)drawRect:(CGRect)rect
{
    // Drawing code.
    [super drawRect:rect];
    
    if (self.backgroundImageName == nil) {
        self.backgroundImageName = @"";
    }
    
    if (self.foregroundImageName == nil) {
        self.foregroundImageName = @"";
    }
	
	CGPoint ratingImageOrigin = CGPointMake(0, 0);
	
    UIImage *ratingBackgroundImage = [UIImage imageNamed:self.backgroundImageName];
    [ratingBackgroundImage drawAtPoint:ratingImageOrigin];
    
    
    UIImage *ratingForegroundImage = [UIImage imageNamed:self.foregroundImageName];
    CGFloat width = ratingForegroundImage.size.width;
    width = ratingForegroundImage.size.width * _mark;
    UIRectClip(CGRectMake(ratingImageOrigin.x, ratingImageOrigin.y, 
                          width,
                          ratingForegroundImage.size.height));
    [ratingForegroundImage drawAtPoint:ratingImageOrigin];
}

-(void)setMark:(double)mark
{
    _mark = mark;

    [self setNeedsDisplay];
}

@end
