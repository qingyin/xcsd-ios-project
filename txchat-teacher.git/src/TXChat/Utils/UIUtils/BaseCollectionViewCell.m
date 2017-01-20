

#import "BaseCollectionViewCell.h"

@implementation BaseCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 在此添加
        
        // 初始化时加载xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options: nil];
        
        // 如果路径不存在，return nil
        if(arrayOfViews.count < 1)
        {
            return nil;
        }
        
        // 如果xib中view不属于UICollectionViewCell类，return nil
        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[self class]]){
            return nil;
        }
        
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

@end
