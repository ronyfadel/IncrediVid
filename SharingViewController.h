//
//  SharingViewController.h
//  incrediVid
//
//  Created by Rony Fadel on 5/2/13.
//
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface SharingViewController : UIViewController

- (IBAction)share:(id)sender;
- (IBAction)tapped:(UITapGestureRecognizer *)recognizer;
- (void)dismiss;

@property IBOutlet UILabel *shareLabel;
@property IBOutlet UIView *shareLabelBackgroundView;
@property IBOutlet UIView *holderView;

@property IBOutlet UIButton *facebookShareButton;
@property IBOutlet UIButton *twitterShareButton;
@property IBOutlet UIButton *youtubeShareButton;
@property IBOutlet UIButton *emailShareButton;

@end
