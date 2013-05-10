#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RFRenderer.h"
#import "RFVideoProcessor.h"

@interface AVCaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    
}
@property (retain) RFVideoProcessor* videoProcessor;
- (id)initWithRenderer:(RFRenderer*)theRenderer;
- (void)startRecording;
- (void)stopRecording;
- (void)stopAndTearDownCaptureSession;
@end
