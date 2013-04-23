#import <CoreMedia/CoreMedia.h>
#import "AVCaptureSessionManager.h"

#define CAPTURE_FRAMES_PER_SECOND 30

extern CVPixelBufferRef __renderTarget;

@interface AVCaptureSessionManager() {
@private
    RFRenderer* renderer;
    
    CVOpenGLESTextureCacheRef _videoTextureCache;
    CVOpenGLESTextureRef bgraTexture;
    CMBufferQueueRef previewBufferQueue;
    AVCaptureSession* captureSession;
    RFVideoProcessor* videoProcessor;
    AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
}

- (void)setupCaptureSession;
- (void)createTextureFromImageBuffer:(CVImageBufferRef)imageBuffer;
@end

@implementation AVCaptureSessionManager

- (id)initWithRenderer:(RFRenderer*)theRenderer;
{
    if((self = [super init]))
    {
        self->renderer = theRenderer;
        videoProcessor = [[RFVideoProcessor alloc] init];
        [self setupCaptureSession];
    }
    return self;
}

- (void)setVideoProcessorDelegate:(id<RFVideoProcessorDelegate>)delegate
{
    videoProcessor.delegate = delegate;
}

- (void)setupCaptureSession
{
    OSStatus bufferQueueCreateError = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
	if (bufferQueueCreateError) {
        NSLog(@"Error at CMBufferQueueCreate %ld", bufferQueueCreateError);
    }

    CVReturn textureCacheCreateError = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &_videoTextureCache);
    if (textureCacheCreateError)  {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", textureCacheCreateError);
        return;
    }
    
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession beginConfiguration];
    captureSession.sessionPreset =  AVCaptureSessionPresetMedium; //AVCaptureSessionPresetHigh;
    
    // audio
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    if ([captureSession canAddInput:audioIn])
        [captureSession addInput:audioIn];
	[audioIn release];
    
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
	dispatch_release(audioCaptureQueue);
	if ([captureSession canAddOutput:audioOut])
		[captureSession addOutput:audioOut];
	audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
	[audioOut release];
    
    // video
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
    if ([captureSession canAddInput:videoIn])
        [captureSession addInput:videoIn];
	[videoIn release];
    
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
	dispatch_release(videoCaptureQueue);
//    [videoOut setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	if ([captureSession canAddOutput:videoOut])
		[captureSession addOutput:videoOut];
	videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    if([videoConnection isVideoOrientationSupported])
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    videoConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    videoConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);

	[videoOut release];
    
    videoProcessor.videoConnection = videoConnection;
    videoProcessor.audioConnection = audioConnection;
    
    [captureSession commitConfiguration];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionStoppedRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:captureSession];
    
    [captureSession startRunning];    
}

- (void)stopAndTearDownCaptureSession
{
    [captureSession stopRunning];
	if (captureSession)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	[captureSession release];
	captureSession = nil;
	if (previewBufferQueue) {
		CFRelease(previewBufferQueue);
		previewBufferQueue = NULL;
	}
    [videoProcessor stopAndTearDownRecordingSession];
}

/*
 delegate routine for processing samples
 to use sample buffer outside this scope, have
 to CFRetain then CFRelease it
 Autorelease pool necessary, sampleBuffer is added to
 autorelease pool, if its processing was not fast enough
 pool cleaned up every once in a while
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{
    if ( connection == videoConnection ) {
        if (!_videoTextureCache)
        {
            NSLog(@"No video texture cache");
            return;
        }
        
        OSStatus err = CMBufferQueueEnqueue(previewBufferQueue, sampleBuffer);
        if ( !err ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
                if (sbuf) {
                    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sbuf);
                    [self createTextureFromImageBuffer:imageBuffer];
                    CFRelease(sbuf);
                    NSLog(@"rendering");
                    self->renderer->render();
                }
            });
        }
    }
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CFRetain(formatDescription);
    
    if (connection == audioConnection) {
        CFRetain(sampleBuffer);
    }
    else {
        CMVideoFormatDescriptionRef videoInfo = NULL;
        CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
        CMSampleBufferRef newSampleBuffer;

        CVReturn err = CVPixelBufferLockBaseAddress(__renderTarget, kCVPixelBufferLock_ReadOnly);
        if (!err) {
            OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, __renderTarget, &videoInfo);
            
            CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timingInfo);
            
            CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, __renderTarget, YES, NULL, NULL, videoInfo, &timingInfo, &newSampleBuffer);
            sampleBuffer = newSampleBuffer;
        } else {
            NSLog(@"huge error: %d", err);
        }
        CVPixelBufferUnlockBaseAddress(__renderTarget, kCVPixelBufferLock_ReadOnly);
    }
   
    [videoProcessor processFrameWithSampleBuffer:sampleBuffer
                            andFormatDescription:formatDescription
                            andConnection:connection];
}

// CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture
// optimally from CVImageBufferRef.
- (void)createTextureFromImageBuffer:(CVImageBufferRef)imageBuffer
{
    if (bgraTexture) {
        CFRelease(bgraTexture);
        bgraTexture = NULL;
    }
    
    CVReturn err;
    GLsizei _textureWidth = CVPixelBufferGetWidth(imageBuffer);
    GLsizei _textureHeight = CVPixelBufferGetHeight(imageBuffer);
    
    glActiveTexture(GL_TEXTURE0);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       imageBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       _textureWidth,
                                                       _textureHeight,
                                                       GL_RGBA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &bgraTexture);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(bgraTexture), CVOpenGLESTextureGetName(bgraTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
//    glBindTexture(CVOpenGLESTextureGetTarget(bgraTexture), 0);

    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (AVCaptureDevice *)audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0)
        return [devices objectAtIndex:0];
    
    return nil;
}

- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    
    return nil;
}

- (void)startRecording
{
    [videoProcessor startRecording];
}

- (void)stopRecording
{
    [videoProcessor stopRecording];
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
    [videoProcessor stopRecording];
}

- (void)dealloc
{
    [self stopAndTearDownCaptureSession], [captureSession release];
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
        _videoTextureCache = 0;
    }
    [super dealloc];
}

@end
