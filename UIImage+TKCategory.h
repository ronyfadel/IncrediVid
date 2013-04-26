#import <UIKit/UIKit.h>

@interface UIImage (TKCategory)



- (UIImage *) imageCroppedToRect:(CGRect)rect;
- (UIImage *) squareImage;


- (void) drawInRect:(CGRect)rect withImageMask:(UIImage*)mask;

- (void) drawMaskedColorInRect:(CGRect)rect withColor:(UIColor*)color;
- (void) drawMaskedGradientInRect:(CGRect)rect withColors:(NSArray*)colors;


+ (UIImage*) imageNamedTK:(NSString*)path;

@end

