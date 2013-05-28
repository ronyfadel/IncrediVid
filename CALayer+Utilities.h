//
//  CALayer+Utilities.h
//  incrediVid
//
//  Created by Rony Fadel on 5/28/13.
//
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Utilities)

+ (UIImage*)haloImageWithRadius:(CGFloat)radius;

+ (CALayer*)haloLayerWithBounds:(CGRect)bounds
                  animationDuration:(NSTimeInterval)animationDuration
                 delayBetweenCycles:(NSTimeInterval)delayBetweenCycles
                              radii:(NSArray*)radii
                          fromValue:(NSNumber*)fromValue
                            toValue:(NSNumber*)toValue;

@end
