#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RFRenderer.h"
#import "RFVideoProcessor.h"

@interface AVCaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
@private
    AVCaptureSession* captureSession;
//    RFVideoProcessor* videoProcessor;
    RFRenderer* renderer;
}

-(id)initWithRenderer:(RFRenderer*)aRenderer;
-(void)startRecording;
-(void)stopRecording;
@end
