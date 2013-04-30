#import <UIKit/UIKit.h>
#import "MyRenderer.h"
#import "AVCaptureSessionManager.h"

@interface MyViewController : UIViewController <RFVideoProcessorDelegate> {
    CADisplayLink* displayLink;
    MyRenderer* renderer;
    AVCaptureSessionManager* captureSessionManager;
    
    IBOutlet UIButton *chooseFilterButton, *videoButton;
    IBOutlet UILabel *logoLabel;
}

- (IBAction)wandPushed:(id)obj;
@end
