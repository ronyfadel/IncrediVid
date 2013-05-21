#import <iostream>
#import <CoreMedia/CoreMedia.h>
#import "AVCaptureSessionManager.h"

#define CAPTURE_FRAMES_PER_SECOND 30

extern CVPixelBufferRef __renderTarget;

@interface AVCaptureSessionManager() {
@private
    RFRenderer* renderer;

    CVOpenGLESTextureCacheRef _videoTextureCache;
    CVOpenGLESTextureRef bgraTexture;
    CMBufferQueueRef previewBufferQueue, savingBufferQueue;
    AVCaptureSession* captureSession;
    AVCaptureConnection *audioConnection;
	AVCaptureConnection *videoConnection;
    dispatch_queue_t videoCaptureQueue;
}

- (void)setupCaptureSession;
- (void)createTextureFromImageBuffer:(CVImageBufferRef)imageBuffer;
@end

@implementation AVCaptureSessionManager
@synthesize videoProcessor;

- (id)initWithRenderer:(RFRenderer*)theRenderer;
{
    if((self = [super init]))
    {
        self->renderer = theRenderer;
        self.videoProcessor = [[[RFVideoProcessor alloc] init] autorelease];
        [self setupCaptureSession];
    }
    return self;
}

- (void)setupCaptureSession
{
    OSStatus bufferQueueCreateError = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
	if (bufferQueueCreateError) {
        NSLog(@"Error at CMBufferQueueCreate %ld", bufferQueueCreateError);
    }
    
    bufferQueueCreateError = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &savingBufferQueue);
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
    captureSession.sessionPreset =  AVCaptureSessionPreset640x480;
    
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
    videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
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
    
    self.videoProcessor.videoConnection = videoConnection;
    self.videoProcessor.audioConnection = audioConnection;
    
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
    [self.videoProcessor stopAndTearDownRecordingSession];
}

/*
 delegate routine for processing samples
 to use sample buffer outside this scope, have
 to CFRetain then CFRelease it
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if ( connection == videoConnection ) { // video
        
        _videoTextureCache ? CVOpenGLESTextureCacheFlush(_videoTextureCache, 0) : NSLog(@"No video texture cache");
        
        CFRetain(sampleBuffer);
        dispatch_async(dispatch_get_main_queue(), ^{
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            [self createTextureFromImageBuffer:imageBuffer];
            self->renderer->render();

            // saving timing info (we wouldn't need the original sample buffer after that
            CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
            CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timingInfo);
            CFRelease(sampleBuffer);
            
            CVReturn err = CVPixelBufferLockBaseAddress(__renderTarget, kCVPixelBufferLock_ReadOnly);
            
            if (!err) {
                if (self.videoProcessor.recording || self.videoProcessor.recordingWillBeStarted) {
                    
                    // getting video info from the rendered frame
                    CMVideoFormatDescriptionRef videoInfo = NULL;
                    CMVideoFormatDescriptionCreateForImageBuffer(NULL, __renderTarget, &videoInfo);
                    
                    // storing the frame in a new buffer
                    CMSampleBufferRef resultBuffer = NULL;
                    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, __renderTarget, YES, NULL, NULL, videoInfo, &timingInfo, &resultBuffer);
                    
                    [self.videoProcessor processFrameWithSampleBuffer:resultBuffer
                                                 andFormatDescription:videoInfo
                                                        andConnection:connection];                    
                }
                
            } else {
                NSLog(@"Error locking __renderTarget: %d", err);
            }
            
            CVPixelBufferUnlockBaseAddress(__renderTarget, kCVPixelBufferLock_ReadOnly);
            
        });
    } else { // audio
        if (connection == audioConnection) {
            CFRetain(sampleBuffer);
            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
            CFRetain(formatDescription);
            [self.videoProcessor processFrameWithSampleBuffer:sampleBuffer
                                    andFormatDescription:formatDescription
                                           andConnection:connection];
        }
    }
}

///*
// delegate routine for processing samples
// to use sample buffer outside this scope, have
// to CFRetain then CFRelease it
// */
//- (void)captureOutput:(AVCaptureOutput *)captureOutput 
//didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
//       fromConnection:(AVCaptureConnection *)connection
//{
//    if ( connection == videoConnection ) {
//        if (!_videoTextureCache)
//        {
//            NSLog(@"No video texture cache");
//            return;
//        } else {
//            CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
//        }
//    
//        OSStatus err = CMBufferQueueEnqueue(previewBufferQueue, sampleBuffer);
//        if ( !err ) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
//                if (sbuf) {
//                    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sbuf);
//                    [self createTextureFromImageBuffer:imageBuffer];
//                    self->renderer->render();
//                    
//                    CVReturn err = CVPixelBufferLockBaseAddress(__renderTarget, kCVPixelBufferLock_ReadOnly);
//                    
//                    if (!err) {
//                        CMVideoFormatDescriptionRef videoInfo = NULL;
//                        CMVideoFormatDescriptionCreateForImageBuffer(NULL, __renderTarget, &videoInfo);
//
//                        CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
//                        CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timingInfo);
//                        
//                        CMSampleBufferRef newSampleBuffer = NULL;
//                        CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, __renderTarget, YES, NULL, NULL, videoInfo, &timingInfo, &newSampleBuffer);
//                        
//                        
//                        CMBufferQueueEnqueue(savingBufferQueue, newSampleBuffer);
//                    } else {
//                        NSLog(@"Error locking __renderTarget: %d", err);
//                    }
//                    
//                    CVPixelBufferUnlockBaseAddress(__renderTarget, kCVPixelBufferLock_ReadOnly);
//                    
//                    if (! (self.videoProcessor.recording || self.videoProcessor.recordingWillBeStarted) ) {
//                        CFRelease((CMSampleBufferRef)CMBufferQueueDequeueAndRetain(savingBufferQueue));
//                    }
//                    
//                    CFRelease(sbuf);
//                }
//            });
//        }
//    }
//    
//    if (self.videoProcessor.recording || self.videoProcessor.recordingWillBeStarted) {
//                
//        if (connection == audioConnection) {
//            CFRetain(sampleBuffer);
//        } else {
//            sampleBuffer = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(savingBufferQueue);
//        }
//        if (sampleBuffer) {
//            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
//            CFRetain(formatDescription);
//
//            [self.videoProcessor processFrameWithSampleBuffer:sampleBuffer
//                                    andFormatDescription:formatDescription
//                                           andConnection:connection];
//        }
//    }
//}

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
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(CVOpenGLESTextureGetTarget(bgraTexture), CVOpenGLESTextureGetName(bgraTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
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
    [self.videoProcessor startRecording];
}

- (void)stopRecording
{
    [self.videoProcessor stopRecording];
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
    [self.videoProcessor stopRecording];
}

- (void)toggleCamera
{    
    NSArray* videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if ([videoDevices count] > 1)		//Only do if device has multiple cameras
	{
        AVCaptureDeviceInput *oldVideoInput = nil;
        AVCaptureDeviceInput *newVideoInput = nil;

        for (AVCaptureDeviceInput* deviceInput in captureSession.inputs) {
            if ([videoDevices containsObject:deviceInput.device]) {
                oldVideoInput = deviceInput;
            }
        }
        
        AVCaptureDevicePosition newPosition = (oldVideoInput.device.position == AVCaptureDevicePositionFront) ? AVCaptureDevicePositionBack
                                                                                                              : AVCaptureDevicePositionFront;
        
        for (AVCaptureDevice* device in videoDevices) {
            if (device.position == newPosition) {
                newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                break;
            }
        }
        
        NSLog(@"old Video Input: %@", oldVideoInput);
        NSLog(@"new Video Input: %@", newVideoInput);

		if (newVideoInput)
		{
            
			[captureSession beginConfiguration];
//            [captureSession setSessionPreset:AVCaptureSessionPresetHigh]; //Always reset preset before testing canAddInput because preset will cause it to return NO

            [captureSession removeInput:oldVideoInput];
			if ([captureSession canAddInput:newVideoInput])
			{
				[captureSession addInput:newVideoInput];
			} else {
                NSLog(@"can't add input");
            }
            
			[captureSession commitConfiguration];
		}
	}
}
//
//// Toggle between the front and back camera, if both are present.
//- (BOOL) toggleCamera
//{
//    BOOL success = NO;
//    
//    if ([self cameraCount] > 1) {
//        NSError *error;
//        AVCaptureDeviceInput *newVideoInput;
//        AVCaptureDevicePosition position = [[videoInput device] position];
//        
//        if (position == AVCaptureDevicePositionBack)
//            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
//        else if (position == AVCaptureDevicePositionFront)
//            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
//        else
//            goto bail;
//        
//        if (newVideoInput != nil) {
//            [[self session] beginConfiguration];
//            [[self session] removeInput:[self videoInput]];
//            if ([[self session] canAddInput:newVideoInput]) {
//                [[self session] addInput:newVideoInput];
//                [self setVideoInput:newVideoInput];
//            } else {
//                [[self session] addInput:[self videoInput]];
//            }
//            [[self session] commitConfiguration];
//            success = YES;
//            [newVideoInput release];
//        } else if (error) {
//            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
//                [[self delegate] captureManager:self didFailWithError:error];
//            }
//        }
//    }
//    
//bail:
//    return success;
//}


- (void)pause
{
    dispatch_async(videoCaptureQueue, ^(){
        [captureSession stopRunning];
    });
}

- (void)resume
{
    dispatch_async(videoCaptureQueue, ^(){
        [captureSession startRunning];
    });
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
