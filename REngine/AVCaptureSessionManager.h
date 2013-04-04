#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RFVideoProcessor.h"
#import "RFVideoProcessor.h"

@interface AVCaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
@private
    AVCaptureSession* captureSession;
//    RFVideoProcessor* videoProcessor;
}

-(void)startRecording;
-(void)stopRecording;
@end
