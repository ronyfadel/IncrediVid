//
//  RFRecordButton.m
//  incrediVid
//
//  Created by Rony Fadel on 4/30/13.
//
//

#import "RFRecordButton.h"
#import <QuartzCore/QuartzCore.h>

@interface RFRecordButton ()
@property (nonatomic, readwrite) NSTimeInterval pulseAnimationDuration; // default is 1s
@property (nonatomic, readwrite) NSTimeInterval delayBetweenPulseCycles; // default is 1s
@end

@implementation RFRecordButton

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.pulseAnimationDuration = 2;
    self.delayBetweenPulseCycles = 0.5;
    self.haloLayer = [RFRecordButton makeHaloLayerWithBounds:self.bounds
                                           animationDuration:self.pulseAnimationDuration
                                          delayBetweenCycles:self.delayBetweenPulseCycles
                                                       radii:@[@50, @65, @80]
                                                   fromValue:@0.65
                                                     toValue:@1.1];
}

//- (void)drawRect:(CGRect)rect
//{
//    float buttonOpacity = (self.state == UIControlStateHighlighted) ? 0.8 : 1.0;
//    //// General Declarations
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    //// Color Declarations
//    UIColor* fillColor = [UIColor colorWithRed: 0.08 green: 0.07 blue: 0.09 alpha: 1];
//    
//    UIColor* strokeColor = [UIColor colorWithRed: 0.528 green: 0.053 blue: 0.132 alpha: 1];
//    UIColor* color = [UIColor colorWithRed: 0.114 green: 0.705 blue: 1 alpha: buttonOpacity];
//    UIColor* gradientColor = [UIColor colorWithRed: 0.902 green: 0.31 blue: 0.306 alpha: buttonOpacity];
//    UIColor* color2 = [UIColor colorWithRed: 0.321 green: 0.261 blue: 0.261 alpha: 1];
//    UIColor* gradientColor2 = [UIColor colorWithRed: 0.879 green: 0.089 blue: 0.157 alpha: buttonOpacity];
//    
//    //// Gradient Declarations
//    NSArray* gradientColors = [NSArray arrayWithObjects:
//                               (id)gradientColor.CGColor,
//                               (id)[UIColor colorWithRed: 0.89 green: 0.199 blue: 0.232 alpha: buttonOpacity].CGColor,
//                               (id)gradientColor2.CGColor,
//                               (id)[UIColor colorWithRed: 0.704 green: 0.071 blue: 0.145 alpha: buttonOpacity].CGColor,
//                               (id)strokeColor.CGColor, nil];
//    CGFloat gradientLocations[] = {0, 0.39, 0.48, 0.93, 1};
//    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
//    
//    //// Shadow Declarations
//    UIColor* shadow = color2;
//    CGSize shadowOffset = CGSizeMake(0.1, -0.1);
//    CGFloat shadowBlurRadius = 8;
//    
//    //// Oval Drawing
//    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(3, 3, 81, 81)];
//    [[UIColor clearColor] setFill];
//    [ovalPath fill];
//    CGContextSaveGState(context);
//    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
//    [color setStroke];
//    ovalPath.lineWidth = 3;
//    [ovalPath stroke];
//    CGContextRestoreGState(context);
//    
//    
//    //// Oval 2 Drawing
//    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(3.5, 3.5, 80, 80)];
//    CGContextSaveGState(context);
//    [oval2Path addClip];
//    CGContextDrawLinearGradient(context, gradient, CGPointMake(43.5, 3.5), CGPointMake(43.5, 83.5), 0);
//    CGContextRestoreGState(context);
//    CGContextSaveGState(context);
//    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
//    [color2 setStroke];
//    oval2Path.lineWidth = 0.5;
//    [oval2Path stroke];
//    CGContextRestoreGState(context);
//    
//    
//    //// Cleanup
//    CGGradientRelease(gradient);
//    CGColorSpaceRelease(colorSpace);
//}


- (void)setHighlighted:(BOOL)highlighted
{
    [self setNeedsDisplay];
    [super setHighlighted:highlighted];
}

- (void)dealloc
{
    [_haloLayer release];
    [super dealloc];
}

@end
