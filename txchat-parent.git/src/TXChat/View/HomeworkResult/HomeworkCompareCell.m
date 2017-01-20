//
//  HomeworkCompareCell.m
//  TXChatParent
//
//  Created by gaoju on 12/27/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import "HomeworkCompareCell.h"
#import "UIColor+Hex.h"

@interface HomeworkCompareCell ()

@property (nonatomic, weak) UILabel *titleLbl;

@end

@implementation HomeworkCompareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexRGB:@"8CD0FF"];
        
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.textLabel.textColor = [UIColor colorWithHexRGB:@"484848"];
        self.textLabel.font = [UIFont systemFontOfSize:16];
    }
    
    return self;
}

@end
