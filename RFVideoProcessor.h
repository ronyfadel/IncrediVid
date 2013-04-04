#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>

@protocol RFVideoProcessorDelegate;

@interface RFVideoProcessor : NSObject
{
    id <RFVideoProcessorDelegate> delegate;
}

@property (readwrite, assign) id <RFVideoProcessorDelegate> delegate;
@property (retain) AVCaptureConnection* videoConnection;
@property (retain) AVCaptureConnection* audioConnection;

- (void) startRecording;
- (void) stopRecording;
- (void)processFrameWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                andFormatDescription:(CMFormatDescriptionRef)formatDescription
                andConnection:(AVCaptureConnection*)connection;
- (void)stopAndTearDownRecordingSession;

@end

@protocol RFVideoProcessorDelegate <NSObject>
@required
- (void)recordingWillStart;
- (void)recordingDidStart;
- (void)recordingWillStop;
- (void)recordingDidStop;
@end
