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
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TKAlertCenter.h"
#import "SharingViewController.h"
#import "RFPlayButton.h"
#import "RFVideoCollection.h"

#define FACEBOOK_SHARING_2_STEP_HACK YES

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

@property(retain) MPMoviePlayerViewController *moviePlayerController;
@property(retain) ACAccount *facebookAccount;

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
    NSLog(@"PLAY");
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
            [self authenticateWithFacebook];
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

- (void)authenticateWithFacebook
{
    //Centralized iOS user Twitter, Facebook and Sina Weibo accounts are accessed by apps via the ACAccountStore
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountTypeFacebook = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

    NSArray *permissions;
    NSString *facebookAudience;
#if (FACEBOOK_SHARING_2_STEP_HACK)
    if (self.facebookAccount == nil) {
        permissions = @[@"email"];
        facebookAudience = ACFacebookAudienceOnlyMe;
    } else {
        permissions = @[@"publish_stream"];
        facebookAudience = ACFacebookAudienceFriends;
    }
#else
    permissions = @[@"email", @"publish_stream"];
    facebookAudience = ACFacebookAudienceFriends;
#endif
    
    NSDictionary *options = @{ACFacebookAppIdKey: @"578010692220043",
                              ACFacebookPermissionsKey: permissions,
                              ACFacebookAudienceKey: facebookAudience};
    [accountStore requestAccessToAccountsWithType:accountTypeFacebook
                                          options:options
                                       completion:^(BOOL granted, NSError *error)
    {
        if(granted) {
#if (FACEBOOK_SHARING_2_STEP_HACK)
            if (self.facebookAccount == nil) {
                NSArray *accounts = [accountStore accountsWithAccountType:accountTypeFacebook];
                self.facebookAccount = [accounts lastObject];
                [self authenticateWithFacebook];
                return;
            }
#else
            NSArray *accounts = [accountStore accountsWithAccountType:accountTypeFacebook];
            self.facebookAccount = [accounts lastObject];
#endif
            [self shareOnFacebook];
        } else {
            if ([error code] == ACErrorAccountNotFound) {
                NSLog(@"No Facebook Account Found");
            }
            else {
                NSLog(@"Facebook SSO Authentication Failed: %@", error);
            }            
        }
    }];
}

- (void)shareOnFacebook
{
    NSURL *videoURL = [self.videoInfo objectForKey:@"videoURL"];
    NSData *videoData = [NSData dataWithContentsOfFile:videoURL.path];
    
    NSDictionary *parameters = @{@"title": @"My 4th iOS 6 Facebook posting"};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/videos"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodPOST
                              URL:feedURL
                              parameters:parameters];
    
    [feedRequest addMultipartData:videoData
                           withName:@"source"
                               type:@"video/quicktime"
                           filename:[videoURL absoluteString]];

    feedRequest.account = self.facebookAccount;
        
    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (error) {
              NSLog(@"error: %@", error);
         } else {
             NSLog(@"response: %@", urlResponse);
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
