//
//  LZLineView.m
//  ZengLab5
//
//  Created by Li Zeng on 3/30/14.
//  Copyright (c) 2014 LZ. All rights reserved.
//

#import "LZLineView.h"

@implementation LZLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [[UIColor orangeColor] setStroke];
    
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    [bezierPath moveToPoint: CGPointMake(x, y)];
    [bezierPath addLineToPoint:CGPointMake(x + CELLSIZE, y + CELLSIZE)];
    [bezierPath stroke];
    [bezierPath removeAllPoints];
    
    [bezierPath moveToPoint: CGPointMake(x + CELLSIZE, y)];
    [bezierPath addLineToPoint:CGPointMake(x, y + CELLSIZE)];
    [bezierPath stroke];
    [bezierPath removeAllPoints];

    CGContextRestoreGState(contextRef);

}

@end
