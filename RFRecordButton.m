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

- (void)drawRect:(CGRect)rect
{
    float buttonOpacity = (self.state == UIControlStateHighlighted) ? 0.8 : 1.0;
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.08 green: 0.07 blue: 0.09 alpha: 1];
    
    UIColor* strokeColor = [UIColor colorWithRed: 0.528 green: 0.053 blue: 0.132 alpha: 1];
    UIColor* color = [UIColor colorWithRed: 0.114 green: 0.705 blue: 1 alpha: buttonOpacity];
    UIColor* gradientColor = [UIColor colorWithRed: 0.902 green: 0.31 blue: 0.306 alpha: buttonOpacity];
    UIColor* color2 = [UIColor colorWithRed: 0.321 green: 0.261 blue: 0.261 alpha: 1];
    UIColor* gradientColor2 = [UIColor colorWithRed: 0.879 green: 0.089 blue: 0.157 alpha: buttonOpacity];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)gradientColor.CGColor,
                               (id)[UIColor colorWithRed: 0.89 green: 0.199 blue: 0.232 alpha: buttonOpacity].CGColor,
                               (id)gradientColor2.CGColor,
                               (id)[UIColor colorWithRed: 0.704 green: 0.071 blue: 0.145 alpha: buttonOpacity].CGColor,
                               (id)strokeColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 0.39, 0.48, 0.93, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    UIColor* shadow = color2;
    CGSize shadowOffset = CGSizeMake(0.1, -0.1);
    CGFloat shadowBlurRadius = 8;
    
    //// Oval 3 Drawing
    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1, 0, 104, 104)];
    [fillColor setFill];
    [oval3Path fill];
    [[UIColor clearColor] setStroke];
    oval3Path.lineWidth = 0.5;
    [oval3Path stroke];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(13, 12, 80, 80)];
    [[UIColor clearColor] setFill];
    [ovalPath fill];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [color setStroke];
    ovalPath.lineWidth = 2;
    [ovalPath stroke];
    CGContextRestoreGState(context);
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(28, 27, 50, 50)];
    CGContextSaveGState(context);
    [oval2Path addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(53, 27), CGPointMake(53, 77), 0);
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

+ (CALayer*)makeHaloLayerWithBounds:(CGRect)bounds
              animationDuration:(NSTimeInterval)animationDuration
             delayBetweenCycles:(NSTimeInterval)delayBetweenCycles
                          radii:(NSArray*)radii
                          fromValue:(NSNumber*)fromValue
                            toValue:(NSNumber*)toValue
{
    CALayer *_haloLayer = [CALayer layer];
    _haloLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    _haloLayer.frame = CGRectMake(0, 0, 80, 80);
    _haloLayer.position = CGPointMake(bounds.size.width / 2 + 1.5, bounds.size.height / 2);
    
    _haloLayer.contentsScale = [UIScreen mainScreen].scale;
    
    CAMediaTimingFunction *linear = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    CAMediaTimingFunction *easeIn = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = animationDuration + delayBetweenCycles;
    animationGroup.repeatCount = INFINITY;
    animationGroup.timingFunction = linear;
    animationGroup.removedOnCompletion = NO;
    
    CAKeyframeAnimation *imageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    NSMutableArray *values = [[[NSMutableArray alloc] init] autorelease];
    for (NSNumber *number in radii) {
        [values addObject:(id)[[RFRecordButton haloImageWithRadius:[number floatValue]] CGImage]];
    }
    imageAnimation.values = values;
    imageAnimation.duration = animationDuration;
    imageAnimation.calculationMode = kCAAnimationDiscrete;
    
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    pulseAnimation.fromValue = fromValue;
    pulseAnimation.toValue = toValue;
    pulseAnimation.duration = animationDuration;
    pulseAnimation.timingFunction = easeOut;
    
    CABasicAnimation *fadeOutAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnim.fromValue = @1.0;
    fadeOutAnim.toValue = @0.0;
    fadeOutAnim.duration = animationDuration;
    fadeOutAnim.timingFunction = easeIn;
    fadeOutAnim.removedOnCompletion = NO;
    fadeOutAnim.fillMode = kCAFillModeForwards;
    
    animationGroup.animations = @[imageAnimation, pulseAnimation, fadeOutAnim];
    
    [_haloLayer addAnimation:animationGroup forKey:@"pulse"];
    
    return _haloLayer;
}

+ (UIImage*)haloImageWithRadius:(CGFloat)radius {
    CGColorRef haloColor = [UIColor colorWithRed: 0.114 green: 0.705 blue: 1 alpha: 0.8].CGColor;
    CGFloat glowRadius = radius/6;
    CGFloat ringThickness = radius/24;
    CGPoint center = CGPointMake(glowRadius+radius, glowRadius+radius);
    CGRect imageBounds = CGRectMake(0, 0, center.x*2, center.y*2);
    CGRect ringFrame = CGRectMake(glowRadius, glowRadius, radius*2, radius*2);
    
    UIGraphicsBeginImageContextWithOptions(imageBounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor* ringColor = [UIColor whiteColor];
    [ringColor setFill];
    
    UIBezierPath *ringPath = [UIBezierPath bezierPathWithOvalInRect:ringFrame];
    [ringPath appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectInset(ringFrame, ringThickness, ringThickness)]];
    ringPath.usesEvenOddFillRule = YES;
    
    for(float i=1.3; i>0.3; i-=0.18) {
        CGFloat blurRadius = MIN(1, i)*glowRadius;
        CGContextSetShadowWithColor(context, CGSizeZero, blurRadius, haloColor);
        [ringPath fill];
    }
    
    UIImage *ringImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ringImage;
}

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
