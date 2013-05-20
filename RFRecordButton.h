//
//  RFRecordButton.h
//  incrediVid
//
//  Created by Rony Fadel on 4/30/13.
//
//

#import <UIKit/UIKit.h>

@interface RFRecordButton : UIButton

@property (nonatomic, retain) CALayer *haloLayer;

+ (CALayer*)makeHaloLayerWithBounds:(CGRect)bounds
                  animationDuration:(NSTimeInterval)animationDuration
                 delayBetweenCycles:(NSTimeInterval)delayBetweenCycles
                              radii:(NSArray*)radii
                          fromValue:(NSNumber*)fromValue
                            toValue:(NSNumber*)toValue;
@end
