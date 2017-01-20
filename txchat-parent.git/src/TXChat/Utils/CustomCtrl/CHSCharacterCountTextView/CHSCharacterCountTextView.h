//
//  CHSCharacterCountTextView.h
//  ChildHoodStemp
//
//  Created by 日东 罗 on 13-9-9.
//
//

#import <UIKit/UIKit.h>

@class CHSCharacterCountTextView;

@protocol CHSCharacterCountTextViewDelegate <NSObject>

@optional
-(void)characterCountTextView:(CHSCharacterCountTextView *)textView postedMessage:(NSString *)message;
//是否显示初始内容
-(void)characterCountTextViewIsShowPlaceholder:(BOOL)isShowPlaceholder;

@end

@interface CHSCharacterCountTextView : UIView <UITextViewDelegate>
{
    NSString *_text;
    
    UITextView *messageTextView;
    
	// The character counter
	UILabel *characterCountLabel;
	
	// The character count
	int characterCount;
    
	// Showing a placeholder
	BOOL showingPlaceholder;
	
	// The delegate
	__weak id <CHSCharacterCountTextViewDelegate> delegate;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, weak) id <CHSCharacterCountTextViewDelegate> delegate;
@property(nonatomic, assign)NSInteger maxInputNumbers;
@property(nonatomic, retain)NSString *placeholdeText;//默认显示内容

-(id)initWithMaxNumber:(NSInteger)maxInputNumber placeHoder:(NSString *)placeHoder;

-(NSString *)getContent;

-(BOOL)resignFirstResponder;

@end
