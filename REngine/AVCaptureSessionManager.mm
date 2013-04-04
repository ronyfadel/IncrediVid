#import "AVCaptureSessionManager.h"
#import <CoreMedia/CoreMedia.h>


@interface AVCaptureSessionManager(){
@private
    CVOpenGLESTextureCacheRef _videoTextureCache;
    CVOpenGLESTextureRef bgraTexture;
    CMBufferQueueRef previewBufferQueue;
}
- (void)setupSession;
- (void)createTextureFromImageBufferRef:(CVImageBufferRef)imageBuffer;
- (void)cleanUpTextures;
@end

@implementation AVCaptureSessionManager

-(id)initWithRenderer:(RFRenderer*)aRenderer
{
    if((self = [super init]))
    {
        self->renderer = aRenderer;
        [self setupSession];
    }
    return self;
}

- (void)setupSession 
{
    // Create a shallow queue for buffers going to the display for preview.
	OSStatus bufferQueueErr = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
	if (bufferQueueErr)
    {
        NSLog(@"Error at CMBufferQueueCreate %li", bufferQueueErr);
        return;
    }
    
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &_videoTextureCache);
    if (err) 
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return;
    }
    
    // allocating the session
    captureSession = [[AVCaptureSession alloc] init];
    
    // starting configuration
    [captureSession beginConfiguration];
    
#warning check session preset for other devices
// setting the session preset (other option: captureSession.sessionPreset = AVCaptureSessionPresetMedium)
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    // config input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [captureSession addInput:input];
    if (!input) { NSLog(@"bad input %d %s", __LINE__, __FUNCTION__); exit(1); }
    
    // config output
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    output.alwaysDiscardsLateVideoFrames = YES;
    [captureSession addOutput:output];

    // queue to process samples
    // option 1
    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:videoCaptureQueue];
    dispatch_release(videoCaptureQueue);
    // option 2
    //    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    // pixel format (can use kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    output.videoSettings =  [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                        forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // configuring connection
    AVCaptureConnection* connection = (AVCaptureConnection*)[output.connections objectAtIndex:0];

    // setting capture rate at 30 FPS (kCMTimeZero for maximum FPS)
    connection.videoMinFrameDuration = CMTimeMake(1, 30);
    if([connection isVideoOrientationSupported])
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    // committing configuration
    [captureSession commitConfiguration];
    
    // starts session
    [captureSession startRunning];
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
    if (!_videoTextureCache)
    {
        NSLog(@"No video texture cache");
        return;
    }
        
    [self cleanUpTextures];
    
    OSStatus bufferEnqueueError = CMBufferQueueEnqueue(previewBufferQueue, sampleBuffer);
    if ( !bufferEnqueueError ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
            if (sbuf) {
                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sbuf);
                [self createTextureFromImageBufferRef:imageBuffer];
                CFRelease(sbuf);
            }
        });
    }
}

// CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture
// optimally from CVImageBufferRef.
- (void)createTextureFromImageBufferRef:(CVImageBufferRef)imageBuffer
{
    CVReturn err;
    GLsizei _textureWidth = CVPixelBufferGetWidth(imageBuffer),
    _textureHeight = CVPixelBufferGetHeight(imageBuffer);
    
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
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}
    
- (void)cleanUpTextures
{
    if (bgraTexture)
    {
        CFRelease(bgraTexture);
        bgraTexture = NULL;
    }
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

-(void)startRecording
{
}

-(void)stopRecording
{
}

- (void)dealloc
{
    if (previewBufferQueue) {
		CFRelease(previewBufferQueue);
		previewBufferQueue = NULL;
	}
    [captureSession stopRunning], [captureSession release];
    [super dealloc];
}

@end
