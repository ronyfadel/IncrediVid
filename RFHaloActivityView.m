//
//  RFHaloActivityView.m
//  incrediVid
//
//  Created by Rony Fadel on 5/19/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "RFHaloActivityView.h"
#import "RFRecordButton.h"

@implementation RFHaloActivityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *holderView = [[[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2 - 40,
                                                                      frame.size.height / 2 - 80,
                                                                      80,
                                                                      80)] autorelease];
        holderView.layer.cornerRadius = 10;
        holderView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];

        CALayer* haloLayer = [RFRecordButton makeHaloLayerWithBounds:self.bounds
                                                   animationDuration:2
                                                  delayBetweenCycles:0.2
                                                               radii:@[@20, @50, @80]
                                                           fromValue:@0.1
                                                             toValue:@1];
        haloLayer.frame = holderView.bounds;
        [holderView.layer addSublayer:haloLayer];
        [self addSubview:holderView];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];

    }
    return self;
}

@end
