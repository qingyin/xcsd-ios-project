

#import "BaseJSONModel.h"
#import "MemberInfo.h"

@protocol CommentInfo
@end

@interface CommentInfo : BaseJSONModel

@property NSString* content;
@property BOOL deletable;
@property NSString* id;
@property MemberInfo *user;

@property NSDate *createDate;
//{
    //                      applyTo = "<null>";
    //                      content = "   \U6d4b\U8bd5   ";
    //                      createDate = "<null>";
    //                      deletable = 1;
    //                      id = 32;
    //                      user =             {
    //                          id = 132;
    //                          name = test;
    //                      };
    //                  },
@end
