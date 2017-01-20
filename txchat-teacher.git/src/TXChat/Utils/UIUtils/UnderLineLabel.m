
#import "UnderLineLabel.h"
//#import "LabelUtils.h"
#import "UILabel+ContentSize.h"

@implementation UnderLineLabel


- (id)initWithFrame:(CGRect)frame

{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
    
}


- (id)init

{
    
    if (self = [super init]) {
        
    }
    
    return self;
    
}


-(void)setText:(NSString *)text
{

    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange contentRange = {0, [content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];

    self.attributedText = content;
    
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByWordWrapping;
    
//    CGSize size = [LabelUtils sizeWithFont:self.font WithText:text width:CGRectGetWidth(self.frame) andMinHeight:0];
    CGSize size = [UILabel contentSizeForLabelWithText:text maxWidth:self.width_ font:self.font];
    CGRect frame = self.frame;
    frame.size.height = size.height;
    self.frame = frame;
}





- (void)addTarget:(id)target action:(SEL)action

{
    
    [self setUserInteractionEnabled:TRUE];
    
    if (_actionView) {
        [_actionView removeFromSuperview];
        _actionView=nil;
    }
    _actionView = [[UIControl alloc] initWithFrame:self.bounds];
    [self addSubview:_actionView];
    [_actionView setBackgroundColor:[UIColor clearColor]];
    
    [_actionView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
}







@end


