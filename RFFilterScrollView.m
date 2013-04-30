//
//  RFFilterScrollView.m
//  incrediVid
//
//  Created by Rony Fadel on 4/29/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "RFFilterScrollView.h"

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
            UIView *filterThumbnailView = [[[UIView alloc] initWithFrame:CGRectMake(edgeLength * i + padding,
                                                                                 padding,
                                                                                 edgeLength - padding,
                                                                                 edgeLength - padding)] autorelease];

            NSDictionary* filterInfo = [filtersInfo objectAtIndex:i];
            NSString* imageFileName = [filterInfo objectForKey:@"imageFileName"];
            
            UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            thumbnailButton.tag = i;
            thumbnailButton.frame = filterThumbnailView.bounds;
            [thumbnailButton setImage:[UIImage imageNamed:imageFileName] forState:UIControlStateNormal];
            [thumbnailButton addTarget:self action:@selector(newFilterChosen:) forControlEvents:UIControlEventTouchUpInside];
            [filterThumbnailView addSubview:thumbnailButton];
            
            UILabel *filterName = [[UILabel alloc] initWithFrame:CGRectMake(-3, 0.6f * edgeLength, edgeLength, 0.2f * edgeLength)];
            filterName.text = [filterInfo objectForKey:@"imageTitle"];
            filterName.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
            filterName.textColor = [UIColor whiteColor];
            filterName.backgroundColor = [UIColor clearColor];
            filterName.textAlignment = NSTextAlignmentCenter;
            [filterThumbnailView addSubview:filterName];

            filterThumbnailView.layer.cornerRadius = 4.f;
            filterThumbnailView.layer.masksToBounds = YES;

            [self addSubview:filterThumbnailView];
        }
        
        CGFloat contentWidth =  padding + filterCount * edgeLength;
        self.contentSize = CGSizeMake(contentWidth, 1);
    }
    return self;
}

- (void)newFilterChosen:(id)target
{
    UIButton* pushedButton = (UIButton*)target;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"New Filter Chosen" object:[NSNumber numberWithInteger:pushedButton.tag]];
}

@end
