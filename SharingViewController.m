//
//  SharingViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/2/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "SharingViewController.h"
//#import "ShareKit/Sharers/Services/Facebook/SHKFacebook.h"
//#import "ShareKit/Sharers/Services/Twitter/SHKTwitter.h"

@implementation SharingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil video:(NSDictionary*)video
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.video = video;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *fillColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.8];
    UIColor *darkerFillColor = [UIColor colorWithRed: 0.153 green: 0.153 blue: 0.153 alpha: 1];
    UIColor *strokeColor = [UIColor colorWithRed:0.22f green:0.66f blue:0.92f alpha:1.f];
    
    self.view.backgroundColor = fillColor;
    
    // share label
    UIFont* latoBlack = [UIFont fontWithName:@"Lato-Black" size:34.0];
    self.shareLabel.font = latoBlack;
    
    // holder view
    self.holderView.backgroundColor = darkerFillColor;
    self.holderView.layer.cornerRadius = 16;
    self.holderView.layer.borderColor = strokeColor.CGColor;
    self.holderView.layer.borderWidth = 1.5f;
    
    // customizing share buttons
    UIFont* shareButtonFont = [UIFont fontWithName:@"Lato-Black" size:24.0];
    self.facebookShareButton.titleLabel.font = shareButtonFont;
    self.facebookShareButton.layer.cornerRadius = 10;
    
    self.twitterShareButton.titleLabel.font = shareButtonFont;
    self.twitterShareButton.layer.cornerRadius = 10;
    
    self.youtubeShareButton.titleLabel.font = shareButtonFont;
    self.youtubeShareButton.layer.cornerRadius = 10;
    
    self.emailShareButton.titleLabel.font = shareButtonFont;
    self.emailShareButton.layer.cornerRadius = 10;
}

- (IBAction)tapped:(UITapGestureRecognizer *)recognizer
{
    UIView *targetView = self.holderView;
    CGPoint point = [recognizer locationInView:targetView];
    CGFloat w = targetView.frame.size.width, h = targetView.frame.size.height,
            x = point.x, y = point.y;
    if (x < 0 || x > w || y < 0 || y > h) {
        [self dismiss];
    }
}

- (IBAction)share:(id)sender
{
//    Class sharer;
//    NSString *someText = @"This is a blurb of text I highlighted from a document.";
//    SHKItem *item = [SHKItem text:someText];
    
//    UIButton *pressedButton = (UIButton*)sender;
//    NSString *serviceName = pressedButton.titleLabel.text;
//    if ([serviceName isEqualToString:@"Facebook"]) {
//        sharer = [SHKFacebook class];
//    } else if ([serviceName isEqualToString:@"Twitter"]) {
//        sharer = [SHKTwitter class];
//    }
//    [sharer shareItem:item];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.layer.opacity = 0;
                     }
                     completion:^(BOOL finished){
                         [self.view removeFromSuperview];
                         [self release];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.video release];
    [super dealloc];
}

@end
