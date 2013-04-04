#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RFVideoProcessor.h"
#import "RFVideoProcessor.h"

@interface AVCaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
}

- (void)startRecording;
- (void)stopRecording;
@end
