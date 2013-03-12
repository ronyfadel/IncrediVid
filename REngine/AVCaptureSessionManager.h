#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVCaptureSessionManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
@private
    AVCaptureSession* captureSession;
@public

}

@end
