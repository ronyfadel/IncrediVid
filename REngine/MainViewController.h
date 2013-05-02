#import <UIKit/UIKit.h>
#import "MyRenderer.h"
#import "AVCaptureSessionManager.h"

@class RFRecordButton;

@interface MainViewController : UIViewController {
    CADisplayLink* displayLink;
    MyRenderer* renderer;
    AVCaptureSessionManager* captureSessionManager;
    
    IBOutlet UIButton *chooseFilterButton, *openGalleryButton;
    IBOutlet RFRecordButton *recordButton;
    IBOutlet UILabel *logoLabel, *elapsedTimeLabel;
}

@end
