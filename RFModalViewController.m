//
//  RFModalViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/19/13.
//
//

#import "RFModalViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RFModalViewController ()

@end

@implementation RFModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *darkerFillColor = [UIColor colorWithRed: 0.153 green: 0.153 blue: 0.153 alpha: 1];
    UIColor *strokeColor = [UIColor colorWithRed:0.22f green:0.66f blue:0.92f alpha:1.f];
    
    // share label
    UIFont* latoBlack = [UIFont fontWithName:@"Lato-Black" size:34.0];
    self.titleLabel.font = latoBlack;
    
    // main view
    self.holderView.backgroundColor = darkerFillColor;
    self.holderView.layer.cornerRadius = 16;
    self.holderView.layer.borderColor = strokeColor.CGColor;
    self.holderView.layer.borderWidth = 1.5f;
    
    // masking Title Label Background View for rounded corners
    UIBezierPath *maskPathtop = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds
                                                      byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                            cornerRadii:CGSizeMake(16.0, 16.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.titleLabelBackgroundView.bounds;
    maskLayer.path = maskPathtop.CGPath;
    self.titleLabelBackgroundView.layer.mask = maskLayer;
    
    self.dimmedOverlayButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
}

- (void)presentRFModalViewController:(UIView*)view
{
    self.view.alpha = 0;

    [view addSubview:self.view];
    
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (IBAction)dismiss
{
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                     }];
}

- (void)dealloc
{
    [super dealloc];
}
@end
