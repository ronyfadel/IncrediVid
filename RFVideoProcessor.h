#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>

@interface RFVideoProcessor : NSObject
{
}

@property (retain) AVCaptureConnection* videoConnection;
@property (retain) AVCaptureConnection* audioConnection;

- (void) startRecording;
- (void) stopRecording;
- (void)processFrameWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                andFormatDescription:(CMFormatDescriptionRef)formatDescription
                andConnection:(AVCaptureConnection*)connection;
- (void)stopAndTearDownRecordingSession;

@property (readonly) BOOL recording;
@property (readonly) BOOL recordingWillBeStarted;
@end