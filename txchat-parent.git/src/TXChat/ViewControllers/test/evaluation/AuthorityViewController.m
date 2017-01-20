

#import "AuthorityViewController.h"
#import "TaskDetailItem.h"
//#import "LabelUtils.h"
#import "TTTAttributedLabel.h"
#import "UIView+UIViewUtils.h"

@interface AuthorityViewController ()
{
    
    __weak IBOutlet UIScrollView *_scrollView;
}
@end

@implementation AuthorityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"文献介绍";

//    作者
//    Xxx
//    期刊名
//    Xxx
//    关键词
//    Xxx
//    文献摘要
//    Xxxx
    
    CGFloat y = 20;
    //标题
    CGFloat x = 10;
    CGFloat width = CGRectGetWidth(_scrollView.frame)-2*x;
    NSString *title = self.authorityInfo.title;
    
    TTTAttributedLabel *titleLabel = [[TTTAttributedLabel alloc]init];
    titleLabel.textColor=[UIColor colorWithRed:39/255.0 green:39/255.0 blue:39/255.0 alpha:1];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.lineSpacing = 5;//行距
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0 ;
    titleLabel.text = title;
    
    CGSize size =   [TTTAttributedLabel sizeThatFitsAttributedString:titleLabel.attributedText withConstraints:CGSizeMake(width, 1000) limitedToNumberOfLines:100];
    
    titleLabel.frame = CGRectMake(x, y, width, size.height);
    
    [_scrollView addSubview:titleLabel];
    
    
    NSMutableArray* _dataArray = [[NSMutableArray alloc]init];
    TaskDetailItem *item = nil;
    
    if (self.authorityInfo.introduction.length>0)
    {
        item = [[TaskDetailItem alloc]init];
        item.title = @"简介";
        item.content = self.authorityInfo.introduction;
        [_dataArray addObject:item];
    }
    
    if (self.authorityInfo.author.length>0)
    {
        item = [[TaskDetailItem alloc]init];
        item.title = @"作者";
        item.content = self.authorityInfo.author;
        [_dataArray addObject:item];
    }
    
    if (self.authorityInfo.journalName.length>0) {
        item = [[TaskDetailItem alloc]init];
        item.title = @"期刊名";
        item.content = self.authorityInfo.journalName;
        [_dataArray addObject:item];
    }
    
    if (self.authorityInfo.keywords.length>0) {
        item = [[TaskDetailItem alloc]init];
        item.title = @"关键词";
        item.content = self.authorityInfo.keywords;
        [_dataArray addObject:item];
    }
    
    if (self.authorityInfo.summary.length>0) {
        item = [[TaskDetailItem alloc]init];
        item.title = @"文献摘要";
        item.content = self.authorityInfo.summary;
        [_dataArray addObject:item];
    }
    
//    for (UIView *view in _scrollView.subviews) {
//        [view removeFromSuperview];
//    }
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(titleLabel.frame)+20, width, 1)];
    container.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    [container setBorderWithWidth:0.5 andCornerRadius:0 andBorderColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1]];
    
    CGFloat y1 = 0;
    NSInteger i=0;
    for (TaskDetailItem *data in _dataArray) {
        
        if (i>0) {
            //分割线
            CGFloat x1 = 7.5;
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(x1, y1, CGRectGetWidth(container.frame)-2*x1, 1)];
            line.backgroundColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1];
            [container addSubview:line];
            
            y1 = CGRectGetMaxY(line.frame);
        }
        
        
        UIView *view = [self createViewWithData:data parentView:container];
        CGRect frame = view.frame;
        frame.origin.y = y1;
        view.frame = frame;
        [container addSubview:view];
        
        y1 = CGRectGetMaxY(view.frame);
     
        
        i++;
        
    }
    
    container.frame = CGRectMake(x, CGRectGetMaxY(titleLabel.frame)+20, width, y1+10);
    [_scrollView addSubview:container];
    
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(container.frame)+25);
}

-(UIView*)createViewWithData:(TaskDetailItem *)data parentView:(UIView*)parentView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(parentView.frame), 1)];
    
    CGFloat x = 7.5;
    CGFloat y = 10;
    CGFloat width = CGRectGetWidth(parentView.frame)-2*x;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, width, 25)];
    titleLabel.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = data.title;
    [view addSubview:titleLabel];
    
    
    y = CGRectGetMaxY(titleLabel.frame)+10;
    
    
//    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, width, 25)];
//    contentLabel.numberOfLines=0;
//    contentLabel.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
//    contentLabel.font = [UIFont systemFontOfSize:12];
//    contentLabel.text = data.content;
//    
//    CGSize size = [LabelUtils  sizeWithFont:contentLabel.font WithText:contentLabel.text width:CGRectGetWidth(contentLabel.frame) andMinHeight:25];
//    CGRect frame = contentLabel.frame;
//    frame.size.height = size.height;
//    contentLabel.frame = frame;
//    [view addSubview:contentLabel];
    
    TTTAttributedLabel *contentLabel = [[TTTAttributedLabel alloc]init];
    contentLabel.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    contentLabel.font = [UIFont systemFontOfSize:12];
    contentLabel.lineSpacing = 5;//行距
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contentLabel.numberOfLines = 0 ;
    contentLabel.text = data.content;
    
    CGSize size =   [TTTAttributedLabel sizeThatFitsAttributedString:contentLabel.attributedText withConstraints:CGSizeMake(width, 1000) limitedToNumberOfLines:100];
    
    contentLabel.frame = CGRectMake(x, y, width, size.height);
    [view addSubview:contentLabel];
    
    y=  CGRectGetMaxY(contentLabel.frame)+10;
    
    
    CGRect frame = view.frame;
    frame.size.height = y;
    view.frame = frame;
    
    return view;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
