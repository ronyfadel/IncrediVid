#import <UIKit/UIKit.h>
#import "MyRenderer.h"
#import "AVCaptureSessionManager.h"
#import "RFModalViewController.h"

@class RFRecordButton;
@class SharingViewController;

@interface MainViewController : UIViewController <RFModalViewControllerDelegate> {
    MyRenderer* renderer;
}

@property(retain) AVCaptureSessionManager* captureSessionManager;
@end
