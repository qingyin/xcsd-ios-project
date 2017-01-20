//
//  CHSelectChildCell.m
//  ChildHoodStemp
//
//  Created by zhuxuehang on 13-12-5.
//
//

#import <QuartzCore/QuartzCore.h>
#import "CHSelectChildCell.h"
//#import "UIUtil.h"
#import "MicroDef.h"
//
//#import "Snsp.pb.h"
//
//#import "ChildHoodMemory.h"




//#define PortraitEdge 70
//#define HorSpace    20
//#define VerSpace    10
//#define SpaceToLeft (HARDWARE_SCREEN_WIDTH-2*HorSpace-3*PortraitEdge)/2
//
//#define BtnEdge             70
//#define BtnHorizontalSpace  5
//#define BtnVerticalSpace    5
//#define LabelNameHeight     20
//#define MemberWidth         (BtnEdge+2*BtnHorizontalSpace)
//#define MemberHeight        (BtnEdge+LabelNameHeight+BtnVerticalSpace)
//#define EdgeSpaceToLeft     (HARDWARE_SCREEN_WIDTH-4*MemberWidth)/2
//#define EdgeSpaceToTop      30
//#define LabelHight          20
//#define LabelWidth          60



//---------------------------------------------------------------------------------------//
//选择项

@implementation SelectItem
@synthesize portraitView = _portraitView;
@synthesize selectView = _selectView;
@synthesize name = _name;
@synthesize isSelect = _isSelect;
@synthesize hasChooosedView =  _hasChooosedView;

-(void)dealloc
{
    NSLog(@"SelectItem dealloc");
}

-(id)initWithCenter:(CGPoint)center name:(NSString*)name portraitURI:(NSString*)uri action:(CHTapGesture*)action
{
    self = [super init];
    if (self) {
        _portraitView = [[MutiltimediaView alloc] initWithFrame:CGRectMake(Contact_BtnHorizontalSpace, Contact_LabelHight/2, Contact_BtnEdge-8, Contact_BtnEdge-8)];
        [_portraitView setMultimediaFileUri:uri type:SNSPMaterialTypeKImage];
        [_portraitView.layer setCornerRadius:6];
        [_portraitView setClipsToBounds:YES];
        [_portraitView setBackgroundColor:ContentLightGrayColor];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(_portraitView.frame.origin.x-3, (_portraitView.frame.origin.y + Contact_BtnEdge-3), Contact_BtnEdge, Contact_LabelNameHeight-5)];
        [_name setBackgroundColor:[UIColor clearColor]];
        [_name setTextAlignment:NSTextAlignmentCenter];
        [_name setText:name];
        [_name setTextColor:SpecialGrayColor];
        [_name setFont:ContentDarkFont];
        
        _selectView = [[UIImageView alloc]initWithFrame:CGRectMake(Contact_BtnEdge-25, 15, 20, 20)];
        [_selectView setImage:[UIImage imageNamed:@"overlay.png"]];
        _selectView.frame = _portraitView.frame;
        _selectView.hidden = !_isSelect;
        
        
        _hasChooosedView = [[UIView alloc]initWithFrame:CGRectMake(Contact_BtnEdge-25, 15, 20, 20)];
        _hasChooosedView.frame = _portraitView.frame;
        _hasChooosedView.backgroundColor = [UIColor blackColor];
        _hasChooosedView.alpha = 0.7;
        _hasChooosedView.hidden = YES;

        
        [self addSubview:_portraitView];
        [self addSubview:_name];
        [self addSubview:_selectView];
        [self addSubview:_hasChooosedView];
        
        [self setFrame:CGRectMake(0, 0, Contact_MemberWidth, Contact_MemberHeight)];
        [self setCenter:center];
        [self setClipsToBounds:YES];
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:action];
        [self bringSubviewToFront:_selectView];

    }
    return self;
}

-(void)setSelectItem
{
    _isSelect = YES;
    _selectView.hidden = !_isSelect;
}

-(void)deSelectItem
{
    _isSelect = NO;
    _selectView.hidden = !_isSelect;
}
- (void)setHasChooseItem
{
    _hasChooosedView.hidden = NO;
    self.userInteractionEnabled = NO;
}


@end
//---------------------------------------------------------------------------------------//
//

@implementation CHSelectChildCell
@synthesize delegate = _delegate;
@synthesize clazzId = _clazzId;
@synthesize sectionIndex = _sectionIndex;

-(void)dealloc
{
    NSLog(@"CHSelectChildCell dealloc");
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        self.backgroundView = nil;
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDataWithArray:(NSArray*)arr
{
    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];
    for (UIView* ele in self.contentView.subviews) {
        [ele removeFromSuperview];
    }
    if ([arr count]==0) {
        return;
    }
    
    CGFloat left = HARDWARE_SCREEN_WIDTH > 375?Contact_EdgeSpaceToLeft_h:Contact_EdgeSpaceToLeft;
    int colums = HARDWARE_SCREEN_WIDTH > 375?5:4;
    
    //[self.contentView removeFromSuperview];
    
    self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    NSInteger lines = ([arr count]%colums >0) ? ([arr count]/colums + 1) : [arr count]/colums;
    for (int i=0 ;i < arr.count;i++) {
//        ChildHoodMemory* ele = (ChildHoodMemory*)[arr objectAtIndex:i];
        CHTapGesture* tap = [[CHTapGesture alloc] initWithTarget:self
                                                           action:@selector(selectItemTapAction:)
                                                              tag:i+100];
        [tap.userInfo setObject:@"0" forKey:@"IsSelect"];
        SelectItem* item = [[SelectItem alloc] initWithCenter:CGPointMake(                                                                          4+ left+ Contact_MemberWidth*(i%colums)+Contact_MemberWidth/2,(i/colums)*Contact_MemberHeight+Contact_MemberHeight/2)
                                                          name:@"name"
                                                   portraitURI:@"first_selected"
                                                        action:tap];
        [item setTag:i+100];
        [self.contentView addSubview:item];
    }

    CGFloat viewHeight = Contact_EdgeSpaceToTop;// VerSpace;
    viewHeight += (lines*(Contact_MemberHeight));
    CGRect fra = self.frame;
    fra.size.height = viewHeight;
    [self setFrame:fra];
}

-(void)selectItemTapAction:(CHTapGesture*)item
{
    SelectItem* ele = (SelectItem*)[self.contentView viewWithTag:item.tag];
    if (ele.isSelect) {
        [ele deSelectItem];
    }else
    {
        [ele setSelectItem];
    }
    [item.userInfo setObject:[NSString stringWithFormat:@"%d",ele.isSelect] forKey:@"IsSelect"];
    [item.userInfo setObject:[NSNumber numberWithInt:self.clazzId] forKey:@"ClazzId"];
    [item.userInfo setObject:[NSNumber numberWithInt:self.sectionIndex] forKey:@"sectionIndex"];
    if (_delegate && [_delegate respondsToSelector:@selector(selectItemDelegate:)]) {
        [_delegate selectItemDelegate:item];
    }
}

-(void)selectAllItem
{
    for (SelectItem* ele in self.contentView.subviews) {
        [ele setSelectItem];
    }
}

-(void)selectItems:(NSDictionary*)selectDict
{
    for(NSString* key in selectDict.allKeys){
        int tag = [key intValue]+100;
        SelectItem* ele = (SelectItem*)[self.contentView viewWithTag:tag];
        [ele setSelectItem];
        //int BOOL = selectDict objectForKey:key
    }
   
}



@end
