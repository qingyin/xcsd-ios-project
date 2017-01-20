//
//  CHSCharacterCountTextView.m
//  ChildHoodStemp
//
//  Created by 日东 罗 on 13-9-9.
//
//

#import "CHSCharacterCountTextView.h"
#import <QuartzCore/QuartzCore.h>
//#import "MicroDef.h"

#define kViewRoundedCornerRadius 6.0f
#define KCountLabelHight (18.0f)
#define kMaxCharacterCount 30
#define kFontName @"[z] Arista"
#define kPlaceholderText @"输入内容..."

#define KNormalTextColor RGBCOLOR(0x32, 0x32, 0x32)
//#define KPlacehoderTextColor RGBCOLOR(0xd4, 0xd4, 0xd4)
#define KPlacehoderTextColor kColorLightGray

@interface CHSCharacterCountTextView (Private)
-(void)setupView;
@end

@implementation CHSCharacterCountTextView
@synthesize text = _text;

@synthesize delegate;

- (void)dealloc
{
    NSLog(@"CHSCharacterCountTextView dealloc");
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _maxInputNumbers = kMaxCharacterCount;
		// Setup the view
		[self setupView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	
	if( (self = [super initWithCoder:aDecoder]) ) {
		
		// Setup the view
		[self setupView];
	}
	return self;
}

-(id)initWithMaxNumber:(NSInteger)maxInputNumber placeHoder:(NSString *)placeHoder
{
    self = [super init];
    if(self)
    {
        _maxInputNumbers = maxInputNumber;
        _placeholdeText = placeHoder;
        [self setupView];
    }
    return self;
}


-(void)setText:(NSString *)text
{
    _text = text;
    messageTextView.text = text;
    characterCount =(int)( _maxInputNumbers - [[messageTextView text] length]);
    [characterCountLabel setText:[NSString stringWithFormat:@"%d", characterCount]];
    showingPlaceholder = NO;
    [messageTextView setTextColor:KNormalTextColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Private
-(void)setupView {
	// ****** README ********
	// Sometimes the font file name will be different than the embedded font name that the iOS system is using as it's key descriptior
	// So you'll have to print the available fonts and see which one font your looking for.
	// Print the available fonts
	//NSLog(@"Available Font Families: %@", [UIFont familyNames]);
    
	// Set rounded corners on the text view
	[self.layer setCornerRadius:kViewRoundedCornerRadius];
    
	// Set showing a placeholder by default
	showingPlaceholder = YES;
	
	// Add the text view
    

    
	messageTextView = [[UITextView alloc] initWithFrame:self.bounds];
	[messageTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
	[messageTextView setReturnKeyType:UIReturnKeyGo];
	[messageTextView.layer setCornerRadius:kViewRoundedCornerRadius];
	[messageTextView setBackgroundColor:[UIColor clearColor]];
    if(KISSTRNULL(_placeholdeText))
    {
        [messageTextView setText:kPlaceholderText];
    }
    else
    {
        [messageTextView setText:_placeholdeText];
    }
//	[messageTextView setTextColor:[UIColor lightGrayColor]];
    [messageTextView setTextColor:KPlacehoderTextColor];
	
	messageTextView.delegate = self;
	[messageTextView setFont:kFontTitle];
	[self addSubview:messageTextView];
	
	// Set the max character count
//	characterCount = _maxInputNumbers;
    characterCount = 0;
	
	// Add a character label
//	float characterCountLabelWidth = 20.0f;
//	float characterCountLabelHeight =  18.0f;
//	characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-characterCountLabelWidth-3, self.frame.size.height-characterCountLabelHeight, characterCountLabelWidth, characterCountLabelHeight)];
    
    characterCountLabel = [[UILabel alloc] init];
	[characterCountLabel setTextAlignment:NSTextAlignmentRight];
	[characterCountLabel setFont:[UIFont systemFontOfSize:14.0f]];
	[characterCountLabel setBackgroundColor:[UIColor clearColor]];
//    characterCountLabel.textColor = [UIColor lightGrayColor];
    characterCountLabel.textColor = RGBCOLOR(0xd4, 0xd4, 0xd4);
	[characterCountLabel setText:[NSString stringWithFormat:@"%d/%ld", characterCount, (long)_maxInputNumbers]];
	[self addSubview:characterCountLabel];
    [self setBackgroundColor:[UIColor clearColor]];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    float characterCountLabelWidth = 70;
    float characterCountLabelHeight =  KCountLabelHight;
    characterCountLabel.frame = CGRectMake(self.frame.size.width-characterCountLabelWidth-3, self.frame.size.height-characterCountLabelHeight, characterCountLabelWidth, characterCountLabelHeight);
    CGRect rect = self.bounds;
    rect.size.height -= KCountLabelHight;
    messageTextView.frame = rect;
    
}

-(NSString *)getContent
{
    if(showingPlaceholder)
    {
        return nil;
    }
    return messageTextView.text;
}

#pragma mark - UITextView Delegate Methods
-(void)textViewDidBeginEditing:(UITextView *)textView {
    
	// Check if it's showing a placeholder, remove it if so
	if(showingPlaceholder) {
		[textView setText:@""];
		[textView setTextColor:KNormalTextColor];
		
		showingPlaceholder = NO;
	}
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
	// Check the length and if it should add a placeholder
	if([[textView text] length] == 0 && !showingPlaceholder) {
        if(KISSTRNULL(_placeholdeText))
        {
            [messageTextView setText:kPlaceholderText];
        }
        else
        {
            [messageTextView setText:_placeholdeText];
        }
		[textView setTextColor:KPlacehoderTextColor];
		
		showingPlaceholder = YES;
	}

    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

	// if the user clicked the return key
	if ([text isEqualToString: @"\n"]) {
		// Hide the keyboard
		[textView resignFirstResponder];
		
		// Also return if its showing a placeholder
		if(showingPlaceholder) {
			return NO;
		}
		
		// Notify the delegate
		if(delegate && [delegate respondsToSelector:@selector(characterCountTextView:postedMessage:)]) {
			[delegate characterCountTextView:self postedMessage:textView.text];
		}
        
		return NO ;
	}
	return YES ;
}

- (void)textViewDidChange:(UITextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (textView.text.length > _maxInputNumbers) {
            textView.text = [textView.text substringToIndex:_maxInputNumbers];
        }
        if (textView.text.length <=_maxInputNumbers) {
            // Update the character count
            characterCount =  (int)[[textView text] length];
            [characterCountLabel setText:[NSString stringWithFormat:@"%d/%ld", characterCount, (long)_maxInputNumbers]];
        }
    });
    if(delegate && [delegate respondsToSelector:@selector(characterCountTextViewIsShowPlaceholder:)])
    {
        [delegate characterCountTextViewIsShowPlaceholder:showingPlaceholder || textView.text.length == 0];
    }
	
//	// Check if the count is over the limit
//	if(characterCount < 0) {
//		// Change the color
//		[characterCountLabel setTextColor:[UIColor redColor]];
//	}
//	else if(characterCount < 20) {
//		// Change the color to yellow
//		[characterCountLabel setTextColor:[UIColor orangeColor]];
//	}
//	else {
//		// Set normal color
//		[characterCountLabel setTextColor:[UIColor lightGrayColor]];
//	}
}
-(BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    [messageTextView resignFirstResponder];
    return YES;
}

@end
