#import <UIKit/UIKit.h>
#import "MyRenderer.h"
#import "AVCaptureSessionManager.h"

@class RFRecordButton;
@class SharingViewController;

@interface MainViewController : UIViewController {
    MyRenderer* renderer;
}

@property(retain) AVCaptureSessionManager* captureSessionManager;
@end
