//
//  RFFilterScrollView.m
//  incrediVid
//
//  Created by Rony Fadel on 4/29/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "RFFilterScrollView.h"
#import "RFFilterThumbnailView.h"

@implementation RFFilterScrollView

- (id)initWithFrame:(CGRect)frame filtersInfo:(NSArray*)filtersInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;

        int filterCount = [filtersInfo count];
        CGFloat edgeLength = self.frame.size.height;
        CGFloat padding = 7;
        
        for (int i = 0; i < filterCount; ++i) {
            NSDictionary* filterInfo = [filtersInfo objectAtIndex:i];
            
            RFFilterThumbnailView *thumbnailView = [[[RFFilterThumbnailView alloc] initWithFrame:CGRectMake(edgeLength * i + padding,
                                                                                                          padding,
                                                                                                          edgeLength - padding,
                                                                                                           edgeLength - padding)
                                                                                            info:@{@"imageFileName": [filterInfo objectForKey:@"imageFileName"],
                                                                                                   @"imageTitle": [filterInfo objectForKey:@"imageTitle"],
                                                                                                   @"tag": [NSNumber numberWithInt:i],
                                                                                                   @"hasButton": @YES,
                                                                                                   @"delegate": self}] autorelease];
            if (i == 0) {
                [thumbnailView highlight:YES];
            }
            [self addSubview:thumbnailView];
//            UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(edgeLength * i + padding,
//                                                                            padding,
//                                                                            edgeLength - padding,
//                                                                            edgeLength - padding)] autorelease];
//            containerView.backgroundColor = [UIColor clearColor];
//            containerView.layer.shadowOffset = CGSizeMake(0, 0);
//            containerView.layer.shadowOpacity = 1;
//            containerView.layer.shadowColor = glowingColor.CGColor;
//            containerView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:containerView.bounds cornerRadius:4] CGPath];
//            containerView.layer.shadowRadius = 0;
//            
//            UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            thumbnailButton.tag = i;
//            thumbnailButton.frame = containerView.bounds;
//            thumbnailButton.layer.cornerRadius = 4.f;
//            thumbnailButton.layer.masksToBounds = YES;
//            thumbnailButton.layer.borderColor = glowingColor.CGColor;
//            
//            if (i == 0) {
//                containerView.layer.shadowRadius = 6;
//                thumbnailButton.layer.borderWidth = 2;
//            }
//            
//            NSDictionary* filterInfo = [filtersInfo objectAtIndex:i];
//            NSString* imageFileName = [filterInfo objectForKey:@"imageFileName"];
//            [thumbnailButton setBackgroundImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
//            [thumbnailButton addTarget:self action:@selector(newFilterChosen:) forControlEvents:UIControlEventTouchUpInside];
//            
//            UILabel *filterName = [[UILabel alloc] initWithFrame:CGRectMake(-3,
//                                                                            0.6f * edgeLength,
//                                                                            edgeLength,
//                                                                            0.2f * edgeLength)];
//            filterName.text = [filterInfo objectForKey:@"imageTitle"];
//            filterName.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
//            filterName.textColor = [UIColor whiteColor];
//            filterName.backgroundColor = [UIColor clearColor];
//            filterName.textAlignment = NSTextAlignmentCenter;
//            [thumbnailButton addSubview:filterName];
//
//            [containerView addSubview:thumbnailButton];
//            [self addSubview:containerView];
        }
        
        CGFloat contentWidth =  padding + filterCount * edgeLength;
        self.contentSize = CGSizeMake(contentWidth, 1);
    }
    return self;
}

- (void)newFilterChosen:(id)target
{
    UIButton *pushedButton = (UIButton*)target;
    RFFilterThumbnailView *thumbnailView = (RFFilterThumbnailView*)pushedButton.superview;
    for (RFFilterThumbnailView* subview in self.subviews) {
        if ([[subview class] isSubclassOfClass:[RFFilterThumbnailView class]]) {
            [subview highlight:NO];
        }
    }
    [thumbnailView highlight:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"New Filter Chosen" object:[NSNumber numberWithInteger:pushedButton.tag]];
}

@end
