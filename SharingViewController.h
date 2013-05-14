//
//  SharingViewController.h
//  incrediVid
//
//  Created by Rony Fadel on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class MainViewController;

@interface SharingViewController : UIViewController <MFMailComposeViewControllerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil videoInfo:(NSDictionary*)videoInfo;
- (IBAction)tapped:(UITapGestureRecognizer *)recognizer;
- (IBAction)play:(id)sender;
- (IBAction)share:(id)sender;
- (void)dismiss;
- (void)addToView:(UIView*)view;


@property (retain) NSDictionary* videoInfo;

@end
