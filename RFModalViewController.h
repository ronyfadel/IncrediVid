//
//  RFModalViewController.h
//  incrediVid
//
//  Created by Rony Fadel on 5/19/13.
//
//

#import <UIKit/UIKit.h>

@interface RFModalViewController : UIViewController

@property IBOutlet UILabel *titleLabel;
@property IBOutlet UIView *titleLabelBackgroundView, *holderView;
@property IBOutlet UIButton *dimmedOverlayButton;
- (void)presentRFModalViewController:(UIView*)view;
- (IBAction)dismiss;
@end
