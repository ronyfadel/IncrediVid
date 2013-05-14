//
//  SharingViewController.m
//  incrediVid
//
//  Created by Rony Fadel on 5/2/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TKAlertCenter.h"
#import "SharingViewController.h"
#import "RFPlayButton.h"

enum SHARING_SERVICE {
    FACEBOOK_SHARING_SERVICE = 0,
    EMAIl_SHARING_SERVICE,
    CAMERA_ROLL_SHARING_SERVICE
};

@interface SharingViewController ()

@property IBOutlet UIImageView *thumbnailView;
@property IBOutlet UILabel *shareLabel;
@property IBOutlet UIView *shareLabelBackgroundView;
@property IBOutlet UIView *holderView;

@property IBOutlet RFPlayButton *playButton;
@property IBOutlet UIButton *facebookShareButton;
@property IBOutlet UIButton *emailShareButton;
@property IBOutlet UIButton *cameraRollShareButton;
@property IBOutlet UIButton *openInShareButton;

@end

@implementation SharingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil videoInfo:(NSDictionary*)videoInfo
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.videoInfo = videoInfo;
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
    
    // thumbnail image view
    self.thumbnailView.image = [self.videoInfo objectForKey:@"thumbnail"];
    self.thumbnailView.layer.cornerRadius = 6;
    self.thumbnailView.layer.masksToBounds = YES;
    self.playButton.layer.cornerRadius = 6;
    self.playButton.layer.masksToBounds = YES;
    
    // holder view
    self.holderView.backgroundColor = darkerFillColor;
    self.holderView.layer.cornerRadius = 16;
    self.holderView.layer.borderColor = strokeColor.CGColor;
    self.holderView.layer.borderWidth = 1.5f;
    
    // masking holder view
    UIBezierPath *maskPathtop = [UIBezierPath bezierPathWithRoundedRect:self.holderView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(16.0, 16.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.shareLabelBackgroundView.bounds;
    maskLayer.path = maskPathtop.CGPath;
    self.shareLabelBackgroundView.layer.mask = maskLayer;
    
    // masking email button
    UIBezierPath *maskPathbottomLeft = [UIBezierPath bezierPathWithRoundedRect:self.emailShareButton.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft
                                                         cornerRadii:CGSizeMake(16.0, 16.0)];
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.emailShareButton.bounds;
    maskLayer.path = maskPathbottomLeft.CGPath;
    self.emailShareButton.layer.mask = maskLayer;

    // masking Open In button
    UIBezierPath *maskPathbottomRight = [UIBezierPath bezierPathWithRoundedRect:self.openInShareButton.bounds
                                                             byRoundingCorners:UIRectCornerBottomRight
                                                                   cornerRadii:CGSizeMake(16.0, 16.0)];
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.openInShareButton.bounds;
    maskLayer.path = maskPathbottomRight.CGPath;
    self.openInShareButton.layer.mask = maskLayer;

    

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

- (IBAction)play:(id)sender
{
    NSURL *videoURL = [self.videoInfo objectForKey:@"movieURL"];
    
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    UIGraphicsEndImageContext();
}

- (IBAction)share:(id)sender
{
    enum SHARING_SERVICE sharingServiceId = ((UIButton*)sender).tag;
    
    switch (sharingServiceId) {
        case FACEBOOK_SHARING_SERVICE:
            break;
        case EMAIl_SHARING_SERVICE:
            [self emailMovie];
            break;
        case CAMERA_ROLL_SHARING_SERVICE:
            [self saveMovieToCameraRoll];
            break;
        default:
            break;
    }
}

- (void)saveMovieToCameraRoll
{
    NSURL *videoURL = [self.videoInfo objectForKey:@"movieURL"];

	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeVideoAtPathToSavedPhotosAlbum:videoURL
								completionBlock:^(NSURL *assetURL, NSError *error) {
                                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Saved to Camera Roll!"];
								}];
	[library release];
}

- (void)emailMovie
{
    NSURL *videoURL = [self.videoInfo objectForKey:@"movieURL"];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Attach an image to the email
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [picker addAttachmentData:videoData mimeType:@"video/quicktime" fileName:@"coolVid.mov"];
    
    // Fill out the email body text
    NSString *emailBody = @"Shot using incrediVid\n";
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentModalViewController:picker animated:YES];
    
    [picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
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

- (void)addToView:(UIView*)view
{
    self.view.layer.opacity = 0;
    [view addSubview:self.view];
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.layer.opacity = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)dealloc
{
    [self.videoInfo release];
    [super dealloc];
}

@end
