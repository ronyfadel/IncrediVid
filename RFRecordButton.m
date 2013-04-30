//
//  RFRecordButton.m
//  incrediVid
//
//  Created by Rony Fadel on 4/30/13.
//
//

#import "RFRecordButton.h"

@implementation RFRecordButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.106 green: 0.09 blue: 0.114 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0.528 green: 0.053 blue: 0.132 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 0.114 green: 0.705 blue: 1 alpha: 1];
    UIColor* gradientColor = [UIColor colorWithRed: 0.902 green: 0.31 blue: 0.306 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0.321 green: 0.261 blue: 0.261 alpha: 1];
    UIColor* gradientColor2 = [UIColor colorWithRed: 0.879 green: 0.089 blue: 0.157 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientColor.CGColor,
                               (id)[UIColor colorWithRed: 0.89 green: 0.199 blue: 0.232 alpha: 1].CGColor,
                               (id)gradientColor2.CGColor,
                               (id)[UIColor colorWithRed: 0.704 green: 0.071 blue: 0.145 alpha: 1].CGColor,
                               (id)strokeColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 0.39, 0.48, 0.93, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow = color2;
    CGSize shadowOffset = CGSizeMake(0.1, -0.1);
    CGFloat shadowBlurRadius = 8;
    
    //// Oval 3 Drawing
    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(3.5, 2.5, 103, 101)];
    [fillColor setFill];
    [oval3Path fill];
    [[UIColor clearColor] setStroke];
    oval3Path.lineWidth = 0.5;
    [oval3Path stroke];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(15, 13, 80, 80)];
    [[UIColor clearColor] setFill];
    [ovalPath fill];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [color setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    CGContextRestoreGState(context);
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(30, 28, 50, 50)];
    CGContextSaveGState(context);
    [oval2Path addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(55, 28), CGPointMake(55, 78), 0);
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [color2 setStroke];
    oval2Path.lineWidth = 0.5;
    [oval2Path stroke];
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
