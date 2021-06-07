//
//  RXPopMenuArrow.m
//  sanjiao
//
//  Created by Rex on 2018/4/24.
//  Copyright © 2018年 Rex. All rights reserved.
//

#import "RXPopMenuArrow.h"

@interface RXPopMenuArrow()

@property (nonatomic, strong) UIColor * backColor;

@end

@implementation RXPopMenuArrow

- (instancetype)initWithFrame:(CGRect)frame Color:(UIColor *)backColor; {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.backColor = backColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    CGFloat arrowwid = rect.size.width;
    CGFloat arrowhei = rect.size.height;
    CGContextMoveToPoint(ctx, 0, arrowhei);
    CGContextAddLineToPoint(ctx, arrowwid/2, 0);
    CGContextAddLineToPoint(ctx, arrowwid, arrowhei);
    
    [self.backColor set];
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

@end
