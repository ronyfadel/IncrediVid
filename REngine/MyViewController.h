#import <UIKit/UIKit.h>
#import "RFRenderer.h"
#import "AVCaptureSessionManager.h"

@interface MyViewController : UIViewController {
    CADisplayLink* displayLink;
    RFRenderer* renderer;
    AVCaptureSessionManager* captureSessionManager;
    
    IBOutlet UIButton *nextButton, *prevButton, *videoButton;
}

- (IBAction)changeFilter:(id)obj;
- (IBAction)recordVideo:(id)obj;
@end
