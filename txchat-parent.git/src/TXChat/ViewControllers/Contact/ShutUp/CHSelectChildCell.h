//
//  CHSelectChildCell.h
//  ChildHoodStemp
//
//  Created by zhuxuehang on 13-12-5.
//
//

#import <UIKit/UIKit.h>
#import "MutiltimediaView.h"
#import "CHTapGesture.h"


@protocol CHSelectChildCellDelegate <NSObject>

@optional
-(void)selectItemDelegate:(CHTapGesture*)sender;

@end

@interface CHSelectChildCell : UITableViewCell
{
    int  _clazzId;
    int  _sectionIndex;

}
@property (nonatomic,assign)id<CHSelectChildCellDelegate>delegate;
@property (nonatomic,assign) int clazzId;
@property (nonatomic,assign) int sectionIndex;


-(void)setDataWithArray:(NSArray*)arr;
-(void)selectAllItem;
-(void)selectItems:(NSDictionary*)selectDict;

@end




@interface SelectItem : UIView
{
    MutiltimediaView* _portraitView;
    UIImageView*   _selectView;
    UILabel* _name;
    BOOL _isSelect;
}
@property (nonatomic,retain) MutiltimediaView* portraitView;
@property (nonatomic,retain) UIImageView* selectView;
@property (nonatomic,retain) UILabel* name;
@property (nonatomic,assign) BOOL isSelect;
@property (nonatomic, retain) UIView *hasChooosedView;


-(id)initWithCenter:(CGPoint)center name:(NSString*)name portraitURI:(NSString*)uri action:(CHTapGesture*)action;
-(void)setSelectItem;
-(void)deSelectItem;
- (void)setHasChooseItem;
@end