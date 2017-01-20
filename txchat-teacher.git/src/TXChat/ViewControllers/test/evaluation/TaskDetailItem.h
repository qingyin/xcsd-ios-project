
#import <Foundation/Foundation.h>

@interface TaskDetailItem : NSObject

@property NSInteger tag;

@property NSString *title;
@property NSString *content;
@property NSString *picture;
@property BOOL html;


@property BOOL expandable;
@property BOOL isExpanded;

@property int contentHeight;
@end
