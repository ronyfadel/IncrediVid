#import <UIKit/UIKit.h>
#import "MyRenderer.h"
#import "AVCaptureSessionManager.h"

@class RFRecordButton;
@class SharingViewController;

@interface MainViewController : UIViewController {
    CADisplayLink* displayLink;
    MyRenderer* renderer;
    AVCaptureSessionManager* captureSessionManager;
    
    IBOutlet UIButton *chooseFilterButton, *openGalleryButton;
    IBOutlet RFRecordButton *recordButton;
    IBOutlet UILabel *logoLabel, *elapsedTimeLabel;
}

@property(retain) AVCaptureSessionManager* captureSessionManager;

- (void)dismissSharingViewController:(SharingViewController*)sharingViewController;
@end
