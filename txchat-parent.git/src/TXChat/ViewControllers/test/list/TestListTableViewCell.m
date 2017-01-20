

#import "TestListTableViewCell.h"

#import "UIView+UIViewUtils.h"
//#import "LabelUtils.h"
#import "CategoryFirstCollectionViewCell.h"
#import "TaskInfo.h"
#import "UIColor+Hex.h"
//#import "UIImageView+WebCache.h"

@interface TestListTableViewCell(){
    
}
@end

@implementation TestListTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    
    //边框
    [self.borderView  setBorderWithWidth:0.5 andCornerRadius:0 andBorderColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setData:(TestInfo*)data
{
    
    
    NSURL *url=nil;
    if (data.animalPic.length>0)
    {
        url= [NSURL URLWithString:data.animalPic] ;
    }
    [self.animalImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    
    self.animalImageView.backgroundColor = [UIColor colorWithHexRGB:data.colorValue];
    
    self.titleLabel.text = data.name;
    
    
    self.finishView.hidden = (data.status!=kTestStatusFinish);
    
}
@end
