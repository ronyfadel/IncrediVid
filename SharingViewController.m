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

//#import "<#header#>"

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

@property (retain) UITextField *facebookTitleTextField;

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
    
    if (![RFFacebookSharer supportsNativeFacebookSharing]) {
        [self.facebookShareButton removeFromSuperview];
    }

    // thumbnail image view
    self.playButton.layer.cornerRadius = 6;
    self.playButton.layer.masksToBounds = YES;
    NSURL *thumbnailURL = [self.videoInfo objectForKey:@"largeThumbnail"];
    UIImage *thumbnailImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailURL]];
    [self.playButton setBackgroundImage:thumbnailImage forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"playButton@2x.png"] forState:UIControlStateNormal];
    
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

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (void)shareOnFacebook
{
//    NSURL *videoURL = [self.videoInfo objectForKey:@"videoURL"];
//    if ([[UIApplication sharedApplication] canOpenURL:videoURL]) {
//        UIDocumentInteractionController* interactionController = [UIDocumentInteractionController interactionControllerWithURL:videoURL];
//        [interactionController presentOpenInMenuFromRect:self.facebookShareButton.bounds inView:self.view animated:YES];
//    } else {
//        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"You do not have any apps that can read incrediVids"];
//    }
    
    self.facebookSharer = [[RFFacebookSharer alloc] init];
    [self.facebookSharer authenticateWithCompletion:^(BOOL granted, NSError *error) {
        if (!granted) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Please Enable Facebook from Settings then Try Again"
                                                                 message:[error description]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alertView show];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView* sharingInputView = [[UIAlertView alloc] initWithTitle:@"IncrediVid Title"
                                                                           message:nil
                                                                          delegate:self
                                                                 cancelButtonTitle:@"Cancel"
                                                                 otherButtonTitles:@"Share", nil];
                
                sharingInputView.tag = 1;
                self.facebookTitleTextField = [[[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 30)] autorelease];
                self.facebookTitleTextField.placeholder = @"Incredivid Title";
                self.facebookTitleTextField.borderStyle = UITextBorderStyleRoundedRect;
                self.facebookTitleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
                self.facebookTitleTextField.returnKeyType = UIReturnKeyDone;
                [self.facebookTitleTextField becomeFirstResponder];
                [sharingInputView addSubview:self.facebookTitleTextField];
                self.facebookTitleTextField.delegate = self;
                [sharingInputView show];
                [sharingInputView release];
            });
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIAlertView* alertView = (UIAlertView*) [textField superview];
    [alertView dismissWithClickedButtonIndex:1 animated:YES];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0: // delete alert view
            if (buttonIndex == 0) {
                NSLog(@"tapped cancel");
            }
            else if (buttonIndex == 1) {
                [[RFVideoCollection sharedCollection] deleteVideoWithInfo:self.videoInfo];
                [self dismiss];
            }
            break;
        case 1: // facebook alert view
            if (buttonIndex == 1)
            {
                NSDictionary *sharingInfo = @{@"videoURL": [self.videoInfo valueForKey:@"videoURL"],
                                              @"videoTitle": self.facebookTitleTextField.text};
                NSString *videoTitle = [self.facebookTitleTextField.text copy];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Uploading will be done in the background"];
                [self dismiss];
                [self.facebookSharer share:sharingInfo completion:^(BOOL shared, NSError *error) {
                    if (!shared) {
                        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Sharing Failed"
                                                                             message:[error localizedDescription]
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                        [alertView show];
                    } else {
                        [[TKAlertCenter defaultCenter] postAlertWithMessage:[NSString stringWithFormat:@" \"%@\" Shared on Facebook!", videoTitle]];
                        [videoTitle release];
                    }
                }];
            }
        default:
            break;
    }
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

- (void)dealloc
{
    [self.videoInfo release];
    [self.delegate release];
    [self.moviePlayerController release];
    [super dealloc];
}

@end
