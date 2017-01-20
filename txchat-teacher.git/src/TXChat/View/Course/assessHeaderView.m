//
//  assessHeaderView.m
//  TXChatParent
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "assessHeaderView.h"

@implementation assessHeaderView

- (void)bindDateWithCourse:(TXPBCourse *)course andStarNum:(NSInteger)integer
{
    if (course != nil) {
        self.scoreLable.text = [NSString stringWithFormat:@"综合评分：%.1f分",course.score];
        self.lableAssess.text = [NSString stringWithFormat:@"%lld人评价",course.scoreCnt];
        
        int num = (int)course.score;
        if (num == 0) {
            self.star1.image = [UIImage imageNamed:@"s-star_71"];
            self.star3.image = [UIImage imageNamed:@"s-star_71"];
            self.star4.image = [UIImage imageNamed:@"s-star_71"];
            self.star5.image = [UIImage imageNamed:@"s-star_71"];
            self.star2.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (num == 1) {
            if (course.score-num != 0) {
                self.star2.image = [UIImage imageNamed:@"s-star_74"];
            }else{
                self.star2.image = [UIImage imageNamed:@"s-star_71"];
            }
            self.star1.image = [UIImage imageNamed:@"s-star_68"];
            self.star3.image = [UIImage imageNamed:@"s-star_71"];
            self.star4.image = [UIImage imageNamed:@"s-star_71"];
            self.star5.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (num == 2) {
            if (course.score-num != 0) {
                self.star3.image = [UIImage imageNamed:@"s-star_74"];
            }else{
                self.star3.image = [UIImage imageNamed:@"s-star_71"];
            }
            self.star1.image = [UIImage imageNamed:@"s-star_68"];
            self.star2.image = [UIImage imageNamed:@"s-star_68"];
            self.star4.image = [UIImage imageNamed:@"s-star_71"];
            self.star5.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (num == 3) {
            if (course.score-num != 0) {
                self.star4.image = [UIImage imageNamed:@"s-star_74"];
            }else{
                self.star4.image = [UIImage imageNamed:@"s-star_71"];
            }
            self.star1.image = [UIImage imageNamed:@"s-star_68"];
            self.star3.image = [UIImage imageNamed:@"s-star_68"];
            self.star2.image = [UIImage imageNamed:@"s-star_68"];
            self.star5.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (num == 4) {
            if (course.score-num != 0) {
                self.star5.image = [UIImage imageNamed:@"s-star_74"];
            }else{
                self.star5.image = [UIImage imageNamed:@"s-star_71"];
            }
            self.star1.image = [UIImage imageNamed:@"s-star_68"];
            self.star3.image = [UIImage imageNamed:@"s-star_68"];
            self.star2.image = [UIImage imageNamed:@"s-star_68"];
            self.star4.image = [UIImage imageNamed:@"s-star_68"];
        }
        if (num == 5) {
            self.star1.image = [UIImage imageNamed:@"s-star_68"];
            self.star3.image = [UIImage imageNamed:@"s-star_68"];
            self.star4.image = [UIImage imageNamed:@"s-star_68"];
            self.star5.image = [UIImage imageNamed:@"s-star_68"];
            self.star2.image = [UIImage imageNamed:@"s-star_68"];
        }
        
        if (integer == 1) {
            self.image1.image = [UIImage imageNamed:@"l-star_23"];
            self.image2.image = [UIImage imageNamed:@"l-star_26"];
            self.image4.image = [UIImage imageNamed:@"l-star_26"];
            self.image5.image = [UIImage imageNamed:@"l-star_26"];
            self.image3.image = [UIImage imageNamed:@"l-star_26"];
        }
        if (integer == 2) {
            self.image1.image = [UIImage imageNamed:@"l-star_23"];
            self.image3.image = [UIImage imageNamed:@"l-star_26"];
            self.image4.image = [UIImage imageNamed:@"l-star_26"];
            self.image5.image = [UIImage imageNamed:@"l-star_26"];
            self.image2.image = [UIImage imageNamed:@"l-star_23"];
        }
        if (integer == 3) {
            self.image1.image = [UIImage imageNamed:@"l-star_23"];
            self.image3.image = [UIImage imageNamed:@"l-star_23"];
            self.image4.image = [UIImage imageNamed:@"l-star_26"];
            self.image5.image = [UIImage imageNamed:@"l-star_26"];
            self.image2.image = [UIImage imageNamed:@"l-star_23"];
        }
        if (integer == 4) {
            self.image1.image = [UIImage imageNamed:@"l-star_23"];
            self.image3.image = [UIImage imageNamed:@"l-star_23"];
            self.image4.image = [UIImage imageNamed:@"l-star_23"];
            self.image5.image = [UIImage imageNamed:@"l-star_26"];
            self.image2.image = [UIImage imageNamed:@"l-star_23"];
        }
        if (integer == 5) {
            self.image1.image = [UIImage imageNamed:@"l-star_23"];
            self.image3.image = [UIImage imageNamed:@"l-star_23"];
            self.image4.image = [UIImage imageNamed:@"l-star_23"];
            self.image5.image = [UIImage imageNamed:@"l-star_23"];
            self.image2.image = [UIImage imageNamed:@"l-star_23"];
        }
    }
}

@end
