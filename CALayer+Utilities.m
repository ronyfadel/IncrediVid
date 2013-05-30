//
//  CALayer+Utilities.m
//  incrediVid
//
//  Created by Rony Fadel on 5/28/13.
//
//

#import "CALayer+Utilities.h"

@implementation CALayer (Utilities)

+ (CALayer*)haloLayerWithBounds:(CGRect)bounds
                  animationDuration:(NSTimeInterval)animationDuration
                 delayBetweenCycles:(NSTimeInterval)delayBetweenCycles
                              radii:(NSArray*)radii
                          fromValue:(NSNumber*)fromValue
                            toValue:(NSNumber*)toValue
{
    CALayer *_haloLayer = [CALayer layer];
    _haloLayer.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
//    _haloLayer.frame = CGRectMake(0, 0, 80, 80);
    _haloLayer.position = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    
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
        [values addObject:(id)[[CALayer haloImageWithRadius:[number floatValue]] CGImage]];
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

+ (UIImage*)haloImageWithRadius:(CGFloat)radius
{
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


@end
