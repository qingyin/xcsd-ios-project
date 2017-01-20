//
//  LineChartsView.m
//  ChartsTest
//
//  Created by gaoju on 16/7/11.
//  Copyright © 2016年 Shlvit. All rights reserved.
//

#import "LineChartsView.h"
#import "UIColor+Hex.h"


//#define kRow_Margin 40
#define kRow_Margin ((kScreenWidth - 70 * 2) / 6)
#define kOrigin_Point CGPointMake(60, self.frame.size.height - 20 - 36)



@interface LineChartsView ()


@property (nonatomic, strong) NSArray *points;

@property (nonatomic, strong) NSArray<NSString *> *rowArr;

@property (nonatomic, strong) NSArray<NSString *> *colArr;

@end


@implementation LineChartsView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setAllPoints:(NSArray *)points{
    
    self.points = points;
}

- (void)setRowDataSource:(NSArray<NSString *> *)rowArr{
    self.rowArr = rowArr;
}

- (void)setColDataSource:(NSArray<NSString *> *)colArr{
    
    self.colArr = colArr;
}

- (void)addOriginLines{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [[UIColor colorWithHexRGB:@"919191"] set];
    
    [path moveToPoint:kOrigin_Point];
    [path addLineToPoint:CGPointMake(kOrigin_Point.x + self.rowArr.count * kRow_Margin + kRow_Margin, kOrigin_Point.y)];
    [path addLineToPoint:CGPointMake(kOrigin_Point.x + self.rowArr.count * kRow_Margin + kRow_Margin - 10, kOrigin_Point.y - 8)];
    [path addLineToPoint:CGPointMake(kOrigin_Point.x + self.rowArr.count * kRow_Margin + kRow_Margin, kOrigin_Point.y)];
    [path addLineToPoint:CGPointMake(kOrigin_Point.x + self.rowArr.count * kRow_Margin + kRow_Margin - 10, kOrigin_Point.y + 8)];
    
    [path moveToPoint:kOrigin_Point];
    [path addLineToPoint:CGPointMake(kOrigin_Point.x, kOrigin_Point.y - self.colArr.count * kRow_Margin)];
    [path addLineToPoint:CGPointMake(kOrigin_Point.x - 10, kOrigin_Point.y - self.colArr.count * kRow_Margin + 10)];
    [path addLineToPoint:CGPointMake(kOrigin_Point.x, kOrigin_Point.y - self.colArr.count * kRow_Margin)];
    
    [path addLineToPoint:CGPointMake(kOrigin_Point.x + 10, kOrigin_Point.y - self.colArr.count * kRow_Margin + 10)];
    
    [path stroke];
}

- (void)addRowAndColLines{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [[UIColor lightGrayColor] set];
    
    NSInteger offSetY = self.colArr.count * kRow_Margin;
    
    for (NSInteger i = 0; i < self.rowArr.count; i++) {
        
        [path moveToPoint:CGPointMake((i + 1) * kRow_Margin + kOrigin_Point.x, kOrigin_Point.y)];
        [path addLineToPoint:CGPointMake((i + 1) * kRow_Margin + kOrigin_Point.x, kOrigin_Point.y - offSetY)];
    }
    
    NSInteger offSetX = self.rowArr.count * kRow_Margin;
    for (NSInteger i = 0; i < self.colArr.count; i++) {
        
        [path moveToPoint:CGPointMake(kOrigin_Point.x, kOrigin_Point.y - (i + 1) * kRow_Margin)];
        [path addLineToPoint:CGPointMake(kOrigin_Point.x + offSetX, kOrigin_Point.y - (i + 1) * kRow_Margin)];
    }
    
    [path stroke];
}

- (void)addTexts{
    
    [self.rowArr enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat titleX = kOrigin_Point.x + (idx + 1) * kRow_Margin - 5;
        CGFloat titleY = kOrigin_Point.y + 5;
        CGFloat titleWH = 50;
        
        [str drawInRect:CGRectMake(titleX, titleY, titleWH, titleWH) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],
                    NSForegroundColorAttributeName : [UIColor colorWithHexRGB:@"919191"]}];
        
    }];
    
    [self.colArr enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat titleX = kOrigin_Point.x - 30;
        CGFloat titleY = kOrigin_Point.y - 10 - idx * kRow_Margin;
        CGFloat titleWH = 50;
        
        [str drawInRect:CGRectMake(titleX, titleY, titleWH, titleWH) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13],
            NSForegroundColorAttributeName : [UIColor colorWithHexRGB:@"919191"]}];
    }];
}

- (void)addSelectedPoints{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSInteger minScore = self.colArr.firstObject.integerValue;
    
    [[UIColor colorWithHexRGB:@"fda220"] set];
    NSInteger pointY = ((NSNumber *)self.points.firstObject).integerValue;
    CGContextSetLineWidth(ctx, 3);
    
    for (NSInteger i = 1; i < self.points.count; ++i) {
        
        NSInteger score = [self.points[i] integerValue] - minScore;
        NSInteger score1 = [self.points[i - 1] integerValue] - minScore;
        
        CGFloat pointX = kOrigin_Point.x + kRow_Margin + i * kRow_Margin;
        CGFloat pointY1 = kOrigin_Point.y - (score / self.length) * kRow_Margin - (float)(score % self.length) / self.length * kRow_Margin;
        CGFloat pointY2 = kOrigin_Point.y - (score1 / self.length) * kRow_Margin - (float)(score1 % self.length) / self.length * kRow_Margin;
        
        CGContextMoveToPoint(ctx, pointX - kRow_Margin, pointY2);
        
        CGContextAddLineToPoint(ctx, pointX, pointY1);
        
        CGContextStrokePath(ctx);
        pointY = score;
    }
    
    CGContextClosePath(ctx);
}

- (void)addPointNumbers{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NSInteger minScore = self.colArr.firstObject.integerValue;
    
    [self.points enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat pointX = kOrigin_Point.x + kRow_Margin + idx * kRow_Margin;
        NSInteger score = str.integerValue - minScore;
        CGFloat pointY = kOrigin_Point.y - (score / self.length) * kRow_Margin - (float)(score % self.length) / self.length * kRow_Margin;
        
        [RGBCOLOR(255, 201, 34) set];
        CGContextAddArc(ctx, pointX, pointY, 4.5, 0, 2 * M_PI, 1);
        
        CGContextFillPath(ctx);
        
        [str drawAtPoint:CGPointMake(pointX + 3, pointY + 3) withAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexRGB:@"919191"], NSFontAttributeName : [UIFont systemFontOfSize:12]}];
    }];
}

- (void)addRowColTitle:(NSString *)rowTitle colTitle:(NSString *)colTitle{
    
    CGFloat titleX = kOrigin_Point.x + self.rowArr.count * kRow_Margin + 10;
    CGFloat titleY = kOrigin_Point.y + 10;
    CGFloat titleWH = 60;
    
    [rowTitle drawInRect:CGRectMake(titleX, titleY, titleWH + 10, titleWH) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                                                            NSForegroundColorAttributeName : [UIColor colorWithHexRGB:@"919191"]}];
    
    CGFloat ytitleX = kOrigin_Point.x - 30 - 10 - 2;
    CGFloat ytitleY = kOrigin_Point.y - 10 - self.colArr.count * kRow_Margin + 15 - 15;
    CGFloat ytitleWH = 50;
    [colTitle drawInRect:CGRectMake(ytitleX, ytitleY, ytitleWH, ytitleWH) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                                                                       NSForegroundColorAttributeName : [UIColor colorWithHexRGB:@"919191"]}];
}

- (void)drawRect:(CGRect)rect{
    
    [self addOriginLines];
    
//    [self addRowAndColLines];
    
    [self addSelectedPoints];
    
    [self addTexts];
    
    [self addRowColTitle:@"测试次数" colTitle:@"成绩"];
    
    [self addPointNumbers];
}

- (NSInteger)colSize{
    
    if (_colSize == 0) {
        
        _colSize = 50;
    }
    return _colSize;
}

@end
