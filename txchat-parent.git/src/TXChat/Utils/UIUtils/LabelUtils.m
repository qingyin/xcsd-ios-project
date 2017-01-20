

#import "LabelUtils.h"

@implementation LabelUtils

+(CGSize) sizeWithFont: (UIFont *)font WithText: (NSString *) strText width:(CGFloat)width andMinHeight:(CGFloat)minHeight
{
    
    CGSize  actualsize = CGSizeMake(0, 0);
    if (strText.length>0) {
        
        CGSize constraint = CGSizeMake(width, MAXFLOAT);
        
        CGFloat version =[[UIDevice currentDevice].systemVersion floatValue];
        if ( version >=7.0 )
        {
            //    获取当前文本的属性
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
            
            //ios7方法，获取文本需要的size，限制宽度
            
            actualsize =[strText boundingRectWithSize:constraint options: NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            
            
            actualsize.height=    actualsize.height+1;
            
            
        }else{
            
            
            
            actualsize = [strText sizeWithFont: font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            actualsize.height =actualsize.height+1;
        }
    }
    
    if (actualsize.height<minHeight) {
        actualsize.height=minHeight;
    }
    
    return actualsize;
}

+(CGFloat) heightForLabel: (UILabel *)label WithText: (NSString *) strText andMinHeight:(CGFloat)minHeight{
    
    CGFloat height = 0;
    if (strText.length>0) {
        
        CGSize constraint = CGSizeMake(CGRectGetWidth(label.frame), MAXFLOAT);
        
        CGFloat version =[[UIDevice currentDevice].systemVersion floatValue];
        if ( version >=7.0 )
        {
            //    获取当前文本的属性
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:label.font,NSFontAttributeName,nil];
            
            //ios7方法，获取文本需要的size，限制宽度
            
            CGSize  actualsize =[strText boundingRectWithSize:constraint options: NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
            
            
            height=    actualsize.height+1;
            
            
        }else{
            
            
            
            CGSize size = [strText sizeWithFont: label.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            height =size.height+1;
        }
    }
    
    if (height<minHeight) {
        height=minHeight;
    }
    
    return height;
}

+(CGFloat)widthForLabel:(UILabel *)label WithText:(NSString *)strText
{
    //    获取宽度，获取字符串不折行单行显示时所需要的长度
    //    如果想得到宽度的话，size的width应该设为MAXFLOAT。
    CGSize size = [strText sizeWithFont:label.font constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(label.frame))];
    
    return size.width;
}

@end
