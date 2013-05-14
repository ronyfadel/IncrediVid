//
//  RFPlayButton.m
//  incrediVid
//
//  Created by Rony Fadel on 5/14/13.
//
//

#import "RFPlayButton.h"

@implementation RFPlayButton

- (void)drawRect:(CGRect)rect
{
    float playButtonOpacity = (self.state == UIControlStateHighlighted) ? 0.7 : 1.0;
    float backgroundOpacity = (self.state == UIControlStateHighlighted) ? 0.6 : 1.0;
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: playButtonOpacity];
    UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: playButtonOpacity];
    
    //// Shadow Declarations
    UIColor* shadow = strokeColor;
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 2;
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 183, 183) cornerRadius: 6];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0 - backgroundOpacity] setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(112, 92.02)];
    [bezier2Path addLineToPoint: CGPointMake(81.94, 109.43)];
    [bezier2Path addLineToPoint: CGPointMake(82.02, 74.46)];
    [bezier2Path addLineToPoint: CGPointMake(112, 92.02)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(67.6, 67.1)];
    [bezier2Path addCurveToPoint: CGPointMake(67.6, 115.9) controlPoint1: CGPointMake(54.13, 80.58) controlPoint2: CGPointMake(54.13, 102.42)];
    [bezier2Path addCurveToPoint: CGPointMake(116.4, 115.9) controlPoint1: CGPointMake(81.08, 129.37) controlPoint2: CGPointMake(102.92, 129.37)];
    [bezier2Path addCurveToPoint: CGPointMake(116.4, 67.1) controlPoint1: CGPointMake(129.87, 102.42) controlPoint2: CGPointMake(129.87, 80.58)];
    [bezier2Path addCurveToPoint: CGPointMake(67.6, 67.1) controlPoint1: CGPointMake(102.92, 53.63) controlPoint2: CGPointMake(81.08, 53.63)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(121.2, 62.3)];
    [bezier2Path addCurveToPoint: CGPointMake(121.2, 121.7) controlPoint1: CGPointMake(137.6, 78.7) controlPoint2: CGPointMake(137.6, 105.3)];
    [bezier2Path addCurveToPoint: CGPointMake(61.8, 121.7) controlPoint1: CGPointMake(104.8, 138.1) controlPoint2: CGPointMake(78.2, 138.1)];
    [bezier2Path addCurveToPoint: CGPointMake(61.8, 62.3) controlPoint1: CGPointMake(45.4, 105.3) controlPoint2: CGPointMake(45.4, 78.7)];
    [bezier2Path addCurveToPoint: CGPointMake(121.2, 62.3) controlPoint1: CGPointMake(78.2, 45.9) controlPoint2: CGPointMake(104.8, 45.9)];
    [bezier2Path closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [fillColor setFill];
    [bezier2Path fill];
    CGContextRestoreGState(context);
}
- (void)setHighlighted:(BOOL)highlighted
{
    [self setNeedsDisplay];
    [super setHighlighted:highlighted];
}


@end









