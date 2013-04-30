//
//  RFAnnotationView.m
//  AnnotationViewTest
//
//  Created by Rony Fadel on 4/29/13.
//  Copyright (c) 2013 Rony Fadel. All rights reserved.
//

#import "RFAnnotationView.h"

#define RFAnnotationViewWidth   300.f
#define RFAnnotationViewHeight  90.f

//#define JPSThumbnailAnnotationViewExpandOffset   200.0f

#define JPSThumbnailAnnotationViewExpandOffset   5000.0f

#define JPSThumbnailAnnotationViewVerticalOffset 34.0f

@interface RFAnnotationView () {
    CAShapeLayer *bubbleLayer;
}
- (void)setLayerProperties;
@end

@implementation RFAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLayerProperties];
    }
    return self;
}

- (void)setLayerProperties
{
    bubbleLayer = [[CAShapeLayer layer] retain];
    
    bubbleLayer.shadowColor = [UIColor blackColor].CGColor;
    bubbleLayer.shadowOffset = CGSizeMake (0, [[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2 ? 1 : -1);
    bubbleLayer.shadowRadius = 1.0;
    bubbleLayer.shadowOpacity = 0.8;
    
    CGPathRef bubbleLayerPath = [self newBubbleWithRect:self.bounds];
    bubbleLayer.path = bubbleLayerPath;
    CGPathRelease(bubbleLayerPath);
    //    bubbleLayer.masksToBounds = NO;
    bubbleLayer.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.35].CGColor;
    NSLog(@"w %f,h %f - origin (%f, %f)", self.bounds.size.width, self.bounds.size.height, self.bounds.origin.x, self.bounds.origin.y);
    [self.layer insertSublayer:bubbleLayer atIndex:0];
    NSLog(@"w %f,h %f - origin (%f, %f)", bubbleLayer.bounds.size.width, bubbleLayer.bounds.size.height, bubbleLayer.bounds.origin.x, bubbleLayer.bounds.origin.y);
}

- (CGPathRef)newBubbleWithRect:(CGRect)rect {
    CGFloat nibPositionRatio = 0.87f;
    CGFloat stroke = 1.0;
	CGFloat radius = 4.0;
	CGMutablePathRef path = CGPathCreateMutable();
	CGFloat parentX = rect.origin.x + rect.size.width * nibPositionRatio;
	
	//Determine Size
	rect.size.width -= stroke + 14;
	rect.size.height -= stroke + 29;
	rect.origin.x += stroke / 2.0 + 7;
	rect.origin.y += stroke / 2.0 + 7;
    
	//Create Path For Callout Bubble
	CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
	CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI_2, 1);
	CGPathAddLineToPoint(path, NULL, parentX - 14, rect.origin.y + rect.size.height);
	CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 14);
	CGPathAddLineToPoint(path, NULL, parentX + 14, rect.origin.y + rect.size.height);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI_2, 0.0f, 1);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI_2, 1);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI_2, M_PI, 1);
	CGPathCloseSubpath(path);
    return path;
}

- (void)dealloc
{
    [bubbleLayer release];
    bubbleLayer = nil;
    [super dealloc];
}

@end