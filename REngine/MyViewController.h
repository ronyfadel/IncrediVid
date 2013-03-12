#import <UIKit/UIKit.h>
#import "RFRenderer.h"
#import "AVCaptureSessionManager.h"

@interface MyViewController : UIViewController {
    CADisplayLink* displayLink;
    RFRenderer* renderer;
    AVCaptureSessionManager* captureSessionManager;
}
@end
