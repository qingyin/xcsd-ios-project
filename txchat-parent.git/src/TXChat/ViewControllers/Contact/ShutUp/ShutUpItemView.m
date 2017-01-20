//
//  ShutUpItemView.m
//  ChildHoodStemp
//
//  Created by steven_l on 15/2/13.
//
//

#import "ShutUpItemView.h"
//#import "UIUtil.h"
#import "MicroDef.h"
//#import "Snsp.pb.h"
//#define ContentLightGrayColor   [UIColor lightGrayColor]        //界面所用小字号所用字体颜色
//#define ContentDarkGrayColor    [UIColor grayColor]             //界面所用中字号所用字体颜色
////#define SpecialGrayColor        [UIUtil colorWithHexString:@"#595757" withAlpha:1]      //界面所用大字号所用字体颜色
//#define SpecialGrayColor                RGBCOLOR(0x59, 0x57, 0x57)      //界面所用大字号所用字体颜色
//#define Contact_EdgeSpaceToTop      30
//#define Contact_LabelHight          20
//#define Contact_LabelWidth          60
//#define Contact_BtnHorizontalSpace  5
//#define Contact_BtnVerticalSpace    5
//#define Contact_BtnEdge             70
//#define Contact_LabelNameHeight     20
//#define Contact_MemberWidth         (Contact_BtnEdge+2*Contact_BtnHorizontalSpace)
//#define Contact_MemberHeight        (Contact_BtnEdge+Contact_LabelNameHeight+Contact_BtnVerticalSpace)
@interface ShutUpItemView()

@property (nonatomic,retain) UILabel* name;
@property (nonatomic,strong) UIImageView *deleteImageView;
@property (nonatomic,retain) MutiltimediaView* portraitView;
@property (nonatomic,strong) UIButton *deleteBtn;



@end
@implementation ShutUpItemView


-(void)dealloc
{
    self.portraitView = nil;
    self.name = nil;
    NSLog(@"SelectItem dealloc");
}

-(id)initWithName:(NSString*)name portraitURI:(NSString*)uri withIndex:(int)index
{
    self = [super init];
    if (self) {
        self.portraitView = [[MutiltimediaView alloc] initWithFrame:CGRectMake(Contact_BtnHorizontalSpace, Contact_LabelHight/2, Contact_BtnEdge-8, Contact_BtnEdge-8)];
        [_portraitView setMultimediaFileUri:uri type:SNSPMaterialTypeKImage];
        [_portraitView.layer setCornerRadius:6];
        [_portraitView setClipsToBounds:YES];
        [_portraitView setUserInteractionEnabled: YES];
        [_portraitView setBackgroundColor:ContentLightGrayColor];
        [self addSubview:_portraitView];

        self.index = index;
        
        self.name = [[UILabel alloc] initWithFrame:CGRectMake(_portraitView.frame.origin.x-3, (_portraitView.frame.origin.y + Contact_BtnEdge-3), Contact_BtnEdge, Contact_LabelNameHeight-5)];
        [_name setBackgroundColor:[UIColor clearColor]];
        [_name setTextAlignment:NSTextAlignmentCenter];
        [_name setText:name];
        [_name setTextColor:SpecialGrayColor];
        [_name setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_name];


        [self setFrame:CGRectMake(0, 0, Contact_MemberWidth, Contact_MemberHeight)];
        [self setUserInteractionEnabled:YES];
        [self setClipsToBounds:YES];
        
        
        self.deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_portraitView.frame), CGRectGetMinY(_portraitView.frame), 25, 25)];
        _deleteImageView.hidden = YES;
        _deleteBtn.userInteractionEnabled = YES;
        _deleteImageView.image = [UIImage imageNamed:@"deteleIdentifier"];
        [self addSubview:_deleteImageView];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn addTarget:self action:@selector(deleteItem) forControlEvents:UIControlEventTouchUpInside];
        _deleteBtn.enabled = NO;
        _deleteBtn.frame = self.bounds;
        [self addSubview:_deleteBtn];
    }
    return self;
}


- (void)deleteItem
{
    _block(_index);
}

#pragma mark -
#pragma mark Wobble Methods

-(void)beginWobble
{
    _deleteImageView.hidden = NO;
    _deleteBtn.enabled = YES;
//    @autoreleasepool {
//        srand([[NSDate date] timeIntervalSince1970]);
//        float rand=(float)random();
//        CFTimeInterval t=rand*0.0000000001;
//        [UIView animateWithDuration:0.1 delay:t options:0  animations:^
//         {
//             self.transform=CGAffineTransformMakeRotation(-0.05);
//         } completion:^(BOOL finished)
//         {
//             [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^
//              {
//                  self.transform=CGAffineTransformMakeRotation(0.05);
//              } completion:^(BOOL finished) {}];
//         }];
//    }
}

-(void)endWobble
{
    _deleteImageView.hidden = YES;
    _deleteBtn.enabled = NO;

//    @autoreleasepool {
//        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
//         {
//             self.transform=CGAffineTransformIdentity;
//         } completion:^(BOOL finished) {}];
//    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
