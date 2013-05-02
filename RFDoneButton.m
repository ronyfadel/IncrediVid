//
//  RFDoneButton.m
//  incrediVid
//
//  Created by Rony Fadel on 5/1/13.
//
//

#import "RFDoneButton.h"

@implementation RFDoneButton


- (void)drawRect:(CGRect)rect
{
    float buttonOpacity = (self.state == UIControlStateHighlighted) ? 0.8 : 1.0;
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.294 green: 0.776 blue: 0.937 alpha: buttonOpacity];
    UIColor* strokeColor = [UIColor colorWithRed: 0.106 green: 0.09 blue: 0.114 alpha: buttonOpacity];
    
    //// Abstracted Attributes
    NSString* textContent = @"Done";
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 57, 35) cornerRadius: 6];
    [fillColor setFill];
    [rectanglePath fill];
    
    
    //// Text Drawing
    CGRect textRect = CGRectMake(0, 0, 57, 35);
    [strokeColor setFill];
    [textContent drawInRect: CGRectInset(textRect, 0, 7) withFont: [UIFont fontWithName: @"Lato-Black" size: 17] lineBreakMode: UILineBreakModeWordWrap alignment: UITextAlignmentCenter];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [self setNeedsDisplay];
    [super setHighlighted:highlighted];
}

@end


