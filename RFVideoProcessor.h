//#import <Foundation/Foundation.h>
//#import <AVFoundation/AVFoundation.h>
//#import <CoreMedia/CMBufferQueue.h>
//
//@protocol RFVideoProcessorDelegate;
//
//@interface RFVideoProcessor : NSObject <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
//{
//    id <RFVideoProcessorDelegate> delegate;
//	
//	NSMutableArray *previousSecondTimestamps;
//	Float64 videoFrameRate;
//	CMVideoDimensions videoDimensions;
//	CMVideoCodecType videoType;
//    
//	AVCaptureSession *captureSession;
//	AVCaptureConnection *audioConnection;
//	AVCaptureConnection *videoConnection;
//	CMBufferQueueRef previewBufferQueue;
//	
//	NSURL *movieURL;
//	AVAssetWriter *assetWriter;
//	AVAssetWriterInput *assetWriterAudioIn;
//	AVAssetWriterInput *assetWriterVideoIn;
//	dispatch_queue_t movieWritingQueue;
//    
//	AVCaptureVideoOrientation referenceOrientation;
//	AVCaptureVideoOrientation videoOrientation;
//    
//	// Only accessed on movie writing queue
//    BOOL readyToRecordAudio;
//    BOOL readyToRecordVideo;
//	BOOL recordingWillBeStarted;
//	BOOL recordingWillBeStopped;
//    
//	BOOL recording;
//}
//
//@property (readwrite, assign) id <RFVideoProcessorDelegate> delegate;
//
//@property (readonly) Float64 videoFrameRate;
//@property (readonly) CMVideoDimensions videoDimensions;
//@property (readonly) CMVideoCodecType videoType;
//
//@property (readwrite) AVCaptureVideoOrientation referenceOrientation;
//
//- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation;
//
//- (void) showError:(NSError*)error;
//
//- (void) setupAndStartCaptureSession;
//- (void) stopAndTearDownCaptureSession;
//
//- (void) startRecording;
//- (void) stopRecording;
//
//- (void) pauseCaptureSession; // Pausing while a recording is in progress will cause the recording to be stopped and saved.
//- (void) resumeCaptureSession;
//
//@property(readonly, getter=isRecording) BOOL recording;
//
//@end
//
//@protocol RosyWriterVideoProcessorDelegate <NSObject>
//@required
//- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;	// This method is always called on the main thread.
//- (void)recordingWillStart;
//- (void)recordingDidStart;
//- (void)recordingWillStop;
//- (void)recordingDidStop;
//@end
