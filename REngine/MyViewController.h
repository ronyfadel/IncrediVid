#import <UIKit/UIKit.h>
#import "RFRenderer.h"
#import "AVCaptureSessionManager.h"

@interface MyViewController : UIViewController {
    CADisplayLink* displayLink;
    RFRenderer* renderer;
    AVCaptureSessionManager* captureSessionManager;
    IBOutlet UIButton *nextButton, *prevButton;
}

- (IBAction)changeFilter:(id)obj;
@end
