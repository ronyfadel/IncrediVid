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
#import "RFVideoCollection.h"
#import "RFFacebookSharer.h"

enum SHARING_SERVICE {
    FACEBOOK_SHARING_SERVICE = 0,
    EMAIl_SHARING_SERVICE,
    CAMERA_ROLL_SHARING_SERVICE,
    OPEN_IN_SHARING_SERVICE
};

@interface SharingViewController ()

@property IBOutlet UIImageView *thumbnailView;
@property IBOutlet UILabel *titleLabel;
@property IBOutlet UIView *titleLabelBackgroundView;

@property IBOutlet RFPlayButton *playButton;
@property IBOutlet UIButton *facebookShareButton;
@property IBOutlet UIButton *deleteVideoButton;
@property IBOutlet UIButton *emailVideoButton;

@property (retain) MPMoviePlayerViewController *moviePlayerController;
@property (retain) RFFacebookSharer *facebookSharer;

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
    
    self.thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.videoInfo objectForKey:@"largeThumbnail"]]];
    // thumbnail image view
    self.thumbnailView.layer.cornerRadius = 6;
    self.thumbnailView.layer.masksToBounds = YES;
    self.playButton.layer.cornerRadius = 6;
    self.playButton.layer.masksToBounds = YES;
    
    // masking delete video button
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.deleteVideoButton.bounds
                                                   byRoundingCorners:UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(16.0, 16.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.deleteVideoButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.deleteVideoButton.layer.mask = maskLayer;
    
    // masking email button
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.emailVideoButton.bounds
                                     byRoundingCorners:UIRectCornerBottomLeft
                                           cornerRadii:CGSizeMake(16.0, 16.0)];
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.emailVideoButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.emailVideoButton.layer.mask = maskLayer;
}

- (IBAction)play:(id)sender
{
    NSURL *videoURL = [self.videoInfo objectForKey:@"videoURL"];
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    self.moviePlayerController = [[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL] autorelease];
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayerController];
    UIGraphicsEndImageContext();
}

- (IBAction)share:(id)sender
{
    enum SHARING_SERVICE sharingServiceId = ((UIButton*)sender).tag;
    
    switch (sharingServiceId) {
        case FACEBOOK_SHARING_SERVICE:
            [self shareOnFacebook];
            break;
        case EMAIl_SHARING_SERVICE:
            [self emailMovie];
            break;
        case CAMERA_ROLL_SHARING_SERVICE:
            [self saveMovieToCameraRoll];
            break;
        case OPEN_IN_SHARING_SERVICE:
            [self openIn];
            break;
        default:
            break;
    }
}

- (void)shareOnFacebook
{
    self.facebookSharer = [[RFFacebookSharer alloc] init];
    [self.facebookSharer authenticateWithCompletion:^(BOOL granted, NSError *error) {
        if (! granted) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Failed Authenticating Facebbok"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
            [alertView show];
        } else {
            [self.facebookSharer share:self.videoInfo completion:^(BOOL shared, NSError *error) {
                if (!shared) {
                    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Sharing Failed"
                                                                         message:[error localizedDescription]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
                } else {
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Shared on Facebook!"];
                }
            }];
        }
    }];
}

- (void)saveMovieToCameraRoll
{
    NSURL *videoURL = [self.videoInfo objectForKey:@"videoURL"];

	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeVideoAtPathToSavedPhotosAlbum:videoURL
								completionBlock:^(NSURL *assetURL, NSError *error) {
                                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Saved to Camera Roll!"];
								}];
	[library release];
}

- (void)emailMovie
{
    NSURL *videoURL = [self.videoInfo objectForKey:@"videoURL"];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Attach an image to the email
    NSString *videoTitle = [[videoURL.absoluteString lastPathComponent] stringByDeletingPathExtension];
    

    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    [picker addAttachmentData:videoData mimeType:@"video/quicktime" fileName:videoTitle];
    
    // Fill out the email body text
    NSString *emailBody = @"Shot using incrediVid\n";
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentModalViewController:picker animated:YES];
    
    [picker release];
}

- (void)openIn
{
    NSLog(@"%@", self.videoInfo);
    
    NSURL *videoURL = [self.videoInfo objectForKey:@"videoURL"];
    NSArray* dataToShare = @[[NSData dataWithContentsOfURL:videoURL]];
    UIActivityViewController* activityViewController = [[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil] autorelease];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

-(UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
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

- (IBAction)deleteVideo:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete this incrediVid?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete",nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"tapped cancel");
    }
    else if (buttonIndex == 1) {
        NSLog(@"videos count: %d", [[RFVideoCollection sharedCollection].videos count]);
        [[RFVideoCollection sharedCollection] deleteVideoWithInfo:self.videoInfo];
        NSLog(@"videos count after delete: %d", [[RFVideoCollection sharedCollection].videos count]);
        [self dismiss];
    }
}

- (void)dealloc
{
    [self.videoInfo release];
    [self.delegate release];
    [self.moviePlayerController release];
    [super dealloc];
}

@end
