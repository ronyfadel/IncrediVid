#import "UIImage+TKCategory.h"
#import "UIView+TKCategory.h"

@implementation UIImage (TKCategory)

+ (UIImage*) imageNamedTK:(NSString*)str{
    return nil;
}

- (UIImage *) imageCroppedToRect:(CGRect)rect{
	CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
	UIImage *cropped = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return cropped; // autoreleased
}

- (UIImage *) squareImage{
	CGFloat shortestSide = self.size.width <= self.size.height ? self.size.width : self.size.height;	
	return [self imageCroppedToRect:CGRectMake(0.0, 0.0, shortestSide, shortestSide)];
}




- (void) drawInRect:(CGRect)rect withImageMask:(UIImage*)mask{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, mask.CGImage);
	//CGContextSetRGBFillColor(context, color[0], color[1], color[2], color[3]);
	//CGContextFillRect(context, rect);
	CGContextDrawImage(context,rect,self.CGImage);
	
	
	CGContextRestoreGState(context);
}

- (void) drawMaskedColorInRect:(CGRect)rect withColor:(UIColor*)color{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	
	CGContextSetFillColorWithColor(context, color.CGColor);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	rect.origin.y = rect.origin.y * -1;
	
	
	CGContextClipToMask(context, rect, self.CGImage);
	CGContextFillRect(context, rect);
	
	CGContextRestoreGState(context);
	
}
- (void) drawMaskedGradientInRect:(CGRect)rect withColors:(NSArray*)colors{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, self.CGImage);
	
	[UIView drawGradientInRect:rect withColors:colors];
	
	CGContextRestoreGState(context);
}

@end
