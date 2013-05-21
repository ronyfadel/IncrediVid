//
//  SharingViewController.h
//  incrediVid
//
//  Created by Rony Fadel on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "RFModalViewController.h"

@interface SharingViewController : RFModalViewController <MFMailComposeViewControllerDelegate,
                                                            UIDocumentInteractionControllerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil videoInfo:(NSDictionary*)videoInfo;
- (IBAction)play:(id)sender;
- (IBAction)share:(id)sender;

@property (retain) NSDictionary* videoInfo;

@end